return setmetatable({}, {
    __index = function(_, key)
        if key == "__version" then
            return "3.5"
        elseif key == "__log" then
            return {
                "[+] New config-system",
                "[+] Fixed grab function being broken"
            }
        end
    end
})
