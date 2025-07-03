return setmetatable({}, {
    __index = function(_, key)
        if key == "__version" then
            return "4.3"
        elseif key == "__log" then
            return {
                "[+] Added Hide old function labels",
                "[/] Fixed decompile crashes",
                "[/] Fixed frequent crashes with decompile"
            }
        end
        return nil 
    end
})