


local common_base = require("framework.mvp.common_base")
local ads_base = class("ads_base", common_base)

function ads_base:ctor(plaform)
    self.m_plaform = plaform
    self:init()
end

function ads_base:init( )
    log.d("############## ads_base:init")
end

function ads_base:set_ad_data(useAdtype, adData)
	log.d("############## ads_base:set_ad_data", useAdtype, adData)
end

function ads_base:show_banner( index, view)
    log.d("############## show_banner")
end

function ads_base:clear_banner()
    log.d("############## clear_banner")
end

function ads_base:show_video( finishCallback )
    log.d("############## show_video")
end

function ads_base:show_splash( donceCallback )
    log.d("############## show_splash")
end

function ads_base:show_interstitial()
    log.d("############## show_interstitial")
end

return ads_base