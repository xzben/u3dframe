--[[
	多个 action 顺序执行的容器
--]]

local action_base = require("framework.utils.action.action_base")
local sequence = class("sequence", action_base)

function sequence:ctor( ... )	
	self.m_actions = { ... }
	self.m_size = #self.m_actions
	self.m_curIndex = 1
	action_base.ctor(self)
end


function sequence:get_cur_action()
	local curAction = self.m_actions[self.m_curIndex]

	return curAction
end

function sequence:start_with_target( target )
	self:get_cur_action():start_with_target(target)
	action_base.start_with_target(self, target)
end

function sequence:step(dt)
	local curAction = self.m_actions[self.m_curIndex]
	curAction:step(dt)
	if curAction:is_done() then
		self.m_curIndex = self.m_curIndex + 1
		if self.m_curIndex > self.m_size then
			self:set_done()
		else
			self:get_cur_action():start_with_target(self:get_target())
		end
	end
end

function sequence:update(dt)

end

function sequence:execute()
	
end

return sequence