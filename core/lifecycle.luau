[lifecycle.luau]

local lifecycle = {}
lifecycle.__index = lifecycle

function lifecycle.new()
    local self = setmetatable({}, lifecycle)
    self.hooksmap = {
        init = {},
        ready = {},
        update = {},
        lateupdate = {},
        destroy = {}
    }
    self.active = true
    return self
end

function lifecycle:register(hookname, callback, priority)
    priority = priority or 0
    if not self.hooksmap[hookname] then
        self.hooksmap[hookname] = {}
    end
    
    table.insert(self.hooksmap[hookname], {
        callback = callback,
        priority = priority
    })
    
    table.sort(self.hooksmap[hookname], function(a, b)
        return a.priority > b.priority
    end)
end

function lifecycle:oninit(callback, priority)
    self:register("init", callback, priority)
end

function lifecycle:onready(callback, priority)
    self:register("ready", callback, priority)
end

function lifecycle:onupdate(callback, priority)
    self:register("update", callback, priority)
end

function lifecycle:onlateupdate(callback, priority)
    self:register("lateupdate", callback, priority)
end

function lifecycle:ondestroy(callback, priority)
    self:register("destroy", callback, priority)
end

function lifecycle:executehooks(hookname)
    if not self.hooksmap[hookname] then return end
    for _, hook in self.hooksmap[hookname] do
        local success, err = pcall(hook.callback)
        if not success then
            warn("Lifecycle hook error (" .. hookname .. "): " .. tostring(err))
        end
    end
end

function lifecycle:init()
    self:executehooks("init")
end

function lifecycle:ready()
    self:executehooks("ready")
end

function lifecycle:update(deltatime)
    self:executehooks("update")
end

function lifecycle:lateupdate(deltatime)
    self:executehooks("lateupdate")
end

function lifecycle:destroy()
    self:executehooks("destroy")
    self.active = false
end

return lifecycle
