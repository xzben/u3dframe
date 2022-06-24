local env = require("config.env")

local net_config = {}

net_config.CONNECT_TIMEOUT = 2  --// 链接超时 2秒

net_config.HEART_TIMEOUT = 5   	--//心跳超时 5 秒

net_config.HEART_GAP = 30 --// 30 秒一次心跳，可根据实际情况调整


local env_ip_config = {
	[env.DEBUG] = {
		{ ip = "192.168.0.150"; port = 4000 };
	},

	[env.INNER_TEST] = {
		{ ip = "192.168.0.141"; port = 4000 };
	},

	[env.OUT_TEST] = {
		{ ip = "192.168.0.141"; port = 4000 };
	},

	[env.RELEASE] = {
		{ ip = "192.168.0.141"; port = 4000 };
	},
}

net_config.get_cur_server_list = function() 
	return env_ip_config[config.get_cur_env()]
end

return net_config