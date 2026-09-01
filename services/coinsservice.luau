[coinsservice.luau]

local tax = require(game.ServerScriptService.tax_framework)
local datastoreservice = require(game.ServerScriptService.datastoreservice)

local coinsservice = tax.service({
    name = "coinsservice",
    dependencies = { datastoreservice }
})

function coinsservice:init(datastoreservice)
    self.datastoreservice = datastoreservice
    self.playercoins = {}
    self.coingupdated = tax.signal()
    self.coinsmilestones = { 100, 500, 1000, 5000, 10000, 50000, 100000 }
end

function coinsservice:loadplayercoins(userid)
    if self.playercoins[userid] then
        return self.playercoins[userid]
    end
    
    local playerdata = self.datastoreservice:loadplayerdata(userid)
    if playerdata and playerdata.coins then
        self.playercoins[userid] = playerdata.coins
        return playerdata.coins
    end
    
    self.playercoins[userid] = 0
    return 0
end

function coinsservice:addcoins(userid, amount)
    if amount <= 0 then return false end
    
    local currentcoins = self.playercoins[userid] or 0
    self.playercoins[userid] = currentcoins + amount
    
    local playerdata = self.datastoreservice:getcachedplayer(userid)
    if playerdata then
        playerdata.coins = self.playercoins[userid]
        playerdata.dirty = true
    end
    
    self.coingupdated:fire(userid, self.playercoins[userid], amount)
    return true
end

function coinsservice:removecoins(userid, amount)
    if amount <= 0 then return false end
    
    local currentcoins = self.playercoins[userid] or 0
    if currentcoins < amount then
        return false
    end
    
    self.playercoins[userid] = currentcoins - amount
    
    local playerdata = self.datastoreservice:getcachedplayer(userid)
    if playerdata then
        playerdata.coins = self.playercoins[userid]
        playerdata.dirty = true
    end
    
    self.coingupdated:fire(userid, self.playercoins[userid], -amount)
    return true
end

function coinsservice:getcoins(userid)
    return self.playercoins[userid] or 0
end

function coinsservice:hascoins(userid, amount)
    return (self.playercoins[userid] or 0) >= amount
end

function coinsservice:resetcoins(userid)
    self.playercoins[userid] = 0
    
    local playerdata = self.datastoreservice:getcachedplayer(userid)
    if playerdata then
        playerdata.coins = 0
        playerdata.dirty = true
    end
    
    self.coingupdated:fire(userid, 0, 0)
end

function coinsservice:setcoins(userid, amount)
    self.playercoins[userid] = amount
    
    local playerdata = self.datastoreservice:getcachedplayer(userid)
    if playerdata then
        playerdata.coins = amount
        playerdata.dirty = true
    end
    
    self.coingupdated:fire(userid, amount, 0)
end

function coinsservice:destroy()
    table.clear(self.playercoins)
    self.coingupdated:destroy()
end

return coinsservice
