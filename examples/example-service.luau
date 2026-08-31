[example-service.luau]

local tax = require(game.ServerScriptService.tax_framework)

local playerservice = tax.service({
    name = "playerservice"
})

function playerservice:init()
    self.players = {}
    self.playerjoined = tax.signal()
    self.playerleft = tax.signal()
    self.playerdead = tax.signal()
end

function playerservice:addplayer(player)
    self.players[player.UserId] = {
        userid = player.UserId,
        name = player.Name,
        joined = tick(),
        level = 1,
        experience = 0
    }
    self.playerjoined:fire(player)
end

function playerservice:removeplayer(player)
    if self.players[player.UserId] then
        self.playerleft:fire(player)
        self.players[player.UserId] = nil
    end
end

function playerservice:getplayer(userid)
    return self.players[userid]
end

function playerservice:addexperience(userid, amount)
    local playerdata = self.players[userid]
    if playerdata then
        playerdata.experience = playerdata.experience + amount
        if playerdata.experience >= 100 then
            playerdata.level = playerdata.level + 1
            playerdata.experience = 0
        end
    end
end

function playerservice:destroy()
    table.clear(self.players)
    self.playerjoined:destroy()
    self.playerleft:destroy()
    self.playerdead:destroy()
end

return playerservice
