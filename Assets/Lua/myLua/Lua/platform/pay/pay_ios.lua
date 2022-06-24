
local cjson = require "cjson"
local platform_config = require("config.platform.platform_config")
local pay_base = require("platform.pay.pay_base")
local pay_ios = class("pay_ios", pay_base)

function pay_ios:ctor(...)
    pay_base.ctor(self, ...)
end

--支付sdk初始化
function pay_ios:init()
    log.d("############## pay_ios:init")
end

--获取掉单数据列表
function pay_ios:get_drop_order_list( )
    local orderList = {}
    -- local value = self:call_native("com.utils.StoreUtil", "getIntValue", "google_pay_size", 0)
    -- for i = 1, value do
    --     local userData = self:call_native_return_string("com.utils.StoreUtil", "getStringItem", "google_pay_item_"..idx, "")
    --     local object = cjson.decode(userData);
    --     orderList[#orderList + 1] = object;
    -- end
    return orderList
end

--删除掉单数据
function pay_ios:del_drop_order_list( )
    -- local value = self:call_native("com.utils.StoreUtil", "getIntValue", "google_pay_size", 0)
    -- for i = 1, value do
    --     self:call_native("com.utils.StoreUtil", "removeItem", "google_pay_item_"..idx)
    -- end
    -- self:call_native("com.utils.StoreUtil", "removeItem", "google_pay_size")
end

--恢复购买
function pay_ios:restore_purchases()
    local stringify = cjson.encode({

    })
    self.m_plaform:call_native("ApplePayUtil", "restorePurchases:", stringify)
end


--查询商品信息
--payWay:支付方式 platform_config.PayWay
--products:商品id列表
function pay_ios:query_products( payWay, products, succFunc )
    if payWay == platform_config.PayWay.GOOGLE then 
        self.m_plaform:add_listener_once("onQueryProducts", function(obj)
            if succFunc then 
                succFunc(obj.products or {})  
            end
        end, self)
        local stringify = cjson.encode({
            products = products,
        })
        self.m_plaform:call_native("onQueryProducts", "queryProducts:", stringify)
    end
end


--渠道支付
--payWay:支付方式 platform_config.PayWay
--productId:商品id
--goodsType:商品类型 platform_config.ShopItemType
function pay_ios:pay(payWay, productId, goodsType, succFunc, failFunc) 
    local PayWayFuncMap = {
        [platform_config.PayWay.IOS_APPLE] = pay_ios.apple_pay;
    }

    local func = PayWayFuncMap[payWay]
    if func then
        func(self, productId, goodsType, succFunc, failFunc)
    else
        log.w("can't find pay func from target: "..tostring(payWay))
    end
end

--苹果支付
function pay_ios:apple_pay(productId, goodsType, succFunc, failFunc)
    self.m_plaform:add_listener_once("onApplePay", function(obj)
        log.d("=====onApplePay====productId:", obj.productId)
        if succFunc then 
            succFunc({
                    productId = obj.productId,
                    orderId = obj.orderId,
                })  
        end
    end, self)
    self.m_plaform:add_listener_once("onApplePayError", function(obj)
        log.d("=====onApplePayError====")
        if failFunc then 
            failFunc({
                    errorCode = obj.errorCode,
                    errorMsg = obj.errorMsg,
                })  
        end
    end, self)

    local stringify = cjson.encode({
        productId = productId,
        goodsType = goodsType,
    })

    self.m_plaform:call_native("ApplePayUtil", "applePay:", stringify)
end



return pay_ios