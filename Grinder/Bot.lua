Bot = { }
Bot.Settings = Settings()
Bot.Running = false
Bot.Fsm = FSM()
Bot.Combat = nil
Bot.CombatPull = nil
-- Converted to CommonStates
Bot.WarehouseState = WarehouseState()
Bot.VendorState = VendorState()
Bot.DeathState = DeathState()
Bot.RepairState = RepairState()
Bot.LootState = LootActorState()
Bot.BuildNavigationState = BuildNavigationState()

-- Not Converted yet
Bot.PotionsState = PotionsState()
Bot.ConsumablesState = ConsumablesState()
Bot.CombatFightState = CombatFightState()
Bot.CombatPullState = CombatPullState()

--Bot.Fsm:AddState(RoamingState())
--Bot.Fsm:AddState(IdleState())


function Bot.Start()
    if not Bot.Running then

        Bot.ResetStats()
        Bot.Combat = nil
        Bot.RepairState.Forced = false
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

        Bot.DeathState.CallWhenCompleted = Bot.Death

        Bot.RepairState.Settings.NpcName = currentProfile.RepairNpcName
        Bot.RepairState.Settings.NpcPosition = currentProfile.RepairNpcPosition
        Bot.RepairState.CallWhileMoving = Bot.StateMoving

        Bot.LootState.CallWhileMoving = Bot.StateMoving

        ProfileEditor.Visible = false
        Navigation.MesherEnabled = false

        Bot.Fsm = FSM()
        Bot.Fsm.ShowOutput = true
        Bot.Fsm:AddState(Bot.BuildNavigationState)
        Bot.Fsm:AddState(Bot.DeathState)
        Bot.Fsm:AddState(Bot.PotionsState)
        Bot.Fsm:AddState(Bot.ConsumablesState)
        Bot.Fsm:AddState(Bot.CombatFightState)
        Bot.Fsm:AddState(Bot.LootState)
        Bot.Fsm:AddState(Bot.VendorState)
        Bot.Fsm:AddState(Bot.WarehouseState)
        Bot.Fsm:AddState(Bot.RepairState)
        Bot.Fsm:AddState(Bot.CombatPullState)
        Bot.Fsm:AddState(RoamingState())
        Bot.Fsm:AddState(IdleState())

        Bot.Running = true
    end
end

function Bot.Death(state)
    if Bot.DeathState.Settings.ReviveMethod == DeathState.SETTINGS_ON_DEATH_ONLY_CALL_WHEN_COMPLETED then
        Bot.Stop()
    end
end

function Bot.Stop()
    Navigator.Stop()
    Bot.Running = false
    Bot.WarehouseState:Reset()
    Bot.VendorState:Reset()
    Bot.RepairState:Reset()

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
    Bot.Settings.WarehouseSettings = Bot.WarehouseState.Settings
    Bot.Settings.VendorSettings = Bot.VendorState.Settings
    Bot.Settings.DeathSettings = Bot.DeathState.Settings
    Bot.Settings.RepairSettings = Bot.RepairState.Settings
    Bot.Settings.LootSettings = Bot.LootState.Settings
    Bot.Settings.DeathSettings = Bot.DeathState.Settings


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
    print("State Complete!")
end


Bot.ResetStats()
