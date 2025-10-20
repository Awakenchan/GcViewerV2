return setmetatable({}, {
    __index = function(_, key)
        if key == "__version" then
            return "5.4.1"
        elseif key == "__log" then
            return {
                    "[/] Detection patching",
                    "[/] MetaMethod invoking patched",
            }
        end
        return nil 
    end
})
