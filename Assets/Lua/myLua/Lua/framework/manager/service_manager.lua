local service_manager = class("service_manager")

function service_manager:ctor()
	self.m_services = {}
	self.m_serviceConfig = {}
end

function service_manager:init( service_config )
	self.m_serviceConfig = service_config
	for name, config in pairs(service_config) do
		if config.auto_start then
			self:get(name)
		end
	end
end

function service_manager:get( name )
	local config = self.m_serviceConfig[name]
	if nil == config then
		g_log.e("can't find the data by name:", name)
		return nil
	end

	if nil == self.m_services[name] then
		local cls = require(config.path)
		local data = cls.new()
		data:set_service_name(name)
		if type(data.start) == "function" then
			data:start()
		end
		self.m_services[name] = data
	end

	return self.m_services[name]
end

function service_manager:dtor()
	for name, service in pairs(self.m_services) do
		service:stop()
	end
end

return service_manager