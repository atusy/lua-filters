local function CodeBlock(code)
  local _, index = code.classes:find('un-numberLines')
  if index then
    local classes = {}
    for i,j in ipairs(code.classes) do
      if i ~= idex then
        table.insert(classes, j)
      end
    end
    code.classes = classes
    return(code)
  end

  code.classes[#code.classes+1] = 'numberLines'
  return(code)
end

number_lines_code_blocks = {
  { CodeBlock = CodeBlock }
}

return number_lines_code_blocks