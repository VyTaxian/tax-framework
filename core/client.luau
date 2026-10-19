local Client = {}
Client.__index = Client

local serviceRegistry = {}
local controllerRegistry = {}

local function normalizeName(definition)
    if typeof(definition) ~= "table" then
        return "Unnamed"
    end

    return definition.Name or definition.name or "Unnamed"
end

local function runLifecycle(instance, lifecycleName)
    if type(instance) ~= "table" then
        return
    end

    local hook = instance[lifecycleName] or instance[lifecycleName:lower()]
    if type(hook) == "function" then
        local success, result = xpcall(function()
            return hook(instance)
        end, debug.traceback)

        if not success then
            warn((lifecycleName or "hook") .. " failed: " .. tostring(result))
        end
    end
end

function Client.CreateService(definition)
    local service = setmetatable({
        Name = normalizeName(definition),
        Client = definition and definition.Client or {},
        Service = definition and definition.Service or definition or {},
        Started = false,
    }, Client)

    serviceRegistry[service.Name] = service
    return service
end

function Client.CreateController(definition)
    local controller = setmetatable({
        Name = normalizeName(definition),
        Client = definition and definition.Client or {},
        Controller = definition and definition.Controller or definition or {},
        Started = false,
    }, Client)

    controllerRegistry[controller.Name] = controller
    return controller
end

function Client.new(options)
    local self = setmetatable({}, Client)
    self.options = options or {}
    self.services = {}
    self.controllers = {}

    for _, serviceDefinition in ipairs(self.options.Services or self.options.services or {}) do
        local service = Client.CreateService(serviceDefinition)
        self.services[service.Name] = service
    end

    for _, controllerDefinition in ipairs(self.options.Controllers or self.options.controllers or {}) do
        local controller = Client.CreateController(controllerDefinition)
        self.controllers[controller.Name] = controller
    end

    return self
end

function Client:RegisterService(definition)
    local service = Client.CreateService(definition)
    self.services[service.Name] = service
    return service
end

function Client:RegisterController(definition)
    local controller = Client.CreateController(definition)
    self.controllers[controller.Name] = controller
    return controller
end

function Client:Start()
    for _, service in pairs(self.services) do
        if service and not service.Started then
            runLifecycle(service.Service, "Init")
            runLifecycle(service.Service, "Start")
            service.Started = true
        end
    end

    for _, controller in pairs(self.controllers) do
        if controller and not controller.Started then
            runLifecycle(controller.Controller, "Init")
            runLifecycle(controller.Controller, "Start")
            controller.Started = true
        end
    end

    return self
end

function Client.GetService(name)
    return serviceRegistry[name]
end

function Client.GetController(name)
    return controllerRegistry[name]
end

return Client
