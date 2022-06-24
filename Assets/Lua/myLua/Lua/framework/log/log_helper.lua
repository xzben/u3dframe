local log_helper = {}

local tab_tag = ""
local s_max_nest = 5;

local function _load_table(t, nest)
    if type(t) ~= "table" then 
        return t;
    end
    if nest > s_max_nest then
        return "MAX NESTING \n";
    end
    local tab = tab_tag;
    tab_tag = tab_tag .. "    ";
    local strArr = {};
    table.insert(strArr, "");
    for k,v in pairs(t) do 
        if v ~= nil and k~="___message" and k ~= "_listener_for_children" then 
            local key = tab_tag;
            if type(k) == "string" then
                key =  string.format("%s[\"%s\"] = ", key, tostring(k) );
            else 
                key =  string.format("%s[%s] = ", key, tostring(k) );
            end 
            
            table.insert(strArr, key);
            if type(v) == "table" then 
                local metatable = getmetatable(v)
                if metatable and metatable.__tostring then
                    table.insert(strArr, string.format("{%s}", tostring(v)));
                else
                    table.insert(strArr, _load_table(v, nest+1) );
                end
            elseif type(v) == "string" then 
                table.insert(strArr, string.format("\"%s\";\n",tostring(v)));
            else 
                table.insert(strArr, string.format("%s;\n",tostring(v)));
            end 
        end 
    end 
    tab_tag = tab;
    local str = string.format("\n%s{\n%s%s};\n", tab_tag, table.concat(strArr), tab_tag);
    return str;
end

--@brief 转换为字符串
local function _get_data(...)  
    local strArr = {};
    table.insert(strArr, "");
    local arg = {...}
    local count = #arg

    -- 因 lua table 数组机制问题,如果中间有 nil 的话,获取的长度可能不准确,这里优化一下
    for k, v in pairs(arg) do
        if count < k  then
            count = k
        end
    end

    for i = 1, count, 1 do
        local v = arg[i]
        local tempType = type(v); 
        if tempType == "table" then
            local metatable = getmetatable(v)
            if metatable and metatable.__tostring then
                table.insert(strArr, string.format("{\n%s\n}", tostring(v)));
            else
                table.insert(strArr, _load_table(v, 1) );
            end
        else
            table.insert(strArr, tostring(v));
        end
        if i == 1 then
            table.insert(strArr, " : ");
        elseif i ~= 1 and i < count then
            table.insert(strArr, "\n");
        end
    end

    return string.format("%s", table.concat(strArr));
end

function log_helper.print(...)
	local logInfo = _get_data(...)

	local info = debug.getinfo( 4, "nSl") 
  
    if nil ~= info then
        logInfo = string.format(" [%s:%d] ", info.source, info.currentline) .. logInfo
    end
    return logInfo
end

return log_helper