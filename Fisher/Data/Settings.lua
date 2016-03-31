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
    
   
--    self.VendorOnInventoryFull = true
--    self.VendorOnWeight = true
--    self.VendorWhite = true
--    self.VendorGreen = true
--    self.VendorBlue = false
--    self.NeverVendor = { }
    self.VendorafterTradeManager = true

    self.WarehouseAfterVendor = true
    self.WarehouseAfterTradeManager = true

    self.WarehouseSettings = WarehouseState.DefaultSettings
    self.VendorSettings = VendorState.DefaultSettings

    self.TradeManagerSettings = TradeManagerState.DefaultSettings

    self.IgnoreUntradeAbleItems = false
    
  return self
end

