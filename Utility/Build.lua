return setmetatable({}, {
    __index = function(_, key)
        if key == "__version" then
            return "4.2"
        elseif key == "__log" then
            return {
                "[+] Added Filtering functions via Max constants/upvalue.",
                "[+] Added Multi Auto-Load-Config support.",
                "[+] Added CodeEditor for function constants and upvalues to prevent lag.",
                "[+] Added More do detectfunc > now show more label pops to prevent mass loading.",
                "[/] Fixed call back errors on grab func.",
                "[/] Improved decompile file again.",
                "[/] Error handler on other stuff."
            }
        end
    end
})