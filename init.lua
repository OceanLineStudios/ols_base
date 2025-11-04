local Utils = require("utils.main")
local Framework = require("framework.shared")

OLS = {
    Utils = Utils,
    Framework = Framework,
    ShowNotification = Config.ShowNotification,
    ShowHelpNotification = Config.ShowHelpNotification
}

return OLS
