--[[
Number sections for formats without --number-sections
A meta data option is `number_sections_with_attributes`,
which is by default `true` except for markdown FORMAT.

---
number_sections_with_attributes: false
---
]]
local full_attributes = FORMAT ~= "markdown"
local section_number_table = {0, 0, 0, 0, 0, 0, 0, 0, 0}
local previous_header_level = 0

local function Meta(meta)
  if meta.number_sections_with_attributes then
    full_attributes = meta.number_sections_with_attributes
  end
end

local function Header(elem)
  -- If unnumbered
  if (elem.classes:find("unnumbered")) then
    if full_attributes then
      elem.attributes["data-number"] = ""
    end
    return(elem)
  end

  -- Else
  --- Reset and update section_number_table
  if (elem.level < previous_header_level) then
    for i=elem.level+1,n_section_number_table do
      section_number_table[i] = 0
    end
  end
  section_number_table[elem.level] = section_number_table[elem.level] + 1

  --- Define section number as string
  local section_number_string = tostring(section_number_table[elem.level])
  if elem.level > 1 then
    for i = elem.level-1,1,-1 do
      section_number_string = section_number_table[i] .. "." .. section_number_string
    end
  end

  --- Update Header element
  table.insert(elem.content, 1, pandoc.Space())
  if full_attributes then
    table.insert(elem.content, 1, pandoc.Span(section_number_string))
    elem.content[1].classes = {"header-section-number"}
    elem.attributes["data-number"] = section_number_string
  else
    table.insert(elem.content, 1, pandoc.Str(section_number_string))
  end
  return(elem)
end

number_sections = {
  {Meta = Meta},
  {Header = Header}
}

return(number_sections)