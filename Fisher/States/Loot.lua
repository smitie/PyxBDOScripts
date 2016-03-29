LootState = { }
LootState.__index = LootState
LootState.Name = "Loot"

setmetatable(LootState, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function LootState.new()
  local self = setmetatable({}, LootState)
  self.LastHookFishTickCount = 0
  return self
end

function LootState:NeedToRun()

    local selfPlayer = GetSelfPlayer()
    
    if not selfPlayer then
        return false
    end
    
    if not selfPlayer.IsAlive then
        return false
    end
    
    if selfPlayer.Inventory.FreeSlots == 0 then
        return false
    end
    
    return selfPlayer.LootState > 0
    
end

function LootState:Run()
    local selfPlayer = GetSelfPlayer()
    selfPlayer:LootAllItemsToPlayer()
end
