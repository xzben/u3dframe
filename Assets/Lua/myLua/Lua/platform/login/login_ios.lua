
local cjson = require "cjson"
local platform_config = require("config.platform.platform_config")

local login_base = require("platform.login.login_base")
local login_ios = class("login_ios", login_base)

function login_ios:ctor(...)
    login_base.ctor(self, ...)
end

--登录sdk初始化
function login_ios:init()
    log.d("############## login_ios:init")
end

--检测应用是否存在
function login_ios:check_app_exist(URLSchemes)
    local value = self.m_plaform:call_native_return_int('AppUtil', 'checkAppExist:', URLSchemes); 
    log.d("===check_app_exist======:", value)
    return value == 1;
end


--获取登录方式应用平台的包信息
function login_ios:get_package_data(loginWay)
    local LoginWayPackageData = {
        [LoginWay.IOS_APPLE] = {URLSchemes = "apple://", appname = 'apple'},
        [LoginWay.WEIXIN] = {URLSchemes = "weixin://", appname = '微信'},
    }
    return LoginWayPackageData[loginWay];
end

-- 渠道登录
--//doneCallback((data:any)=>{})
--//data:返回参数
--{
--    openId : data.openId,
--    icon : data.icon,
--    nickname : data.nickname,
--    loginWay : data.loginWay,
--}
function login_ios:login(loginWay, succFunc, failFunc)
    local PayWayFuncMap = {
        [platform_config.LoginWay.IOS_APPLE] = login_ios.apple_login;
        [platform_config.LoginWay.WEIXIN] = login_ios.wechat_login;
    }
    local func = PayWayFuncMap[loginWay]
    if func then
        func(self, succFunc, failFunc)
    else
        log.w("login_ios:login can't find pay func from target: "..tostring(loginWay))
    end
end

-- 游客绑定账号
--//doneCallback((data:any)=>{})
--//data:返回参数
--{
--    openId : data.touristId,
--    icon : data.icon,
--    nickname : data.nickname,
--    loginWay : data.loginWay,
--}
function login_ios:bind_account(loginWay, succFunc, failFunc)
    local PayWayFuncMap = {
        [platform_config.LoginWay.IOS_APPLE] = login_ios.apple_login;
        [platform_config.LoginWay.WEIXIN] = login_ios.wechat_login;
    }
    local func = PayWayFuncMap[loginWay]
    if func then
        func(self, function(data)
            local touristId = cjson.encode({
                ouuid = self:getTouristToken(),
                sdk = data.loginWay,
                nuuid = data.openId,
            })
            if succFunc then 
                succFunc({
                        openId = touristId,
                        icon = data.icon,
                        nickname = data.nickname,
                        loginWay = data.loginWay,
                    })  
            end
        end, failFunc)
    else
        log.w("login_ios:bind_account can't find pay func from target: "..tostring(loginWay))
    end
end

--apple登录
function login_ios:apple_login(succFunc, failFunc)
    self.m_plaform:add_listener_once("onAppleLogin", function(obj)
        log.d("=====onAppleLogin===:", obj.code)
        if succFunc then 
            succFunc({
                    openId = obj.userID,
                    loginWay = platform_config.LoginWay.IOS_APPLE,
                })  
        end
    end, self)
    self.m_plaform:add_listener_once("onAppleLoginError", function(obj)
        log.d("=====onAppleLoginError====")
        if failFunc then 
            failFunc({
                    errorCode = obj.errorCode,
                    errorMsg = obj.errorMsg,
                })  
        end
    end, self)

    local stringify = cjson.encode({})
    self.m_plaform:call_native("AppleLoginUtil", "appleLogin:", stringify)
end

--微信的SDK登录
function login_ios:wechat_login(succFunc, failFunc)
    self.m_plaform:add_listener_once("onWeChatLogin", function(obj)
        log.d("=====onWeChatLogin===:", obj.code)
        if succFunc then 
            succFunc({
                    openId = obj.userID,
                    loginWay = platform_config.LoginWay.IOS_APPLE,
                })  
        end
    end, self)
    self.m_plaform:add_listener_once("onWeChatLoginError", function(obj)
        log.d("=====onWeChatLoginError====")
        if failFunc then 
            failFunc({
                    errorCode = obj.errorCode,
                    errorMsg = obj.errorMsg,
                })  
        end
    end, self)

    local stringify = cjson.encode({
        scope = "snsapi_userinfo",
        state = "123",
    })
    self.m_plaform:call_native("WeChatUtil", "weChatLogin:", stringify)
end

return login_ios