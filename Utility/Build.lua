return setmetatable({}, {
    __index = function(_, key)
        if key == "__version" then
            return "5.7"
        elseif key == "__log" then
            return {
                "[/] GC> improved Table values/table dumping"
            }
        end
        return nil 
    end
})
