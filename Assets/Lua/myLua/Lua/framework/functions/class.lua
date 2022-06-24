
function class(className, ...)
    local cls = { __cname = className }

    local supers = { ... }
    for _, super in ipairs(supers) do
        local super_type = type(super)
        if super_type == "function" then
            assert(cls.__create == nil, "只能有1个 create 方法")
            cls.__create = super
        elseif super_type == "table" then
            cls.__supers = cls.__supers or {}
            cls.__supers[#cls.__supers + 1] = super
            if not cls.super then
                -- set first super pure lua class as class.super
                cls.super = super
            end
        end
    end
    
    if not cls.__supers or #cls.__supers == 1 then
        setmetatable(cls, {__index = cls.super})
    else
        setmetatable(cls, {__index = function(tbl, key)
            local supers = cls.__supers
            for i = 1, #supers do
                local super = supers[i]
                if super[key] then return super[key] end
            end
        end})
    end

    -- 属性监听器,可以不用
    cls.__index = function(self,k)
        if type(cls[k]) == "table" and cls[k].proprety == true then
            -- local function get(self)
            --     local value = cls[k].get(self)
            --     if type(value) == "table" then
            --          子属性也需要递归处理
            --         local x = {}
            --         setmetatable(x, {__index = value, __newindex = function(self, _k, v)
            --             g_log.w( className .. " 的属性:[" .. k .. "] 为只读，子属性:[" .. _k .. "]亦不可修改，或需要通过接口修改")
            --         end})
            --         return x
            --     end
            --     return value
            -- end
            -- return get(self)
            return cls[k].get(self, k)
        else
            return cls[k]
        end
    end
    cls.__newindex = function(self, k, v)
        if type(cls[k]) == "table" and cls[k].proprety == true then
            if cls[k].set then
                return cls[k].set(self, k, v)
            else
                g_log.w( className .. " 的属性:[" .. k .. "] 未提供写方法，或需要通过接口修改")
            end
        else
            rawset(self, k, v)
        end
    end

    cls.__tostring = function(self)
        return string.format("{class obj : %s  %s}", tostring(className), self.__table_address)
    end
    
    if cls.ctor == nil then
        cls.ctor = function() end
    end

    if cls.dtor == nil then
        cls.dtor = function() end
    end
    
    cls.new = function(...)
        local instance
        if rawget(cls, "__create") then
            instance = cls.__create(...)
        else
            instance = {}
        end
        instance.__table_address = tostring(instance)
        setmetatable(instance, cls)
        instance.class = cls
        instance:ctor(...)
        return instance
    end

    --在对象调用构造函数前，调用pre_ctor 做些预处理
    cls.preset_new = function(pre_ctor, ...)
        local instance
        if rawget(cls, "__create") then
            instance = cls.__create(...)
        else
            instance = {}
        end
        instance.__table_address = tostring(instance)
        setmetatable(instance, cls)
        instance.class = cls

        if type(pre_ctor) ~= "function" then
            g_log.e("please pass a valid function!!!")
        else
            pre_ctor(instance, ...)
        end
         
        instance:ctor(...)
        return instance
    end

    cls.create = function(_, ...)
        return cls.new(...)
    end

    cls.extend = function(target, ...)
        local instance

        if rawget(cls, "__create") then
            instance = cls.__create(...)
        else
            instance = {}
        end
        instance.__table_address = tostring(instance)
        setmetatable(instance, cls)
        instance.class = cls

        if type(target) == "function" then
            target = target(instance)
        end
        
        instance.m_uiroot = target
        instance:ctor(...)

        return instance
    end

    return cls
end