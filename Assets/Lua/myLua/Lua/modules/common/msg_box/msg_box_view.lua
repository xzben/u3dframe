local view_base = import("framework.mvp.view_base")
local msg_box_view = class("msg_box_view", view_base)

-- 需要 ctr 提供的回调接口
msg_box_view.interfaces = {
    "close",
    "handle_func_n",
    "handle_func_y"
}

function msg_box_view:on_init(data)
    self:load_view("common/panel", "msg_box")

    self.m_title = self:get_child_by_name("content/txt_title", "Text")
    self.m_tip = self:get_child_by_name("content/txt_tip", "Text")

    self:add_click_callback("content/btn_close", function()
        self.close()
    end)

    self:add_click_callback("content/btn_cancel", function()
        self.handle_func_n()
    end)

    self:add_click_callback("content/btn_ok", function()
        self.handle_func_y()
    end)

    self:add_click_callback("content/btn_ok_2", function()
        self.handle_func_y()
    end)
end

function msg_box_view:set_only_confirm(only_confirm, needClose)
    utils.ui.set_visible(self:get_child_by_name("content/btn_cancel"), not only_confirm)
    utils.ui.set_visible(self:get_child_by_name("content/btn_ok"), not only_confirm)
    utils.ui.set_visible(self:get_child_by_name("content/btn_ok_2"), only_confirm)
    utils.ui.set_visible(self:get_child_by_name("content/btn_close"), needClose)
end

function msg_box_view:on_uninit()

end

function msg_box_view:on_update(data)
    self.m_tip.text = data.content;
    self.m_title.text = data.title;
end

function msg_box_view:get_layer_name()
    return const.layer_name.layer_confirm_popup
end

return msg_box_view