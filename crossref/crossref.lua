--[[
Default setting is as follows

---
crossref:
  labels:
    fig: "Fig. "
    tab: "Tab. "
    eqn: "Eqn. "
  link: true
  number_sections: false # TODO: NOT WORKING!!
---

In case `number_sections: true`, and using HTML/EPUB,
`--number-sections` (or the `-N`) option should also be enabled.
]]

-- latex, pdf, and context supports crossref by themselves
if (FORMAT == "latex") or (FORMAT == "pdf") or (FORMAT == "context") then
    return(nil)
end

labels = {fig = "Fig. ", tab = "Tab. ", eqn = "Eqn. "}

-- Initialize counts and index
count = {}
index = {}

patterns = {
    ref = "(@ref%(([%a%d-]+):([%a%d-]+)%))",
    ref_section = "(@ref%(([%a%d-]+)%))",
    hash = "(%(#([%a%d-]+):([%a%d-]+)%))"
}

function escape_symbol(text)
    return(text:gsub("([\\`*_{}[]()>#+-.!])", "\\%1"))
end

function markdown(text)
    return(pandoc.read(text, "markdown").blocks[1].content)
end

function name_span(text, name)
    if link then
        return("[" .. text .. "]{#" .. name .. "}")
    else
        return(text)
    end
end

function hyperlink(string, href)
    if link then
        return("[" .. string .. "](" .. href .. ")")
    else
        return(string)
    end
end

function solve_hash(element)
    local pattern = patterns["hash"]

    if element.text:match(pattern) then
        local _ = ""
        local type = ""
        local key = ""
        local name = ""
        local label = ""
        if link then
            element.text = escape_symbol(element.text)
        end
        for matched in element.text:gmatch(pattern) do
            _, type, name = matched:match(pattern)

            label = labels[type]
            
            if index[type][name] == nil then
                count[type] = count[type] + 1
                if section then
                    index[type][name] = section .. "." .. count[type]
                else
                    index[type][name] = "" .. count[type]
                end
            end
            
            element.text = element.text:gsub(
                matched:gsub("([()-])", "%%%1"), -- escaping
                name_span(label .. index[type][name], type .. "-" .. name)
            )
        end
        if link then
            return(markdown(element.text))
        else
            return(element)
        end
    end
end

function solve_ref_general(str)
    local pattern = patterns["ref"]
    if str.text:match(pattern) then
        local _ = ""
        local type = ""
        local name = ""
        local ref = ""
        if link then
            str.text = escape_symbol(str.text)
        end
        for matched in str.text:gmatch(pattern) do
            _, type, name = matched:match(pattern)

            if index[type][name] then
                ref = index[type][name]
            else
                ref = "??"
            end
            
            str.text = str.text:gsub(
                matched:gsub("([()-])", "%%%1"), -- escaping
                hyperlink(ref, "#" .. type .. "-" .. name)
            )
        end
        if link then
            return(pandoc.read(str.text).blocks[1])
        else
            return(str)
        end
    end
    return(str)
end

function f(x)
    print(x.t)
    print(pandoc.utils.stringify(x))
    print("---")
end

function solve_ref_section(str)
    local pattern = patterns["ref_section"]
    if str.text:match(pattern) then
        if link then
            str.text = escape_symbol(str.text)
        end
        local _ = ""
        local type = "section"
        local name = ""
        local ref = ""
        for matched in str.text:gmatch(pattern) do
            _, name = matched:match(pattern)
            if index[type][name] then
                ref = index[type][name]
            else
                ref = "??"
            end
            
            str.text = str.text:gsub(
                matched:gsub("([()-])", "%%%1"), -- escaping
                hyperlink(ref, "#" .. name)
            )
        end
        if link then
            return(markdown(str.text))
        else
            return(str)
        end
    end
end

function solve_ref(str)
    local res = solve_ref_general(str)
    if (res.t == "Str") then
        return(solve_ref_section(res))
    end
    
    res = pandoc.walk_block(res, {Str = solve_hash})
    return(res.content)
end

function increment_section_and_reset_count(element)
    if section and (element.t == "Header") and (element.level == 1) and not element.classes:find("unnumbered") then
        section = section + 1
        for key, value in pairs(count) do
            count[key] = 0
        end
    end
end

function Meta(element)
    header_levels = {0, 0, 0, 0, 0, 0, 0, 0, 0}
    n_header_levels = 9
    previous_header_level = 0
    if element.crossref then
        number_sections = element.crossref.number_sections and (not FORMAT:match("html[45]?")) and (FORMAT ~= "epub")
        if number_sections then
            section = 0
        end
            
        if element.crossref.labels then
            for key, val in pairs(element.crossref.labels) do
                labels[key] = pandoc.utils.stringify(val)
            end
        end
        if element.crossref.link then
            link = element.crossref.link
        end
    end

    for k, v in pairs(labels) do
        count[k] = 0
        index[k] = {}
    end
    index["section"] = {}

    return(element)
end

function Pandoc(document)
    local hblocks = {}
    for i,el in pairs(document.blocks) do
        increment_section_and_reset_count(el)
        table.insert(hblocks, pandoc.walk_block(el, {Str = solve_hash}))
    end
    return(pandoc.Pandoc(hblocks, document.meta))
end

function Header(elem)
    if (elem.level < previous_header_level) then
        for i=elem.level+1,n_header_levels do
            header_levels[i] = 0
        end
    end
    previous_header_level = elem.level
    header_levels[elem.level] = header_levels[elem.level] + 1
    local level = ""
    for i = elem.level,1,-1 do
        level = header_levels[i] .. "." .. level
    end
    index["section"][elem.identifier] = level:gsub("%.$", "")
    if number_sections then
        level = level .. " "
        content = {pandoc.Str(level)}
        for i = 1,#elem.content do
            content[i + 1] = elem.content[i]
        end
        elem.content = content
        return(elem)
    end
end

return {
  { Meta = Meta },
  { Header = Header },
  { Pandoc = Pandoc },
  { Str = solve_ref }
}
