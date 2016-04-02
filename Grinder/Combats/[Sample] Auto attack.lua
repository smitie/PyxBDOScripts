CombatAutoAttack = { }
CombatAutoAttack.__index = CombatAutoAttack

setmetatable(CombatAutoAttack, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function CombatAutoAttack.new()
  local self = setmetatable({}, CombatAutoAttack)
  return self
end

function CombatAutoAttack:Attack(monsterActor)
    if monsterActor then
        local selfPlayer = GetSelfPlayer()
        local actorPosition = monsterActor.Position
        if actorPosition.Distance3DFromMe > monsterActor.BodySize + 900 or not monsterActor.IsLineOfSight then
            Navigator.MoveTo(actorPosition)
        else
            Navigator.Stop()
            if not selfPlayer.IsActionPending then
                selfPlayer:DoActionAtPosition("BT_skill_WindblowShot_Fire", actorPosition, 0)
                --selfPlayer:Interact(monsterActor) -- Auto attack for the win !
            end
        end
    end
end

return CombatAutoAttack()