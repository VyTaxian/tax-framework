[example-controller.luau]

local tax = require(game.ReplicatedStorage.tax_framework)
local playerservice = require(game.ServerScriptService.playerservice)

local playercontroller = tax.controller({
    name = "playercontroller",
    dependencies = { playerservice }
})

function playercontroller:init(playerservice)
    self.playerservice = playerservice
    self.onplayerjoinedconnection = nil
    self.onplayerleftconnection = nil
    self:setupconnections()
end

function playercontroller:setupconnections()
    self.onplayerjoinedconnection = self.playerservice.playerjoined:connect(function(player)
        print(player.Name .. " joined the game")
        self:onplayerjoined(player)
    end)
    
    self.onplayerleftconnection = self.playerservice.playerleft:connect(function(player)
        print(player.Name .. " left the game")
        self:onplayerleft(player)
    end)
end

function playercontroller:onplayerjoined(player)
    print("Setting up player data for " .. player.Name)
    self.playerservice:addplayer(player)
end

function playercontroller:onplayerleft(player)
    print("Cleaning up player data for " .. player.Name)
    self.playerservice:removeplayer(player)
end

function playercontroller:destroy()
    if self.onplayerjoinedconnection then
        self.onplayerjoinedconnection:disconnect()
    end
    if self.onplayerleftconnection then
        self.onplayerleftconnection:disconnect()
    end
end

return playercontroller
