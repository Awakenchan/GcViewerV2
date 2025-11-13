return setmetatable({}, {
    __index = function(_, key)
        if key == "__version" then
            return "5.5"
        elseif key == "__log" then
            return {
                "[+] AssetDownloader and checker",
                "[/] Name abuse fixes",
                "[/] Gui detection mitigation",
                "[+] Added safeScriptInfo function",
                "[/] Various optimizations and bug fixes"
            }
        end
        return nil 
    end
})
