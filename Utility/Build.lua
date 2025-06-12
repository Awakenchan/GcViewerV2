return setmetatable({}, {
    __index = function(_, key)
        if key == "__version" then
            return "3.1"
        elseif key == "__log" then
            return {
                "[/] Fixed erlc crashes",
                "[/] Should be ud on all games."
            }
        end
    end
})
