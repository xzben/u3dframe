local action_base = class("action_base")


function action_base:ctor()
	self.m_target = nil;
	self.m_running = false;
	self.m_isDone = false
	self.m_owner = nil
end

function action_base:reset()
	self.m_isDone = false
end

function action_base:set_done()
	self.m_isDone = true
end

function action_base:is_done()
	return self.m_isDone
end

function action_base:get_target()
	return self.m_target
end

function action_base:get_owner()
	return self.m_owner
end

function action_base:set_owner( owner )
	self.m_owner = owner
end

function action_base:start_with_target( target )
	self.m_target = target
end

function action_base:set_running( running )
	self.m_running = running
end

function action_base:stop()
	self.m_isDone = true
	self.m_running = false
	self.m_target = nil
end

function action_base:is_running()
	return self.m_running
end

function action_base:step( dt )
	self.m_isDone = true
end

function action_base:update(dt)

end

function action_base:execute()

end

function action_base:is_interval_action()
	return false
end

return action_base