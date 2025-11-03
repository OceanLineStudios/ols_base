ESX = exports['es_extended']:getSharedObject()

local registeredCallbacks = {
    playerLoaded = {},
    playerDropped = {}
}

if not ESX then
    TriggerEvent(Config.SharedObject, function(obj)
        ESX = obj
    end)
end

if IsDuplicityVersion() then
    ---@param callback fun(source: number, playerHandle: xPlayer, isNew: boolean)
    function Server.onPlayerLoaded(callback)
        registeredCallbacks.playerLoaded[#registeredCallbacks.playerLoaded + 1] = callback
    end

    ---@param callback fun(playerId: number)
    function Server.onPlayerDropped(callback)
        registeredCallbacks.playerLoaded[#registeredCallbacks.playerLoaded + 1] = callback
    end

    ---@param callback fun(source: number, job: ESXJob, lastJob: ESXJob)
    function Server.onSetJob(callback)

    end

    ---@param source number
    ---@return xPlayer
    function Server.getPlayerFromId(source)
        return ESX.GetPlayerFromId(source)
    end

    RegisterNetEvent('esx:playerLoaded', function(_, xPlayer)
        for i = 1, #registeredCallbacks.playerLoaded do
            registeredCallbacks.playerLoaded[i](xPlayer)
        end
    end)

    RegisterNetEvent('esx:playerDropped', function(playerId)
        for i = 1, #registeredCallbacks.playerLoaded do
            registeredCallbacks.playerDropped[i](playerId)
        end
    end)
else

end
