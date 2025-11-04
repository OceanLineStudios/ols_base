local QBCore = exports['qb-core']:GetCoreObject()

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
    ---@param source number
    ---@return table|nil
    local function getPlayerFromId(source)
        return QBCore.Functions.GetPlayer(source)
    end

    ---@param callback fun(source: number, isNew: boolean)
    function Server.onPlayerLoaded(callback)
        registeredCallbacks.onPlayerLoaded[#registeredCallbacks.onPlayerLoaded + 1] = callback
    end

    ---@param callback fun(playerId: number)
    function Server.onPlayerDropped(callback)
        registeredCallbacks.onPlayerDropped[#registeredCallbacks.onPlayerDropped + 1] = callback
    end

    ---@param callback fun(source: number, job: PlayerJob, lastJob: PlayerJob)
    function Server.onSetJob(callback)
        registeredCallbacks.onSetJob[#registeredCallbacks.onSetJob + 1] = callback
    end

    ---@param callback fun(source: number, killer: number|nil)
    function Server.onPlayerDeath(callback)
        registeredCallbacks.onPlayerDeath[#registeredCallbacks.onPlayerDeath + 1] = callback
    end

    ---@param source number
    ---@return string
    function Server.getPlayerIdentifier(source)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        return player.PlayerData.citizenid
    end

    ---@param source number
    ---@return PlayerJob
    function Server.getPlayerJob(source)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        local job = player.PlayerData.job
        return {
            name = job.name,
            label = job.label,
            grade = {
                grade = job.grade.level,
                label = job.grade.name,
                name = job.grade.name
            }
        } --[[@as PlayerJob]]
    end

    ---@param source number
    ---@param jobName string
    ---@param grade number
    ---@param isDuty boolean
    function Server.setPlayerJob(source, jobName, grade, isDuty)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        player.Functions.SetJob(jobName, grade)
        if isDuty ~= nil then
            player.Functions.SetJobDuty(isDuty)
        end
    end

    ---@param source number
    ---@return PlayerAccounts
    function Server.getPlayerAccounts(source)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        local money = player.PlayerData.money

        return {
            money = money['cash'] or 0,
            black_money = money['black_money'] or 0,
            bank = money['bank'] or 0
        } --[[@as PlayerAccounts]]
    end

    ---@param source number
    ---@return string
    function Server.getFullName(source)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        local charinfo = player.PlayerData.charinfo
        local fullName = charinfo.firstname .. " " .. charinfo.lastname

        return fullName
    end

    ---@param source number
    ---@param accountName string
    ---@param amount number
    ---@param reason string
    function Server.setAccountMoney(source, accountName, amount, reason)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        player.Functions.SetMoney(accountName, amount, reason)
    end

    ---@param source number
    ---@param accountName string
    ---@param amount number
    ---@param reason string
    function Server.addAccountMoney(source, accountName, amount, reason)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        player.Functions.AddMoney(accountName, amount, reason)
    end

    ---@param source number
    ---@param accountName string
    ---@param amount number
    ---@param reason string
    function Server.removeAccountMoney(source, accountName, amount, reason)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        player.Functions.RemoveMoney(accountName, amount, reason)
    end

    ---@param source number
    ---@return PlayerInventoryWeapon[]
    function Server.getLoadout(source)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        local items = player.PlayerData.items
        local weapons = {}

        for _, item in pairs(items) do
            if item.type == "weapon" then
                weapons[#weapons + 1] = {
                    name = item.name,
                    label = item.label,
                    ammo = item.ammo or 0,
                    components = item.components or {},
                    tintIndex = item.tintIndex or 0
                } --[[@as PlayerInventoryWeapon]]
            end
        end

        return weapons
    end

    ---@param source number
    ---@param weaponName string
    ---@return PlayerInventoryWeapon|nil
    function Server.getWeapon(source, weaponName)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        local item = player.Functions.GetItemByName(weaponName)

        if item and item.type == "weapon" then
            return {
                name = item.name,
                label = item.label,
                ammo = item.ammo or 0,
                components = item.components or {},
                tintIndex = item.tintIndex or 0
            } --[[@as PlayerInventoryWeapon]]
        end

        return nil
    end

    ---@param source number
    ---@param weaponName string
    ---@param ammo number
    function Server.addWeapon(source, weaponName, ammo)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        player.Functions.AddItem(weaponName, 1, false, {
            ammo = ammo or 250,
            quality = 100
        })
    end

    ---@param source number
    ---@param weaponName string
    ---@param componentName string
    function Server.addWeaponComponent(source, weaponName, componentName)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        local item = player.Functions.GetItemByName(weaponName)

        if item and item.type == "weapon" then
            local components = item.info.components or {}
            components[#components + 1] = componentName
            player.Functions.SetItemMetadata(weaponName, {
                components = components
            })
        end
    end

    ---@param source number
    ---@param weaponName string
    ---@param ammo number
    function Server.addWeaponAmmo(source, weaponName, ammo)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        local item = player.Functions.GetItemByName(weaponName)

        if item and item.type == "weapon" then
            local currentAmmo = (item.info and item.info.ammo) or 0
            player.Functions.SetItemMetadata(weaponName, {
                ammo = currentAmmo + ammo
            })
        end
    end

    ---@param source number
    ---@param weaponName string
    ---@param ammo number
    function Server.updateWeaponAmmo(source, weaponName, ammo)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        local item = player.Functions.GetItemByName(weaponName)

        if item and item.type == "weapon" then
            player.Functions.SetItemMetadata(weaponName, {
                ammo = ammo
            })
        end
    end

    ---@param source number
    ---@param weaponName string
    ---@param tintIndex number
    function Server.setWeaponTint(source, weaponName, tintIndex)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        local item = player.Functions.GetItemByName(weaponName)

        if item and item.type == "weapon" then
            player.Functions.SetItemMetadata(weaponName, {
                tintIndex = tintIndex
            })
        end
    end

    ---@param source number
    ---@param weaponName string
    ---@return number
    function Server.getWeaponTint(source, weaponName)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        local item = player.Functions.GetItemByName(weaponName)

        if item and item.type == "weapon" and item.info then
            return item.info.tintIndex or 0
        end

        return 0
    end

    ---@param source number
    ---@param weaponName string
    function Server.removeWeapon(source, weaponName)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        player.Functions.RemoveItem(weaponName, 1)
    end

    ---@param source number
    ---@param weaponName string
    ---@param componentName string
    function Server.removeWeaponComponent(source, weaponName, componentName)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        local item = player.Functions.GetItemByName(weaponName)

        if item and item.type == "weapon" and item.info and item.info.components then
            local components = {}
            for _, comp in pairs(item.info.components) do
                if comp ~= componentName then
                    components[#components + 1] = comp
                end
            end
            player.Functions.SetItemMetadata(weaponName, {
                components = components
            })
        end
    end

    ---@param source number
    ---@param weaponName string
    ---@param ammo number
    function Server.removeWeaponAmmo(source, weaponName, ammo)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        local item = player.Functions.GetItemByName(weaponName)

        if item and item.type == "weapon" then
            local currentAmmo = (item.info and item.info.ammo) or 0
            local newAmmo = math.max(0, currentAmmo - ammo)
            player.Functions.SetItemMetadata(weaponName, {
                ammo = newAmmo
            })
        end
    end

    ---@param source number
    ---@param weaponName string
    ---@param componentName string
    ---@return boolean
    function Server.hasWeaponComponent(source, weaponName, componentName)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        local item = player.Functions.GetItemByName(weaponName)

        if item and item.type == "weapon" and item.info and item.info.components then
            for _, comp in pairs(item.info.components) do
                if comp == componentName then
                    return true
                end
            end
        end

        return false
    end

    ---@param source number
    ---@param weaponName string
    ---@return boolean
    function Server.hasWeapon(source, weaponName)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        return player.Functions.GetItemByName(weaponName) ~= nil
    end

    ---@param source number
    ---@return PlayerInventoryItem[]
    function Server.getInventory(source)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        local items = player.PlayerData.items
        local inventory = {}

        for _, item in pairs(items) do
            inventory[#inventory + 1] = {
                name = item.name,
                label = item.label,
                weight = item.weight or 0,
                usable = item.usable or false,
                rare = item.rare or false,
                canRemove = item.canRemove ~= false,
                count = item.amount or 0
            } --[[@as PlayerInventoryItem]]
        end

        return inventory
    end

    ---@param source number
    ---@return number
    function Server.getWeight(source)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        return player.PlayerData.metadata['inventoryweight'] or 0
    end

    ---@param source number
    ---@return number
    function Server.getMaxWeight(source)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        return player.PlayerData.metadata['maxweight'] or 50000
    end

    ---@param source number
    ---@param maxWeight number
    function Server.setMaxWeight(source, maxWeight)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        player.Functions.SetMetaData('maxweight', maxWeight)
    end

    ---@param source number
    ---@param itemName string
    ---@param count number
    ---@return boolean
    function Server.canCarryItem(source, itemName, count)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        return player.Functions.CanCarryItem(itemName, count)
    end

    ---@param source number
    ---@param firstItem string
    ---@param firstItemCount number
    ---@param secondItem string
    ---@param secondItemCount number
    ---@return boolean
    function Server.canSwapItem(source, firstItem, firstItemCount, secondItem, secondItemCount)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        -- QBCore doesn't have a direct swap function, check if we can carry both
        local canCarryFirst = player.Functions.CanCarryItem(firstItem, firstItemCount)
        local canCarrySecond = player.Functions.CanCarryItem(secondItem, secondItemCount)
        return canCarryFirst and canCarrySecond
    end

    ---@param source number
    ---@param itemName string
    ---@return boolean
    function Server.hasItem(source, itemName)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        local item = player.Functions.GetItemByName(itemName)
        return item ~= nil and (item.amount or 0) > 0
    end

    ---@param source number
    ---@param itemName string
    ---@return PlayerInventoryItem|nil
    function Server.getInventoryItem(source, itemName)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        local item = player.Functions.GetItemByName(itemName)

        if item then
            return {
                name = item.name,
                label = item.label,
                weight = item.weight or 0,
                usable = item.usable or false,
                rare = item.rare or false,
                canRemove = item.canRemove ~= false,
                count = item.amount or 0
            } --[[@as PlayerInventoryItem]]
        end

        return nil
    end

    ---@param source number
    ---@param itemName string
    ---@param count number
    function Server.addInventoryItem(source, itemName, count)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        player.Functions.AddItem(itemName, count)
    end

    ---@param source number
    ---@param itemName string
    ---@param count number
    function Server.removeInventoryItem(source, itemName, count)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        player.Functions.RemoveItem(itemName, count)
    end

    ---@param source number
    ---@param itemName string
    ---@param count number
    function Server.setInventoryItem(source, itemName, count)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        local item = player.Functions.GetItemByName(itemName)

        if item then
            local currentCount = item.amount or 0
            if count > currentCount then
                player.Functions.AddItem(itemName, count - currentCount)
            elseif count < currentCount then
                player.Functions.RemoveItem(itemName, currentCount - count)
            end
        elseif count > 0 then
            player.Functions.AddItem(itemName, count)
        end
    end

    ---@param source number
    ---@return string
    function Server.getGroup(source)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        return player.PlayerData.job.name
    end

    ---@param source number
    ---@param group string
    function Server.setGroup(source, group)
        local player = getPlayerFromId(source)
        if not player then error("Player not found") end
        -- In QBCore, groups are typically jobs, so we set the job
        player.Functions.SetJob(group, 0)
    end

    ---@return table[]
    function Server.getExtendedPlayers()
        return QBCore.Functions.GetQBPlayers()
    end

    ---@param itemName string
    ---@param callback fun(source: number)
    function Server.registerUsableItem(itemName, callback)
        QBCore.Functions.CreateUseableItem(itemName, function(source, item)
            callback(source)
        end)
    end

    ---@param source number
    ---@param itemName string
    function Server.useItem(source, itemName)
        TriggerClientEvent('inventory:client:UseItem', source, itemName)
    end

    RegisterNetEvent("QBCore:Server:PlayerLoaded", function(Player)
        local playerId = Player.PlayerData.source
        local isNew = Player.PlayerData.metadata.isNew or false

        for i = 1, #registeredCallbacks.onPlayerLoaded do
            registeredCallbacks.onPlayerLoaded[i](playerId, isNew)
        end
    end)

    RegisterNetEvent("QBCore:Server:OnPlayerUnload", function(src)
        for i = 1, #registeredCallbacks.onPlayerDropped do
            registeredCallbacks.onPlayerDropped[i](src)
        end
    end)

    RegisterNetEvent("QBCore:Server:OnPlayerDeath", function(data)
        local src = source
        local killerId = data.killerServerId or nil

        for i = 1, #registeredCallbacks.onPlayerDeath do
            registeredCallbacks.onPlayerDeath[i](src, killerId)
        end
    end)

    RegisterNetEvent("QBCore:Server:OnJobUpdate", function(src, job)
        local player = QBCore.Functions.GetPlayer(src)
        if not player then return end

        local lastJob = player.PlayerData.job
        local newJob = job

        for i = 1, #registeredCallbacks.onSetJob do
            local jobData = {
                name = newJob.name,
                label = newJob.label,
                grade = {
                    grade = newJob.grade.level,
                    label = newJob.grade.name,
                    name = newJob.grade.name
                }
            } --[[@as PlayerJob]]

            local lastJobData = {
                name = lastJob.name,
                label = lastJob.label,
                grade = {
                    grade = lastJob.grade.level,
                    label = lastJob.grade.name,
                    name = lastJob.grade.name
                }
            } --[[@as PlayerJob]]

            registeredCallbacks.onSetJob[i](src, jobData, lastJobData)
        end
    end)
else
    ---@param model string|number
    ---@param coords vector4
    ---@return number
    function Client.spawnVehicle(model, coords)
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
        local menuItems = {}

        for i = 1, #menu.items do
            menuItems[#menuItems + 1] = {
                header = menu.items[i].label,
                txt = "",
                action = menu.items[i].onSelect
            }
        end

        exports['qb-menu']:openMenu(menuItems)
    end

    function Client.closeMenu()
        exports['qb-menu']:closeMenu()
    end

    ---@return PlayerData
    function Client.getPlayerData()
        local playerData = QBCore.Functions.GetPlayerData()
        local money = playerData.money or {}

        return {
            accounts = {
                money = money['cash'] or 0,
                black_money = money['black_money'] or 0,
                bank = money['bank'] or 0
            },
            job = {
                name = playerData.job.name,
                label = playerData.job.label,
                grade = {
                    name = playerData.job.grade.name,
                    label = playerData.job.grade.name,
                    grade = playerData.job.grade.level
                }
            },
            fullname = (playerData.charinfo.firstname or "") .. " " .. (playerData.charinfo.lastname or ""),
            firstname = playerData.charinfo.firstname or "",
            lastname = playerData.charinfo.lastname or "",
            sex = playerData.charinfo.gender == 1 and "f" or "m"
        } --[[@as PlayerData]]
    end

    ---@return boolean
    function Client.isPlayerLoaded()
        local playerData = QBCore.Functions.GetPlayerData()
        return playerData ~= nil and playerData.citizenid ~= nil
    end
end

return {
    Client = Client,
    Server = Server
}
