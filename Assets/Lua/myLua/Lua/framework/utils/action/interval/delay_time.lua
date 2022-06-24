local action_interval = require("framework.utils.action.action_interval")
local delay_time = class("delay_time", action_interval)

function delay_time:ctor( dt )
	action_interval.ctor(self, dt)
end

return delay_time