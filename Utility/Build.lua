return setmetatable({}, {
    __index = function(_, key)
        if key == "__version" then
            return "3.6"
        elseif key == "__log" then
            return {
                "[+] Added Dump all functions Const+Upval",
                "[+] Fixed overview label error"
            }
        end
    end
})
