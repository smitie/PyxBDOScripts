DeathState = { }
DeathState.__index = DeathState
DeathState.Name = "Death"

DeathState.SETTINGS_ON_DEATH_ONLY_CALL_WHEN_COMPLETED = 0
DeathState.SETTINGS_ON_DEATH_REVIVE_NODE = 1
DeathState.SETTINGS_ON_DEATH_REVIVE_VILLAGE = 2

--DeathState.DefaultSettings =  {ReviveMethod = DeathState.SETTINGS_ON_DEATH_ONLY_CALL_WHEN_COMPLETED} 

setmetatable(DeathState, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function DeathState.new()
  local self = setmetatable({}, DeathState)
  self.LastUseTimer = nil
  self.CallWhenCompleted = nil
  self.Settings = {ReviveMethod = DeathState.SETTINGS_ON_DEATH_ONLY_CALL_WHEN_COMPLETED} 

  return self
end

function DeathState:NeedToRun()
    
    local selfPlayer = GetSelfPlayer()
    
    if self.LastUseTimer ~= nil and not self.LastUseTimer:Expired() then
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
    
        self.LastUseTimer = PyxTimer:New(1)
        self.LastUseTimer:Start()

    local selfPlayer = GetSelfPlayer()
    
    if self.Settings.ReviveMethod == DeathState.SETTINGS_ON_DEATH_REVIVE_NODE then
        print("I'm dead, attempt to revive at nearest node ...");
        selfPlayer:ReviveAtNode()
    elseif self.Settings.ReviveMethod == DeathState.SETTINGS_ON_DEATH_REVIVE_VILLAGE then
        print("I'm dead, attempt to revive at nearest village ...");
        selfPlayer:ReviveAtVillage()
        else 
        print("Death have state: "..self.Settings.ReviveMethod)
    end
    
   if self.CallWhenCompleted then
        self.CallWhenCompleted(self)
    end

end
