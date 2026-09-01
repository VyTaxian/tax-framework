[coingamecontroller.luau]

local tax = require(game.ReplicatedStorage.tax_framework)
local datastoreservice = require(game.ServerScriptService.datastoreservice)
local coinsservice = require(game.ServerScriptService.coinsservice)
local rebirthservice = require(game.ServerScriptService.rebirthservice)
local collectionservice = require(game.ServerScriptService.collectionservice)

local coingamecontroller = tax.controller({
    name = "coingamecontroller",
    dependencies = { datastoreservice, coinsservice, rebirthservice, collectionservice }
})

function coingamecontroller:init(datastoreservice, coinsservice, rebirthservice, collectionservice)
    self.datastoreservice = datastoreservice
    self.coinsservice = coinsservice
    self.rebirthservice = rebirthservice
    self.collectionservice = collectionservice
    self.playerjoined = tax.signal()
    self.playerleft = tax.signal()
end

function coingamecontroller:onplayerjoined(player)
    print("Player " .. player.Name .. " joined")
    
    local playerdata = {
        userid = player.UserId,
        username = player.Name,
        jointime = tick(),
        coins = 0,
        rebirths = {
            level = 0,
            totalrebirths = 0,
            lasrebirthtime = 0,
            rebirthbonus = 1.0
        },
        collection = {},
        dirty = false
    }
    
    self.datastoreservice:playercache(player.UserId, playerdata)
    self.coinsservice:loadplayercoins(player.UserId)
    self.rebirthservice:loadplayerrebirths(player.UserId)
    self.collectionservice:loadplayercollection(player.UserId)
    
    self.playerjoined:fire(player)
end

function coingamecontroller:onplayerleft(player)
    print("Player " .. player.Name .. " left")
    
    local playerdata = self.datastoreservice:getcachedplayer(player.UserId)
    if playerdata then
        self.datastoreservice:saveplayerdata(player.UserId, playerdata)
    end
    
    self.datastoreservice:removecachedplayer(player.UserId)
    self.playerleft:fire(player)
end

function coingamecontroller:addcoinstoiplayer(player, amount)
    local success = self.coinsservice:addcoins(player.UserId, amount)
    return success
end

function coingamecontroller:removecoinsfromplayer(player, amount)
    local success = self.coinsservice:removecoins(player.UserId, amount)
    return success
end

function coingamecontroller:rebirtiplayer(player)
    local success, result = self.rebirthservice:rebirth(player.UserId)
    return success, result
end

function coingamecontroller:addcointocollection(player, coinid)
    local success, coin = self.collectionservice:addcointoollection(player.UserId, coinid)
    return success, coin
end

function coingamecontroller:getplayerstats(player)
    local coins = self.coinsservice:getcoins(player.UserId)
    local rebirthinfo = self.rebirthservice:getrebirthinfo(player.UserId)
    local collectionprogress = self.collectionservice:getcollectionprogress(player.UserId)
    
    return {
        coins = coins,
        rebirth = rebirthinfo,
        collection = collectionprogress
    }
end

function coingamecontroller:destroy()
    self.playerjoined:destroy()
    self.playerleft:destroy()
end

return coingamecontroller
