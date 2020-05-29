-- For the formats not supporting the number-sections option
header_levels = {0, 0, 0, 0, 0, 0, 0, 0, 0}

function Header(elem)
  header_levels[elem.level] = header_levels[elem.level] + 1
  local level = ""
  for i = elem.level,1,-1 do
    level = header_levels[i] .. "." .. level
  end
  level = level .. " "
  content = {pandoc.Str(level)}
  for i = 1,#elem.content do
    content[i + 1] = elem.content[i]
  end
  elem.content = content
  return(elem)
end