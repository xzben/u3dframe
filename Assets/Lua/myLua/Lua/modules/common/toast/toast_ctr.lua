local ctr_base = import("framework.mvp.ctr_base")
local toast_ctr = class("toast_ctr", ctr_base)

toast_ctr.service_event_func_map = {
-- ["service_name"] = {
--     [event_name] = "handle_func"
-- }
}

toast_ctr.interfaces = {
-- "testInterface",
}

function toast_ctr:on_init()

end

function toast_ctr:get_view_class()
    return require("modules.common.toast.toast_view")
end


return toast_ctr