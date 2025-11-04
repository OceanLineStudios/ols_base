-- Custom Framework Implementation
-- Replace these placeholder functions with your custom framework logic

local registeredCallbacks = {
    ---@type table<number, fun(source: number, isNew: boolean)>
    onPlayerLoaded = {},
    ---@type table<number, fun(source: number)>
    onPlayerDropped = {},
    ---@type table<number, fun(source: number, job: PlayerJob, lastJob: PlayerJob)>
    onSetJob = {},
    ---@type table<number, fun(source: number, killer: number|nil)>
    onPlayerDeath = {}
}

local Client = {}
local Server = {}

if IsDuplicityVersion() then
    ---@param callback fun(source: number, isNew: boolean)
    function Server.onPlayerLoaded(callback)
        registeredCallbacks.onPlayerLoaded[#registeredCallbacks.onPlayerLoaded + 1] = callback
        -- TODO: Register your custom framework's player loaded event here
        -- Example: RegisterNetEvent("your_framework:playerLoaded", function(...) callback(...) end)
    end

    ---@param callback fun(playerId: number)
    function Server.onPlayerDropped(callback)
        registeredCallbacks.onPlayerDropped[#registeredCallbacks.onPlayerDropped + 1] = callback
        -- TODO: Register your custom framework's player dropped event here
        -- Example: RegisterNetEvent("your_framework:playerDropped", function(...) callback(...) end)
    end

    ---@param callback fun(source: number, job: PlayerJob, lastJob: PlayerJob)
    function Server.onSetJob(callback)
        registeredCallbacks.onSetJob[#registeredCallbacks.onSetJob + 1] = callback
        -- TODO: Register your custom framework's job update event here
        -- Example: RegisterNetEvent("your_framework:setJob", function(...) callback(...) end)
    end

    ---@param callback fun(source: number, killer: number|nil)
    function Server.onPlayerDeath(callback)
        registeredCallbacks.onPlayerDeath[#registeredCallbacks.onPlayerDeath + 1] = callback
        -- TODO: Register your custom framework's player death event here
        -- Example: RegisterNetEvent("your_framework:onPlayerDeath", function(...) callback(...) end)
    end

    ---@param source number
    ---@return string
    function Server.getPlayerIdentifier(source)
        -- TODO: Implement your custom framework's player identifier retrieval
        -- Example: return YourFramework.GetPlayerIdentifier(source)
        return "custom_player_" .. tostring(source)
    end

    ---@param source number
    ---@return PlayerJob
    function Server.getPlayerJob(source)
        -- TODO: Implement your custom framework's job retrieval
        -- Example:
        -- local job = YourFramework.GetPlayerJob(source)
        -- return { name = job.name, label = job.label, grade = {...} }
        return {
            name = "unemployed",
            label = "Unemployed",
            grade = {
                grade = 0,
                label = "Unemployed",
                name = "unemployed"
            }
        } --[[@as PlayerJob]]
    end

    ---@param source number
    ---@param jobName string
    ---@param grade number
    ---@param isDuty boolean
    function Server.setPlayerJob(source, jobName, grade, isDuty)
        -- TODO: Implement your custom framework's job setting
        -- Example: YourFramework.SetPlayerJob(source, jobName, grade, isDuty)
    end

    ---@param source number
    ---@return PlayerAccounts
    function Server.getPlayerAccounts(source)
        -- TODO: Implement your custom framework's account retrieval
        -- Example: return YourFramework.GetPlayerAccounts(source)
        return {
            money = 0,
            black_money = 0,
            bank = 0
        } --[[@as PlayerAccounts]]
    end

    ---@param source number
    ---@return string
    function Server.getFullName(source)
        -- TODO: Implement your custom framework's full name retrieval
        -- Example: return YourFramework.GetPlayerFullName(source)
        return "Custom Player"
    end

    ---@param source number
    ---@param accountName string
    ---@param amount number
    ---@param reason string
    function Server.setAccountMoney(source, accountName, amount, reason)
        -- TODO: Implement your custom framework's account money setting
        -- Example: YourFramework.SetAccountMoney(source, accountName, amount, reason)
    end

    ---@param source number
    ---@param accountName string
    ---@param amount number
    ---@param reason string
    function Server.addAccountMoney(source, accountName, amount, reason)
        -- TODO: Implement your custom framework's account money addition
        -- Example: YourFramework.AddAccountMoney(source, accountName, amount, reason)
    end

    ---@param source number
    ---@param accountName string
    ---@param amount number
    ---@param reason string
    function Server.removeAccountMoney(source, accountName, amount, reason)
        -- TODO: Implement your custom framework's account money removal
        -- Example: YourFramework.RemoveAccountMoney(source, accountName, amount, reason)
    end

    ---@param source number
    ---@return PlayerInventoryWeapon[]
    function Server.getLoadout(source)
        -- TODO: Implement your custom framework's weapon loadout retrieval
        -- Example: return YourFramework.GetPlayerWeapons(source)
        return {}
    end

    ---@param source number
    ---@param weaponName string
    ---@return PlayerInventoryWeapon|nil
    function Server.getWeapon(source, weaponName)
        -- TODO: Implement your custom framework's weapon retrieval
        -- Example: return YourFramework.GetPlayerWeapon(source, weaponName)
        return nil
    end

    ---@param source number
    ---@param weaponName string
    ---@param ammo number
    function Server.addWeapon(source, weaponName, ammo)
        -- TODO: Implement your custom framework's weapon addition
        -- Example: YourFramework.AddWeapon(source, weaponName, ammo)
    end

    ---@param source number
    ---@param weaponName string
    ---@param componentName string
    function Server.addWeaponComponent(source, weaponName, componentName)
        -- TODO: Implement your custom framework's weapon component addition
        -- Example: YourFramework.AddWeaponComponent(source, weaponName, componentName)
    end

    ---@param source number
    ---@param weaponName string
    ---@param ammo number
    function Server.addWeaponAmmo(source, weaponName, ammo)
        -- TODO: Implement your custom framework's weapon ammo addition
        -- Example: YourFramework.AddWeaponAmmo(source, weaponName, ammo)
    end

    ---@param source number
    ---@param weaponName string
    ---@param ammo number
    function Server.updateWeaponAmmo(source, weaponName, ammo)
        -- TODO: Implement your custom framework's weapon ammo update
        -- Example: YourFramework.UpdateWeaponAmmo(source, weaponName, ammo)
    end

    ---@param source number
    ---@param weaponName string
    ---@param tintIndex number
    function Server.setWeaponTint(source, weaponName, tintIndex)
        -- TODO: Implement your custom framework's weapon tint setting
        -- Example: YourFramework.SetWeaponTint(source, weaponName, tintIndex)
    end

    ---@param source number
    ---@param weaponName string
    ---@return number
    function Server.getWeaponTint(source, weaponName)
        -- TODO: Implement your custom framework's weapon tint retrieval
        -- Example: return YourFramework.GetWeaponTint(source, weaponName)
        return 0
    end

    ---@param source number
    ---@param weaponName string
    function Server.removeWeapon(source, weaponName)
        -- TODO: Implement your custom framework's weapon removal
        -- Example: YourFramework.RemoveWeapon(source, weaponName)
    end

    ---@param source number
    ---@param weaponName string
    ---@param componentName string
    function Server.removeWeaponComponent(source, weaponName, componentName)
        -- TODO: Implement your custom framework's weapon component removal
        -- Example: YourFramework.RemoveWeaponComponent(source, weaponName, componentName)
    end

    ---@param source number
    ---@param weaponName string
    ---@param ammo number
    function Server.removeWeaponAmmo(source, weaponName, ammo)
        -- TODO: Implement your custom framework's weapon ammo removal
        -- Example: YourFramework.RemoveWeaponAmmo(source, weaponName, ammo)
    end

    ---@param source number
    ---@param weaponName string
    ---@param componentName string
    ---@return boolean
    function Server.hasWeaponComponent(source, weaponName, componentName)
        -- TODO: Implement your custom framework's weapon component check
        -- Example: return YourFramework.HasWeaponComponent(source, weaponName, componentName)
        return false
    end

    ---@param source number
    ---@param weaponName string
    ---@return boolean
    function Server.hasWeapon(source, weaponName)
        -- TODO: Implement your custom framework's weapon check
        -- Example: return YourFramework.HasWeapon(source, weaponName)
        return false
    end

    ---@param source number
    ---@return PlayerInventoryItem[]
    function Server.getInventory(source)
        -- TODO: Implement your custom framework's inventory retrieval
        -- Example: return YourFramework.GetPlayerInventory(source)
        return {}
    end

    ---@param source number
    ---@return number
    function Server.getWeight(source)
        -- TODO: Implement your custom framework's weight retrieval
        -- Example: return YourFramework.GetPlayerWeight(source)
        return 0
    end

    ---@param source number
    ---@return number
    function Server.getMaxWeight(source)
        -- TODO: Implement your custom framework's max weight retrieval
        -- Example: return YourFramework.GetPlayerMaxWeight(source)
        return 50000
    end

    ---@param source number
    ---@param maxWeight number
    function Server.setMaxWeight(source, maxWeight)
        -- TODO: Implement your custom framework's max weight setting
        -- Example: YourFramework.SetPlayerMaxWeight(source, maxWeight)
    end

    ---@param source number
    ---@param itemName string
    ---@param count number
    ---@return boolean
    function Server.canCarryItem(source, itemName, count)
        -- TODO: Implement your custom framework's item carry check
        -- Example: return YourFramework.CanCarryItem(source, itemName, count)
        return true
    end

    ---@param source number
    ---@param firstItem string
    ---@param firstItemCount number
    ---@param secondItem string
    ---@param secondItemCount number
    ---@return boolean
    function Server.canSwapItem(source, firstItem, firstItemCount, secondItem, secondItemCount)
        -- TODO: Implement your custom framework's item swap check
        -- Example: return YourFramework.CanSwapItem(source, firstItem, firstItemCount, secondItem, secondItemCount)
        return true
    end

    ---@param source number
    ---@param itemName string
    ---@return boolean
    function Server.hasItem(source, itemName)
        -- TODO: Implement your custom framework's item check
        -- Example: return YourFramework.HasItem(source, itemName)
        return false
    end

    ---@param source number
    ---@param itemName string
    ---@return PlayerInventoryItem|nil
    function Server.getInventoryItem(source, itemName)
        -- TODO: Implement your custom framework's inventory item retrieval
        -- Example: return YourFramework.GetInventoryItem(source, itemName)
        return nil
    end

    ---@param source number
    ---@param itemName string
    ---@param count number
    function Server.addInventoryItem(source, itemName, count)
        -- TODO: Implement your custom framework's item addition
        -- Example: YourFramework.AddItem(source, itemName, count)
    end

    ---@param source number
    ---@param itemName string
    ---@param count number
    function Server.removeInventoryItem(source, itemName, count)
        -- TODO: Implement your custom framework's item removal
        -- Example: YourFramework.RemoveItem(source, itemName, count)
    end

    ---@param source number
    ---@param itemName string
    ---@param count number
    function Server.setInventoryItem(source, itemName, count)
        -- TODO: Implement your custom framework's item count setting
        -- Example: YourFramework.SetItemCount(source, itemName, count)
    end

    ---@param source number
    ---@return string
    function Server.getGroup(source)
        -- TODO: Implement your custom framework's group retrieval
        -- Example: return YourFramework.GetPlayerGroup(source)
        return "user"
    end

    ---@param source number
    ---@param group string
    function Server.setGroup(source, group)
        -- TODO: Implement your custom framework's group setting
        -- Example: YourFramework.SetPlayerGroup(source, group)
    end

    ---@return table[]
    function Server.getExtendedPlayers()
        -- TODO: Implement your custom framework's extended players retrieval
        -- Example: return YourFramework.GetAllPlayers()
        return {}
    end

    ---@param itemName string
    ---@param callback fun(source: number)
    function Server.registerUsableItem(itemName, callback)
        -- TODO: Register your custom framework's usable item
        -- Example: YourFramework.RegisterUsableItem(itemName, function(source) callback(source) end)
    end

    ---@param source number
    ---@param itemName string
    function Server.useItem(source, itemName)
        -- TODO: Implement your custom framework's item use
        -- Example: YourFramework.UseItem(source, itemName)
    end
else
    ---@param model string|number
    ---@param coords vector4
    ---@return number
    function Client.spawnVehicle(model, coords)
        -- TODO: Implement your custom framework's vehicle spawning
        -- Example: return YourFramework.SpawnVehicle(model, coords)
        local modelHash = type(model) == "string" and GetHashKey(model) or model
        RequestModel(modelHash)

        while not HasModelLoaded(modelHash) do
            Wait(0)
        end

        local vehicle = CreateVehicle(modelHash, coords.x, coords.y, coords.z, coords.w, true, false)
        SetModelAsNoLongerNeeded(modelHash)

        return vehicle
    end

    ---@param menu Menu
    function Client.openMenu(menu)
        -- TODO: Implement your custom framework's menu opening
        -- Example: YourFramework.OpenMenu(menu)
        print("^3[CUSTOM FRAMEWORK]^7 Menu opened: " .. menu.title)
        for i = 1, #menu.items do
            print("  - " .. menu.items[i].label)
        end
    end

    function Client.closeMenu()
        -- TODO: Implement your custom framework's menu closing
        -- Example: YourFramework.CloseMenu()
        print("^3[CUSTOM FRAMEWORK]^7 Menu closed")
    end

    ---@return PlayerData
    function Client.getPlayerData()
        -- TODO: Implement your custom framework's player data retrieval
        -- Example: return YourFramework.GetPlayerData()
        return {
            accounts = {
                money = 0,
                black_money = 0,
                bank = 0
            },
            job = {
                name = "unemployed",
                label = "Unemployed",
                grade = {
                    name = "unemployed",
                    label = "Unemployed",
                    grade = 0
                }
            },
            fullname = "Custom Player",
            firstname = "Custom",
            lastname = "Player",
            sex = "m"
        } --[[@as PlayerData]]
    end

    ---@return boolean
    function Client.isPlayerLoaded()
        -- TODO: Implement your custom framework's player loaded check
        -- Example: return YourFramework.IsPlayerLoaded()
        return false
    end
end

return {
    Client = Client,
    Server = Server
}
