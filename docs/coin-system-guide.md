# Coin Collection & Rebirth System Guide

## Overview

This system provides a complete coin collection, data store management, and rebirth progression system for Roblox games.

## Components

### DataStoreService

Handles all data persistence and caching.

```lua
local datastoreservice = tax.service({ name = "datastoreservice" })

-- Save data
datastoreservice:set("playerdata", tostring(userid), playerdata)

-- Load data
local data = datastoreservice:get("playerdata", tostring(userid))

-- Increment value
datastoreservice:increment("stats", "playtime", 60)
```

### CoinsService

Manages player coin balance and transactions.

```lua
local coinsservice = tax.service({
    name = "coinsservice",
    dependencies = { datastoreservice }
})

-- Add coins
coinsservice:addcoins(userid, 100)

-- Remove coins
coinsservice:removecoins(userid, 50)

-- Check balance
local coins = coinsservice:getcoins(userid)

-- Check if player has enough coins
local has = coinsservice:hascoins(userid, 1000)

-- Listen to coin updates
coinsservice.coingupdated:connect(function(userid, totalcoins, change)
    print(userid .. " now has " .. totalcoins .. " coins")
end)
```

### RebirthService

Manages rebirth progression and bonuses.

```lua
local rebirthservice = tax.service({
    name = "rebirthservice",
    dependencies = { datastoreservice, coinsservice }
})

-- Perform rebirth
local success, result = rebirthservice:rebirth(userid)

-- Get rebirth info
local info = rebirthservice:getrebirthinfo(userid)
-- Returns: {
--   currentlevel = 1,
--   totalrebirths = 3,
--   bonus = 2.5,
--   nextcost = 5000,
--   hascoins = true,
--   currentcoins = 10000
-- }

-- Get rebirth bonus multiplier
local bonus = rebirthservice:getrebirthbonus(userid)

-- Listen to rebirth events
rebirthservice.rebirthcompleted:connect(function(userid, level, cost)
    print(userid .. " reached rebirth level " .. level)
end)
```

#### Rebirth Levels & Costs

- Level 1: 1,000 coins (1.5x multiplier)
- Level 2: 5,000 coins (2.0x multiplier)
- Level 3: 25,000 coins (2.5x multiplier)
- Level 4: 100,000 coins (3.0x multiplier)
- Level 5: 500,000 coins (4.0x multiplier)

### CollectionService

Manages coin collection and completion tracking.

```lua
local collectionservice = tax.service({
    name = "collectionservice",
    dependencies = { datastoreservice }
})

-- Add coin to collection
local success, coin = collectionservice:addcointoollection(userid, coinid)

-- Get collection progress
local progress = collectionservice:getcollectionprogress(userid)
-- Returns: {
--   collected = 5,
--   total = 10,
--   percentage = 50.0
-- }

-- Check if collection complete
if collectionservice:iscollectioncomplete(userid) then
    print("Collection complete!")
end

-- Get available coins
local coins = collectionservice:getavailablecoins()
-- Returns array of coins with id, name, rarity

-- Listen to collection events
collectionservice.coincollected:connect(function(userid, coinid, coinname, rarity)
    print(userid .. " collected " .. coinname)
end)

collectionservice.collectioncomplete:connect(function(userid)
    print(userid .. " completed the collection!")
end)
```

#### Available Coins

1. **Bronze** (Common) - 10 value
2. **Silver** (Uncommon) - 25 value
3. **Gold** (Rare) - 100 value
4. **Platinum** (Epic) - 500 value
5. **Diamond** (Legendary) - 2,500 value
6. **Emerald** (Rare) - 100 value
7. **Ruby** (Rare) - 100 value
8. **Sapphire** (Epic) - 500 value
9. **Crystal** (Legendary) - 2,500 value
10. **Celestial** (Mythic) - 10,000 value

## Complete Example

```lua
local gamemanager = require(game.ServerScriptService.coingamesetup)

-- Initialize
gamemanager:initialize()

-- Add coins to player
local player = game.Players:FindFirstChild("PlayerName")
if player then
    gamemanager:addcointoiplayer(player, 500)
    
    -- Add coin to collection
    gamemanager:addcointocollection(player, 1)
    
    -- Attempt rebirth
    local success, result = gamemanager:rebirtiplayer(player)
    if success then
        print("Rebirth successful!")
    else
        print("Rebirth failed")
    end
    
    -- Get stats
    local stats = gamemanager:getplayerstats(player)
    print("Coins:", stats.coins)
    print("Rebirth Level:", stats.rebirth.currentlevel)
    print("Collection:", stats.collection.percentage .. "%")
end

-- Shutdown
gamemanager:shutdown()
```

## Auto-Save System

The DataStoreService automatically saves player data every 60 seconds. Mark data as dirty to trigger save:

```lua
local playerdata = datastoreservice:getcachedplayer(userid)
playerdata.dirty = true  -- Marks for auto-save
```

## Error Handling

All data operations include retry logic (3 attempts by default) with 1-second delays.

```lua
local success = datastoreservice:set("playerdata", key, value)
if not success then
    warn("Failed to save data")
end
```
