---@diagnostic disable-next-line: missing-parameter
lib.locale()

local Table = {
    ---@param table table
    ---@param key string
    ---@param value any
    ---@return any, number?
    findByKey = function(table, key, value)
        for i = 1, #table do
            if table[i][key] == value then
                return table[i], i
            end
        end
        return nil, nil
    end,
    ---@param table table
    ---@param callback fun(value: any): boolean
    ---@return table
    filter = function(table, callback)
        local newTable = {}
        for i = 1, #table do
            if callback(table[i]) then
                newTable[#newTable + 1] = table[i]
            end
        end
        return newTable
    end,
}

local Server = {}
local Client = {
    isNuiReady = false,
}

local Letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
local Numbers = "0123456789"

if IsDuplicityVersion() then
    ---@param name string
    ---@param columns table<string, string>
    function Server.createTable(name, columns)
        local columnDefinitions = {}

        for columnName, columnType in pairs(columns) do
            columnDefinitions[#columnDefinitions + 1] = "`" .. columnName .. "` " .. columnType
        end

        local query = "CREATE TABLE IF NOT EXISTS `" .. name .. "` (" .. table.concat(columnDefinitions, ", ") .. ")"
        local doesExist = MySQL.scalar.await("SHOW TABLES LIKE ?", { "%" .. name .. "%" })

        if not doesExist then
            MySQL.insert.await(query)
            print("^2[OLS]^7 Created table: " .. name)
        end
    end

    ---@param tableName string
    ---@param query string
    function Server.alterTable(tableName, query)
        local doesExist = MySQL.scalar.await("SHOW TABLES LIKE ?",
            { "%" .. tableName .. "%" })
        if not doesExist then
            MySQL.insert.await("ALTER TABLE `" .. tableName .. "` " .. query, {})
            print("^2[OLS]^7 Altered table: " .. tableName)
        end
    end

    ---@param tableName string
    ---@return boolean
    function Server.doesTableExist(tableName)
        return MySQL.scalar.await("SHOW TABLES LIKE ?", { "%" .. tableName .. "%" }) ~= nil
    end

    ---@return string
    function Server.generatePlate()
        local plate
        repeat
            plate = ""
            for i = 1, 3 do
                local rand = math.random(#Letters)
                plate = plate .. Letters:sub(rand, rand)
            end
            for i = 1, 3 do
                local rand = math.random(#Numbers)
                plate = plate .. Numbers:sub(rand, rand)
            end
        until MySQL.scalar.await("SELECT 1 FROM owned_vehicles WHERE plate = ?", { plate }) == nil
        return plate
    end
else
    local spawnedPeds, spawnedPedCount   = {}, 0
    local createdBlips, createdBlipCount = {}, 0
    local spawnedProps, spawnedPropCount = {}, 0

    ---@param bool boolean
    function Client.showHud(bool)
        Client.sendNUIMessage("hud:setVisible", bool)
    end

    ---@param data Blip
    ---@return number
    function Client.createBlip(data)
        local coords = data.coords
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

        SetBlipSprite(blip, data.sprite)
        SetBlipColour(blip, data.color or 0)
        SetBlipScale(blip, data.scale or 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(data.label)

        if data.category then
            AddTextEntry("BLIP_CAT_" .. data.category, data.label)
        end

        EndTextCommandSetBlipName(blip)

        createdBlipCount += 1
        createdBlips[createdBlipCount] = blip
        return blip
    end

    ---@param data Ped
    ---@return number?
    function Client.spawnPed(data)
        local model = lib.requestModel(data.model)
        if not model then return end

        local coords = data.coords
        local entity = CreatePed(0, model, coords.x, coords.y, coords.z, coords.w, false, true)

        local animation = data.animation
        local animationDict, animationName = animation?.dict, animation?.name
        if animationDict then
            lib.requestAnimDict(animationDict)
            TaskPlayAnim(entity, animationDict, animationName, 8.0, -8.0, -1, animation?.flag, 0, false, false, false)
        elseif animationName then
            TaskStartScenarioInPlace(entity, animationName, 0, true)
        end

        SetModelAsNoLongerNeeded(model)
        FreezeEntityPosition(entity, true)
        SetEntityInvincible(entity, true)
        SetBlockingOfNonTemporaryEvents(entity, true)

        spawnedPedCount += 1
        spawnedPeds[spawnedPedCount] = entity

        return entity
    end

    ---@param data Prop
    ---@return number?
    function Client.spawnProp(data)
        local model = lib.requestModel(data.model)
        if not model then return end

        local coords = data.coords
        local entity = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)

        SetEntityInvincible(entity, true)
        SetBlockingOfNonTemporaryEvents(entity, true)

        spawnedPropCount += 1
        spawnedProps[spawnedPropCount] = entity

        return entity
    end

    ---@param options PointOptions
    function Client.createPoint(options)
        local marker
        if options.marker then
            local markerData = options.marker --[[@as MarkerProps]]
            markerData.coords = options.coords.xyz
            marker = lib.marker.new(markerData)
        end

        return lib.points.new({
            coords = options.coords.xyz,
            distance = 20,
            marker = marker,
            onEnter = function(point)
                if point.ped then Client.deleteEntity(point.ped) end
                if options.ped then
                    point.ped = Client.spawnPed({
                        coords = options.coords,
                        model = options.ped.model,
                        animation = options.ped.animation,
                    })
                end
                if options.onEnter then options.onEnter() end
            end,
            onExit = function(point)
                if point.ped then Client.deleteEntity(point.ped) end
                if options.onExit then options.onExit() end
            end,
            nearby = function(point)
                if options.canInteract and not options.canInteract() then return end
                if point.marker then point.marker:draw() end
                if point.currentDistance > 2 then return end
                if options.nearby then options.nearby() end
                if options.helpNotify then
                    TriggerEvent("hud:setHelpNotify", options.helpNotify)
                end

                if IsControlJustReleased(0, 38) then
                    if options.onInteract then options.onInteract() end
                end
            end,
            canInteract = options.canInteract,
        })
    end

    ---@param entity number
    function Client.deleteEntity(entity)
        if DoesEntityExist(entity) then
            SetEntityAsMissionEntity(entity, false, true)
            DeleteEntity(entity)
        end
    end

    ---@param action string
    ---@param data? any
    ---@param optionalData? { focus?: { hasFocus: boolean, hasCursor: boolean }, keepInput?: boolean, freezePlayer?: boolean }
    function Client.sendNUIMessage(action, data, optionalData)
        while not Client.isNuiReady do
            Wait(100)
        end

        SendNUIMessage({
            action = action,
            data = data,
        })

        if optionalData then
            if optionalData and type(optionalData.focus) == "table" then
                local hasFocus = optionalData.focus.hasFocus
                local hasCursor = optionalData.focus.hasCursor

                SetNuiFocus(hasFocus, hasCursor)
            end

            if type(optionalData.keepInput) == "boolean" then
                SetNuiFocusKeepInput(optionalData.keepInput)
            end

            if type(optionalData.freezePlayer) == "boolean" then
                FreezeEntityPosition(PlayerPedId(), optionalData.freezePlayer)
            end
        end
    end

    ---@param action string
    ---@param cb fun(data: any): any
    function Client.registerNUICallback(action, cb)
        RegisterNUICallback(action, function(data, callback)
            local response = cb(data)
            callback(response and response or "ok")
        end)
    end

    ---@param event string
    ---@param fn function
    function Client.onNet(event, fn)
        RegisterNetEvent(event, function(...)
            if source == "" then return end

            fn(...)
        end)
    end

    ---@param blip number
    function Client.deleteBlip(blip)
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
            createdBlips[blip] = nil
        end
    end

    function Client.deleteAllBlips()
        for _, blip in pairs(createdBlips) do
            Client.deleteBlip(blip)
        end
    end

    ---@param vehicle number
    ---@return string
    function Client.getVehiclePlate(vehicle)
        local plate = GetVehicleNumberPlateText(vehicle):gsub("%s+", "")
        return plate
    end

    RegisterNetEvent("notifications:add", function(title, message, type, duration)
        Client.notify(title, message, type, duration)
    end)

    AddEventHandler("onResourceStop", function(resource)
        if resource ~= cache.resource then return end

        for _, entity in pairs(spawnedPeds) do
            Client.deleteEntity(entity)
        end
        for _, entity in pairs(spawnedProps) do
            Client.deleteEntity(entity)
        end
    end)
end

return {
    Table = Table,
    Server = Server,
    Client = Client
}
