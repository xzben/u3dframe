
local cjson = require "cjson"
local platform_base = require("platform.platform_base")
local platform_config = require("config.platform.platform_config")
local platform_ios = class("platform_ios",platform_base)

function platform_ios:ctor()
	platform_base.ctor(self)
end

--平台初始化
--这里处理功能偏大的,单独抽离出来些,防止这个文件很多东西找不到
function platform_ios:init()
	log.d("=====platform_ios:init======")
    self.login = require("platform.login.login_ios").new(self)
    self.pay = require("platform.pay.pay_ios").new(self)
    self.ads = require("platform.ads.ads_ios").new(self)
end

--获得平台信息
function platform_ios:get_platform()
	return platform_config.PlatformType.IOS
end

--获取渠道
function platform_ios:get_channel()
    return platform_config.ChannelType.Apple
end


--唯一码用于游客登录
function platform_ios:get_uuid()
	local stringify = cjson.encode({

    })
    local value = self:call_native_return_string("AppUtil", "getUniqueCode:", stringify)
    log.d("===getUniqueCode======:", value)
    return value;
end

--震动接口
--ms:震动时间
function platform_ios:vibrator( ms )
	local stringify = cjson.encode({
        type = 1,
        ms = ms,
    })
    self:call_native("AppUtil", "Vibrator:", stringify)
end

--邮件发送
function platform_ios:send_mail( mailto, title, content )
	local stringify = cjson.encode({
        mailto = mailto,
        title = title, 
        content = content,
    })
    self:call_native("EmailUtil", "sendMail:", stringify)
end


return platform_ios