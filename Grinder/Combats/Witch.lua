CombatWitch = { }
CombatWitch.__index = CombatWitch

CombatWitch.ABILITY_DAGGER_STAB_IDS = { 897, 896, 895, 894, 893 }
--CombatWitch.ABILITY_STAFF_ATTACK_IDS = { 877, 878, 879, 880, 881, 882, 883, 884, 885, 886}
CombatWitch.ABILITY_FIREBALL_IDS = { 821, 820, 819, 818 }
CombatWitch.ABILITY_MAGIC_ARROW_IDS = { 854, 853, 852, 851, 850 }
CombatWitch.ABILITY_LIGHTNING_CHAIN_IDS = { 830, 829, 828, 827 }
CombatWitch.UsedDagger = false


setmetatable(CombatWitch, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})

function CombatWitch.new()
    local self = setmetatable({}, CombatWitch)
    return self
end

function CombatWitch:Roaming()
    local selfPlayer = GetSelfPlayer()
    if selfPlayer and selfPlayer:CheckCurrentAction("BT_Skill_Fireball_Ing") then
        selfPlayer:DoActionAtPosition("BT_Skill_Fireball_Shot", selfPlayer.Position, 500)
    end
end

function CombatWitch:Attack(monsterActor)
    
    local selfPlayer = GetSelfPlayer()
    
    local ABILITY_DAGGER_STAB_ID = SkillsHelper.GetKnownSkillId(CombatWitch.ABILITY_DAGGER_STAB_IDS)
    --	local ABILITY_STAFF_ATTACK_ID = SkillsHelper.GetFirstKnownSpell(CombatWitch.ABILITY_STAFF_ATTACK_IDS)
    local ABILITY_FIREBALL_ID = SkillsHelper.GetKnownSkillId(CombatWitch.ABILITY_FIREBALL_IDS)
    local ABILITY_MAGIC_ARROW_ID = SkillsHelper.GetKnownSkillId(CombatWitch.ABILITY_MAGIC_ARROW_IDS)
    local ABILITY_LIGHTNING_CHAIN_ID = SkillsHelper.GetKnownSkillId(CombatWitch.ABILITY_LIGHTNING_CHAIN_IDS)
    
    if monsterActor and selfPlayer then
        
        local actorPosition = monsterActor.Position
            
        if selfPlayer:CheckCurrentAction("BT_Skill_Fireball_Ing") then
            print("Launch fireball !")
            selfPlayer:DoActionAtPosition("BT_Skill_Fireball_Shot",actorPosition,500)
        end
            
        if actorPosition.Distance3DFromMe > monsterActor.BodySize + 1900 then
            Navigator.MoveTo(actorPosition)
        else
            
            if not selfPlayer.IsActionPending then                
                
                if ABILITY_FIREBALL_ID ~= 0 and
                    actorPosition.Distance3DFromMe > (monsterActor.BodySize + 800) and
                    SkillsHelper.IsSkillUsable(ABILITY_FIREBALL_ID) and
                    not selfPlayer:IsSkillOnCooldown(ABILITY_FIREBALL_ID)
                    then
                    print("Use Fireball")
                    Navigator.Stop()
                    selfPlayer:UseSkillAtPosition(ABILITY_FIREBALL_ID,actorPosition, 5000)
                    return
                end
                
                if ABILITY_DAGGER_STAB_ID ~= 0 and 
                    actorPosition.Distance3DFromMe < monsterActor.BodySize + 150 and
                    not selfPlayer:IsSkillOnCooldown(ABILITY_DAGGER_STAB_ID)
                then
                    print("Use Dagger Stab")
                    selfPlayer:UseSkillAtPosition(ABILITY_DAGGER_STAB_ID, actorPosition, 500)
                    return
                end
                
                if ABILITY_MAGIC_ARROW_ID ~= 0 and 
                    SkillsHelper.IsSkillUsable(ABILITY_MAGIC_ARROW_ID) and
                    not selfPlayer:IsSkillOnCooldown(ABILITY_MAGIC_ARROW_ID)
                then
                    print("Use Magic Arrow")
                    Navigator.Stop()
                    selfPlayer:UseSkillAtPosition(ABILITY_MAGIC_ARROW_ID, actorPosition, 300)
                    return
                end
                
                if actorPosition.Distance3DFromMe > monsterActor.BodySize + 150 then
                    Navigator.MoveTo(actorPosition)
                    return
                end
                Navigator.Stop()               
                
                selfPlayer:Interact(monsterActor) -- Auto attack for the win !
                
            end
            
        end
    end
end

return CombatWitch()