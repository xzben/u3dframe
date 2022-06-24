

local cjson = require "cjson"
local common_base = require("framework.mvp.common_base")
local platform_config = require("config.platform.platform_config")
local event_dispatcher = require("framework.event.event_dispatcher")
local platform_base = class("platform_base",event_dispatcher, common_base)

function platform_base:ctor()
	event_dispatcher.ctor(self)
	self:init()
end

--平台初始化
--这里处理功能偏大的,单独抽离出来些,防止这个文件很多东西找不到
function platform_base:init()
	log.d("=====platform_base:init======")
    self.login = require("platform.login.login_base").new(self)
    self.pay = require("platform.pay.pay_base").new(self)
	self.ads = require("platform.ads.ads_base").new(self)
end

--调用原生接口，具体查看PlatformManager.cs
--className：原生类名
--methodName：原生函数名
--return 返回void
function platform_base:call_native(className, methodName, ...)
    LuaFramework.GameWorld.Inst.PlatformManager:callNative(className, methodName, ...)
end

--调用原生接口，具体查看PlatformManager.cs
--className：原生类名
--methodName：原生函数名
--return 返回int
function platform_base:call_native_return_int(className, methodName, ...)
    return LuaFramework.GameWorld.Inst.PlatformManager:callNativeReturnInt(className, methodName, ...)
end

--调用原生接口，具体查看PlatformManager.cs
--className：原生类名
--methodName：原生函数名
--return 返回string
function platform_base:call_native_return_string(className, methodName, ...)
    return LuaFramework.GameWorld.Inst.PlatformManager:callNativeReturnString(className, methodName, ...)
end


--获得平台信息
function platform_base:get_platform()
	return platform_config.PlatformType.WIN32
end

--获取渠道
function platform_base:get_channel()
    return platform_config.ChannelType.Official
end

--获得版本名称
function platform_base:get_package_version()
    return "1.0.1";
end

--获得版本名称
function platform_base:get_current_language()
    return "zh";
end

--唯一码用于游客登录
function platform_base:get_uuid()
    return "10010";
end

--震动接口
--ms:震动时间
function platform_base:vibrator( ms )
	log.d("vibrator ms", ms)
end


--邮件发送
function platform_base:send_mail( mailto, title, content )
	local stringify = cjson.encode({
        mailto = mailto,
        title = title,
        content = content,
    })
    log.d("sendMail stringify:", stringify)
end


--提交排行数据
--leaderboardId:排行榜id
--value:需要保存的值
function platform_base:submit_leaderboard( leaderboardId, value )
    local stringify = cjson.encode({
        value = value,
        leaderboardId = leaderboardId, 
    })
    log.d("submitLeaderboard stringify:", stringify)
end

--显示系统排行数据
--leaderboardId:排行榜id
function platform_base:show_leaderboard( leaderboardId )
    local stringify = cjson.encode({
        leaderboardId = leaderboardId, 
    })
    log.d("showLeaderboard stringify:", stringify)
end

--获得自己的排行数据
--leaderboardId:排行榜id
--span: 排行榜间隔时间 0:每日  1:每周   2:所有时间
function platform_base:get_self_leaderboard( leaderboardId, span, succFunc, failFunc )
    local stringify = cjson.encode({
        span = span or 2,  --0:每日  1:每周   2:所有时间
        leaderboardId = leaderboardId, 
    })
    log.d("getSelfLeaderboard stringify:", stringify)
end

--获得世界的排行数据
--leaderboardId:排行榜id
--span: 排行榜间隔时间 0:每日  1:每周   2:所有时间
--maxResults: 查询结果的最大数量
function platform_base:get_world_leaderboards( leaderboardId, span, maxResults, succFunc, failFunc )
    local stringify = cjson.encode({
        span = span or 2,  --0:每日  1:每周   2:所有时间
        leaderboardId = leaderboardId, 
        maxResults = maxResults or 25,
    })
    log.d("getWorldLeaderboards stringify:", stringify)
end


return platform_base