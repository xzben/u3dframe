local cjson = require "cjson"
local ads_base = require("platform.ads.ads_base")
local ads_ios = class("ads_ios", ads_base)

function ads_ios:ctor(...)
    ads_base.ctor(self, ...)
end

function ads_ios:init( )
    log.d("############## ads_ios:init")
end

function ads_ios:set_ad_data(useAdtype, adData)
    local stringify1 = cjson.encode({
        key = "__adUseType__",
        value = useAdtype,
    })
    self.m_plaform:call_native("ADUtil", 'setStringItem:', stringify1);

    local stringify2 = cjson.encode({
        key = "__adDatas__",
        value = cjson.encode(adData),
    })
    self.m_plaform:call_native("ADUtil", 'setStringItem:', stringify2);
end

function ads_ios:show_banner( index, view)
    log.d("############## show_banner")
    local stringify = cjson.encode({
    	isDeepLink = true,
        refreshTime = 30*1000,
        index = 5,
        adCount = 1,
        width = 320,
        height = 50,
    })
    self.m_plaform:call_native("ADUtil", "createBannerAd:", stringify)
end

function ads_ios:clear_banner()
    log.d("############## clear_banner")
    local stringify = cjson.encode({

    })
    self.m_plaform:call_native("ADUtil", "clearBannerAd:", stringify)
end

function ads_ios:show_video( finishCallback )
    log.d("############## show_video")

    local isFinish = false
    local isError = false

    local isHideLoading = false
    utils.wait:show()

    local function hideLoadingView()
        if isHideLoading then return end
        isHideLoading = true
        utils.wait:hide()
    end

    local function doFinishCallback(errorMsg)
        if self.m_videoTimer ~= nil then
            self:unschedule(self.m_videoTimer)
            self.m_videoTimer = nil
        end
        if type(finishCallback) == "function" then 
            finishCallback(isFinish, isError, errorMsg)
            finishCallback = nil
        end
        hideLoadingView()
    end

    self.m_plaform:removeListener_by_owner(self, "onVideoShow")
    self.m_plaform:removeListener_by_owner(self, "onVideoError")
    self.m_plaform:removeListener_by_owner(self, "onRewardVerify")
    self.m_plaform:removeListener_by_owner(self, "onVideoClose")


    self.m_plaform:add_listener_once("onVideoShow", function()
        log.d("=====onVideoShow=====")
        hideLoadingView()
    end, self)

    self.m_plaform:add_listener_once("onVideoError", function()
        isError = true 
        log.d("=====onVideoError=====")
        doFinishCallback({
            code = msg.errorCode,
            msg = msg.errorMsg,
        })   
    end, self)

    self.m_plaform:add_listener_once("onRewardVerify", function(obj, msg)
        log.d("=====onRewardVerify=====", msg)
        isFinish = true 
    end, self)

    self.m_plaform:add_listener_once("onVideoClose", function()
        log.d("=====onVideoClose=====")
        self.m_videoTimer = self:schedule_once(function()
            doFinishCallback()
        end, 0.5)
    end, self)


    local stringify = cjson.encode({
        userId = "user123",
    })
    self.m_plaform:call_native("ADUtil", "createVideoAd:", stringify)
end

function ads_ios:show_splash( donceCallback )
    log.d("############## show_splash")
    self.m_plaform:removeListener_by_owner(self, "onSplashGoto")
    self.m_plaform:add_listener_once("onSplashGoto", function()
        log.d("=====onSplashGoto=====")
         if type(donceCallback) == "function" then 
            donceCallback()
            donceCallback = nil
        end
    end, self)

    local stringify = cjson.encode({
        timeout = 3000,
        isLand = true,
    })
    self.m_plaform:call_native("ADUtil", 'createSplashAd:', stringify)
end

function ads_ios:show_interstitial()
    log.d("############## show_interstitial")
    local stringify = cjson.encode({
        width = 400,
        height = 267,
    })
    self.m_plaform:call_native("ADUtil", 'createInterstitialAd:', stringify)
end


return ads_ios



