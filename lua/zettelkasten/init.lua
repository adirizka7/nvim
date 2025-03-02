require('zettelkasten.zettelkasten')

function titleize(str)
    return str:gsub("(%S)(%S*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end
