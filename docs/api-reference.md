# Tax Framework API Reference

## tax.signal()

Creates a new signal for event emission and listening.

### Methods

- `connect(callback: function)`: Returns a connection that calls callback when signal fires
- `once(callback: function)`: Returns a connection that calls callback once, then disconnects
- `wait()`: Yields until signal fires, returns fired arguments
- `fire(...)`: Fires the signal with given arguments
- `firelocal(...)`: Fires signal synchronously without spawning new threads
- `destroy()`: Clears all connections

### Example

```lua
local signal = tax.signal()

local connection = signal:connect(function(message)
    print("Signal fired:", message)
end)

signal:fire("Hello!")
connection:disconnect()
```

---

## tax.promise(resolver)

Creates a promise for handling asynchronous operations.

### Constructor

```lua
local promise = tax.promise(function(resolve, reject)
    -- Async work
    if success then
        resolve(value)
    else
        reject(error)
    end
end)
```

### Methods

- `then(onsuccess, onerror)`: Chains operations
- `catch(onerror)`: Handles errors
- `finally(callback)`: Executes regardless of outcome
- `await()`: Yields coroutine until resolved, returns (success, value)
- `promise.all(promises)`: Resolves when all promises resolve
- `promise.race(promises)`: Resolves with first completed promise

### Example

```lua
tax.promise(function(resolve, reject)
    task.wait(1)
    resolve("done")
end)
    :then(function(value) print(value) end)
    :catch(function(error) print("Error:", error) end)
```

---

## tax.service(config)

Creates a singleton service.

### Config

```lua
{
    name = "servicename",
    dependencies = { service1, service2 }
}
```

### Lifecycle Methods

- `init(...dependencies)`: Called on creation, receives injected dependencies
- `destroy()`: Called on cleanup

### Example

```lua
local gameservice = tax.service({
    name = "gameservice"
})

function gameservice:init()
    self.running = true
end

function gameservice:destroy()
    self.running = false
end
```

---

## tax.controller(config)

Creates a controller with dependency injection support.

### Config

```lua
{
    name = "controllername",
    dependencies = { service1, service2 }
}
```

### Lifecycle Methods

- `init(...dependencies)`: Called on creation
- `destroy()`: Called on cleanup

### Example

```lua
local playercontroller = tax.controller({
    name = "playercontroller",
    dependencies = { gameservice }
})

function playercontroller:init(gameservice)
    self.gameservice = gameservice
end
```

---

## tax.middleware(handler)

Creates middleware for request/response processing.

### Handler Signature

```lua
function handler(request, response, next)
    -- Process request
    next()  -- Call next middleware
    -- Process response
end
```

### Methods

- `use(nextmiddleware)`: Chain another middleware
- `chain(middlewarelist)`: Chain multiple middleware
- `process(request, response)`: Execute the pipeline

### Example

```lua
local mw1 = tax.middleware(function(req, res, next)
    print("Start")
    next()
    print("End")
end)

local mw2 = tax.middleware(function(req, res, next)
    print("Middle")
    next()
end)

mw1:use(mw2)
mw1:process({}, {})
-- Output: Start, Middle, End
```

---

## tax.lifecycle()

Manages lifecycle hooks for initialization and cleanup.

### Hook Methods

- `oninit(callback, priority)`: Initialization hook
- `onready(callback, priority)`: Ready hook
- `onupdate(callback, priority)`: Update hook
- `onlateupdate(callback, priority)`: Late update hook
- `ondestroy(callback, priority)`: Destroy hook

### Execution Methods

- `init()`: Execute init hooks
- `ready()`: Execute ready hooks
- `update(deltatime)`: Execute update hooks
- `lateupdate(deltatime)`: Execute late update hooks
- `destroy()`: Execute destroy hooks

### Example

```lua
local lifecycle = tax.lifecycle()

lifecycle:oninit(function()
    print("Init")
end, 10)

lifecycle:init()
```

---

## tax.container()

Manages service and controller registration.

### Methods

- `registerservice(config)`: Register a service
- `registercontroller(config)`: Register a controller
- `cleanup()`: Cleanup all services and controllers

### Static Methods

- `tax.getservice(name)`: Get registered service by name
- `tax.getcontroller(name)`: Get registered controller by name

### Example

```lua
local container = tax.container()
container:registerservice({ name = "myservice" })
local service = tax.getservice("myservice")
```
