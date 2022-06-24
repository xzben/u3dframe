

local cjson = require "cjson"
local platform_base = require("platform.platform_base")
local platform_config = require("config.platform.platform_config")
local platform_android = class("platform_android",platform_base)

function platform_android:ctor()
	platform_base.ctor(self)
end

--平台初始化
--这里处理功能偏大的,单独抽离出来些,防止这个文件很多东西找不到
function platform_android:init()
	log.d("=====platform_android:init======")
    self.login = require("platform.login.login_android").new(self)
    self.pay = require("platform.pay.pay_android").new(self)
    self.ads = require("platform.ads.ads_android").new(self)
end

--获得平台信息
function platform_android:get_platform()
	return platform_config.PlatformType.Android
end

--获取渠道
function platform_android:get_channel()
    local channel = self:call_native_return_string("com.utils.AppUtil", "getChannel")
    log.d("===getChannel======:", channel)
    return channel;
end


--获得版本名称
function platform_android:get_package_version()
    local version = self:call_native_return_string("com.utils.AppUtil", "getAppVersionName")
    log.d("===getAppVersionName======:", version)
    return version;
end


--获得当前语言
function platform_android:get_current_language()
    local language = self:call_native_return_string("com.utils.AppUtil", "getCurrentLanguage")
    log.d("===getCurrentLanguage======:", language)
    return language;
end


--唯一码用于游客登录
function platform_android:get_uuid()
    local value = self:call_native_return_string("com.utils.DeviceIdUtil", "getDeviceId")
    log.d("===getUniqueCode======:", value)
    return value;
end

--震动接口
--ms:震动时间
function platform_android:vibrator( ms )
	local stringify = cjson.encode({
        type = 1,
        ms = ms,
    })
    self:call_native("com.utils.AppUtil", "Vibrator", stringify)
end


--邮件发送
--mailto:邮件发送目的地
--title:邮件标题
--content:邮件内容
function platform_android:send_mail( mailto, title, content )
	local stringify = cjson.encode({
        mailto = mailto,
        title = title, 
        content = content,
    })
    self:call_native("com.utils.AppUtil", "sendMail", stringify)
end

--提交排行数据
--leaderboardId:排行榜id
--value:需要保存的值
function platform_android:submit_leaderboard( leaderboardId, value )
    if self:getChannel() == platform_config.ChannelType.Google then
        local stringify = cjson.encode({
            value = value,
            leaderboardId = leaderboardId, 
        })
        self:call_native("channel.GoogleUtil", "submitLeaderboard", stringify)
    end
end

--显示系统排行数据
--leaderboardId:排行榜id
function platform_android:show_leaderboard( leaderboardId )
    if self:getChannel() == platform_config.ChannelType.Google then
        local stringify = cjson.encode({
            leaderboardId = leaderboardId, 
        })
        self:call_native("channel.GoogleUtil", "showLeaderboard", stringify)
    end
end

--获得自己的排行数据
--leaderboardId:排行榜id
--span: 排行榜间隔时间 0:每日  1:每周   2:所有时间
function platform_android:get_self_leaderboard( leaderboardId, span, succFunc, failFunc )
    if self:getChannel() == platform_config.ChannelType.Google then
        self:add_listener_once("onSelfLeaderboard", function(obj)
            log.d("=====onSelfLeaderboard===")
            if succFunc then 
                succFunc(obj)  
            end
        end, self)
        self:add_listener_once("onSelfLeaderboardError", function(obj)
            log.d("=====onSelfLeaderboardError====")
            if failFunc then 
                failFunc({
                        errorCode = obj.errorCode,
                        errorMsg = obj.errorMsg,
                    })  
            end
        end, self)

        local stringify = cjson.encode({
            span = span or 2,  --0:每日  1:每周   2:所有时间
            leaderboardId = leaderboardId, 
        })
        self:call_native("channel.GoogleUtil", "getSelfLeaderboard", stringify)
    end
end

--获得世界的排行数据
--leaderboardId:排行榜id
--span: 排行榜间隔时间 0:每日  1:每周   2:所有时间
--maxResults: 查询结果的最大数量
function platform_android:get_world_leaderboards( leaderboardId, span, maxResults, succFunc, failFunc )
    if self:getChannel() == platform_config.ChannelType.Google then
        self:add_listener_once("onAllLeaderboards", function(obj)
            log.d("=====onAllLeaderboards===")
            if succFunc then 
                succFunc(obj.datas)  
            end
        end, self)
        self:add_listener_once("onAllLeaderboardsError", function(obj)
            log.d("=====onAllLeaderboardsError====")
            if failFunc then 
                failFunc({
                        errorCode = obj.errorCode,
                        errorMsg = obj.errorMsg,
                    })  
            end
        end, self)

        local stringify = cjson.encode({
            span = span or 2,  --0:每日  1:每周   2:所有时间
            leaderboardId = leaderboardId, 
            maxResults = maxResults or 25
        })
        self:call_native("channel.GoogleUtil", "getAllLeaderboards", stringify)
    end
end


return platform_android