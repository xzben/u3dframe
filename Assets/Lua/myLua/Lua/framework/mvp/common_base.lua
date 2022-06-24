local common_base = class("common_base")


function common_base:ctor()

end

function common_base:dtor()
	self:clear_timer()
end

function common_base:set_service( name, service )
	self.m__cache_service = self.m__cache_service or {} 
	self.m__cache_service[name] = service
end

function common_base:get_service( name )
	self.m__cache_service = self.m__cache_service or {}
	
	local service = self.m__cache_service[name]

	if service == nil then
		service = game.service_manager:get(name)
		self.m__cache_service[name] = service
	end

	return service
end

-------------------------------------定时器-------------------------------------
local function _get_timer_id( self )
    if self.m_timer_id == nil then
        self.m_timer_id = 0
    end

    self.m_timer_id = self.m_timer_id + 1

    return self.m_timer_id
end

function common_base:schedule_once(func, interval, ...)
    return self:schedule(func, interval, 1, ...)
end

function common_base:schedule( func, interval, count, ...)
    assert(func ~= nil, "please pass a valid func")
    local count = count == nil and -1 or count
    local interval = interval == nil and 0 or interval

    if self.m_timers == nil then
        self.m_timers = {}
    end

    local params = { ... }
    local id = _get_timer_id(self)
    local timer = Timer.New(function() 
        return func(unpack(params))
    end, interval, count, nil, function() 
        self.m_timers[id] = nil
    end)
    self.m_timers[id] = timer
    timer:Start()
    return id
end

function common_base:unschedule( id )
    if self.m_timers == nil then return end

    local timer = self.m_timers[id]
    if timer ~= nil then
        self.m_timers[id] = nil
        timer:Stop()
    end
end

function common_base:clear_timer()
    for id, timer in pairs(self.m_timers or {}) do
        timer:Stop()
    end
    self.m_timers = nil
end

return common_base