[coin-game-setup.luau]

local tax = require(game.ServerScriptService.tax_framework)
local datastoreservice = require(game.ServerScriptService.datastoreservice)
local coinsservice = require(game.ServerScriptService.coinsservice)
local rebirthservice = require(game.ServerScriptService.rebirthservice)
local collectionservice = require(game.ServerScriptService.collectionservice)
local coingamecontroller = require(game.ServerScriptService.coingamecontroller)

local gamemanager = {}

function gamemanager:initialize()
    print("Initializing coin game system")
    
    datastoreservice:init()
    coinsservice:init(datastoreservice)
    rebirthservice:init(datastoreservice, coinsservice)
    collectionservice:init(datastoreservice)
    coingamecontroller:init(datastoreservice, coinsservice, rebirthservice, collectionservice)
    
    self:setupevents()
end

function gamemanager:setupevents()
    local players = game:GetService("Players")
    
    players.PlayerAdded:Connect(function(player)
        coingamecontroller:onplayerjoined(player)
    end)
    
    players.PlayerRemoving:Connect(function(player)
        coingamecontroller:onplayerleft(player)
    end)
    
    coinsservice.coingupdated:connect(function(userid, totalcoins, change)
        print("Player " .. userid .. " now has " .. totalcoins .. " coins (" .. change .. ")")
    end)
    
    rebirthservice.rebirthcompleted:connect(function(userid, level, cost)
        print("Player " .. userid .. " reached rebirth level " .. level .. " for " .. cost .. " coins")
    end)
    
    collectionservice.coincollected:connect(function(userid, coinid, coinname, rarity)
        print("Player " .. userid .. " collected " .. coinname .. " (" .. rarity .. ")")
    end)
    
    collectionservice.collectioncomplete:connect(function(userid)
        print("Player " .. userid .. " completed the collection!")
    end)
end

function gamemanager:addcointoiplayer(player, amount)
    return coingamecontroller:addcoinstoiplayer(player, amount)
end

function gamemanager:removecoinsfromplayer(player, amount)
    return coingamecontroller:removecoinsfromplayer(player, amount)
end

function gamemanager:rebirtiplayer(player)
    return coingamecontroller:rebirtiplayer(player)
end

function gamemanager:addcointocollection(player, coinid)
    return coingamecontroller:addcointocollection(player, coinid)
end

function gamemanager:getplayerstats(player)
    return coingamecontroller:getplayerstats(player)
end

function gamemanager:shutdown()
    print("Shutting down coin game system")
    datastoreservice:destroy()
    coinsservice:destroy()
    rebirthservice:destroy()
    collectionservice:destroy()
    coingamecontroller:destroy()
end

return gamemanager
