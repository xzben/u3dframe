local env = require("config.env")

config = {}

config.env = env

config.net_config = require("config.net.net_config")

config.update_config = require("config.update.update_config")

config.get_cur_env = function() 
	return env.DEBUG	
end

config.is_release = function() 
	return config.get_cur_env() == env.RELEASE
end