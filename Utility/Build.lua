return setmetatable({}, {
    __index = function(_, key)
        if key == "__version" then
            return "5.6"
        elseif key == "__log" then
            return {
                "[+] Table values/table dumping"
            }
        end
        return nil 
    end
})
