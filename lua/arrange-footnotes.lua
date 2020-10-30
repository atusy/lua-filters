--[[
arrange-footnotes - Better formatting for footnote keys

Footnote keys separated by spaces will be collapsed by superscript comma.
For example, turns out to be `text[^foo] [^bar]` becomes `text[^foo]^, ^[^bar]`.
The separator can be changed via the "sep-footnotes" metadata.

# MIT License

Copyright (c) 2020 Atsushi Yasumoto

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

https://github.com/atusy/lua-filters/blob/master/lua/arrange-footnotes.lua
]]
function Meta(meta)
  sep = pandoc.Superscript(
    meta['sep-footnotes'] or {pandoc.Str(','), pandoc.Space()}
  )
end

function Inlines(inlines)
  for i=1,#inlines do
    inlines[i+1] = (
        inlines[i+2]
      ) and (
        inlines[i].t == 'Note'
      ) and (
        inlines[i+1].t == 'Space'
      ) and (
        inlines[i+2].t == 'Note'
      ) and (
        sep
      ) or (
        inlines[i+1]
      )
  end

  return inlines
end

return {{Meta = Meta}, {Inlines = Inlines}}
