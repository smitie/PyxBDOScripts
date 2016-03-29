DeathState = { }
DeathState.__index = DeathState
DeathState.Name = "Death"

setmetatable(DeathState, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function DeathState.new()
  local self = setmetatable({}, DeathState)
  self.LastDeathHandledTickcount = 0
  return self
end

function DeathState:NeedToRun()
    
    local selfPlayer = GetSelfPlayer()
    
    if Pyx.System.TickCount - self.LastDeathHandledTickcount < 200 then
        return false
    end
    
    if not selfPlayer then
        return false
    end
    
    if not selfPlayer.IsAlive then
        return true
    end
    
    return false
end

function DeathState:Run()
    
    self.LastDeathHandledTickcount = Pyx.System.TickCount
    
    local selfPlayer = GetSelfPlayer()
    
    if Bot.Settings.OnDeathAction == SETTINGS_ON_DEATH_REVIVE_NODE then
        print("I'm dead, attempt to revive at nearest node ...");
        selfPlayer:ReviveAtNode()
    elseif Bot.Settings.OnDeathAction == SETTINGS_ON_DEATH_REVIVE_VILLAGE then
        print("I'm dead, attempt to revive at nearest village ...");
        selfPlayer:ReviveAtVillage()
    else
        print("I'm dead, stop bot ...");
        Bot.Stop()
    end
    
end
