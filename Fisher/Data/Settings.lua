Settings = { }
Settings.__index = Settings

SETTINGS_ON_DEATH_STOP_BOT = 0
SETTINGS_ON_DEATH_REVIVE_NODE = 1
SETTINGS_ON_DEATH_REVIVE_VILLAGE = 2

setmetatable(Settings, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function Settings.new()
  local self = setmetatable({}, Settings)
    
    self.LastProfileName = ""
    self.CombatScript = ""
    
   
    self.VendorafterTradeManager = true

    self.WarehouseAfterVendor = true
    self.WarehouseAfterTradeManager = true

    self.WarehouseSettings = {}
    self.VendorSettings = {}

    self.TradeManagerSettings = {}

    self.InventoryDeleteSettings = {}

    self.IgnoreUntradeAbleItems = false
    
  return self
end

