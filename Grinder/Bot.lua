Bot = { }
Bot.Settings = Settings()
Bot.Running = false
Bot.Fsm = FSM()
Bot.Combat = nil
Bot.CombatPull = nil
Bot.RepairForced = false
Bot.WarehouseState = WarehouseState()
Bot.VendorState = VendorState()


function Bot.Start()
    if not Bot.Running then
        
        Bot.ResetStats()
        Bot.Combat = nil
        Bot.RepairForced = false
        Bot.WarehouseState.Forced = false
        Bot.VendorState.Forced = false

		Bot.SaveSettings()
        
        local combatScriptFile = Bot.Settings.CombatScript
        
        local combatScriptFunc = loadfile("Combats/" .. combatScriptFile)
        
        if not combatScriptFunc then
            print("Unable to load combat script !")
            return
        end
        
        Bot.Combat = combatScriptFunc()
        
        if not Bot.Combat then
            print("Unable to load combat script !")
            return
        end
        
        if not Bot.Combat.Attack then
            print("Combat script doesn't have .Attack function !")
            return
        end
        
        if not Bot.Combat.Pull then
            print("Combat script doesn't have Seperate .Pull function Setting Pull to Attack")
        end

            local currentProfile = ProfileEditor.CurrentProfile
        
        if not currentProfile then
            print("No profile loaded !")
            return
        end
        
        if table.length(currentProfile:GetHotspots()) < 2 then
            print("Profile require at least 2 hotspots !")
            return
        end
        Bot.WarehouseState.Settings.NpcName = currentProfile.WarehouseNpcName
        Bot.WarehouseState.Settings.NpcPosition = currentProfile.WarehouseNpcPosition
        Bot.WarehouseState.CallWhenCompleted = Bot.StateComplete
        Bot.WarehouseState.CallWhileMoving = Bot.StateMoving

        Bot.VendorState.Settings.NpcName = currentProfile.VendorNpcName
        Bot.VendorState.Settings.NpcPosition = currentProfile.VendorNpcPosition
        Bot.VendorState.CallWhenCompleted = Bot.StateComplete
        Bot.VendorState.CallWhileMoving = Bot.StateMoving

        
        ProfileEditor.Visible = false
        Navigation.MesherEnabled = false
        
        Bot.Fsm = FSM()
        Bot.Fsm.ShowOutput = true
        Bot.Fsm:AddState(BuildNavigationState())
        Bot.Fsm:AddState(DeathState())
        Bot.Fsm:AddState(PotionsState())
		Bot.Fsm:AddState(ConsumablesState())
		Bot.Fsm:AddState(CombatFightState())
        Bot.Fsm:AddState(LootActorState())
        Bot.Fsm:AddState(Bot.VendorState)
		Bot.Fsm:AddState(Bot.WarehouseState)
		Bot.Fsm:AddState(RepairState())
        Bot.Fsm:AddState(CombatPullState())
        Bot.Fsm:AddState(RoamingState())
        Bot.Fsm:AddState(IdleState())
        
        Bot.Running = true
    end
end

function Bot.Stop()
    Navigator.Stop()
    Bot.Running = false
end

function Bot.ResetStats()
    
end

function Bot.OnPulse()
    if Bot.Running then
        Bot.Fsm:Pulse()
    end
end

function Bot.CallCombatAttack(monsterActor, isPull)
    if Bot.Combat and Bot.Combat.Attack then
        Bot.Combat:Attack(monsterActor, isPull)
    end
end

function Bot.CallCombatRoaming()
    if Bot.Combat and Bot.Combat.Roaming then
        Bot.Combat:Roaming()
    end
end

function Bot.SaveSettings()
    local json = JSON:new()
    Pyx.FileSystem.WriteFile("Settings.json", json:encode_pretty(Bot.Settings))
end

function Bot.LoadSettings()
    local json = JSON:new()
    Bot.Settings = Settings()
    table.merge(Bot.Settings, json:decode(Pyx.FileSystem.ReadFile("Settings.json")))
    if string.len(Bot.Settings.LastProfileName) > 0 then
        ProfileEditor.LoadProfile(Bot.Settings.LastProfileName)
    end
end

function Bot.StateMoving(state)
    Bot.CallCombatRoaming()
end


function Bot.StateComplete(state)

if state == Bot.VendorState then
if Bot.Settings.WarehouseAfterVendor == true then
Bot.WarehouseState.Forced = true
end
end
--[[
    if state == Bot.TradeManagerState then
        if Bot.Settings.VendorafterTradeManager == true then
            Bot.VendorState.Forced = true
        end
        if Bot.Settings.WarehouseAfterTradeManager == true then
            Bot.WarehouseState.Forced = true
        end
    elseif state == Bot.VendorState then
        if Bot.Settings.WarehouseAfterVendor == true then
            Bot.WarehouseState.Forced = true
        end

    end
    --]]
    print("State Complete!")
end


Bot.ResetStats()
