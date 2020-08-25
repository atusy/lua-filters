--[[
fold-code-blocks - Let code blocks be foldable

This filter folds all the code blocks by default.
Users may selectively open some of them by adding the `open` class to them.

# MIT License

Copyright (c) 2020 Atsushi Yasumoto

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

local function CodeBlock(elem)
  if elem.classes and elem.classes:find("details") then
    local open = ""
    if elem.classes:find("show") then
      open = " open"
    end
    local summary = "Code"
    if elem.attributes.summary then
      summary = elem.attributes.summary
    end
    return{
      pandoc.RawBlock(
        "html",
        "<details class=code-details" .. open .. ">"
        ..
        "<summary class=code-summary>" .. summary .. "</summary>"
      ),
      elem,
      pandoc.RawBlock("html", "</details>")
    }
  end
end

fold_code_blocks = {
  {CodeBlock = CodeBlock}
}

return fold_code_blocks
