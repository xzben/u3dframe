--[[
	一个action 重复指定次数的容器
--]]

local action_base = require("framework.utils.action.action_base")
local repeated = class("repeated", action_base)

function repeated:ctor( action, times )	
	self.m_action = action
	self.m_times = times
	self.m_useTimes = 0
	action_base.ctor(self)
end

function repeated:reset()
	self.m_useTimes = 0
	action_base.reset(self)
end

function repeated:start_with_target(target)
	self.m_action:start_with_target(target)
	action_base.start_with_target(self, target)
end

function repeated:step(dt)
	self.m_action:step(dt)

	if self.m_action:is_done() then
		self.m_action:reset()
		self.m_useTimes = self.m_useTimes + 1
	end

	if self.m_useTimes >= self.m_times then
		self:set_done()
	end
end

function repeated:update(dt)

end

function repeated:execute()
	
end

return repeated