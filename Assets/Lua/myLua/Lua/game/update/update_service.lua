local VersionInfo = require("game.update.model.VersionInfo")
local service_base = require("framework.mvp.service_base")

local update_service = class("update_service", service_base)

local PLATFORM_NAMES = {
	[const.platform_type.WIN] 		= "win";
	[const.platform_type.ANDROID] 	= "android";
	[const.platform_type.IOS] 		= "ios";
}

function update_service:ctor()
	service_base.ctor(self)
	self.m_updateMgr = LuaFramework.GameWorld.Inst.UpdateManager;
	self.m_writepath = LuaFramework.GameWorld.Inst.GameManager:getWriteablePath();
	self.m_fileDownload = LuaFramework.FileDowload.Inst;

	self.m_remoteVersion = VersionInfo.new()
end

function update_service:start()
	service_base.start(self)
end

function update_service:stop()
	service_base.stop(self)
end

local function download_files( downloadfiles, index, doneCallback)
	local item = downloadfiles[index]
	if item == nil then
		return doneCallback()
	end

	local size = #downloadfiles
	local onePercent = 1/size

	self.m_fileDownload:downloadFile(item.url, item.dest_path, function( percent ) 
		self:dispatch(event.update_event.DOWNLOAD_UPDATE_FILE_PROCESS, (index - 1)*onePercent + percent*onePercent)
	end, function() 
		download_files(downloadfiles, index+1, doneCallback)
	end)
end

local function install_update_files( downloadfiles, index, doneCallback)
	local item = downloadfiles[index]
	if item == nil then
		return doneCallback()
	end

	local size = #downloadfiles
	local onePercent = 1/size

	self.m_updateMgr:InstallUpdateZip(item.dest_path, item.version, function() 
	
	end, function( percent ) 
		self:dispatch(event.update_event.DOWNLOAD_UNZIP_FILE_PROCESS, (index - 1)*onePercent + percent*onePercent)
	end, function() 
		install_update_files(downloadfiles, index+1, doneCallback)
	end)
end

function update_service:do_update( needList)
	self:dispatch(event.update_event.UPDATE_START)

	local downloadfiles = {}
	local url_root = config.update_config.get_cur_update_url();
	local downpath = string.format("%s/update/loading");

	for _, item in ipairs(needList) do
		local filename = FileTools.getFileName(item.res);

		table.insert(downloadfiles, {
			url = string.format("%s/%s", url_root, item.res); 
			dest_path = string.format("%s/%s", downpath, filename);
			version = item.version;
			item = item; 
		})
	end

	self:dispatch(event.update_event.DOWNLOAD_UPDATE_FILE_START)
	download_files(downloadfiles, 1, function() 
		self:dispatch(event.update_event.DOWNLOAD_UPDATE_FILE_DONE)
		self:dispatch(event.update_event.DOWNLOAD_UNZIP_FILE_START)
		install_update_files(downloadfiles, 1, function() 
			self:dispatch(event.update_event.DOWNLOAD_UNZIP_FILE_DONE)
			utils.msg_box:show("更新完成，点击确定重启游戏！", function() 
				LuaFramework.GameWorld.Inst:restartGame()
			end, nil, false)
		end)
	end)
end

local function _check_update_res( version_list )
	local localVersion = self.m_updateMgr:getLocalVersion()
	local needList = {}
	for _, item in ipairs(version_list or {}) do
		if utils.compareVersion(localVersion, item.version) < 0 then
			table.insert(needList, item)
		end
	end

	if #needList <= 0 then
		return self:dispatch(event.update_event.UPDATE_FINISH)
	else
		table.sort(needList, function(a , b) 
			return a.id < b.id
		end)
		return self:dispatch(event.update_event.FIND_NEW_VERSION, needList)
	end
end

local function _handle_get_platform_config_done( self )
	local miniVersion = self.m_remoteVersion.m_version
	local packageVersion = platform:get_package_version()

	if utils.compareVersion(miniVersion, packageVersion) > 0 then
		utils.msg_box:show(self.m_remoteVersion.m_updateTips, function() 
			platform:open_url( self.m_remoteVersion.m_updateUrl)
		end, nil, false)
		return
	end

	local url_root = config.update_config.get_cur_update_url()
	local diff_url = string.format("%s/%s?random=%s", url_root, self.m_remoteVersion.m_diffPath, math.random())
	utils.http_manager:get_time_out(update_config.TIME_OUT, diff_url, function( resp ) 
		local versionFunc = loadstring(resp)
		if versionFunc then
			local versionList = versionFunc();
			_check_update_res(versionList)
		end
	end)
end

function update_service:check_update()
	local url_root = config.update_config.get_cur_update_url()
	local env = LuaFramework.GameWorld.Inst.GameManager:getPlatfromType()
	local channel = platform:get_channel()
	local platform_name = PLATFORM_NAMES[env]

	local url = string.format("%s/%s_%s.json?random=%d", url_root, platform_name, channel, math.random())

	utils.http_manager:get_time_out(update_config.TIME_OUT, url, function( resp ) 
		if resp == nil then
			utils.msg_box:show("读取配置表失败,请检查网络后重试!", function() 
				self:check_update()
			end)
		else
			self.m_remoteVersion:parse_from_remote(resp)
			_handle_get_platform_config_done(self)
		end
	end)
end

return update_service