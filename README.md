# A collection of Lua filters

If you prefer shortened filters, concatenate filters by

```lua
-- filters.lua
require 'fold-code-blocks'
require 'number-sections'

local function concat(tables)
  local result = pandoc.List({})
  for i,j in ipairs(tables) do
    result = result:__concat(pandoc.List(j))
  end
  return(result)
end

return concat({fold_code_blocks, number_sections})
```

and then called by

```sh
pandoc example.md -L filters.lua
```