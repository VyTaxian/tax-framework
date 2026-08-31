[tax-framework]

local tax = {}
tax.__index = tax

-- core modules
local signalmodule = require(script.core.signal)
local promisemodule = require(script.core.promise)
local containermodule = require(script.core.container)
local middlewaremodule = require(script.core.middleware)
local lifecyclemodule = require(script.core.lifecycle)
local utilsmodule = require(script.core.utils)

-- public api
function tax.signal()
    return signalmodule.new()
end

function tax.promise(resolver)
    return promisemodule.new(resolver)
end

function tax.service(config)
    local instance = containermodule.createservice(config)
    return instance
end

function tax.controller(config)
    local instance = containermodule.createcontroller(config)
    return instance
end

function tax.middleware(handler)
    return middlewaremodule.new(handler)
end

function tax.container()
    return containermodule.new()
end

function tax.lifecycle()
    return lifecyclemodule.new()
end

function tax.getservice(name)
    return containermodule.getservice(name)
end

function tax.getcontroller(name)
    return containermodule.getcontroller(name)
end

return tax
