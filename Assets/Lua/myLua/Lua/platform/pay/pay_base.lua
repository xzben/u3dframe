

local common_base = require("framework.mvp.common_base")
local pay_base = class("pay_base", common_base)

function pay_base:ctor(plaform)
    self.m_plaform = plaform
    self:init()
end

--支付sdk初始化
function pay_base:init()
    log.d("############## pay_base:init")
end

--获取掉单数据列表
function pay_base:get_drop_order_list( )
    local orderList = {}
    return orderList
end

--删除掉单数据
function pay_base:del_drop_order_list( )

end

--恢复购买
function pay_base:restore_purchases()
 
end


--查询商品信息
--payWay:支付方式 platform_config.PayWay
--products:商品id列表
function pay_base:query_products( payWay, products, succFunc )
    
end


--渠道支付
--payWay:支付方式 platform_config.PayWay
--productId:商品id
--goodsType:商品类型 platform_config.ShopItemType
function pay_base:pay(payWay, productId, goodsType, succFunc, failFunc)
    if succFunc then
        succFunc({
            productId = productId,
            orderId = "web-test-00000000100001",
        })
    end
end



return pay_base