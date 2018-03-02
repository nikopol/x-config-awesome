local tools = {}

function tools.readline(file)
    local f = io.open(file, "r")
    local b = f:read()
    f:close()
    return b
end

function tools.readnum(file)
    return tonumber(tools.readline(file))
end

return tools