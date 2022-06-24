local ctr_base = import("framework.mvp.ctr_base")
local wait_ctr = class("wait_ctr", ctr_base)

wait_ctr.service_event_func_map = {
-- ["service_name"] = {
--     [event_name] = "handle_func"
-- }
}

wait_ctr.interfaces = {
    "set_tips",
}

function wait_ctr:on_init()
    self.m_count = 0
end

function wait_ctr:get_view_class()
    return require("modules.common.wait.wait_view")
end

function wait_ctr:show(str)
    self.m_count = self.m_count + 1
    if self.m_count == 1 then
        self:show_view(str)
    else
        self.set_tips(str)
    end
end

function wait_ctr:hide()
    self.m_count = self.m_count - 1

    if self.m_count <= 0 then
        self.m_count = 0
        self:close_view()
    end
end

return wait_ctr