local ctr_base = import("framework.mvp.ctr_base")
local msg_box_ctr = class("msg_box_ctr", ctr_base)

msg_box_ctr.service_event_func_map = {
-- ["service_name"] = {
--     [event_name] = "handle_func"
-- }
}

msg_box_ctr.interfaces = {
    "set_only_confirm",
}

function msg_box_ctr:ctor()
    ctr_base.ctor(self)
    self.m_autoClose = true
end

function msg_box_ctr:on_init()

end

function msg_box_ctr:get_view_class()
    return require("modules.common.msg_box.msg_box_view")
end

function msg_box_ctr:show(tips, confirm, cancel, autoClose)
    if type(autoClose) == "boolean" then
        self.m_autoClose = autoClose
    else
        self.m_autoClose = true
    end

    self:show_view({
        title = "Tips";
        content = tips;
        fun_y = confirm;
        fun_n = cancel;
    })
end

function msg_box_ctr:show_with_title(title, tips, confirm, cancel, autoClose)
    if type(autoClose) == "boolean" then
        self.m_autoClose = autoClose
    else
        self.m_autoClose = true
    end
    self:show_view({
        title = title;
        content = tips;
        fun_y = confirm;
        fun_n = cancel;
    })
end

function msg_box_ctr:on_view_exit()

end

-- 在view 创建后回调
function msg_box_ctr:on_view_enter()
    local data = self:get_show_data()
    self.set_only_confirm(data.fun_n == nil, self.m_autoClose)
end

function msg_box_ctr:handle_func_y()
    local data = self:get_show_data()

    if type(data.fun_y) == "function" then
        data.fun_y()
    end

    if self.m_autoClose then
        self:close()
    end
end

function msg_box_ctr:handle_func_n()
    local data = self:get_show_data()

    if type(data.fun_n) == "function" then
        data.fun_n()
    end

    if self.m_autoClose then
        self:close()
    end
end

return msg_box_ctr