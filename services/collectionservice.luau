[collectionservice.luau]

local tax = require(game.ServerScriptService.tax_framework)
local datastoreservice = require(game.ServerScriptService.datastoreservice)

local collectionservice = tax.service({
    name = "collectionservice",
    dependencies = { datastoreservice }
})

local coinrarity = {
    common = { rarity = 1, value = 10, color = Color3.fromRGB(200, 200, 200) },
    uncommon = { rarity = 2, value = 25, color = Color3.fromRGB(34, 139, 34) },
    rare = { rarity = 3, value = 100, color = Color3.fromRGB(0, 0, 255) },
    epic = { rarity = 4, value = 500, color = Color3.fromRGB(128, 0, 128) },
    legendary = { rarity = 5, value = 2500, color = Color3.fromRGB(255, 215, 0) },
    mythic = { rarity = 6, value = 10000, color = Color3.fromRGB(255, 69, 0) }
}

local availablecoins = {
    { id = 1, name = "bronze", rarity = "common" },
    { id = 2, name = "silver", rarity = "uncommon" },
    { id = 3, name = "gold", rarity = "rare" },
    { id = 4, name = "platinum", rarity = "epic" },
    { id = 5, name = "diamond", rarity = "legendary" },
    { id = 6, name = "emerald", rarity = "rare" },
    { id = 7, name = "ruby", rarity = "rare" },
    { id = 8, name = "sapphire", rarity = "epic" },
    { id = 9, name = "crystal", rarity = "legendary" },
    { id = 10, name = "celestial", rarity = "mythic" }
}

function collectionservice:init(datastoreservice)
    self.datastoreservice = datastoreservice
    self.playercollections = {}
    self.coincollected = tax.signal()
    self.collectioncomplete = tax.signal()
end

function collectionservice:loadplayercollection(userid)
    if self.playercollections[userid] then
        return self.playercollections[userid]
    end
    
    local playerdata = self.datastoreservice:loadplayerdata(userid)
    if playerdata and playerdata.collection then
        self.playercollections[userid] = playerdata.collection
        return playerdata.collection
    end
    
    local collection = {}
    for _, coin in availablecoins do
        collection[coin.id] = {
            coinid = coin.id,
            name = coin.name,
            rarity = coin.rarity,
            collected = false,
            collectedat = 0,
            count = 0
        }
    end
    
    self.playercollections[userid] = collection
    return collection
end

function collectionservice:addcointoollection(userid, coinid)
    local collection = self:loadplayercollection(userid)
    local coin = collection[coinid]
    
    if not coin then
        return false, "coin not found"
    end
    
    local wasalreadycollected = coin.collected
    coin.collected = true
    coin.count = coin.count + 1
    if coin.collectedat == 0 then
        coin.collectedat = tick()
    end
    
    local playerdata = self.datastoreservice:getcachedplayer(userid)
    if playerdata then
        playerdata.collection = collection
        playerdata.dirty = true
    end
    
    self.coincollected:fire(userid, coinid, coin.name, coin.rarity)
    
    if not wasalreadycollected and self:iscollectioncomplete(userid) then
        self.collectioncomplete:fire(userid)
    end
    
    return true, coin
end

function collectionservice:getcoin(userid, coinid)
    local collection = self:loadplayercollection(userid)
    return collection[coinid]
end

function collectionservice:getcollection(userid)
    return self:loadplayercollection(userid)
end

function collectionservice:getcollectionprogress(userid)
    local collection = self:loadplayercollection(userid)
    local collected = 0
    local total = 0
    
    for _, coin in collection do
        total = total + 1
        if coin.collected then
            collected = collected + 1
        end
    end
    
    return {
        collected = collected,
        total = total,
        percentage = (collected / total) * 100
    }
end

function collectionservice:iscollectioncomplete(userid)
    local collection = self:loadplayercollection(userid)
    for _, coin in collection do
        if not coin.collected then
            return false
        end
    end
    return true
end

function collectionservice:getcoincoinrarity(rarity)
    return coinrarity[rarity]
end

function collectionservice:getavailablecoins()
    return availablecoins
end

function collectionservice:getcoinrarity()
    return coinrarity
end

function collectionservice:resetsollection(userid)
    local collection = self:loadplayercollection(userid)
    for _, coin in collection do
        coin.collected = false
        coin.collectedat = 0
    end
    
    local playerdata = self.datastoreservice:getcachedplayer(userid)
    if playerdata then
        playerdata.collection = collection
        playerdata.dirty = true
    end
end

function collectionservice:destroy()
    table.clear(self.playercollections)
    self.coincollected:destroy()
    self.collectioncomplete:destroy()
end

return collectionservice
