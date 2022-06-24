local view_base = import("framework.mvp.view_base")
local toast_view = class("toast_view", view_base)

-- 需要 ctr 提供的回调接口
toast_view.interfaces = {
    "close",
}

function toast_view:on_init(data)
    self:load_view("common/panel", "toast")

    self.m_bg = self:get_child_by_name("content/Image")
    self.m_text = self:get_child_by_name("content/Image/Text", "Text")

    local move = utils.action.move_to.new(1, Vector3(0, 300, 0))
    local fade = utils.action.fade_out.new(1)
    local call = utils.action.call_func.new(function()
        self.close()
    end)
    local seq = utils.action.sequence.new(move, fade, call)
    self:run_action(seq, self.m_bg)
end

function toast_view:on_uninit()

end

function toast_view:on_update(data)
    self:set_tips(data)
end

function toast_view:set_tips(tips)
    self.m_text.text = tips
end

function toast_view:get_layer_name()
    return const.layer_name.layer_system
end

return toast_view