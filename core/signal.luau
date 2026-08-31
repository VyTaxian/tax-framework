[signal.luau]

local signal = {}
signal.__index = signal

type callback = (any) -> ()

function signal.new(): signal
    local self = setmetatable({}, signal)
    self.connections = {}
    self.connectingindex = 0
    return self
end

function signal:connect(callback: callback): connection
    local connection = {
        connected = true,
        signal = self,
        callback = callback,
        index = self.connectingindex
    }
    self.connectingindex += 1
    self.connections[connection.index] = connection
    
    function connection:disconnect()
        self.connected = false
        self.signal.connections[self.index] = nil
    end
    
    return connection
end

function signal:once(callback: callback): connection
    local connection
    connection = self:connect(function(...)
        if connection.connected then
            connection:disconnect()
            callback(...)
        end
    end)
    return connection
end

function signal:wait()
    local thread = coroutine.running()
    local connection
    connection = self:once(function(...)
        task.spawn(thread, ...)
    end)
    return coroutine.yield()
end

function signal:fire(...)
    for index, connection in self.connections do
        if connection.connected then
            task.spawn(connection.callback, ...)
        end
    end
end

function signal:firelocal(...)
    for index, connection in self.connections do
        if connection.connected then
            connection.callback(...)
        end
    end
end

function signal:destroyconnection(index: number)
    self.connections[index] = nil
end

function signal:destroy()
    table.clear(self.connections)
end

return signal
