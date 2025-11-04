---@class Webhook
---@field title string
---@field description string
---@field url string

---@class ServerConfig
---@field baseData BaseData
---@field webhooks Webhooks

---@class EmbedField
---@field name string
---@field value string
---@field inline? boolean

---@class BlipStruct
---@field sprite number
---@field color? number
---@field scale? number

---@class Blip : BlipStruct
---@field label string
---@field coords vector3|{ x: number, y: number, z: number }
---@field category? string

---@class PedStruct
---@field model string|number
---@field animation? { name: string }|{ dict: string, name: string, flag: number }

---@class Ped : PedStruct
---@field coords vector4|{ x: number, y: number, z: number, w: number }

---@class PointOptions
---@field coords vector3 | vector4
---@field marker? Marker
---@field ped? PedStruct
---@field onInteract? function
---@field onExit? function
---@field nearby? function
---@field onEnter? function
---@field canInteract? fun(): boolean

---@class Marker
---@field type MarkerType | number
---@field width? number
---@field height? number
---@field color? { r: number, g: number, b: number, a: number }
---@field rotation? { x: number, y: number, z: number }
---@field direction? { x: number, y: number, z: number }
---@field bobUpAndDown? boolean
---@field faceCamera? boolean
---@field rotate? boolean
---@field textureDict? string
---@field textureName? string

---@class BaseData
---@field username string
---@field color number
---@field footer? { text: string }
---@field sendTimestamp? boolean
