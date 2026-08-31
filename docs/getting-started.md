# Getting Started with Tax Framework

## Installation

1. Clone or download the tax-framework repository
2. Place it in your game's ServerScriptService or ReplicatedStorage
3. Require it in your scripts

```lua
local tax = require(game.ServerScriptService.tax_framework)
```

## Basic Setup

### Creating a Service

Services are singleton instances that handle game logic and utilities.

```lua
local tax = require(game.ServerScriptService.tax_framework)

local playerservice = tax.service({
    name = "playerservice"
})

function playerservice:init()
    print("Player service initialized")
    self.players = {}
end

function playerservice:addplayer(player)
    self.players[player.UserId] = player
end

function playerservice:getplayer(userid)
    return self.players[userid]
end

function playerservice:destroy()
    print("Player service destroyed")
    table.clear(self.players)
end

return playerservice
```

### Creating a Controller

Controllers handle client-side logic and can depend on services.

```lua
local tax = require(game.ReplicatedStorage.tax_framework)
local playerservice = require(script.Parent.playerservice)

local playercontroller = tax.controller({
    name = "playercontroller",
    dependencies = { playerservice }
})

function playercontroller:init(playerservice)
    self.playerservice = playerservice
    self:setupplayer()
end

function playercontroller:setupplayer()
    print("Setting up player")
end

function playercontroller:destroy()
    print("Player controller destroyed")
end

return playercontroller
```

## Dependency Injection

Dependencies are automatically resolved and injected into your services and controllers.

```lua
local tax = require(game.ServerScriptService.tax_framework)

local configservice = tax.service({ name = "configservice" })
local databaseservice = tax.service({
    name = "databaseservice",
    dependencies = { configservice }
})

function databaseservice:init(configservice)
    self.config = configservice
    self:connect()
end

function databaseservice:connect()
    print("Connecting with config:", self.config.name)
end
```

## Signals

Signals provide a way to communicate between services without tight coupling.

```lua
local tax = require(game.ServerScriptService.tax_framework)

local playerservice = tax.service({ name = "playerservice" })

function playerservice:init()
    self.playerjoined = tax.signal()
    self.playerleft = tax.signal()
end

function playerservice:playerjoinedevent(player)
    self.playerjoined:fire(player)
end

-- Elsewhere in your code
local connection = playerservice.playerjoined:connect(function(player)
    print(player.Name .. " joined!")
end)

-- Or listen once
local connection = playerservice.playerjoined:once(function(player)
    print(player.Name .. " joined for the first time!")
end)

-- Wait for next signal
local player = playerservice.playerjoined:wait()
```

## Promises

Promises handle asynchronous operations.

```lua
local tax = require(game.ServerScriptService.tax_framework)

local function fetchdata(userid)
    return tax.promise(function(resolve, reject)
        task.wait(1)
        if userid > 0 then
            resolve({ id = userid, name = "Player" })
        else
            reject("Invalid user id")
        end
    end)
end

-- Using then/catch
fetchdata(123)
    :then(function(data)
        print("Data:", data)
    end)
    :catch(function(error)
        print("Error:", error)
    end)

-- Using await (coroutine)
local success, result = fetchdata(456):await()
if success then
    print("Result:", result)
else
    print("Error:", result)
end
```

## Middleware

Middleware processes requests through a chain of handlers.

```lua
local tax = require(game.ServerScriptService.tax_framework)

local loggingmiddleware = tax.middleware(function(request, response, next)
    print("Request received:", request.path)
    next()
    print("Response sent")
end)

local authenticationmiddleware = tax.middleware(function(request, response, next)
    if request.token then
        print("Authenticated")
        next()
    else
        response.error = "Unauthorized"
    end
end)

local pipeline = loggingmiddleware:chain({ authenticationmiddleware })

local request = { path = "/api/players", token = "abc123" }
local response = {}
pipeline:process(request, response)
```

## Lifecycle Hooks

Manage initialization, updates, and cleanup.

```lua
local tax = require(game.ServerScriptService.tax_framework)

local gameservice = tax.service({ name = "gameservice" })
local lifecycle = tax.lifecycle()

lifecycle:oninit(function()
    print("Game initializing")
    gameservice:init()
end, 10)  -- priority 10

lifecycle:onready(function()
    print("Game ready")
end, 5)

lifecycle:onupdate(function()
    -- Called each update cycle
end)

lifecycle:ondestroy(function()
    print("Game shutting down")
end)

lifecycle:init()
lifecycle:ready()

while lifecycle.active do
    lifecycle:update()
    task.wait()
end

lifecycle:destroy()
```

## Complete Example

```lua
local tax = require(game.ServerScriptService.tax_framework)

-- Services
local configservice = tax.service({
    name = "configservice"
})

function configservice:init()
    self.maxplayers = 100
    self.difficulty = "normal"
end

local playerservice = tax.service({
    name = "playerservice",
    dependencies = { configservice }
})

function playerservice:init(configservice)
    self.configservice = configservice
    self.players = {}
    self.playerjoined = tax.signal()
end

function playerservice:addplayer(player)
    if #self.players < self.configservice.maxplayers then
        self.players[player.UserId] = player
        self.playerjoined:fire(player)
        return true
    end
    return false
end

-- Lifecycle management
local lifecycle = tax.lifecycle()

lifecycle:oninit(function()
    configservice:init()
    playerservice:init(configservice)
end)

lifecycle:onready(function()
    playerservice.playerjoined:connect(function(player)
        print(player.Name .. " joined the game")
    end)
end)

lifecycle:ondestroy(function()
    if configservice.destroy then configservice:destroy() end
    if playerservice.destroy then playerservice:destroy() end
end)

lifecycle:init()
lifecycle:ready()

return { lifecycle, configservice, playerservice }
```
