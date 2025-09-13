return setmetatable({}, {
    __index = function(_, key)
        if key == "__version" then
            return "5.1"
        elseif key == "__log" then
            return {
                "[/] Fixed frequent crashes with decompile",
                "[/] Improving it, maybe it will decompile more and more now"
            }
        end
        return nil 
    end
})
