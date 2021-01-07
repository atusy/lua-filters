--[[
math - Render math based on pandoc -t html

# MIT License

Copyright (c) 2020 Atsushi Yasumoto

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

https://github.com/atusy/lua-filters/blob/master/lua/math.lua
]]
local cmd = "pandoc"

local pandoc2_9_x = (PANDOC_VERSION[1] == 2) and (PANDOC_VERSION[2] == 9)

local function Meta(elem)
  if elem["pandoc-path"] ~= nil then
    cmd = pandoc.utils.stringify(elem["pandoc-path"])
  end
end

local function Math(elem)
  local is_display = elem.mathtype == "DisplayMath"
  local text = "$" .. elem.text .. "$"

  if is_display then
    text = "$" .. text .. "$"
  end

  local math = pandoc.read(
    pandoc.pipe(cmd, {"-t", "html", "-f", "markdown"}, text), "html"
  ).blocks[1].content

  if (is_display and pandoc2_9_x) then
    -- remove linebreaks at the beggining and the end
    table.remove(math, 1)
    table.remove(math, #math)
  end

  return math
end

return {
  {Meta = Meta},
  {Math = Math}
}
