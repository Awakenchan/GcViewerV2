return setmetatable({}, {
    __index = function(_, key)
        if key == "__version" then
            return "5.3"
        elseif key == "__log" then
            return {
                    "[/] Detection patching"
            }
        end
        return nil 
    end
})
