--[[
	多个 action 同步执行的容器
--]]
local action_base = require("framework.utils.action.action_base")
local spawn = class("spawn", action_base)

function spawn:ctor( ... )	
	self.m_actions = { ... }
	action_base.ctor(self)
end

function spawn:start_with_target( target )
	for _, action in ipairs(self.m_actions) do
		action:start_with_target(target)
	end
	action_base.start_with_target(self, target)
end

function spawn:step(dt)
	local is_all_done = true
	for _, action in ipairs(self.m_actions) do
		if not action:is_done() then
			action:step(dt)
			is_all_done = false
		end
	end

	if is_all_done then
		self:set_done()
	end
end

function spawn:update(dt)

end

function spawn:execute()
	
end

return spawn