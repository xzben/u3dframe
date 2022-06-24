

local platform_config = {}

-- --平台类型
platform_config.PlatformType = {
    WIN32 = 1,  --电脑
    Android = 2,  --安卓
    IOS = 3,     --苹果
}

--渠道名称(安卓平台渠道映射对应的安卓渠道配置)
platform_config.ChannelType = {
    Official = 'official',  --官方渠道
    TapTap = 'taptap',      --TapTap
    KuaiBao = 'kuaibao',    --快爆
    MoMoYu = 'momoyu',    --摸摸鱼
    Google = 'google',  --googlePlay
    Ch233 = 'ch233',  --233平台

    Apple = 'apple',  --IOS官方渠道
}

--游戏登录方式
platform_config.LoginWay = {
    QUICK = 0,          --快速登录
    ACCOUNT = 1,        --账号登录
    WEIXIN = 2,         --微信登录
    TAPTAP = 3,         --taptap登录
    MINI_WEIXIN = 4,    --微信小游戏登录
    MINI_QQ = 5,        --QQ小游戏登录
    MINI_BYTE = 6,      --字节小游戏登录
    WEB_MEIZU = 7,      --魅族快游戏登录
    MOMOYU = 8,         --摸摸鱼sdk登录
    GOOGLE = 9,         --谷歌play
    IOS_APPLE = 10,    --ios apple登录
    CH233 = 11,         --233平台登录
    
    TOURIST = 99,       --游客登录
    RELATION = 100,     --账号关联
}

--游戏支付方式
platform_config.PayWay = {
    GOOGLE = 0,     --googlePlay支付
    IOS_APPLE = 1,    --ios apple支付
}

--商品类型
platform_config.ShopItemType = {
    CONSUME = 0,     --消耗类型
    NON_CONSUME = 1,  --非消耗类型
    SUBS = 2,       --订阅类型
}


return platform_config

