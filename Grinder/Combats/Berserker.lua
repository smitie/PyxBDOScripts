CombatBerserker = { }
CombatBerserker.__index = CombatBerserker

CombatBerserker.HEADBUTT_IDS = { 1292, 1291, 1159, 1038 }
CombatBerserker.FIERCE_STRIKE_IDS = { 1166, 1165, 1164, 1163, 1041 }

setmetatable(CombatBerserker, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function CombatBerserker.new()
  local self = setmetatable({}, CombatBerserker)
  return self
end

function CombatBerserker:Attack(monsterActor)
    
    local HEADBUTT_ID = SkillsHelper.GetKnownSkillId(CombatBerserker.HEADBUTT_IDS)
    local FIERCE_STRIKE_ID = SkillsHelper.GetKnownSkillId(CombatBerserker.FIERCE_STRIKE_IDS)
    
    if monsterActor then
        local selfPlayer = GetSelfPlayer()
        local actorPosition = monsterActor.Position
        if actorPosition.Distance3DFromMe > monsterActor.BodySize + 150 then
            Navigator.MoveTo(actorPosition)
        else
            Navigator.Stop()
            
            if not selfPlayer.IsActionPending then
                            
                if FIERCE_STRIKE_ID ~= 0 and
                    SkillsHelper.IsSkillUsable(FIERCE_STRIKE_ID)
                then
                    selfPlayer:UseSkillAtPosition(FIERCE_STRIKE_ID, actorPosition, 1500)
                    return
                end
            end
            selfPlayer:Interact(monsterActor) -- Auto attack for the win !
        end
    end
end

return CombatBerserker()