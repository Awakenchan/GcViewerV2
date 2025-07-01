return setmetatable({}, {
    __index = function(_, key)
        if key == "__version" then
            return "4.0"
        elseif key == "__log" then
            return {
                "[+] Added Dump all functions Const+Upval",
                "[+] Fixed overview label error",
                "[+] Added Search Filters",
                "[+] Added Search bar",
                "[/] Improved decompile logic slightly"
            }
        end
    end
})