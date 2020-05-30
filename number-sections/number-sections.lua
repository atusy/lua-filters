-- For the formats not supporting the number-sections option
section_number_table = {0, 0, 0, 0, 0, 0, 0, 0, 0}
previous_header_level = 0
full_attributes = true

function Header(elem)
  if (elem.classes:find("unnumbered")) then
    return(elem)
  end
  if (elem.level < previous_header_level) then
    for i=elem.level+1,n_section_number_table do
      section_number_table[i] = 0
    end
  end
  section_number_table[elem.level] = section_number_table[elem.level] + 1
  local section_number_string = tostring(section_number_table[elem.level])
  if elem.level > 1 then
    for i = elem.level-1,1,-1 do
      section_number_string = section_number_table[i] .. "." .. section_number_string
    end
  end
  local section_number_pandoc = pandoc.Span(section_number_string)
  if full_attributes then
    section_number_pandoc.classes = {"header-section-number"}
    elem.attributes["data-number"] = section_number_string
  end
  local content = {section_number_pandoc, pandoc.Space()}
  for i = 1,#elem.content do
    content[i + 2] = elem.content[i]
  end
  elem.content = content
  return(elem)
end