
local cjson = require "cjson"
local platform_config = require("config.platform.platform_config")

local login_base = require("platform.login.login_base")
local login_android = class("login_android", login_base)

function login_android:ctor(...)
    login_base.ctor(self, ...)
end

--登录sdk初始化
function login_android:init()
    log.d("############## login_android:init")
end

--检测应用是否存在
function login_android:check_app_exist(packageName)
    local value = self.m_plaform:call_native_return_int('com.utils.OpenappUtil', 'checkAppExist', packageName); 
    log.d("===check_app_exist======:", value)
    return value == 1;
end


--获取登录方式应用平台的包信息
function login_android:get_package_data(loginWay)
    local LoginWayPackageData = {
        [LoginWay.WEIXIN] = {package = "com.tencent.mm", appname = '微信'},
        [LoginWay.TAPTAP] = {package = "com.taptap", appname = 'TapTap'},
        [LoginWay.MOMOYU] = {package = "com.playgame.havefun", appname = '摸摸鱼'},
        [LoginWay.GOOGLE] = {package = "google", appname = 'google框架'},
        [LoginWay.CH233] = {package = "com.meta.box", appname = '233平台'},
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
function login_android:login(loginWay, succFunc, failFunc)
    local PayWayFuncMap = {
        [platform_config.LoginWay.GOOGLE] = login_android.google_login;
    }
    local func = PayWayFuncMap[loginWay]
    if func then
        func(self, succFunc, failFunc)
    else
        log.w("login_android:login can't find pay func from target: "..tostring(loginWay))
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
function login_android:bind_account(loginWay, succFunc, failFunc)
    local PayWayFuncMap = {
        [platform_config.LoginWay.GOOGLE] = login_android.google_login;
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
        log.w("login_android:bind_account can't find pay func from target: "..tostring(loginWay))
    end
end

--google登录
function login_android:google_login(succFunc, failFunc)
    self.m_plaform:add_listener_once("onGoogleLogin", function(obj)
        log.d("=====onGoogleLogin===:", obj.userID, obj.avatar, obj.nickname)
        if succFunc then 
            succFunc({
                    openId = obj.userID,
                    icon = obj.avatar,
                    nickname = obj.displayName,
                    loginWay = LoginWay.GOOGLE,
                })  
        end
    end, self)
    self.m_plaform:add_listener_once("onGoogleLoginError", function(obj)
        log.d("=====onGoogleLoginError====")
        if failFunc then 
            failFunc({
                    errorCode = obj.errorCode,
                    errorMsg = obj.errorMsg,
                })  
        end
    end, self)

    local stringify = cjson.encode({
    })
    self.m_plaform:call_native("channel.GoogleUtil", "googleLogin", stringify)
end



return login_android