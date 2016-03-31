CombatRanger = { }
CombatRanger.__index = CombatRanger

CombatRanger.ABILITY_BOW_SKILL_IDS = {98,98,99,100,101, 1002, 1086, 1211, 1332,1333 }
CombatRanger.ABILITY_DAGGER_OF_PROTECTION_IDS = {307,308,309 }
CombatRanger.ABILITY_CHARGING_WIND_IDS = {1006,1091,1092,1093 }
CombatRanger.ABILITY_ROUND_KICK_IDS = {1003,1029,1087,1119,1250, 1252, 1251 }
CombatRanger.ABILITY_BLASTING_GUST_IDS = {1126,1125,1077 }
CombatRanger.ABILITY_EVASIVE_EXLPOSION_SHOT_IDS = {1257,1116,1016 }
CombatRanger.ABILITY_PINPOINT_IDS = {322,323,324 }
CombatRanger.ABILITY_EVASIVE_SHOT_IDS = {1012,1107,1253 }
CombatRanger.DaggerMode = 1


setmetatable(CombatRanger, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function CombatRanger.new()
	local self = setmetatable({}, CombatRanger)
	self.Mode = 0
	self.ModeTimer = nil
	self.CombatTimer = nil
	return self
end


function CombatRanger:Attack(monsterActor,isPulling)
	local ABILITY_BOW_SKILL_ID = SkillsHelper.GetKnownSkillId(CombatRanger.ABILITY_BOW_SKILL_IDS)
	local ABILITY_DAGGER_OF_PROTECTION_ID = SkillsHelper.GetKnownSkillId(CombatRanger.ABILITY_DAGGER_OF_PROTECTION_IDS)
	local ABILITY_CHARGING_WIND_ID = SkillsHelper.GetKnownSkillId(CombatRanger.ABILITY_CHARGING_WIND_IDS)
	local ABILITY_ROUND_KICK_ID = SkillsHelper.GetKnownSkillId(CombatRanger.ABILITY_ROUND_KICK_IDS)
	local ABILITY_BLASTING_GUST_ID = SkillsHelper.GetKnownSkillId(CombatRanger.ABILITY_BLASTING_GUST_IDS)
	local ABILITY_EVASIVE_EXLPOSION_SHOT_ID = SkillsHelper.GetKnownSkillId(CombatRanger.ABILITY_EVASIVE_EXLPOSION_SHOT_IDS)
	local ABILITY_PINPOINT_ID = SkillsHelper.GetKnownSkillId(CombatRanger.ABILITY_PINPOINT_IDS)
	local ABILITY_EVASIVE_SHOT_ID = SkillsHelper.GetKnownSkillId(CombatRanger.ABILITY_EVASIVE_SHOT_IDS)

	local selfPlayer = GetSelfPlayer()

    if monsterActor and selfPlayer then
        local actorPosition = monsterActor.Position

        if self.CombatTimer == nil or self.CombatTimer:Expired() then
			self.CombatTimer = PyxTimer:New(3)
			self.CombatTimer:Start()
			self.Mode = 0
		end

		if self.Mode == 10 and self.ModeTimer ~= nil and self.ModeTimer:Expired() then
			print("Mode 10 Timer Expired")
			self.Mode = 0
		end

        
		if selfPlayer:CheckCurrentAction("BT_skill_WindblowShot_Ing") then
            print("Launch Windblow!")
            if ABILITY_BLASTING_GUST_ID == 1077 then
                selfPlayer:DoActionAtPosition("BT_skill_WindblowShot_Fire",actorPosition,500)
            elseif ABILITY_BLASTING_GUST_ID == 1125 then
                selfPlayer:DoActionAtPosition("BT_skill_WindblowShot_Fire_UP",actorPosition,500)
else
                selfPlayer:DoActionAtPosition("BT_skill_WindblowShot_Fire_UP2",actorPosition,500)
            end
                self.Mode = 0
			return
		end



		if actorPosition.Distance3DFromMe > monsterActor.BodySize + 1700 then
			self.Mode = 0
			Navigator.MoveTo(actorPosition)
		else
			Navigator.Stop()
            


			if selfPlayer.IsActionPending then
				return
			end
            

			if self.Mode == 10 then
			print("Launch JumpShot!")
				self.Mode = 0
				selfPlayer:DoActionAtPosition("BT_Attack_JumpShot_Faster",actorPosition,1000)
				self.CombatTimer:Reset()
				return
			end

            
				if actorPosition.Distance3DFromMe <= monsterActor.BodySize + 450 and  
			ABILITY_EVASIVE_EXLPOSION_SHOT_ID ~= 0 and
			SkillsHelper.IsSkillUsable(ABILITY_EVASIVE_EXLPOSION_SHOT_ID) 
--				not selfPlayer:IsSkillOnCooldown(ABILITY_EVASIVE_EXLPOSION_SHOT_ID)
			then
				print("Evasive Shot!")
				local rnd = math.random(1,3)
				if ABILITY_EVASIVE_EXLPOSION_SHOT_ID == 1016 then
					if rnd == 1 then
						selfPlayer:DoActionAtPosition("BT_skill_TurnArrow",actorPosition,450)
					elseif rnd == 2 then
						selfPlayer:DoActionAtPosition("BT_skill_TurnArrow_L",actorPosition,450)
					elseif rnd == 3 then
						selfPlayer:DoActionAtPosition("BT_skill_TurnArrow_R",actorPosition,450)
					end
				elseif ABILITY_EVASIVE_EXLPOSION_SHOT_ID == 1016 then   
					if rnd == 1 then
						selfPlayer:DoActionAtPosition("BT_skill_TurnArrow_UP",actorPosition,450)
					elseif rnd == 2 then
						selfPlayer:DoActionAtPosition("BT_skill_TurnArrow_L_UP",actorPosition,450)
					elseif rnd == 3 then
						selfPlayer:DoActionAtPosition("BT_skill_TurnArrow_R_UP",actorPosition,450)
					end
                    else
					if rnd == 1 then
						selfPlayer:DoActionAtPosition("BT_skill_TurnArrow_UP2",actorPosition,450)
					elseif rnd == 2 then
						selfPlayer:DoActionAtPosition("BT_skill_TurnArrow_L_UP2",actorPosition,450)
					elseif rnd == 3 then
						selfPlayer:DoActionAtPosition("BT_skill_TurnArrow_R_UP2",actorPosition,450)
					end
                    
				end
				self.Mode= 10
				self.ModeTimer = PyxTimer:New(2)
				self.ModeTimer:Start()
				self.CombatTimer:Reset()
				      
				return
            
			end            

            
			-- Range stuff
			--[[
			if actorPosition.Distance3DFromMe < monsterActor.BodySize + 1000 and
			selfPlayer.Mana >= 40 and ABILITY_BLASTING_GUST_ID ~= 0 and 
			SkillsHelper.IsSkillUsable(ABILITY_BLASTING_GUST_ID) and
			not selfPlayer:IsSkillOnCooldown(ABILITY_BLASTING_GUST_ID)
			then
				selfPlayer:UseSkillAtPosition(ABILITY_BLASTING_GUST_ID,actorPosition, 2000)
			end
            --]]
            

			self.Mode = self.Mode + 1
			
			if self.Mode > 4 then
				self.Mode = 1
			end

			if self.Mode == 1 and ABILITY_PINPOINT_ID ~= 0 and 
			not selfPlayer:IsSkillOnCooldown(ABILITY_PINPOINT_ID)
			then
				print("Using PinPoint")
				local ability = "BT_skill_Weakpoint"

				if ABILITY_PINPOINT_ID == 322 then
					selfPlayer:DoActionAtPosition (ability,actorPosition, 600)
				elseif ABILITY_PINPOINT_ID == 323 then
					selfPlayer:DoActionAtPosition (ability.."_UP",actorPosition, 600)
				elseif ABILITY_PINPOINT_ID == 324 then
					selfPlayer:DoActionAtPosition (ability.."_UP2",actorPosition, 600)
				end

				self.CombatTimer:Reset()
				return
			end

			if self.Mode == 2  and actorPosition.Distance3DFromMe > monsterActor.BodySize + 400 and
			ABILITY_CHARGING_WIND_ID ~=0 and
			not selfPlayer:IsSkillOnCooldown(ABILITY_CHARGING_WIND_ID) -- and selfPlayer.ManaPercent > 50
			then
				print("Using ChargeWind")
				selfPlayer:UseSkillAtPosition(ABILITY_CHARGING_WIND_ID,actorPosition,1000)
				self.CombatTimer:Reset()
				return
                
			end

			if self.Mode == 3 and actorPosition.Distance3DFromMe < monsterActor.BodySize + 1200 and ABILITY_EVASIVE_SHOT_ID ~= 0 and 
			not selfPlayer:IsSkillOnCooldown(ABILITY_EVASIVE_SHOT_ID)
			then
				print("Using Evasive Shot: "..ABILITY_EVASIVE_SHOT_ID)
				local rnd = math.random(1,2)
				local ability = "BT_STOP_ATTACK_R_START"

				if rnd == 1 then
					ability = "BT_STOP_ATTACK_L_START"
				end



				if ABILITY_EVASIVE_SHOT_ID == 1012 then
					selfPlayer:DoActionAtPosition (ability,actorPosition, 600)
				elseif ABILITY_EVASIVE_SHOT_ID == 1107 then
					selfPlayer:DoActionAtPosition (ability.."_UP",actorPosition, 600)
				elseif ABILITY_EVASIVE_SHOT_ID == 1253 then
					selfPlayer:DoActionAtPosition (ability.."_UP2",actorPosition, 600)
				end
				self.CombatTimer:Reset()
				return
			end
			
            if self.Mode == 4 and actorPosition.Distance3DFromMe < monsterActor.BodySize + 1400 and
            ABILITY_BLASTING_GUST_ID ~= 0 and 
            SkillsHelper.IsSkillUsable(ABILITY_BLASTING_GUST_ID) and
            not selfPlayer:IsSkillOnCooldown(ABILITY_BLASTING_GUST_ID)
            then
                selfPlayer:UseSkillAtPosition(ABILITY_BLASTING_GUST_ID,actorPosition, 2000)
            end


            selfPlayer:Interact(monsterActor) -- Auto attack for the win !
			self.CombatTimer:Reset()
		end
        
	end
    
end


return CombatRanger()

