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
    
    self.HPPotionName = "None"
    self.MPPotionName = "None"
    self.HPPotionPercent = 40
    self.MPPotionPercent = 40
    
    self.VendorOnInventoryFull = true
    self.VendorOnWeight = true
    self.VendorWhite = true
    self.VendorGreen = true
    self.VendorBlue = false
    self.NeverVendor = { }
    
    self.TakeLoot = false
    self.OnDeathAction = SETTINGS_ON_DEATH_STOP_BOT
    

	self.FoodName = "None"
	self.FoodDuration = 30

	self.WarehouseAfterVendor = true
	self.WarehouseDepositMoney = true
	self.WarehouseKeepMoney = 100000
	self.WarehouseDepositItems = false
    self.NeverWarehouse = { }
    self.AdvancedDefault = {HotSpotRadius = 3000, IgnorePullBetweenHotSpots = true, IgnoreInCombatBetweenHotSpots = false, LootRadius = 4000, PullDistance = 2500, PullSecondsUntillIgnore = 10, CombatMaxDistanceFromMe = 2200}
    self.Advanced = self.AdvancedDefault

    return self
end

function Settings:CanWarehouseItem(item)

	if not item then
		return false
	end
    
	if self.HPPotionName == item.ItemEnchantStaticStatus.Name then
		return false
	end

	if self.FoodName == item.ItemEnchantStaticStatus.Name then
		return false
	end
    
	if self.MPPotionName == item.ItemEnchantStaticStatus.Name then
		return false
	end

	if table.find(self.NeverWarehouse, item.ItemEnchantStaticStatus.Name) then
		return false
	end

	return true
end


function Settings:CanSellItem(item)
    
    if not item then
        return false
    end
    
    if self.HPPotionName == item.ItemEnchantStaticStatus.Name then
        return false
    end

	if self.FoodName == item.ItemEnchantStaticStatus.Name then
		return false
	end
    
	if self.MPPotionName == item.ItemEnchantStaticStatus.Name then
        return false
    end
    
    if item.ItemEnchantStaticStatus.Grade >= ITEM_GRADE_GOLD then
        return false
    end
    
    if table.find(self.NeverVendor, item.ItemEnchantStaticStatus.Name) then
        return false
    end

    
    if self.VendorWhite and item.ItemEnchantStaticStatus.Grade == ITEM_GRADE_WHITE then
        return true
    end
    
    if self.VendorGreen and item.ItemEnchantStaticStatus.Grade == ITEM_GRADE_GREEN then
        return true
    end
    
    if self.VendorBlue and item.ItemEnchantStaticStatus.Grade == ITEM_GRADE_BLUE then
        return true
    end
    
    return false
    
end
