return setmetatable({}, {
    __index = function(_, key)
        if key == "__version" then
            return "5.3"
        elseif key == "__log" then
            return {
                "[/] fixed filtering for local script module script etc"
                "[/] fixed coloring"
                "[/] rewrote decompile scripts"
                "[/] rewrote filtering"
            }
        end
        return nil 
    end
})
