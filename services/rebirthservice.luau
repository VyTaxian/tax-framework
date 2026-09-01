[rebirthservice.luau]

local tax = require(game.ServerScriptService.tax_framework)
local datastoreservice = require(game.ServerScriptService.datastoreservice)
local coinsservice = require(game.ServerScriptService.coinsservice)

local rebirthservice = tax.service({
    name = "rebirthservice",
    dependencies = { datastoreservice, coinsservice }
})

local rebirthcosts = {
    { level = 1, cost = 1000, multiplier = 1.5 },
    { level = 2, cost = 5000, multiplier = 2.0 },
    { level = 3, cost = 25000, multiplier = 2.5 },
    { level = 4, cost = 100000, multiplier = 3.0 },
    { level = 5, cost = 500000, multiplier = 4.0 }
}

function rebirthservice:init(datastoreservice, coinsservice)
    self.datastoreservice = datastoreservice
    self.coinsservice = coinsservice
    self.playerrebirths = {}
    self.rebirthcompleted = tax.signal()
    self.rebirthavailable = tax.signal()
end

function rebirthservice:loadplayerrebirths(userid)
    if self.playerrebirths[userid] then
        return self.playerrebirths[userid]
    end
    
    local playerdata = self.datastoreservice:loadplayerdata(userid)
    if playerdata and playerdata.rebirths then
        self.playerrebirths[userid] = playerdata.rebirths
        return playerdata.rebirths
    end
    
    self.playerrebirths[userid] = {
        level = 0,
        totalrebirths = 0,
        lasrebirthtime = 0,
        rebirthbonus = 1.0
    }
    return self.playerrebirths[userid]
end

function rebirthservice:getrebirthcost(rebithlevel)
    for _, rebirth in rebirthcosts do
        if rebirth.level == rebithlevel then
            return rebirth.cost
        end
    end
    return rebirthcosts[#rebirthcosts].cost * (rebithlevel - #rebirthcosts)
end

function rebirthservice:getrebirthdata(userid)
    return self.playerrebirths[userid] or self:loadplayerrebirths(userid)
end

function rebirthservice:canrebirth(userid, requiredcoins)
    local rebirthdata = self:getrebirthdata(userid)
    local coins = self.coinsservice:getcoins(userid)
    return coins >= requiredcoins
end

function rebirthservice:rebirth(userid)
    local rebirthdata = self:getrebirthdata(userid)
    local nextlevel = rebirthdata.level + 1
    local rebirthcost = self:getrebirthcost(nextlevel)
    
    if not self:canrebirth(userid, rebirthcost) then
        return false, "not enough coins"
    end
    
    local success = self.coinsservice:removecoins(userid, rebirthcost)
    if not success then
        return false, "failed to remove coins"
    end
    
    rebirthdata.level = nextlevel
    rebirthdata.totalrebirths = rebirthdata.totalrebirths + 1
    rebirthdata.lasrebirthtime = tick()
    rebirthdata.rebirthbonus = self:calculaterebirthbonus(nextlevel)
    
    local playerdata = self.datastoreservice:getcachedplayer(userid)
    if playerdata then
        playerdata.rebirths = rebirthdata
        playerdata.dirty = true
    end
    
    self.rebirthcompleted:fire(userid, nextlevel, rebirthcost)
    return true, rebirthdata
end

function rebirthservice:calculaterebirthbonus(level)
    local bonus = 1.0
    for i = 1, level do
        if i <= #rebirthcosts then
            bonus = bonus * rebirthcosts[i].multiplier
        else
            bonus = bonus * 1.5
        end
    end
    return bonus
end

function rebirthservice:getrebirthbonus(userid)
    local rebirthdata = self:getrebirthdata(userid)
    return rebirthdata.rebirthbonus or 1.0
end

function rebirthservice:getnextrebirthcost(userid)
    local rebirthdata = self:getrebirthdata(userid)
    return self:getrebirthcost(rebirthdata.level + 1)
end

function rebirthservice:getrebirthinfo(userid)
    local rebirthdata = self:getrebirthdata(userid)
    local nextcost = self:getnextrebirthcost(userid)
    local coins = self.coinsservice:getcoins(userid)
    
    return {
        currentlevel = rebirthdata.level,
        totalrebirths = rebirthdata.totalrebirths,
        bonus = rebirthdata.rebirthbonus,
        nextcost = nextcost,
        hascoins = coins >= nextcost,
        currentcoins = coins
    }
end

function rebirthservice:destroy()
    table.clear(self.playerrebirths)
    self.rebirthcompleted:destroy()
    self.rebirthavailable:destroy()
end

return rebirthservice
