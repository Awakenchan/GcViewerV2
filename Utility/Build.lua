return setmetatable({}, {
    __index = function(_, key)
        if key == "__version" then
            return "5.2"
        elseif key == "__log" then
            return {
                "[+] Actor support"
            }
        end
        return nil 
    end
})
