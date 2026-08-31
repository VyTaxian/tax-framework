[container.luau]

local container = {}
container.__index = container

local servicecache = {}
local controllercache = {}
local dependencymap = {}

local function resolvenames(dependencies)
    if not dependencies then return {} end
    local resolved = {}
    for _, dep in dependencies do
        if typeof(dep) == "table" and dep.name then
            table.insert(resolved, dep)
        end
    end
    return resolved
end

local function injectdependencies(instance, dependencies)
    for _, dep in dependencies do
        if dep.name and instance.dependencies and instance.dependencies[dep.name] then
            instance.dependencies[dep.name] = dep
        end
    end
end

function container.createservice(config)
    if servicecache[config.name] then
        return servicecache[config.name]
    end
    
    local service = setmetatable({}, config)
    service.name = config.name
    service.type = "service"
    service.dependencies = resolvenames(config.dependencies or {})
    service.initialized = false
    service.destroyed = false
    
    servicecache[config.name] = service
    dependencymap[config.name] = service
    
    if service.init then
        task.spawn(function()
            local success, err = pcall(service.init, service, unpack(service.dependencies))
            if success then
                service.initialized = true
            else
                warn("Service " .. config.name .. " initialization error: " .. tostring(err))
            end
        end)
    end
    
    return service
end

function container.createcontroller(config)
    if controllercache[config.name] then
        return controllercache[config.name]
    end
    
    local controller = setmetatable({}, config)
    controller.name = config.name
    controller.type = "controller"
    controller.dependencies = resolvenames(config.dependencies or {})
    controller.initialized = false
    controller.destroyed = false
    
    controllercache[config.name] = controller
    
    if controller.init then
        task.spawn(function()
            local success, err = pcall(controller.init, controller, unpack(controller.dependencies))
            if success then
                controller.initialized = true
            else
                warn("Controller " .. config.name .. " initialization error: " .. tostring(err))
            end
        end)
    end
    
    return controller
end

function container.getservice(name)
    return servicecache[name]
end

function container.getcontroller(name)
    return controllercache[name]
end

function container.getdependency(name)
    return dependencymap[name]
end

function container.new()
    local self = setmetatable({}, container)
    self.services = {}
    self.controllers = {}
    return self
end

function container:registerservice(config)
    local service = container.createservice(config)
    self.services[config.name] = service
    return service
end

function container:registercontroller(config)
    local controller = container.createcontroller(config)
    self.controllers[config.name] = controller
    return controller
end

function container:cleanup()
    for name, service in self.services do
        if service.destroy then
            pcall(service.destroy, service)
        end
        servicecache[name] = nil
    end
    
    for name, controller in self.controllers do
        if controller.destroy then
            pcall(controller.destroy, controller)
        end
        controllercache[name] = nil
    end
end

return container
