PotionsState = { }
PotionsState.__index = PotionsState
PotionsState.Name = "Potions"

setmetatable(PotionsState, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function PotionsState.new()
  local self = setmetatable({}, PotionsState)
  self.PotionToUse = { }
  self.LastPositionUsedTickcount = 0
  return self
end

function PotionsState:NeedToRun()
    
    local selfPlayer = GetSelfPlayer()
    
    if not selfPlayer then
        return false
    end
    
    if not selfPlayer.IsAlive then
        return false
    end
    
    if Pyx.System.TickCount - self.LastPositionUsedTickcount < 1000 then
        return false
    end
    
    if selfPlayer.HealthPercent <= Bot.Settings.HPPotionPercent then
        local potionItem = selfPlayer.Inventory:GetItemByName(Bot.Settings.HPPotionName)
        if potionItem and not potionItem.IsInCooldown then
            self.PotionToUse = potionItem;
            return true
        end
    end
    
    if selfPlayer.ManaPercent <= Bot.Settings.MPPotionPercent then
        local potionItem = selfPlayer.Inventory:GetItemByName(Bot.Settings.MPPotionName)
        if potionItem and not potionItem.IsInCooldown then
            self.PotionToUse = potionItem;
            return true
        end
    end
    
    return false
end

function PotionsState:Run()
    
    print("Use potion : " .. self.PotionToUse.ItemEnchantStaticStatus.Name)
    self.PotionToUse:UseItem()
    self.LastPositionUsedTickcount = Pyx.System.TickCount
    
end
