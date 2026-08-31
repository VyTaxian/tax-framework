# Tax Framework

A comprehensive Roblox framework providing services, controllers, dependency injection, signals, promises, middleware, lifecycle management, and typed APIs.

## Features

- **Services**: Singleton pattern for game-wide utilities
- **Controllers**: MVC architecture for client-side logic
- **Dependency Injection**: Automatic resolution of dependencies
- **Signals**: Event system for decoupled communication
- **Promises**: Async/await pattern for Lua
- **Middleware**: Request/response pipeline processing
- **Lifecycle Management**: Hooks for initialization, update, cleanup
- **Typed APIs**: Strong typing with Luau
- **Zero Dependencies**: Standalone framework

## Quick Start

```lua
local tax = require(game.ServerScriptService.TaxFramework)

-- Create a service
local gameservice = tax.service({
    name = "gameservice"
})

function gameservice:init()
    print("Game service initialized")
end

-- Create a controller
local playercontroller = tax.controller({
    name = "playercontroller",
    dependencies = { gameservice }
})

function playercontroller:init(gameservice)
    gameservice:dosomething()
end
```

## Documentation

See `/docs` for full documentation and examples.
