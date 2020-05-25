-- if sec is nil, then reference numbers increments throughout the document
section = 0
--sec = nil
labels = {fig = "Fig. ", tab = "Tab. "}

-- Initialize counts and index
count = {}
index = {}

for k, v in pairs(labels) do
    count[k] = 0
    index[k] = {}
end

patterns = {
    ref = "(@ref%(([%a%d-]+):([%a%d-]+)%))",
    hash = "(%(#([%a%d-]+):([%a%d-]+)%))"
}

function solve_reference(element, pattern_key)
    local pattern = patterns[pattern_key]
    local type = ""
    local key = ""
    local name = ""
    local label = ""

    for matched in element.text:gmatch(pattern) do
        print(matched)
        type = matched:gsub(pattern, "%2")
        name = matched:gsub(pattern, "%3")

        if (pattern_key == "ref") then
            label = labels[type]
        else
            label = ""
        end
    
        if index[type][name] == nil then
            count[type] = count[type] + 1
            index[type][name] = count[type]
        end
        element.text = element.text:gsub(matched:gsub("([()-])", "%%%1"), label .. index[type][name])
    end
    
    return(element)
end


function Str(element)
    element = solve_reference(element, "ref")
    element = solve_reference(element, "hash")
    return(element)
end
