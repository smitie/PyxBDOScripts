CombatWarrior = { }
CombatWarrior.__index = CombatWarrior
CombatWarrior.Author = "Unreal"

CombatWarrior.CHARGING_THRUST = { 1022, 1130, 1131, 1132 }
CombatWarrior.SPINNING_SLASH = { 1021, 1127, 1128, 1129, 1041 }
CombatWarrior.CHOPPING_KICK = { 1144, 712, 1145 }
CombatWarrior.HEAVY_STRIKE = { 1020, 1083, 1084 }
CombatWarrior.GUARD = { 1019 }
CombatWarrior.SHIELD_CHARGE = { 305 }

setmetatable(CombatWarrior, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function CombatWarrior.new()
  local instance = {}
  local self = setmetatable(instance, CombatWarrior)
  instance.cooldowns = {}
  instance.lastActor = nil
  instance.lastBlock = Pyx.System.TickCount
  instance.lastDodge = Pyx.System.TickCount
  return self
end

function CombatWarrior:CastWithCooldown(target,spellId,cooldown,spellAnimationTime)
    local selfPlayer = GetSelfPlayer()
    --print("Attempting to cast " .. spellId)
    if self.cooldowns[spellId] ~= nil then
        -- Check cooldown
        local timeStamp = Pyx.System.TickCount
        if self.cooldowns[spellId] < timeStamp and 
           SkillsHelper.IsSkillUsable(spellId) then
            selfPlayer:UseSkillAtPosition(spellId, target.Position, spellAnimationTime)
            self.cooldowns[spellId] = Pyx.System.TickCount + cooldown
            return true
        end
    else
        -- Not in the table just add it and cast it 
        selfPlayer:UseSkillAtPosition(spellId, target.Position, spellAnimationTime)
        self.cooldowns[spellId] = Pyx.System.TickCount + cooldown
        return true
    end
    --print("Spell on cooldown")
    return false
end

function CombatWarrior:GetMonsterCount()
    local monsters = GetMonsters()
    local monsterCount = 0
    for k, v in pairs(monsters) do
        if v.IsAggro then
            monsterCount = monsterCount + 1
        end
    end
    return monsterCount
end



function CombatWarrior:CastAbility(monsterActor)
    local selfPlayer = GetSelfPlayer()
    local actorPosition = monsterActor.Position
    local CHARGING_THRUST = SkillsHelper.GetKnownSkillId(CombatWarrior.CHARGING_THRUST)
    local SPINNING_SLASH = SkillsHelper.GetKnownSkillId(CombatWarrior.SPINNING_SLASH)
    local CHOPPING_KICK = SkillsHelper.GetKnownSkillId(CombatWarrior.CHOPPING_KICK)
    local HEAVY_STRIKE = SkillsHelper.GetKnownSkillId(CombatWarrior.HEAVY_STRIKE)
    

    Navigator.Stop()
        
    if not selfPlayer.IsActionPending then                           
        if self:CastWithCooldown(monsterActor,CHOPPING_KICK,4000,1500) then
            return true
        end
        -- If we have less than 4 mobs try single target
        if  self:GetMonsterCount() < 4 then
            if self:CastWithCooldown(monsterActor,SPINNING_SLASH,0,1500) then
                return true
            end
        else
            -- Aoe the fuckers
            if self:CastWithCooldown(monsterActor,SPINNING_SLASH,5000,1500) then
                return true
            end
            if self:CastWithCooldown(monsterActor,HEAVY_STRIKE,0,1500) then
                return true
            end
        end
        -- default to heavy strike for lower levels
        if self:CastWithCooldown(monsterActor,HEAVY_STRIKE,0,1500) then
                return true
        end
    end
    
end

function CombatWarrior:DodgeAndBlock(tarPos)
    local selfPlayer = GetSelfPlayer()
    -- Experimental blocking
    if Pyx.System.TickCount - self.lastBlock > 10000 then
        if not selfPlayer:CheckCurrentAction("BT_skill_Defence_Ing") and not selfPlayer:CheckCurrentAction("BT_skill_Defence_Ing2") then
            if SkillsHelper.IsSkillUsable(GUARD) then
                selfPlayer:UseSkillAtPosition(GUARD, tarPos, 2000)
                self.lastBlock = Pyx.System.TickCount
                return
            end
        end               
    end
    if Pyx.System.TickCount - self.lastDodge > 6000 then        
        if Pyx.System.TickCount % 2 == 0 then
            selfPlayer:DoActionAtPosition("BT_ROLL_R",tarPos,0)
        else
            selfPlayer:DoActionAtPosition("BT_ROLL_L",tarPos,0)
        end        
        self.lastDodge = Pyx.System.TickCount
        return                              
    end
end

function CombatWarrior:Attack(monsterActor)
    local GUARD = SkillsHelper.GetKnownSkillId(CombatWarrior.GUARD)   
    local SHIELD_CHARGE = SkillsHelper.GetKnownSkillId(CombatWarrior.SHIELD_CHARGE)   
    local actorPosition = monsterActor.Position
    local CHARGING_THRUST = SkillsHelper.GetKnownSkillId(CombatWarrior.CHARGING_THRUST)
    local selfPlayer = GetSelfPlayer()
    if monsterActor then
    
         if actorPosition.Distance3DFromMe > monsterActor.BodySize + 150 then
            -- We can use charging thrust for movement ! 
            if self:CastWithCooldown(monsterActor,CHARGING_THRUST,4000,1500) then
                return
            end
            --[[
            if not selfPlayer:CheckCurrentAction("BT_RUN_SPRINT") then            
                selfPlayer:DoActionAtPosition("BT_RUN_SPRINT",actorPosition,0)
                self.lastActor = monsterActor
            end
            ]]--
            Navigator.MoveTo(actorPosition)
        else
            if(self:CastAbility(monsterActor)) then
                -- If we have cast an ability
                self:DodgeAndBlock(monsterActor.Position)
            else
                -- Otherwise
                -- Auto attacks man
                selfPlayer:Interact(monsterActor) 
                self:DodgeAndBlock(monsterActor.Position)
            end    
        end
         
    end
end

return CombatWarrior()