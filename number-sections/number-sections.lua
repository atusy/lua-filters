-- For the formats not supporting the number-sections option
lvls = {0, 0, 0, 0, 0, 0, 0, 0, 0}

function Header(elem)
  lvls[elem.level] = lvls[elem.level] + 1
  local lvl = ""
  for i = elem.level,1,-1 do
    lvl = lvls[i] .. "." .. lvl
  end
  lvl = lvl .. " "
  content = {pandoc.Str(lvl)}
  for i = 1,#elem.content do
    content[i + 1] = elem.content[i]
  end
  elem.content = content
  return(elem)
end