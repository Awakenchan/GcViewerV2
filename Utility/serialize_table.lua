type = typeof or type

local str_types = {
    ['boolean'] = true,
    ['userdata'] = true,
    ['table'] = true,
    ['function'] = true,
    ['number'] = true,
    ['nil'] = true
}

local function count_table(t)
    local c = 0
    for _, _ in t do
        c += 1
    end
    return c
end

local function string_ret(o, typ)
    local ret, mt, old_func
    if not (typ == 'table' or typ == 'userdata') then
        return tostring(o)
    end
    mt = (getrawmetatable or getmetatable)(o)
    if not mt then 
        return tostring(o)
    end

    old_func = rawget(mt, '__tostring')
    rawset(mt, '__tostring', nil)
    ret = tostring(o)
    rawset(mt, '__tostring', old_func)
    return ret
end

local function format_value(v)
    local typ = type(v)
    if str_types[typ] then
        return string_ret(v, typ)
    elseif typ == 'string' then
        return '"'..v..'"'
    elseif typ == 'Instance' then
        return v.GetFullName(v)
    else
        return typ..'.new(' .. tostring(v) .. ')'
    end
end

local function is_nan_inf(n)
    return type(n) == 'number' and (n ~= n or n == math.huge or n == -math.huge)
end

local function serialize_table(t, p, c, s)
    local str = ""
    local n = count_table(t)
    local ti = 1
    local e = n > 0

    c = c or {}
    p = p or 1
    s = s or string.rep

    local function format_value(v)
        if is_nan_inf(v) then
            return 'nil'
        end
        local typ = typeof(v)
        if typ == "function" then
            local info = debug.getinfo(v)
            return string.format('"function [%s @ %s]"', info.name or "?", info.short_src or "?")
        elseif typ == "string" then
            return string.format("%q", v) -- properly quoted string
        elseif typ == "number" or typ == "boolean" then
            return tostring(v) -- keep numbers and booleans unquoted
        else
            return string.format('"%s"', tostring(v)) -- quote other types (like userdata, threads, etc.)
        end
    end

    local function localized_format(v, is_table)
        if is_nan_inf(v) then
            return 'nil'
        end
        return (is_table and (c[v][2] >= p)) and serialize_table(v, p + 1, c, s) or format_value(v)
    end

    c[t] = {t, 0}

    for i, v in next, t do
        local typ_i, typ_v = type(i) == 'table', type(v) == 'table'
        c[i], c[v] = (not c[i] and typ_i) and {i, p} or c[i], (not c[v] and typ_v) and {v, p} or c[v]
        str = str .. s('  ', p) .. '[' .. localized_format(i, typ_i) .. '] = '  .. localized_format(v, typ_v) .. (ti < n and ',' or '') .. '\n'
        ti = ti + 1
    end

    return ('{' .. (e and '\n' or '')) .. str .. (e and s('  ', p - 1) or '') .. '}'
end

return serialize_table
