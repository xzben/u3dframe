

local platform_config = require("config.platform.platform_config")
local common_base = require("framework.mvp.common_base")
local login_base = class("login_base", common_base)

function login_base:ctor(plaform)
    self.m_plaform = plaform
    self:init()
end

--登录sdk初始化
function login_base:init()
    log.d("############## login_base:init")
end

--获得游客登录token
function login_base:getTouristToken()
    return "";
end

--检测应用是否存在
function login_base:check_app_exist()
    return true;
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
function login_base:login(loginWay, succFunc, failFunc)
    if succFunc then
        succFunc({
            openId = "andy",
            loginWay = platform_config.LoginWay.ACCOUNT
        })
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
function login_base:bind_account(loginWay, succFunc, failFunc)
   
end


return login_base