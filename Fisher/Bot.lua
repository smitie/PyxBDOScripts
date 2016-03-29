Bot = { }
Bot.Settings = Settings()
Bot.Running = false
Bot.TradeManagerForced = false
Bot.Fsm = FSM()

function Bot.Start()
    if not Bot.Running then
        
        Bot.ResetStats()
        Bot.SaveSettings()
        
        local currentProfile = ProfileEditor.CurrentProfile
        
        if not currentProfile then
            print("No profile loaded !")
            return
        end
        
        if not currentProfile:HasFishSpot() then
            print("Profile require a fish spot !")
            return
        end
        
        
        ProfileEditor.Visible = false
        Navigation.MesherEnabled = false
        Bot.TradeManagerForced = false
        
        Bot.Fsm = FSM()
        Bot.Fsm.ShowOutput = true
        Bot.Fsm:AddState(BuildNavigationState())
        Bot.Fsm:AddState(LootState())
        Bot.Fsm:AddState(HookFishHandleGameState())
        Bot.Fsm:AddState(HookFishState())
        Bot.Fsm:AddState(UnequipFishingRodState())
        Bot.Fsm:AddState(TradeManagerState())
        Bot.Fsm:AddState(VendorState())
   		Bot.Fsm:AddState(WarehouseState())
        Bot.Fsm:AddState(EquipFishingRodState())
        Bot.Fsm:AddState(StartFishingState())
        Bot.Fsm:AddState(MoveToFishingSpotState())
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

Bot.ResetStats()
