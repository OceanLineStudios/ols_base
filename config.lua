Config = {}

Config.Framework = "esx" -- "esx" | "qbcore" | "custom"
Config.SharedObject = "esx:getSharedObject"

Config.MenuAlign = "top-left" -- if you using a menu

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
