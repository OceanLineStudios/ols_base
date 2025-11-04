Config = {}

Config.Framework = "esx" -- "esx" | "qbcore" | "custom"
Config.SharedObject = "esx:getSharedObject"

Config.MenuAlign = "top-left" -- if you using a menu

Config.WebhookBase = {
    username = "OceanLineStudios",
    color = 16711680,
    footer = {
        text = "OceanLineStudios"
    },
    sendTimestamp = true,
}

---@param title string
---@param message string
---@param type "success"|"info"|"error"|"warning"
---@param source? number
function Config.ShowNotification(title, message, type, source)
    if source then
        return lib.notify(source, {
            title = title,
            description = message,
            type = type
        })
    end

    return lib.notify({
        title = title,
        description = message,
        type = type
    })
end

---@param message string
function Config.ShowHelpNotification(message)
    return ESX.ShowHelpNotification(message)
end
