CombatTamer = { }
CombatTamer.__index = CombatTamer

CombatTamer.HEILANG_WHIPLASH_IDS = { 205, 132, 131, 130, 129 }
CombatTamer.HEILANG_UPWARD_CLAW_IDS = { 212, 211, 210, 209, 208 }
CombatTamer.HEILANG_SURGING_TIDE_IDS = { 1295, 1249, 1248, 1247, 1246, 1074 }

setmetatable(CombatTamer, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function CombatTamer.new()
  local self = setmetatable({}, CombatTamer)
  return self
end

function CombatTamer:Attack(monsterActor)
    
    local HEILANG_WHIPLASH_ID = SkillsHelper.GetKnownSkillId(CombatTamer.HEILANG_WHIPLASH_IDS)
    local HEILANG_UPWARD_CLAW_ID = SkillsHelper.GetKnownSkillId(CombatTamer.HEILANG_UPWARD_CLAW_IDS)
    local HEILANG_SURGING_TIDE_ID = SkillsHelper.GetKnownSkillId(CombatTamer.HEILANG_SURGING_TIDE_IDS)
    
    if monsterActor then
        local selfPlayer = GetSelfPlayer()
        local actorPosition = monsterActor.Position
        if actorPosition.Distance3DFromMe > monsterActor.BodySize + 150 then
            Navigator.MoveTo(actorPosition)
        else
            Navigator.Stop()
            if not selfPlayer.IsActionPending then
            
                if HEILANG_SURGING_TIDE_ID ~= 0 and 
                    SkillsHelper.IsSkillUsable(HEILANG_SURGING_TIDE_ID)  and
                    not selfPlayer:IsSkillOnCooldown(HEILANG_SURGING_TIDE_ID) and
                    monsterActor.HealthPercent >= 50 
                then
                    selfPlayer:UseSkillAtPosition(HEILANG_SURGING_TIDE_ID, actorPosition, 1500)
                    return
                end
            
                if HEILANG_UPWARD_CLAW_ID ~= 0 and 
                    SkillsHelper.IsSkillUsable(HEILANG_UPWARD_CLAW_ID) and
                    not selfPlayer:IsSkillOnCooldown(HEILANG_UPWARD_CLAW_ID) 
                then
                    selfPlayer:UseSkillAtPosition(HEILANG_UPWARD_CLAW_ID, actorPosition, 600)
                    return
                end
            
                if HEILANG_WHIPLASH_ID ~= 0 and 
                    SkillsHelper.IsSkillUsable(HEILANG_WHIPLASH_ID) 
                then
                    selfPlayer:UseSkillAtPosition(HEILANG_WHIPLASH_ID, actorPosition, 600)
                    return
                end
                
                selfPlayer:Interact(monsterActor) -- Auto attack for the win !
                
            end
            
        end
    end
end

return CombatTamer()