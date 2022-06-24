local common_base = require("framework.mvp.common_base")
local event_dispatcher = require("framework.event.event_dispatcher")
local service_base = class("service_base", event_dispatcher, common_base)

-- service_base.event_func_map = {
-- 	[neteventname] = "functionname";
--  [neteventname] = { func = "functionname", order = 0 };
-- }

local _register_event = nil
local _clear_event = nil

function service_base:ctor()
	self.m_service_name = ""
	event_dispatcher.ctor(self)
	common_base.ctor(self)
end

function service_base:dtor()
	common_base.dtor(self)
	event_dispatcher.dtor(self)
end

function service_base:set_service_name( name )
	self.m_service_name = name
end

function service_base:init()

end

function service_base:start()
	_register_event(self)
end

function service_base:stop()
	_clear_event(self)
end

function service_base:send_msg( cmd, data, ...)
    net.network:send_msg(cmd, data, ...)
end

local function _get_store_name( self, store_name )
    if self.m_service_name ~= "" then
        return string.format("service/%s/%s", self.m_service_name, store_name)
    end

    return string.format("service/%s", store_name)
end

function service_base:get_store( store_name )
    if self.__store_cache == nil then
        self.__store_cache = {}
    end

    if self.__store_cache[store_name] == nil then
        self.__store_cache[store_name] = util.dict.new(_get_store_name(self, store_name), true)
    end

    return self.__store_cache[store_name]
end

function service_base:get_net_dispatcher()
    return net.network
end

_register_event = function ( self )
	if self.event_func_map and type(self.event_func_map) == "table" then
        for key, value in pairs(self.event_func_map) do
            local order = 0
            local count = -1
            local func_name = value

            if type(value) == "table" and type(value.func) == "string" then
                func_name = value.func
                order = value.order or 0
                count = value.count or -1   
            end

            local func = self[func_name]
            if type(func) == "function" then
                self:get_net_dispatcher():insert(key, self, func, count, order)
            else
                log.e(tostring(self) .. "没有实现接口:" .. value)
            end
        end
    end
end

_clear_event = function ( self )
    self:get_net_dispatcher():removeListener_by_owner(self)
end


return service_base