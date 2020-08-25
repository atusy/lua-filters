--[[
crossref - Cross referencing in the manner of 'bookdown'

---
crossref:
  labels:
    fig: "Fig. "
    tab: "Tab. "
    eq: "Eqn. "
  link: true
  number_sections: false # TODO: NOT WORKING!!
---

In case `number_sections: true`, and using HTML/EPUB,
`--number-sections` (or the `-N`) option should also be enabled.

# MIT License

Copyright (c) 2020 Atsushi Yasumoto

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

-- latex, pdf, and context supports crossref by themselves
if (FORMAT == "latex") or (FORMAT == "pdf") or (FORMAT == "context") then
    return(nil)
end

local labels = {fig = "Fig. ", tab = "Tab. ", eq = "Eq. "}
local header_levels = {0, 0, 0, 0, 0, 0, 0, 0, 0}
local n_header_levels = 9
local previous_header_level = 0
local number_sections = nil
local section = nil
local link = nil

-- Initialize counts and index
local count = {}
local index = {}

local patterns = {
    ref = "(@ref%(([%a%d-]+):([%a%d-]+)%))",
    ref_escaped = "(\\@ref\\%(([%a%d-]+):([%a%d-]+)\\%))",
    ref_section = "(@ref%(([%a%d-]+)%))",
    ref_section_escaped = "(\\@ref\\%(([%a%d-]+)\\%))",
    hash = "(%(#([%a%d-]+):([%a%d-]+)%))",
    hash_escaped = "(\\%(\\#([%a%d-]+):([%a%d-]+)\\%))"
}

local function escape_symbol(text)
    return(text:gsub("([\\`*_{}%[%]%(%)>#+-.!])", "\\%1"))
end

local function markdown(text)
    return(pandoc.read(text, "markdown").blocks[1].content)
end

local function name_span(text, name)
    if link then
        return("[" .. text .. "]{#" .. name .. "}")
    else
        return(text)
    end
end

local function hyperlink(string, href)
    if link then
        return("[" .. string .. "](" .. href .. ")")
    else
        return(string)
    end
end

local function solve_hash(element)
    local pattern = patterns["hash"]

    if element.text:match(pattern) then
        local _ = ""
        local type = ""
        local key = ""
        local name = ""
        local label = ""
        if link then
            element.text = escape_symbol(element.text)
            pattern = patterns["hash_escaped"]
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

local function solve_ref_general(str)
    local pattern = patterns["ref"]
    if str.text:match(pattern) then
        local _ = ""
        local type = ""
        local name = ""
        local ref = ""
        if link then
            str.text = escape_symbol(str.text)
            pattern = patterns["ref_escaped"]
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

local function solve_ref_section(str)
    local pattern = patterns["ref_section"]
    if str.text:match(pattern) then
        if link then
            str.text = escape_symbol(str.text)
            pattern = patterns["ref_section_escaped"]
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
    return(str)
end

local function solve_ref(str)
    local res = solve_ref_general(str)
    if (res.t == "Str") then
        return(solve_ref_section(res))
    end
    
    res = pandoc.walk_block(res, {Str = solve_hash})
    return(res.content)
end

local function increment_section_and_reset_count(element)
    if section and (element.t == "Header") and (element.level == 1) and not element.classes:find("unnumbered") then
        section = section + 1
        for key, value in pairs(count) do
            count[key] = 0
        end
    end
end

local function Meta(element)
    if element.crossref then
        number_sections = element.crossref.number_sections and (not FORMAT:match("html[45]?")) and (FORMAT ~= "epub")
        if element.crossref.number_sections then
            section = 0
        end
            
        if element.crossref.labels then
            for key, val in pairs(element.crossref.labels) do
                labels[key] = pandoc.utils.stringify(val)
            end
        end
        link = element.crossref.link
    else
        link = true
    end

    for k, v in pairs(labels) do
        count[k] = 0
        index[k] = {}
    end
    index["section"] = {}

    return(element)
end

local function Pandoc(document)
    local hblocks = {}
    for i,el in pairs(document.blocks) do
        increment_section_and_reset_count(el)
        table.insert(hblocks, pandoc.walk_block(el, {Str = solve_hash}))
    end
    return(pandoc.Pandoc(hblocks, document.meta))
end

local function Header(elem)
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

crossref = {
    { Meta = Meta },
    { Header = Header },
    { Pandoc = Pandoc },
    { Str = solve_ref }
}

return crossref
