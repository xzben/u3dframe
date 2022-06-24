local env = require("config.env")
local update_config = {}


local env_url_config = {
	[env.DEBUG] = "http://192.168.0.142/nh5game/update/u3dframe/";
	[env.INNER_TEST] = "http://192.168.0.142/nh5game/update/u3dframe/";
	[env.OUT_TEST] = "https://testgame.yuch188.com/update/u3dframe/";
	[env.RELEASE] = "https://testgame.yuch188.com/update/u3dframe/";
}

update_config.TIME_OUT = 5

update_config.get_cur_update_url = function() 
	return env_url_config[config.get_cur_env()]
end

return update_config