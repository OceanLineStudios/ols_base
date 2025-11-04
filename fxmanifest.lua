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
    "init.lua"
}
