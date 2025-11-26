local FindFunc = {}
function FindFunc:CheckConstants(func, totalConstants, expected)
    assert(typeof(func) == "function", "First argument must be a function")
    assert(typeof(totalConstants) == "number", "Second argument must be a number")
    assert(typeof(expected) == "table", "Third argument must be a table")

    local constants = debug.getconstants(func)
    if not constants then
        return false
    end

    if #constants ~= totalConstants then
        return false
    end

    for index, expectedValue in next, expected do
        local actualValue = constants[index]

        if type(expectedValue) == "string" and expectedValue:match("^typeof:") then
            local expectedType = expectedValue:sub(8)
            if typeof(actualValue) ~= expectedType then
                return false
            end
        else
            if actualValue ~= expectedValue then
                return false
            end
        end
    end

    return true
end
function FindFunc:CheckUpvalues(func, totalUpvalues, expected)
    assert(typeof(func) == "function", "First argument must be a function")
    assert(typeof(totalUpvalues) == "number", "Second argument must be a number")
    assert(typeof(expected) == "table", "Third argument must be a table")

    local count = debug.getupvalues(func)
    if not count then
        return false
    end

    if #count ~= totalUpvalues then
        return false
    end

    for index, expectedValue in next, expected do
        local actualValue = count[index]

        if type(expectedValue) == "string" and expectedValue:match("^typeof:") then
            local expectedType = expectedValue:sub(8)
            if typeof(actualValue) ~= expectedType then
                return false
            end
        else
            if actualValue ~= expectedValue then
                return false
            end
        end
    end

    return true
end
function FindFunc.GcLookUp(val, callback)
    local gcList = getgc(val and true or nil)
    for i, v in next, gcList do
        if callback then
            callback(i, v)
        else
            warn("Found GC value:", v)
        end
    end
end

function FindFunc.getscriptfromthread(script)
    if not getscriptfromthread then
        return "Executor doesnt not support getscriptfromthread"
    end
    for i,v in next, getreg() do 
	    if typeof(v) == "thread" and getscriptfromthread(v) == script then
	      return getscriptfromthread(v)
	    end
    end
end
function FindFunc.getscriptfromfunction(f)
    if not getscriptfromfunction then
         return "Executor doesnt not support getscriptfromfunction"
    end
    return getscriptfromfunction(f)
end

return FindFunc      
