-- not supporting section divs

local function Pandoc(document)
    document.blocks = pandoc.utils.make_sections(true, 1, document.blocks)
    return document
end

local function Div(div)
    if div.classes and div.classes:find("section") and div.classes:find("details") then 
        table.insert(div.content, 1, pandoc.RawBlock("html", "<details><summary>"))
        table.insert(div.content, 3, pandoc.RawBlock("html", "</summary>"))
        table.insert(div.content, #div.content + 1, pandoc.RawBlock("html", "</details>"))
    end
    return div.content
end

fold_sections = {
    {Pandoc = Pandoc},
    {Div = Div}
}

return fold_sections