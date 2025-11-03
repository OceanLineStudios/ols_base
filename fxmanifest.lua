fx_version "cerulean"
game "gta5"
use_experimental_fxv2_oal "yes"

author "Japaner"
name "ols_base"
description "Base resource"

dependencies {
    "ox_lib",
}

shared_scripts {
    "@ox_lib/init.lua",
    "config.lua",
}

client_scripts {
    "framework/esx/client.lua",
    "framework/qbcore/client.lua",
    "framework/custom/client.lua",
    "framework/client.lua",
}

server_scripts {
    "framework/esx/server.lua",
    "framework/qbcore/server.lua",
    "framework/custom/server.lua",
    "framework/server.lua",
}
