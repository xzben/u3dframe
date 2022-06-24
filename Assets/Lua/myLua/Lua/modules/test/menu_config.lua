
---入口配置信息
---title:菜单标题信息
---func:菜单响应函数
local cjson = require "cjson"
local platform_config = require("config.platform.platform_config")

local allTests = {
    {
        title = "测试UI",
        list = {
            { 
                title = "显示msg_box" ,       
                func = function(cellData) 
                    utils.msg_box:show("test", function() 
                        log.d("confirm")
                    end, function() 
                        log.d("cancel")
                    end)
                end
            },
            { 
                title = "显示toast" ,       
                func = function(cellData) 
                    utils.toast:show("提示信息")
                end
            },
            { 
                title = "显示wait" ,       
                func = function(cellData) 
                    utils.wait:show("请等待...")
                    utils.wait:schedule_once(function()
                        utils.wait:hide()
                    end, 1.0)
                end
            },
            { 
                title = "显示list列表" ,       
                func = function(cellData) 
                    local test = require("modules.test.test_list").ctr.new()
                    test:show_view()
                end
            },
            { 
                title = "显示grid列表" ,       
                func = function(cellData) 
                    local test = require("modules.test.test_grid").ctr.new()
                    test:show_view()
                end
            },
            { 
                title = "显示page视图" ,       
                func = function(cellData) 
                    local test = require("modules.test.test_page").ctr.new()
                    test:show_view()
                end
            },
            { 
                title = "显示url图片" ,       
                func = function(cellData) 
                    local test = require("modules.test.test_url_img").ctr.new()
                    test:show_view()
                end
            },
            { 
                title = "action动画使用" ,       
                func = function(cellData) 
                    local test = require("modules.test.test_action").ctr.new()
                    test:show_view()
                end
            },
            { 
                title = "penghu测试" ,       
                func = function(cellData) 
                    local test = require("modules.test.test_penghu").ctr.new()
                    test:show_view()
                end
            },
        },
    },
    {
        title = "测试广告sdk<真机测试>",
        list = {
            { 
                title = "显示banner广告" ,       
                func = function(cellData) 
                    platform.ads:show_banner(0)
                end
            },
            { 
                title = "隐藏banner广告" ,       
                func = function(cellData) 
                    platform.ads:clear_banner(0)
                end
            },
            { 
                title = "插屏广告" ,       
                func = function(cellData) 
                    platform.ads:show_interstitial()
                end
            },
            { 
                title = "视频广告" ,       
                func = function(cellData) 
                    platform.ads:show_video(function()
                        
                    end)
                end
            },
            { 
                title = "开屏广告" ,       
                func = function(cellData) 
                    platform.ads:show_splash(function()
                        log.d("===开屏完成==")
                    end)
                end
            },
        
            { 
                title = "切换到穿山甲广告" ,       
                func = function(cellData) 
                    local adData = {
                        csj = {
                            appId = "5230762",
                            bannerId = "946991179",
                            videoId = "947173989",
                            splashId = "887608792",
                            insertId = "947173972"
                        }
                    }
                    platform.ads:set_ad_data("csj", cjson.encode(adData))
                    utils.toast:show("请重新启动查看")
                end
            },
        
            { 
                title = "切换到google广告" ,       
                func = function(cellData) 
                    local adData = {
                        mob = {
                            appId = "ca-app-pub-3940256099942544~3347511713",
                            bannerId = "ca-app-pub-3940256099942544/6300978111",
                            videoId = "ca-app-pub-3940256099942544/5224354917",
                            splashId = "ca-app-pub-3940256099942544/3419835294",
                            insertId = "ca-app-pub-3940256099942544/1033173712"
                        }
                    }
                    platform.ads:set_ad_data("mob", cjson.encode(adData))
                    utils.toast:show("请重新启动查看")
                end
            },
            
           

        },  
    },
    {
        title = "测试登录支付sdk<真机测试>",
        list = {
            { 
                title = "google登录" ,       
                func = function(cellData) 
                    platform.login:login(platform_config.LoginWay.GOOGLE,
                        function(data)
                            utils.toast:show("登录成功："..data.openId)
                        end,
                        function(error)
                            utils.toast:show("登录失败："..error.errorMsg)
                        end)
                end
            },
            { 
                title = "google支付" ,       
                func = function(cellData) 
                    platform.pay:pay(platform_config.PayWay.GOOGLE, "archer_no_ads", platform_config.ShopItemType.NON_CONSUME,
                        function(data)
                            utils.toast:show("支付成功："..data.orderId)
                        end,
                        function(error)
                            utils.toast:show("支付失败："..error.errorMsg)
                        end)
                end
            },
        
            { 
                title = "apple支付" ,       
                func = function(cellData) 
                    platform.pay:pay(platform_config.PayWay.IOS_APPLE, "archer_no_ads", platform_config.ShopItemType.NON_CONSUME,
                        function(data)
                            utils.toast:show("支付成功："..data.orderId)
                        end,
                        function(error)
                            utils.toast:show("支付失败："..error.errorMsg)
                        end)
                end
            },
        },
    },
    {
        title = "测试通用sdk<真机测试>",
        list = {
            { 
                title = "获取渠道" ,       
                func = function(cellData) 
                    local channel = platform:get_channel()
                    utils.toast:show("当前渠道："..channel)
                end
            },
            { 
                title = "获得版本名称" ,       
                func = function(cellData) 
                    local version = platform:get_package_version()
                    utils.toast:show("当前版本："..version)
                end
            },
            { 
                title = "获得当前语言" ,       
                func = function(cellData) 
                    local language = platform:get_current_language()
                    utils.toast:show("当前语言："..language)
                end
            },
            { 
                title = "唯一码" ,       
                func = function(cellData) 
                    local uuid = platform:get_uuid()
                    utils.toast:show("唯一码uuid："..uuid)
                end
            },
            { 
                title = "震动" ,       
                func = function(cellData) 
                    platform:vibrator(300)
                end
            },
             { 
                title = "邮件发送" ,       
                func = function(cellData) 
                    platform:send_mail("yuchuangtech@gmail.com", "Feedback", "hello:")
                end
            },
        
        },
    },

    
}

return allTests