function createAutoRequire( tbl, require, map)
    local reqResult = {}
    setmetatable(tbl, {
        __index = function(_, key)
            if reqResult[key] == nil and type(map[key]) == "string" then
                reqResult[key] = require(map[key])
            end
            if reqResult[key] ~= nil then
                return reqResult[key]
            end

            log.w(string.format("can't get field [%s] from table", tostring(key)))
        end
    })
end

function createLocalAutoRequire(map, require)
    local reqResult = {}
    local env = {}
    local old_env = getfenv(2)
    setmetatable(env, {
        __index = function(_, key)
            if reqResult[key] == nil and type(map[key]) == "string" then
                reqResult[key] = require(map[key])
            end

            if reqResult[key] ~= nil then
                return reqResult[key]
            end

            local gValue = old_env[key]
            if gValue or gValue == false then
                return gValue
            end

            error(string.format("can't get field [%s] from cur env", tostring(key)))
        end;
    })
    setfenv(2, env)
end

local function __G__TRACKBACK__(msg)
    if g_log == nil then
        UnityEngine.Debug.LogError( tostring(msg) .. "\n" .. debug.traceback("", 2))
    else
        g_log.e(msg)
    end
end

function xpcall_func( func, ... )
    local rets = { xpcall(func, __G__TRACKBACK__, ...) }
    local ok = table.remove(rets, 1)
    if ok then
        return unpack(rets)
    end
end

local instances = {}

function create_instance( class )
    local cls = class
    if type(class) == "string" then
         cls = require(class)
    end

    local inst = cls.new()
    instances[inst] = inst
    return inst
end