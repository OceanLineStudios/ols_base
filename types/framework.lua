---@class PlayerJob
---@field name string
---@field label string
---@field grade { name: string, label: string, grade: number }

---@class PlayerAccounts
---@field money number
---@field black_money number
---@field bank number

---@class PlayerInventoryWeapon
---@field name string
---@field label string
---@field ammo number
---@field components string[]
---@field tintIndex number

---@class PlayerInventoryItem
---@field name string
---@field label string
---@field weight number
---@field usable boolean
---@field rare boolean
---@field canRemove boolean
---@field count number?

---@class Menu
---@field title string
---@field name string
---@field items MenuItem[]

---@class MenuItem
---@field label string
---@field name string
---@field onSelect fun()

---@class PlayerData
---@field accounts PlayerAccounts
---@field job PlayerJob
---@field fullname string
---@field firstname string
---@field lastname string
---@field sex string
