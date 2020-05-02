lab = {fig = "Fig. ", tab = "Tab. "}
cnt = {fig = 0, tab = 0}
idx = {}
idx["fig"] = {}
idx["tab"] = {}
sec = 0

function pattern_hash(t)
  return "((.*)%(#" .. t .. ":([%a%d-]+)%)(.*))"
end

function pattern_ref(t)
  return "((.*)@ref%(" .. t .. ":([%a%d-]+)%)(.*))"
end

patterns = {
  hash = pattern_hash,
  ref = pattern_ref
}

function resolve_label_(elem, t, p)
  local pattern = patterns[p](t)
  local ref = elem.text:match(pattern)
  if ref then
    local key = ref:gsub(pattern, "%3")
    local id = t .. "-" .. key
    if not idx[t][key] then
      cnt[t] = cnt[t] + 1
      idx[t][key] = sec .. "." .. cnt[t]
    end
    
    if p == "hash" then
      res = pandoc.Span(
        pandoc.Str(ref:gsub(pattern, "%2" .. lab[t] .. idx[t][key] .. "%4"))
      )
      res.identifier = id
      return res
    else
      return {
        pandoc.Str(ref:gsub(pattern, "%2")),
        pandoc.Link(idx[t][key] .. "", "#" .. id),
        pandoc.Str(ref:gsub(pattern, "%4"))
      }
    end
  end
end

function resolve_label(elem, t)
  local res = resolve_label_(elem, t, "hash")
  if res then
    return res
  end

  return resolve_label_(elem, t, "ref")
end

function increment_sec_and_reset_cnt(elem)
  if (elem.t == "Header") and (elem.level == 1) then
    sec = sec + 1
    for key, value in pairs(cnt) do
      cnt[key] = 0
    end
  end
end

function str(elem)
  local res = nil
  for key, value in pairs(idx) do
    res = resolve_label(elem, key)
    if res then
      return (res)
    end
  end
end

function Pandoc(doc)
  local hblocks = {}
  for i,el in pairs(doc.blocks) do
    increment_sec_and_reset_cnt(el)
    table.insert(hblocks, pandoc.walk_block(el, {Str = str}))
  end
  return pandoc.Pandoc(hblocks, doc.meta)
end

