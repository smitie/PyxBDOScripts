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
    self.VendorafterTradeManager = true

    self.WarehouseAfterVendor = true
    self.WarehouseAfterTradeManager = true
	self.WarehouseDepositMoney = true
	self.WarehouseKeepMoney = 100000
	self.WarehouseDepositItems = false
    self.NeverWarehouse = { }

    
    self.TradeManagerOnInventoryFull = true
    self.IgnoreUntradeAbleItems = false
    
  return self
end

function Settings:CanSellItem(slot)
    
    if not slot then
        return false
    end
    
    if table.find(self.NeverVendor, slot.ItemEnchantStaticStatus.Name) then
        return false
    end
    
    if slot.ItemEnchantStaticStatus.Grade >= ITEM_GRADE_GOLD then
        return false
    end
    
    if self.VendorWhite and slot.ItemEnchantStaticStatus.Grade == ITEM_GRADE_WHITE then
        return true
    end
    
    if self.VendorGreen and slot.ItemEnchantStaticStatus.Grade == ITEM_GRADE_GREEN then
        return true
    end
    
    if self.VendorBlue and slot.ItemEnchantStaticStatus.Grade == ITEM_GRADE_BLUE then
        return true
    end
    
    return false
    
end

function Settings:CanWarehouseItem(item)

	if not item then
		return false
	end

	if table.find(self.NeverWarehouse, item.ItemEnchantStaticStatus.Name) then
		return false
	end

	return true
end
