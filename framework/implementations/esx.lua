local ESX = exports["es_extended"]:getSharedObject()
local Table = require("utils.main").Table

local registeredCallbacks = {
    ---@type table<number, fun(source: number, isNew: boolean)>
    onPlayerLoaded = {},
    ---@type table<number, fun(source: number)>
    onPlayerDropped = {},
    ---@type table<number, fun(source: number, job: ESXJob, lastJob: ESXJob)>
    onSetJob = {},
    ---@type table<number, fun(source: number, killer: xPlayer)>
    onPlayerDeath = {}
}

if not ESX then
    TriggerEvent(Config.SharedObject, function(obj)
        ESX = obj
    end)
end

local Client = {}
local Server = {}
local MenuAlign = Config.MenuAlign or "top-left"

if IsDuplicityVersion() then
    ---@param source number
    ---@return xPlayer
    local function getPlayerFromId(source)
        local player = ESX.GetPlayerFromId(source)
        if not player then error("Player not found") end
        return player
    end

    ---@param callback fun(source: number, isNew: boolean)
    function Server.onPlayerLoaded(callback)
        registeredCallbacks.playerLoaded[#registeredCallbacks.playerLoaded + 1] = callback
    end

    ---@param callback fun(playerId: number)
    function Server.onPlayerDropped(callback)
        registeredCallbacks.playerDropped[#registeredCallbacks.playerDropped + 1] = callback
    end

    ---@param callback fun(source: number, job: ESXJob, lastJob: ESXJob)
    function Server.onSetJob(callback)
        registeredCallbacks.onSetJob[#registeredCallbacks.onSetJob + 1] = callback
    end

    ---@param callback fun(source: number, killer: xPlayer)
    function Server.onPlayerDeath(callback)
        registeredCallbacks.onPlayerDeath[#registeredCallbacks.onPlayerDeath + 1] = callback
    end

    function Server.getPlayerIdentifier(source)
        local player = getPlayerFromId(source)
        return player.identifier
    end

    ---@param source number
    ---@return PlayerJob
    function Server.getPlayerJob(source)
        local player = getPlayerFromId(source)
        return {
            name = player.job.name,
            label = player.job.label,
            grade = {
                grade = player.job.grade,
                label = player.job.grade_label,
                name = player.job.grade_name
            }
        } --[[@as PlayerJob]]
    end

    ---@param source number
    ---@param jobName string
    ---@param grade number
    ---@param isDuty boolean
    function Server.setPlayerJob(source, jobName, grade, isDuty)
        local player = getPlayerFromId(source)

        ---@diagnostic disable-next-line: param-type-mismatch
        player.setJob(jobName, grade, isDuty)
    end

    ---@param source number
    ---@return PlayerAccounts
    function Server.getPlayerAccounts(source)
        local player = getPlayerFromId(source)
        local accounts = player.getAccounts(true)

        return {
            money = player.getMoney(),
            black_money = accounts.black_money,
            bank = accounts.bank
        } --[[@as PlayerAccounts]]
    end

    ---@param source number
    ---@return string
    function Server.getFullName(source)
        local player = getPlayerFromId(source)
        local firstName = player.get("firstName")
        local lastName = player.get("lastName")
        local fullName = firstName .. " " .. lastName

        return fullName
    end

    ---@param source number
    ---@param accountName string
    ---@param amount number
    ---@param reason string
    function Server.setAccountMoney(source, accountName, amount, reason)
        local player = getPlayerFromId(source)
        player.setAccountMoney(accountName, amount, reason)
    end

    ---@param source number
    ---@param accountName string
    ---@param amount number
    ---@param reason string
    function Server.addAccountMoney(source, accountName, amount, reason)
        local player = getPlayerFromId(source)
        player.addAccountMoney(accountName, amount, reason)
    end

    ---@param source number
    ---@param accountName string
    ---@param amount number
    ---@param reason string
    function Server.removeAccountMoney(source, accountName, amount, reason)
        local player = getPlayerFromId(source)
        player.removeAccountMoney(accountName, amount, reason)
    end

    ---@param source number
    ---@return PlayerInventoryWeapon[]
    function Server.getLoadout(source)
        local player = getPlayerFromId(source)
        return player.getLoadout()
    end

    ---@param source number
    ---@param weaponName string
    ---@return PlayerInventoryWeapon
    function Server.getWeapon(source, weaponName)
        local player = getPlayerFromId(source)
        return player.getWeapon(weaponName) --[[@as PlayerInventoryWeapon]]
    end

    ---@param source number
    ---@param weaponName string
    ---@param ammo number
    function Server.addWeapon(source, weaponName, ammo)
        local player = getPlayerFromId(source)
        player.addWeapon(weaponName, ammo)
    end

    ---@param source number
    ---@param weaponName string
    function Server.addWeaponComponent(source, weaponName, componentName)
        local player = getPlayerFromId(source)
        player.addWeaponComponent(weaponName, componentName)
    end

    ---@param source number
    ---@param weaponName string
    ---@param ammo number
    function Server.addWeaponAmmo(source, weaponName, ammo)
        local player = getPlayerFromId(source)
        player.addWeaponAmmo(weaponName, ammo)
    end

    ---@param source number
    ---@param weaponName string
    function Server.updateWeaponAmmo(source, weaponName, ammo)
        local player = getPlayerFromId(source)
        player.updateWeaponAmmo(weaponName, ammo)
    end

    ---@param source number
    ---@param weaponName string
    function Server.setWeaponTint(source, weaponName, tintIndex)
        local player = getPlayerFromId(source)
        player.setWeaponTint(weaponName, tintIndex)
    end

    ---@param source number
    ---@param weaponName string
    ---@return number
    function Server.getWeaponTint(source, weaponName)
        local player = getPlayerFromId(source)
        return player.getWeaponTint(weaponName)
    end

    ---@param source number
    ---@param weaponName string
    function Server.removeWeapon(source, weaponName)
        local player = getPlayerFromId(source)
        player.removeWeapon(weaponName)
    end

    ---@param source number
    ---@param weaponName string
    function Server.removeWeaponComponent(source, weaponName, componentName)
        local player = getPlayerFromId(source)
        player.removeWeaponComponent(weaponName, componentName)
    end

    ---@param source number
    ---@param weaponName string
    function Server.removeWeaponAmmo(source, weaponName, ammo)
        local player = getPlayerFromId(source)
        player.removeWeaponAmmo(weaponName, ammo)
    end

    ---@param source number
    ---@param weaponName string
    function Server.hasWeaponComponent(source, weaponName, componentName)
        local player = getPlayerFromId(source)
        return player.hasWeaponComponent(weaponName, componentName)
    end

    ---@param source number
    ---@param weaponName string
    function Server.hasWeapon(source, weaponName)
        local player = getPlayerFromId(source)
        return player.hasWeapon(weaponName)
    end

    ---@param source number
    ---@return PlayerInventoryItem[]
    function Server.getInventory(source)
        local player = getPlayerFromId(source)
        return player.getInventory(true)
    end

    ---@param source number
    ---@return number
    function Server.getWeight(source)
        local player = getPlayerFromId(source)
        return player.getWeight()
    end

    ---@param source number
    ---@return number
    function Server.getMaxWeight(source)
        local player = getPlayerFromId(source)
        return player.getMaxWeight()
    end

    ---@param source number
    ---@param maxWeight number
    function Server.setMaxWeight(source, maxWeight)
        local player = getPlayerFromId(source)
        player.setMaxWeight(maxWeight)
    end

    ---@param source number
    ---@param itemName string
    ---@param count number
    ---@return boolean
    function Server.canCarryItem(source, itemName, count)
        local player = getPlayerFromId(source)
        return player.canCarryItem(itemName, count)
    end

    ---@param source number
    ---@param firstItem string
    ---@param firstItemCount number
    ---@param secondItem string
    ---@param secondItemCount number
    ---@return boolean
    function Server.canSwapItem(source, firstItem, firstItemCount, secondItem, secondItemCount)
        local player = getPlayerFromId(source)
        return player.canSwapItem(firstItem, firstItemCount, secondItem, secondItemCount)
    end

    ---@param source number
    ---@param itemName string
    ---@return boolean
    function Server.hasItem(source, itemName)
        local player = getPlayerFromId(source)
        return player.hasItem(itemName) --[[@as boolean]]
    end

    ---@param source number
    ---@param itemName string
    ---@return PlayerInventoryItem
    function Server.getInventoryItem(source, itemName)
        local player = getPlayerFromId(source)
        return player.getInventoryItem(itemName) --[[@as PlayerInventoryItem]]
    end

    ---@param source number
    ---@param itemName string
    ---@param count number
    function Server.addInventoryItem(source, itemName, count)
        local player = getPlayerFromId(source)
        player.addInventoryItem(itemName, count)
    end

    ---@param source number
    ---@param itemName string
    ---@param count number
    function Server.removeInventoryItem(source, itemName, count)
        local player = getPlayerFromId(source)
        player.removeInventoryItem(itemName, count)
    end

    ---@param source number
    ---@param itemName string
    function Server.setInventoryItem(source, itemName, count)
        local player = getPlayerFromId(source)
        player.setInventoryItem(itemName, count)
    end

    ---@param source number
    ---@return string
    function Server.getGroup(source)
        local player = getPlayerFromId(source)
        return player.getGroup()
    end

    ---@param source number
    ---@param group string
    function Server.setGroup(source, group)
        local player = getPlayerFromId(source)
        player.setGroup(group)
    end

    ---@return xPlayer[]
    function Server.getExtendedPlayers()
        return ESX.GetExtendedPlayers()
    end

    ---@param itemName string
    ---@param callback fun(source: number)
    function Server.registerUsableItem(itemName, callback)
        ESX.RegisterUsableItem(itemName, function(source)
            callback(source)
        end)
    end

    function Server.useItem(source, itemName)
        ESX.UseItem(source, itemName)
    end

    RegisterNetEvent("esx:playerLoaded", function(playerId, _, isNew)
        for i = 1, #registeredCallbacks.playerLoaded do
            registeredCallbacks.playerLoaded[i](playerId, isNew)
        end
    end)

    RegisterNetEvent("esx:playerDropped", function(playerId)
        for i = 1, #registeredCallbacks.playerLoaded do
            registeredCallbacks.playerDropped[i](playerId)
        end
    end)

    RegisterNetEvent("esx:onPlayerDeath", function(data)
        local src = source

        for i = 1, #registeredCallbacks.onPlayerDeath do
            registeredCallbacks.onPlayerDeath[i](src, data.killerServerId)
        end
    end)

    RegisterNetEvent("esx:setJob", function(job, lastJob)
        for i = 1, #registeredCallbacks.onSetJob do
            registeredCallbacks.onSetJob[i](source, job, lastJob)
        end
    end)
else
    ---@param model string|number
    ---@param coords vector4
    ---@return number|promise
    function Client.spawnVehicle(model, coords)
        local promise = promise.new()

        ESX.Game.SpawnVehicle(model, coords.xyz, coords.w, function(vehicle)
            promise:resolve(vehicle)
        end)

        return Citizen.Await(promise)
    end

    ---@param menu Menu
    function Client.openMenu(menu)
        local elements = {}
        local elementCallbacks = {}

        for i = 1, #menu.items do
            elements[#elements + 1] = {
                label = menu.items[i].label,
                value = menu.items[i].name
            }

            elementCallbacks[menu.items[i].name] = menu.items[i].onSelect
        end

        ESX.UI.Menu.Open("default", cache.resource, menu.name, {
            title = menu.title,
            align = MenuAlign,
            elements = elements
        }, function(data)
            local callback = elementCallbacks[data.current.value]
            if callback then
                callback()
            end
        end)
    end

    ---@param menuName string
    function Client.closeMenu(menuName)
        ESX.UI.Menu.Close("default", cache.resource, menuName)
    end

    ---@return PlayerData
    function Client.getPlayerData()
        local playerData = ESX.GetPlayerData()
        return {
            accounts = {
                money = Table.findByKey(playerData.accounts, "money")?.money or 0,
                black_money = Table.findByKey(playerData.accounts, "black_money")?.black_money or 0,
                bank = Table.findByKey(playerData.accounts, "bank")?.bank or 0
            },
            job = {
                name = playerData.job.name,
                label = playerData.job.label,
                grade = {
                    name = playerData.job.grade_name,
                    label = playerData.job.grade_label,
                    grade = playerData.job.grade
                }
            },
            fullname = playerData.firstname .. " " .. playerData.lastname,
            firstname = playerData.firstname,
            lastname = playerData.lastname,
            sex = playerData.sex
        } --[[@as PlayerData]]
    end

    ---@return boolean
    function Client.isPlayerLoaded()
        return ESX.IsPlayerLoaded()
    end
end

return {
    Client = Client,
    Server = Server
}
