return setmetatable({}, {
    __index = function(_, key)
        if key == "__version" then
            return "3.2"
        elseif key == "__log" then
            return {
                "[+] Added error handler",
                "[/] fixing few labels"
            }
        end
    end
})
