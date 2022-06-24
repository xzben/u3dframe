local ctr_base = require("framework.mvp.ctr_base")
local test_list_ctr = class("test_list_ctr", ctr_base)

test_list_ctr.service_event_func_map = {
    -- ["service_name"] = {
    --     [event_name] = "handle_func"
    -- }
}

test_list_ctr.interfaces = {
    -- "testInterface",
}

function test_list_ctr:on_init()

end

function test_list_ctr:get_view_class()
	return require("modules.test.test_list.test_list_view")
end

function test_list_ctr:on_uninit()

end

-- 在 ctr 暂停运行的时候调用
function test_list_ctr:on_pause()

end

-- 在 ctr 恢复运行的时候调用
function test_list_ctr:on_resume()

end

-- 在view删除前回调
function test_list_ctr:on_view_exit()

end

-- 在view 创建后回调
function test_list_ctr:on_view_enter()

end

return test_list_ctr