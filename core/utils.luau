[utils.luau]

local utils = {}

function utils.deepcopy(original)
    local copy
    if type(original) == "table" then
        copy = {}
        for key, value in original do
            copy[utils.deepcopy(key)] = utils.deepcopy(value)
        end
    else
        copy = original
    end
    return copy
end

function utils.merge(target, source)
    for key, value in source do
        if type(value) == "table" and type(target[key]) == "table" then
            utils.merge(target[key], value)
        else
            target[key] = value
        end
    end
    return target
end

function utils.debounce(callback, delay)
    local lastcall = 0
    return function(...)
        local currenttime = tick()
        if currenttime - lastcall >= delay then
            lastcall = currenttime
            callback(...)
        end
    end
end

function utils.throttle(callback, delay)
    local lastcall = 0
    return function(...)
        local currenttime = tick()
        if currenttime - lastcall >= delay then
            lastcall = currenttime
            callback(...)
        end
    end
end

function utils.once(callback)
    local called = false
    return function(...)
        if not called then
            called = true
            callback(...)
        end
    end
end

function utils.waitfor(object, property, timeout)
    local signal = Instance.new("BindableEvent")
    local starttime = tick()
    
    local connection
    connection = object:GetPropertyChangedSignal(property):Connect(function()
        signal:Fire(object[property])
        connection:Disconnect()
    end)
    
    local result = signal.Event:wait()
    signal:Destroy()
    
    return result
end

function utils.clamp(value, minimum, maximum)
    if value < minimum then return minimum end
    if value > maximum then return maximum end
    return value
end

function utils.lerp(a, b, t)
    return a + (b - a) * t
end

return utils
