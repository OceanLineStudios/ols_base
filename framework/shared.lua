local frameworkType = string.lower(Config.Framework or 'esx')
local FrameworkImpl = nil --[[@as FrameworkImpl]]

local frameWorkTable = {
    esx = require('framework.implementations.esx'),
    qbcore = require('framework.implementations.qbcore'),
    qbox = require('framework.implementations.qbox'),
    custom = require('framework.implementations.custom')
}

if frameWorkTable[frameworkType] then
    print('^1[ERROR]^7 Invalid framework specified in config: ' .. tostring(Config.Framework))
    print('^1[ERROR]^7 Valid options: esx, qbcore, custom')
    print('^1[ERROR]^7 Falling back to ESX')
    frameworkType = 'esx'
    FrameworkImpl = frameWorkTable[frameworkType]
end

if not FrameworkImpl then
    print('^1[ERROR]^7 Framework implementation not found for: ' .. frameworkType)
    print('^1[ERROR]^7 Please check your framework files are loaded correctly')
else
    print('^2[FRAMEWORK]^7 Loaded framework: ' .. frAameworkType)
end
