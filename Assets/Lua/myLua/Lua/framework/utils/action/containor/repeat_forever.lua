--[[
	 一定 action 按顺序一直循环执行的容器
--]]

local action_base = require("framework.utils.action.action_base")
local repeat_forever = class("repeat_forever", action_base)

function repeat_forever:ctor( ... )	
	self.m_actions = { ... }
	self.m_size = #self.m_actions
	self.m_curIndex = 1
	action_base.ctor(self)
end

function repeat_forever:get_cur_action()
	local curAction = self.m_actions[self.m_curIndex]

	return curAction
end

function repeat_forever:start_with_target( target )
	self:get_cur_action():start_with_target(target)
	action_base.start_with_target(self, target)
end

function repeat_forever:step(dt)
	local curAction = self:get_cur_action()
	curAction:step(dt)

	if curAction:is_done() then
		curAction:reset()
		self.m_curIndex = self.m_curIndex + 1
		if self.m_curIndex > self.m_size then
			self.m_curIndex = 1
		end

		self:get_cur_action():start_with_target(self:get_target())
	end
end

function repeat_forever:update(dt)

end

function repeat_forever:execute()
	
end

return repeat_forever