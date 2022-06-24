local log_http = class("framework.log.log_http")
local log_level = require("framework.log.log_level")

function log_http:ctor()

end

function log_http:get_http_url()
    return "http://47.92.231.60:9995/upload/log"
end

function log_http:handle_log(level, msg)
    if level < log_level.WARN then return end

    local url = self:get_http_url()
    local data = {
        uid = 1;
        uuid = "";
        msg = msg;
    }

    utils.http_manager:post(url, data, function(resp, url, err) 
	
	end)
end


return log_http