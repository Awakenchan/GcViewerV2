return setmetatable({}, {
    __index = function(_, key)
        if key == "__version" then
            return "3"
        elseif key == "__log" then
            return {
                "[+] Ported table serialization to Data2Code",
                "[+] Fixed github urls not having IDE",
                "[+] Added Name = Target name support when using filtergc",
                "[/] Fixed genscript fromat for env table",
                "[/] Made it 2 gui module (was 3 before not including console)"
            }
        end
    end
})
