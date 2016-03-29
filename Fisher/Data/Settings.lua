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
    
    self.TakeLoot = false
    self.OnDeathAction = SETTINGS_ON_DEATH_STOP_BOT
    
  return self
end

function Settings:CanSellItem(slot)
    
    if not slot then
        return false
    end
    
    if not slot.IsFilled then
        return false
    end
    
    if self.HPPotionName == slot.ItemEnchantStaticStatus.Name then
        return false
    end
    
    if self.MPPotionName == slot.ItemEnchantStaticStatus.Name then
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
