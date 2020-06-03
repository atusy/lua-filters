reference_text_table = {}
reference_text_pattern = "^%(ref:([%a%d-]+)%)$"

function curate_refs(para)
  local first_element = para.content[1]
  local second_element = para.content[2]
  if (first_element.tag == "Str") and second_element and (second_element.tag == "Space") then
    local matched = first_element.text:match(reference_text_pattern)
    local n = #para.content
    local reference_text = {}
    if matched and (n > 2) then
      if reference_text_table[matched] then
        error("Duplicated text reference labels: " .. matched)
      end
      for i=3,n do
        reference_text[i - 2] = para.content[i]
      end
      reference_text_table[matched] = reference_text
      return {}
    end
  end
end

function solve_refs(str)
  local matched = str.text:match(reference_text_pattern)
  if matched then
    return(reference_text_table[matched])
  end
end

return {
    {Para = curate_refs},
    {Str = solve_refs}
}