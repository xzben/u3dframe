local cjson = require "cjson"
local VersionInfo = class("VersionInfo")


function VersionInfo:ctor()
	self.m_shenheVersion = ""
	self.m_shenHeServer = ""
	self.m_version = ""
	self.m_updateTips = ""
	self.m_updateUrl = ""

	self.m_diffPath = ""
end

function VersionInfo:parse_from_remote( txt )
	local data = cjson.decode(txt)

	self.m_shenheVersion = assert(data.shenheversion);
	self.m_shenHeServer = assert(data.shenheserver);
	self.m_version = assert(data.version);
	self.m_updateTips = assert(data.updateTips);
	self.m_updateUrl = assert(data.updateUrl);
	self.m_diffPath = assert(data.diff_path);
end

function VersionInfo:get_shenhe_ip_port()
	local arr = utils.spliterString(self.m_shenHeServer, ":")
	assert(#arr == 2)

	return { ip = arr[1]; port = tonumber(arr[2]); }
end

return VersionInfo