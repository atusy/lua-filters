--[[
bookdown-reference-text - Reference text feature inspired by 'bookdown'

cf. https://github.com/rstudio/bookdown/

# MIT License

Copyright (c) 2020 Atsushi Yasumoto

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

local reference_text_table = {}
local patterns = {
  completing = "^%(ref:([%a%d-]+)%)$",
  containing = "(%(ref:[%a%d-]+%))",
  containing_escaped = "\\%(ref:([%a%d-]+)\\%)"
}

local function escape_symbol(text)
  return(text:gsub("([\\`*_{}%[%]%(%)>#+-.!])", "\\%1"))
end

local function curate_refs(para)
  local e1 = para.content[1]
  local e2 = para.content[2]
  if (e1.tag == "Str") and e2 and (e2.tag == "Space") then
    local matched = e1.text:match(patterns["completing"])
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

local function split_refs(str)
  local text = str.text:gsub(patterns["containing"], " %1 ")
  text_table = {}
  for t in text:gmatch("([^%s]+)") do
    table.insert(text_table, pandoc.Str(t))
  end
  return text_table
end

local function solve_refs(str)
  local matched = str.text:match(patterns["completing"])
  if matched then
    return reference_text_table[matched]
  end
end

reference_text = {
  {Para = curate_refs},
  {Str = split_refs},
  {Str = solve_refs}
}

return reference_text
