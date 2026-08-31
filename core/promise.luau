[promise.luau]

local promise = {}
promise.__index = promise

local pending = "pending"
local resolved = "resolved"
local rejected = "rejected"

function promise.new(resolver: (any, any) -> ()): promise
    local self = setmetatable({}, promise)
    self.status = pending
    self.value = nil
    self.reason = nil
    self.callbacks = { success = {}, error = {}, finally = {} }
    
    local function resolve(value)
        if self.status ~= pending then return end
        self.status = resolved
        self.value = value
        self:executecallbacks("success")
    end
    
    local function reject(reason)
        if self.status ~= pending then return end
        self.status = rejected
        self.reason = reason
        self:executecallbacks("error")
    end
    
    task.spawn(function()
        local success, result = pcall(resolver, resolve, reject)
        if not success and self.status == pending then
            reject(result)
        end
    end)
    
    return self
end

function promise:executecallbacks(callbacktype: string)
    if callbacktype == "success" then
        for _, callback in self.callbacks.success do
            task.spawn(callback, self.value)
        end
    elseif callbacktype == "error" then
        for _, callback in self.callbacks.error do
            task.spawn(callback, self.reason)
        end
    end
    
    for _, callback in self.callbacks.finally do
        task.spawn(callback, self.status, self.value or self.reason)
    end
end

function promise:then(onsuccess, onerror)
    return promise.new(function(resolve, reject)
        local function handleresult()
            if self.status == resolved then
                if onsuccess then
                    local success, result = pcall(onsuccess, self.value)
                    if success then
                        resolve(result)
                    else
                        reject(result)
                    end
                else
                    resolve(self.value)
                end
            elseif self.status == rejected then
                if onerror then
                    local success, result = pcall(onerror, self.reason)
                    if success then
                        resolve(result)
                    else
                        reject(result)
                    end
                else
                    reject(self.reason)
                end
            end
        end
        
        if self.status == pending then
            table.insert(self.callbacks.success, function(value)
                self.value = value
                handleresult()
            end)
            table.insert(self.callbacks.error, function(reason)
                self.reason = reason
                handleresult()
            end)
        else
            task.spawn(handleresult)
        end
    end)
end

function promise:catch(onerror)
    return self:then(nil, onerror)
end

function promise:finally(callback)
    return promise.new(function(resolve, reject)
        local function handlefinally()
            task.spawn(callback)
            if self.status == resolved then
                resolve(self.value)
            else
                reject(self.reason)
            end
        end
        
        if self.status == pending then
            table.insert(self.callbacks.finally, handlefinally)
        else
            task.spawn(handlefinally)
        end
    end)
end

function promise:await()
    local thread = coroutine.running()
    self:then(
        function(value)
            task.spawn(thread, true, value)
        end,
        function(reason)
            task.spawn(thread, false, reason)
        end
    )
    return coroutine.yield()
end

function promise.all(promises: {promise}): promise
    return promise.new(function(resolve, reject)
        local results = {}
        local completed = 0
        
        if #promises == 0 then
            resolve({})
            return
        end
        
        for i, p in promises do
            p:then(
                function(value)
                    results[i] = value
                    completed += 1
                    if completed == #promises then
                        resolve(results)
                    end
                end,
                reject
            )
        end
    end)
end

function promise.race(promises: {promise}): promise
    return promise.new(function(resolve, reject)
        for _, p in promises do
            p:then(resolve, reject)
        end
    end)
end

return promise
