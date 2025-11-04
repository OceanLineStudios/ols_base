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

if IsDuplicityVersion() then
    ---@param webhookName WebhookName
    ---@param fields EmbedField[]
    function Server.sendWebhook(webhookName, fields)
        local webhook = Config.ServerConfig.webhooks[webhookName]
        if not webhook then return end

        local data = {
            username = Config.ServerConfig.baseData.username,
            embeds = {
                {
                    title = webhook.title,
                    description = webhook.description,
                    fields = fields,
                    footer = Config.ServerConfig.baseData.footer,
                    timestamp = Config.ServerConfig.baseData.sendTimestamp and os.date("!%Y-%m-%dT%H:%M:%SZ")
                }
            }
        }

        PerformHttpRequest(webhook, function() end, "POST", json.encode(data),
            { ["Content-Type"] = "application/json" })
    end
else
    local spawnedPeds, spawnedPedCount   = {}, 0
    local createdBlips, createdBlipCount = {}, 0

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
            distance = 2,
            marker = marker,
            onEnter = function(point)
                if point.ped then Client.deleteEntity(point.ped) end
                if options.ped then
                    Client.spawnPed({
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
                if options.nearby then options.nearby() end

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

    Client.registerNUICallback("ready", function()
        Client.isNuiReady = true
    end)

    AddEventHandler("onResourceStop", function(resource)
        if resource ~= cache.resource then return end

        for _, entity in pairs(spawnedPeds) do
            Client.deleteEntity(entity)
        end
    end)
end

return {
    Table = Table,
    Server = Server,
    Client = Client
}
