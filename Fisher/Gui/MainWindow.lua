------------------------------------------------------------------------------
-- Variables
-----------------------------------------------------------------------------

MainWindow = { }
------------------------------------------------------------------------------
-- Internal variables (Don't touch this if you don't know what you are doing !)
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- MainWindow Functions
-----------------------------------------------------------------------------

function MainWindow.DrawMainWindow()
    local valueChanged = false
    local _, shouldDisplay = ImGui.Begin("Fisher", true, ImVec2(400, 400), -1.0)
    if shouldDisplay then
        if ImGui.CollapsingHeader("Bot status", "id_gui_status", true, true) then
            local player = GetSelfPlayer()
            ImGui.Columns(2)
            ImGui.Text("State")
            ImGui.NextColumn()
            ImGui.Text((function() if Bot.Running and Bot.Fsm.CurrentState  then return Bot.Fsm.CurrentState.Name else return 'N/A' end end)(player))
            ImGui.NextColumn()
            ImGui.Text("Name")
            ImGui.NextColumn()
            ImGui.Text((function(player) if player  then return player.Name else return 'Disconnected' end end)(player))
            ImGui.NextColumn()
            ImGui.Columns(1)
            if not Bot.Running then
                if ImGui.Button("Start##btn_start_bot", ImVec2(ImGui.GetContentRegionAvailWidth() / 2, 20)) then
                    Bot.Start()
                end
                ImGui.SameLine()
                if ImGui.Button("Profile editor", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
                    ProfileEditor.Visible = true
                end
            else
                if ImGui.Button("Stop##btn_stop_bot", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
                    Bot.Stop()
                end
            end
        end       
        
        if ImGui.CollapsingHeader("Vendor", "id_gui_vendor", true, false) then
           _,Bot.Settings.VendorOnInventoryFull = ImGui.Checkbox("Vendor when inventory is full##id_guid_vendor_full_inventory", Bot.Settings.VendorOnInventoryFull)
           _,Bot.Settings.VendorOnWeight = ImGui.Checkbox("Vendor when you are too heavy##id_guid_vendor_weight", Bot.Settings.VendorOnWeight)
           _,Bot.Settings.VendorWhite = ImGui.Checkbox("##id_guid_vendor_sell_white", Bot.Settings.VendorWhite)
           ImGui.SameLine()
           ImGui.TextColored(ImVec4(1,1,1,1), "Sell white")
           _,Bot.Settings.VendorGreen = ImGui.Checkbox("##id_guid_vendor_sell_green", Bot.Settings.VendorGreen)
           ImGui.SameLine()
           ImGui.TextColored(ImVec4(0.20,1,0.20,1), "Sell green")
           _,Bot.Settings.VendorBlue = ImGui.Checkbox("##id_guid_vendor_sell_blue", Bot.Settings.VendorBlue)
           ImGui.SameLine()
           ImGui.TextColored(ImVec4(0.40,0.6,1,1), "Sell blue")
        end
        ImGui.End()
    end
end

function MainWindow.OnDrawGuiCallback()
    MainWindow.DrawMainWindow()
end

