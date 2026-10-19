# Tax Framework

Tax Framework is a lightweight Roblox framework built for clean server/client architecture, fast startup, and simple service-based development.

It keeps the feel of modern Roblox frameworks without the extra weight. You get:
- server-side services
- client-side controllers
- centralized startup
- lightweight lifecycle hooks
- simple module registration
- a custom structure that stays easy to read and easy to extend

## Why Tax?

Tax is built for people who want a framework that feels handcrafted, not bloated.

It gives you:
- structure without ceremony
- fast startup with minimal abstraction
- modules that are easy to reason about
- a clean separation between server logic and client logic
- room to grow without fighting the framework

## Core idea

Tax is built around two main concepts:

- Services: shared logic for the server or client
- Controllers: flow and behavior modules for handling gameplay systems

Every module is registered and started through a central bootstrap, which keeps your project organized and predictable.

## Quick start

### Server

```lua
local Tax = require(game.ServerScriptService.TaxFramework)

Tax.startServer({
	Services = {
		require(script.Parent.Services.Service1),
	},
	Controllers = {
		require(script.Parent.Controllers.Controller1),
	},
})
```

### Client

```lua
local Tax = require(game.StarterPlayerScripts.TaxFrameworkClient)

Tax.startClient({
	Services = {
		require(script.Parent.Services.Service1),
	},
	Controllers = {
		require(script.Parent.Controllers.Controller1),
	},
})
```

## Module structure

A typical project looks like this:

```txt
TaxFramework/
  init.lua
  core/
    server.lua
    client.lua
  Services/
    Service1.lua
  Controllers/
    Controller1.lua
```

## Service example

```lua
local Service1 = {
	Name = "Service1",

	Init = function(self)
		print("Service1 initialized")
	end,

	Start = function(self)
		print("Service1 started")
	end,
}

return Service1
```

## Controller example

```lua
local Controller1 = {
	Name = "Controller1",

	Init = function(self)
		print("Controller1 initialized")
	end,

	Start = function(self)
		print("Controller1 started")
	end,
}

return Controller1
```

## Lifecycle

Tax modules support lifecycle hooks:

- Init
- Start

This lets you keep your setup clean and predictable without a lot of framework overhead.

## Notes

Tax is intentionally lightweight. It is designed to be:
- readable
- modular
- scalable
- easy to customize

If you want a basic Roblox framework with a clean architecture and a little bit of Knit-style organization, Tax is built for that.
