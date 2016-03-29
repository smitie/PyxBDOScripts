CombatValkyrie = { }
CombatValkyrie.__index = CombatValkyrie

CombatValkyrie.ABILITY_CHARGING_SLASH_IDS = {749,748,747}
CombatValkyrie.ABILITY_FORWARD_SLASH_IDS = {1478,1477,1476}
CombatValkyrie.ABILITY_SEVERING_LIGHT_IDS = {1482,1481,1480,1479}
CombatValkyrie.ABILITY_SWORD_OF_JUDGEMENT_IDS = {735,734,733,732}


setmetatable(CombatValkyrie, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function CombatValkyrie.new()
	local self = setmetatable({}, CombatValkyrie)
	self.SWORD_OF_JUDGEMENT_TIMER = PyxTimer:New(1)
	self.SWORD_OF_JUDGEMENT_COUNT = 0
	self.DOING_SWORD_OF_JUDGEMENT = false
	self.FORWARD_SLASH_TIMER = PyxTimer:New(1)
	self.FORWARD_SLASH_COUNT = 0
	self.DOING_FORWARD_SLASH = false
	self.DID_SEVERING_LIGHT = false
	return self
end


CombatValkyrie.SwordOfJudgement = function(self,monsterActor)
	local selfPlayer = GetSelfPlayer()

	--[[
	if not self.SWORD_OF_JUDGEMENT_TIMER:IsRunning() 
	or self.SWORD_OF_JUDGEMENT_TIMER:IsRunning() and self.SWORD_OF_JUDGEMENT_TIMER:Expired() 
	or self.DOING_SWORD_OF_JUDGEMENT == false
	then
		self.SWORD_OF_JUDGEMENT_COUNT = 0
		self.SWORD_OF_JUDGEMENT_TIMER:Stop()
	end
	--]]

	print("Sword Of Judgement")
	if self.SWORD_OF_JUDGEMENT_COUNT == 0 then
		selfPlayer:DoActionAtPosition("BT_Skill_RotationBash_A_1LV",monsterActor.Position,900)
	elseif self.SWORD_OF_JUDGEMENT_COUNT == 1 then
		selfPlayer:DoActionAtPosition("BT_Skill_RotationBash_B_1LV",monsterActor.Position,900)
	elseif self.SWORD_OF_JUDGEMENT_COUNT == 2 then
		selfPlayer:DoActionAtPosition("BT_Skill_RotationBash_C_1LV",monsterActor.Position,900)
	end

	self.SWORD_OF_JUDGEMENT_COUNT = self.SWORD_OF_JUDGEMENT_COUNT + 1
	self.SWORD_OF_JUDGEMENT_TIMER:Reset()
	self.SWORD_OF_JUDGEMENT_TIMER:Start()
	self.DOING_SWORD_OF_JUDGEMENT = true
	if self.SWORD_OF_JUDGEMENT_COUNT >= 3 then
		self.SWORD_OF_JUDGEMENT_COUNT = 0
		self.DOING_SWORD_OF_JUDGEMENT = false
	end

end


CombatValkyrie.FrontSlice = function(self,monsterActor)
	local selfPlayer = GetSelfPlayer()

--[[
	if not self.FORWARD_SLASH_TIMER:IsRunning() 
	or self.FORWARD_SLASH_TIMER:IsRunning() and self.FORWARD_SLASH_TIMER:Expired() 
	or self.DOING_FORWARD_SLASH == false
	then
		self.FORWARD_SLASH_COUNT = 0
		self.FORWARD_SLASH_TIMER:Stop()
	end
--]]
	print("Front Slice")
	if self.FORWARD_SLASH_COUNT == 0 then
		selfPlayer:DoActionAtPosition("BT_Skill_FrontSlice_UP",monsterActor.Position,900)
	elseif self.FORWARD_SLASH_COUNT == 1 then
		selfPlayer:DoActionAtPosition("BT_Skill_FrontSlice_B_UP",monsterActor.Position,900)
	elseif self.FORWARD_SLASH_COUNT == 2 then
		selfPlayer:DoActionAtPosition("BT_Skill_FrontSlice_RE_UP",monsterActor.Position,900)
	end

	self.FORWARD_SLASH_COUNT = self.FORWARD_SLASH_COUNT + 1
	self.FORWARD_SLASH_TIMER:Reset()
	self.FORWARD_SLASH_TIMER:Start()
	self.DOING_FORWARD_SLASH = true
	if self.FORWARD_SLASH_COUNT >= 3 then
		self.FORWARD_SLASH_COUNT = 1
		self.DOING_FORWARD_SLASH = false
	end


 
end


function CombatValkyrie:Attack(monsterActor)
    
	local ABILITY_CHARGING_SLASH_ID = SkillsHelper.GetKnownSkillId(CombatValkyrie.ABILITY_CHARGING_SLASH_IDS)
	local ABILITY_FORWARD_SLASH_ID = SkillsHelper.GetKnownSkillId(CombatValkyrie.ABILITY_FORWARD_SLASH_IDS)
	local ABILITY_SEVERING_LIGHT_ID = SkillsHelper.GetKnownSkillId(CombatValkyrie.ABILITY_SEVERING_LIGHT_IDS)
	local ABILITY_SWORD_OF_JUDGEMENT_ID = SkillsHelper.GetKnownSkillId(CombatValkyrie.ABILITY_SWORD_OF_JUDGEMENT_IDS)
    
	if monsterActor then
		local selfPlayer = GetSelfPlayer()
		local actorPosition = monsterActor.Position
		--[[]
        if actorPosition.Distance3DFromMe > monsterActor.BodySize + 150 and actorPosition.Distance3DFromMe <= monsterActor.BodySize + 300 and
            not selfPlayer.IsActionPending and 
            SkillsHelper.IsSkillUsable(ABILITY_CHARGING_SLASH_ID) and
            not selfPlayer:IsSkillOnCooldown(ABILITY_CHARGING_SLASH_ID)
            then
                    selfPlayer:DoActionAtPosition("BT_ACTION_CHARGE_AT_MOVING",actorPosition,1000)
return
        end
        --]]
        
		if not self.FORWARD_SLASH_TIMER:IsRunning() 
		or self.FORWARD_SLASH_TIMER:IsRunning() and self.FORWARD_SLASH_TIMER:Expired() then
			self.DOING_FORWARD_SLASH = false
			self.FORWARD_SLASH_COUNT = 0
			self.FORWARD_SLASH_TIMER:Stop()

		end

		if not self.SWORD_OF_JUDGEMENT_TIMER:IsRunning() 
		or self.SWORD_OF_JUDGEMENT_TIMER:IsRunning() and self.SWORD_OF_JUDGEMENT_TIMER:Expired() 
		then
			self.DOING_SWORD_OF_JUDGEMENT = false
			self.SWORD_OF_JUDGEMENT_COUNT = 0
			self.SWORD_OF_JUDGEMENT_TIMER:Stop()

		end



		if actorPosition.Distance3DFromMe > monsterActor.BodySize + 150 then
			Navigator.MoveTo(actorPosition)
		else
			Navigator.Stop()
			if selfPlayer.IsActionPending then
				return
			end

-- Severing Light
			if self.DID_SEVERING_LIGHT == false and self.DOING_SWORD_OF_JUDGEMENT == false and self.DOING_FORWARD_SLASH == false and SkillsHelper.IsSkillUsable(ABILITY_SEVERING_LIGHT_ID) and
			not selfPlayer:IsSkillOnCooldown(ABILITY_SEVERING_LIGHT_ID)
			then
				self.DID_SEVERING_LIGHT = true
				selfPlayer:UseSkillAtPosition(ABILITY_SEVERING_LIGHT_ID,actorPosition,800)
				return
			end
			self.DID_SEVERING_LIGHT = false
-- Sword Of Judgement
			if self.DOING_FORWARD_SLASH == false and SkillsHelper.IsSkillUsable(ABILITY_SWORD_OF_JUDGEMENT_ID) and
			not selfPlayer:IsSkillOnCooldown(ABILITY_SWORD_OF_JUDGEMENT_ID)
			then
				self.SwordOfJudgement(self,monsterActor)
				return
			end
			self.DOING_SWORD_OF_JUDGEMENT = false

-- Front Slice            
			if SkillsHelper.IsSkillUsable(ABILITY_FORWARD_SLASH_ID) and
			not selfPlayer:IsSkillOnCooldown(ABILITY_FORWARD_SLASH_ID)
			then
				self.FrontSlice(self,monsterActor)
				return
			end

-- Default Attack            
				selfPlayer:Interact(monsterActor) -- Auto attack for the win !
            
		end
	end
end

return CombatValkyrie()