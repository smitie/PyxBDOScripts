Settings = { }
Settings.__index = Settings

setmetatable(Settings, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function Settings.new()
  local self = setmetatable({}, Settings)
    
    self.LastProfileName = ""
    self.CombatScript = ""
    
    self.HPPotionName = "None"
    self.MPPotionName = "None"
    self.HPPotionPercent = 40
    self.MPPotionPercent = 40
    
    self.WarehouseSettings = {}
    self.VendorSettings = {}
    self.DeathSettings = {}
    self.RepairSettings = {}
    self.LootSettings = {}
    

	self.FoodName = "None"
	self.FoodDuration = 30
	self.WarehouseAfterVendor = true

    self.AdvancedDefault = {HotSpotRadius = 3000, IgnorePullBetweenHotSpots = true, IgnoreInCombatBetweenHotSpots = false, PullDistance = 2500, PullSecondsUntillIgnore = 10, CombatMaxDistanceFromMe = 2200}
    self.Advanced = self.AdvancedDefault

    return self
end



