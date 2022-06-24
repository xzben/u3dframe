--
--  瞬时动作，立马执行完成的动作
--

local action_base = require("framework.utils.action.action_base")
local action_instant = class("action_instant", action_base)

function action_instant:ctor()
	action_base.ctor(self)
end

function action_instant:step(dt)
	self:execute()
	self:set_done()
end

return action_instant