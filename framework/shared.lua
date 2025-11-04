local frameworkType = string.lower(Config.Framework or "esx")

local frameWorkTable = {
    esx = "framework.implementations.esx",
    qbcore = "framework.implementations.qbcore",
    qbox = "framework.implementations.qbox",
    custom = "framework.implementations.custom"
}

if not frameWorkTable[frameworkType] then
    print("^1[ERROR]^7 Invalid framework specified in config: " .. tostring(Config.Framework))
    print("^1[ERROR]^7 Valid options: esx, qbcore, qbox, custom")
    print("^1[ERROR]^7 Falling back to ESX")
    frameworkType = "esx"
end

local Framework = require(frameWorkTable[frameworkType])

if not Framework then
    print("^1[ERROR]^7 Framework implementation not found for: " .. frameworkType)
    print("^1[ERROR]^7 Please check your framework files are loaded correctly")
else
    print("^2[FRAMEWORK]^7 Loaded framework: " .. frameworkType)
end

---@return "esx"|"qbcore"|"qbox"|"custom"
local function getFrameworkType()
    return frameworkType
end

return {
    getFrameworkType = getFrameworkType,
    Framework = Framework
}
