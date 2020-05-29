-- Labels are tweeakable via meta e.g.,
-- crossref:
--   labels:
--     fig: "Fig."
--     tab: "Tab."
--   link: true
--   section: 0

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

function hyperlink(text, href)
    if link then
        return("[" .. text .. "](" .. href .. ")")
    else
        return(text)
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

function solve_ref(element)
    local pattern = patterns["ref"]
    if element.text:match(pattern) then
        local _ = ""
        local type = ""
        local name = ""
        if link then
            element.text = escape_symbol(element.text)
        end
        for matched in element.text:gmatch(pattern) do
            _, type, name = matched:match(pattern)

            label = labels[type]
            
            if index[type][name] then
                ref = index[type][name]
            else
                ref = "??"
            end
            
            element.text = element.text:gsub(
                matched:gsub("([()-])", "%%%1"), -- escaping
                hyperlink(ref, "#" .. type .. "-" .. name)
            )
        end
        if link then
            return(markdown(element.text))
        else
            return(element)
        end
    end
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
    if number_sections then
        section = 0
    end
    link = true
    if element.crossref then
        if not element.crossref.number_sections or (element.crossref.number_sections ~= nil) then
            section = nil
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

header_levels = {0, 0, 0, 0, 0, 0, 0, 0, 0}

number_sections = (not FORMAT:match("html[45]?")) and (FORMAT ~= "epub")

function Header(elem)    
    header_levels[elem.level] = header_levels[elem.level] + 1
    local level = ""
    for i = elem.level,1,-1 do
        level = header_levels[i] .. "." .. level
    end
    index["section"][elem.identifier] = level
    if number_sections and section then
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
  { Pandoc = Pandoc },
  { Str = solve_ref }
}
