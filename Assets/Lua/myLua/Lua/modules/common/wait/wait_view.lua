local view_base = import("framework.mvp.view_base")
local wait_view = class("wait_view", assert(view_base))

-- 需要 ctr 提供的回调接口
wait_view.interfaces = {
-- "testInterface",
}

function wait_view:on_init(data)
    self:load_view("common/panel", "wait", parent)
    self.m_tips = self:get_child_by_name("content/Text", "Text")
    self.m_point = self:get_child_by_name("content/point")

    local rotation = utils.action.rotation_by.new(1, Vector3(0, 0, 360))
    local action = utils.action.repeat_forever.new(rotation)
    self:run_action(action, self.m_point)
end

function wait_view:on_uninit()

end

function wait_view:on_update(data)
    self:set_tips(data)
end

function wait_view:set_tips(tips)
    if tips == nil or tips == "" then
        utils.ui.set_visible(self.m_tips, false)
    else
        utils.ui.set_visible(self.m_tips, true)
    end
    self.m_tips.text = tips or ""
end

function wait_view:get_layer_name()
    return const.layer_name.layer_system
end

return wait_view