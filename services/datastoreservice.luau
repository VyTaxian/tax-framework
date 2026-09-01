[datastoreservice.luau]

local tax = require(game.ServerScriptService.tax_framework)
local datastore = game:GetService("DataStoreService")

local datastoreservice = tax.service({
    name = "datastoreservice"
})

local maxretries = 3
local retrydelay = 1

function datastoreservice:init()
    self.stores = {}
    self.playercache = {}
    self.autosaveinterval = 60
    self.autosavetimer = 0
end

function datastoreservice:getstore(storename)
    if not self.stores[storename] then
        local success, store = pcall(function()
            return datastore:GetDataStore(storename)
        end)
        if success then
            self.stores[storename] = store
        else
            warn("Failed to get datastore: " .. storename)
            return nil
        end
    end
    return self.stores[storename]
end

function datastoreservice:set(storename, key, value)
    local store = self:getstore(storename)
    if not store then return false end
    
    for attempt = 1, maxretries do
        local success, err = pcall(function()
            store:SetAsync(key, value)
        end)
        if success then
            return true
        elseif attempt < maxretries then
            task.wait(retrydelay)
        end
    end
    
    warn("Failed to set " .. key .. " in " .. storename)
    return false
end

function datastoreservice:get(storename, key)
    local store = self:getstore(storename)
    if not store then return nil end
    
    for attempt = 1, maxretries do
        local success, value = pcall(function()
            return store:GetAsync(key)
        end)
        if success then
            return value
        elseif attempt < maxretries then
            task.wait(retrydelay)
        end
    end
    
    warn("Failed to get " .. key .. " from " .. storename)
    return nil
end

function datastoreservice:increment(storename, key, amount)
    local store = self:getstore(storename)
    if not store then return false end
    
    for attempt = 1, maxretries do
        local success, err = pcall(function()
            store:IncrementAsync(key, amount)
        end)
        if success then
            return true
        elseif attempt < maxretries then
            task.wait(retrydelay)
        end
    end
    
    warn("Failed to increment " .. key .. " in " .. storename)
    return false
end

function datastoreservice:playercache(userid, data)
    self.playercache[userid] = data
end

function datastoreservice:getcachedplayer(userid)
    return self.playercache[userid]
end

function datastoreservice:removecachedplayer(userid)
    self.playercache[userid] = nil
end

function datastoreservice:update(deltatime)
    self.autosavetimer = self.autosavetimer + deltatime
    if self.autosavetimer >= self.autosaveinterval then
        self.autosavetimer = 0
        self:autosaveall()
    end
end

function datastoreservice:autosaveall()
    for userid, playerdata in self.playercache do
        if playerdata and playerdata.dirty then
            self:saveplayerdata(userid, playerdata)
        end
    end
end

function datastoreservice:saveplayerdata(userid, playerdata)
    local success = self:set("playerdata", tostring(userid), playerdata)
    if success then
        playerdata.dirty = false
    end
    return success
end

function datastoreservice:loadplayerdata(userid)
    local data = self:get("playerdata", tostring(userid))
    if data then
        data.dirty = false
        self:playercache(userid, data)
    end
    return data
end

function datastoreservice:destroy()
    self:autosaveall()
    table.clear(self.stores)
    table.clear(self.playercache)
end

return datastoreservice
