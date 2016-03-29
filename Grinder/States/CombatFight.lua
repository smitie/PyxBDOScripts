CombatFightState = { }
CombatFightState.__index = CombatFightState
CombatFightState.Name = "Combat - Fight"

setmetatable(CombatFightState, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function CombatFightState.new()
  local self = setmetatable({}, CombatFightState)
  self.CurrentCombatActor = { }
  return self
end

function CombatFightState:NeedToRun()
    
    local selfPlayer = GetSelfPlayer()
    
    if not selfPlayer then
        return false
    end
    
    if not selfPlayer.IsAlive then
        return false
    end
    
    local selfPlayerPosition = selfPlayer.Position
    
    local monsters = GetMonsters()
    table.sort(monsters, function(a,b) return a.Position:GetDistance3D(selfPlayerPosition) < b.Position:GetDistance3D(selfPlayerPosition) end)
    for k,v in pairs(monsters) do
        if 
            v.IsAlive and 
            v.CanAttack and 
            v.IsAggro and 
        v.Position.Distance3DFromMe <= Bot.Settings.Advanced.CombatMaxDistanceFromMe and
        (Bot.Settings.Advanced.IgnoreInCombatBetweenHotSpots == false or Bot.Settings.Advanced.IgnoreInCombatBetweenHotSpots == true 
        and  ProfileEditor.CurrentProfile:IsPositionNearHotspots(v.Position, Bot.Settings.Advanced.HotSpotRadius*2)) and
        Navigator.CanMoveTo(v.Position) 
        then
            self.CurrentCombatActor = v
            return true
        end
    end
    
    return false
end

function CombatFightState:Run()
    Bot.CallCombatAttack(self.CurrentCombatActor,false)
end


