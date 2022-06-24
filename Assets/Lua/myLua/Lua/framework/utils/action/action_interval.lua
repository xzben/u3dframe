--
--  随时间变化的动作
--

local action_base = require("framework.utils.action.action_base")
local action_interval = class("action_interval", action_base)

function action_interval:ctor( duration )
	self.m_duration = duration
	self.m_dtCount = 0
	action_base.ctor(self)
end

function action_interval:get_duration()
	return self.m_duration
end

function action_interval:reset()
	self.m_dtCount = 0
	action_base.reset(self)
end

function action_interval:step(dt)
	self.m_dtCount = self.m_dtCount + dt

	local updateDt = math.max(0, math.min(1, self.m_dtCount/self.m_duration))
	self:update(updateDt)

	if self.m_dtCount >= self.m_duration then
		self:set_done()
	end
end

function action_interval:is_interval_action()
	return true
end

return action_interval