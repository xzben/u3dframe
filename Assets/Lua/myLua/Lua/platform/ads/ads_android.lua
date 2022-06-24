
local cjson = require "cjson"
local ads_base = require("platform.ads.ads_base")
local ads_android = class("ads_android", ads_base)

function ads_android:ctor(...)
    ads_base.ctor(self, ...)
end

function ads_android:init()
    log.d("############## ads_android:init")
end

function ads_android:set_ad_data(useAdtype, adData)
    local stringify = cjson.encode(adData);
    self.m_plaform:call_native("com.utils.StoreUtil", 'setStringItem', "__adUseType__", useAdtype);
    self.m_plaform:call_native("com.utils.StoreUtil", 'setStringItem', "__adDatas__", stringify);
end

function ads_android:show_banner( index, view)
    log.d("############## show_banner")
    local stringify = cjson.encode({
        refreshTime = 30*1000,
        index = 5,
        adCount = 1,
        viewWidth = 320,
        viewHeight = 50,
    })
    self.m_plaform:call_native("com.ad.ADUtil", "createBannerAd", stringify)
end


function ads_android:clear_banner()
    log.d("############## clear_banner")
    self.m_plaform:call_native("com.ad.ADUtil", "clearBanner")
end

function ads_android:show_video( finishCallback )
    log.d("############## show_video")

    local isFinish = false
    local isError = false

    local isHideLoading = false
    utils.wait:show("")

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

    local stringify = cjson.encode({
            adCount = 1,
            rewardName = "金币",
            rewardNum = 100,
            data = "media_extra",
            accountId = "0008",
            isLand = true,
            autoShow = true,
            outTime = 8000,
    })

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
        if msg and msg.rewardVerify then
            isFinish = true 
        end
    end, self)

    self.m_plaform:add_listener_once("onVideoClose", function()
        log.d("=====onVideoClose=====")
        self.m_videoTimer = self:schedule_once(function()
            doFinishCallback()
        end, 0.5)
    end, self)

    self.m_plaform:call_native("com.ad.ADUtil", "createVideoAd", stringify)
end

function ads_android:show_splash( donceCallback )
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
    self.m_plaform:call_native("com.ad.ADUtil", 'createSplashAd', stringify)
end

function ads_android:show_interstitial()
    log.d("############## showInterstitial")
    local stringify = cjson.encode({
        viewWidth = 640,
        viewHeight = 320,
        isLand = true,
    })
    self.m_plaform:call_native("com.ad.ADUtil", 'createInterstitialAd', stringify)
end

return ads_android