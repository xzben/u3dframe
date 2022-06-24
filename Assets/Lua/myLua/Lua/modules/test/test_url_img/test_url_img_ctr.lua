local ctr_base = require("framework.mvp.ctr_base")
local test_url_img_ctr = class("test_url_img_ctr", ctr_base)

test_url_img_ctr.service_event_func_map = {
    -- ["service_name"] = {
    --     [event_name] = "handle_func"
    -- }
}

test_url_img_ctr.interfaces = {
    -- "testInterface",
}

function test_url_img_ctr:on_init()

end

function test_url_img_ctr:get_view_class()
	return require("modules.test.test_url_img.test_url_img_view")
end

function test_url_img_ctr:on_uninit()

end

-- 在 ctr 暂停运行的时候调用
function test_url_img_ctr:on_pause()

end

-- 在 ctr 恢复运行的时候调用
function test_url_img_ctr:on_resume()

end

-- 在view删除前回调
function test_url_img_ctr:on_view_exit()

end

-- 在view 创建后回调
function test_url_img_ctr:on_view_enter()

end

return test_url_img_ctr