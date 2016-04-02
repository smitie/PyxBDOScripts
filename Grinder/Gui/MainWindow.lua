------------------------------------------------------------------------------
-- Variables
-----------------------------------------------------------------------------

MainWindow = { }
MainWindow.HPPotionsComboBoxItems = { }
MainWindow.HPPotionsComboBoxSelected = 0
MainWindow.MPPotionsComboBoxItems = { }
MainWindow.HPPotionsComboBoxSelected = 0
MainWindow.AvailablesCombats = { }
MainWindow.CombatsComboBoxSelected = 0

MainWindow.InventoryComboSelectedIndex = 0
MainWindow.InventoryName = { }
MainWindow.InventorySelectedIndex = 0

MainWindow.FoodComboBoxItems = { }
MainWindow.FoodComboBoxSelected = 0

MainWindow.WarehouseComboSelectedIndex = 0
MainWindow.WarehouseSelectedIndex = 0
MainWindow.WarehouseName = { }

------------------------------------------------------------------------------
-- Internal variables (Don't touch this if you don't know what you are doing !)
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- MainWindow Functions
-----------------------------------------------------------------------------

function MainWindow.DrawMainWindow()
    local valueChanged = false
    local _, shouldDisplay = ImGui.Begin("Grinder", true, ImVec2(400, 400), -1.0)
    if shouldDisplay then
        if ImGui.CollapsingHeader("Bot status", "id_gui_status", true, true) then
            local player = GetSelfPlayer()
            ImGui.Columns(2)
            ImGui.Text("State")
            ImGui.NextColumn()
            ImGui.Text(( function() if Bot.Running and Bot.Fsm.CurrentState then return Bot.Fsm.CurrentState.Name else return 'N/A' end end)(player))
            ImGui.NextColumn()
            ImGui.Text("Name")
            ImGui.NextColumn()
            ImGui.Text(( function(player) if player then return player.Name else return 'Disconnected' end end)(player))
            ImGui.NextColumn()
            ImGui.Text("Health")
            ImGui.NextColumn()
            ImGui.Text(( function(player) if player then return player.Health .. " / " .. player.MaxHealth else return 'N / A' end end)(player))
            ImGui.NextColumn()
            ImGui.Text("Free slots")
            ImGui.NextColumn()
            ImGui.Text(( function(player) if player then return player.Inventory.FreeSlots else return 'N / A' end end)(player))
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
                if ImGui.Button("Force vendor", ImVec2(ImGui.GetContentRegionAvailWidth() / 2, 20)) then
                    Bot.VendorState.Forced = true
                    -- 				Bot.WarehouseForced = true
                end
                ImGui.SameLine()
                if ImGui.Button("Force repair", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
                    Bot.RepairState.Forced = true
                end
            end
        end

        if ImGui.CollapsingHeader("Combats", "id_gui_combats", true, false) then
            if not table.find(MainWindow.AvailablesCombats, Bot.Settings.CombatName) then
                table.insert(MainWindow.AvailablesCombats, Bot.Settings.CombatName)
            end
            valueChanged, MainWindow.CombatsComboBoxSelected = ImGui.Combo("Combat script##id_gui_combat_script", table.findIndex(MainWindow.AvailablesCombats, Bot.Settings.CombatScript), MainWindow.AvailablesCombats)
            if valueChanged then
                Bot.Settings.CombatScript = MainWindow.AvailablesCombats[MainWindow.CombatsComboBoxSelected]
                print("Combat script selected : " .. Bot.Settings.CombatScript)
            end
        end

        if ImGui.CollapsingHeader("Potions", "id_gui_potions", true, false) then
            MainWindow.UpdatePotionComboBox()
            if not table.find(MainWindow.HPPotionsComboBoxItems, Bot.Settings.HPPotionName) then
                table.insert(MainWindow.HPPotionsComboBoxItems, Bot.Settings.HPPotionName)
            end
            if not table.find(MainWindow.MPPotionsComboBoxItems, Bot.Settings.MPPotionName) then
                table.insert(MainWindow.MPPotionsComboBoxItems, Bot.Settings.MPPotionName)
            end
            valueChanged, MainWindow.HPPotionsComboBoxSelected = ImGui.Combo("Health potion##id_gui_health_potion", table.findIndex(MainWindow.HPPotionsComboBoxItems, Bot.Settings.HPPotionName), MainWindow.HPPotionsComboBoxItems)
            if valueChanged then
                Bot.Settings.HPPotionName = MainWindow.HPPotionsComboBoxItems[MainWindow.HPPotionsComboBoxSelected]
                print("HP potion selected : " .. Bot.Settings.HPPotionName)
            end
            valueChanged, MainWindow.MPPotionsComboBoxSelected = ImGui.Combo("Mana potion##id_gui_mana_potion", table.findIndex(MainWindow.MPPotionsComboBoxItems, Bot.Settings.MPPotionName), MainWindow.MPPotionsComboBoxItems)
            if valueChanged then
                Bot.Settings.MPPotionName = MainWindow.MPPotionsComboBoxItems[MainWindow.MPPotionsComboBoxSelected]
                print("MP potion selected : " .. Bot.Settings.MPPotionName)
            end
            valueChanged, Bot.Settings.HPPotionPercent = ImGui.SliderInt("Health percent##id_gui_potion_health_pct", Bot.Settings.HPPotionPercent, 1, 100)
            valueChanged, Bot.Settings.MPPotionPercent = ImGui.SliderInt("Mana percent##id_gui_potion_health_pct", Bot.Settings.MPPotionPercent, 1, 100)
        end

        if ImGui.CollapsingHeader("Consumables", "id_gui_Consumables", true, false) then
            MainWindow.UpdateFoodComboBox()
            if not table.find(MainWindow.FoodComboBoxItems, Bot.Settings.FoodName) then
                table.insert(MainWindow.FoodComboBoxItems, Bot.Settings.FoodName)
            end
            valueChanged, MainWindow.FoodComboBoxSelected = ImGui.Combo("Food##id_gui_health_potion", table.findIndex(MainWindow.FoodComboBoxItems, Bot.Settings.FoodName), MainWindow.FoodComboBoxItems)
            if valueChanged then
                Bot.Settings.FoodName = MainWindow.FoodComboBoxItems[MainWindow.FoodComboBoxSelected]
                print("Food selected : " .. Bot.Settings.FoodName)
            end
            valueChanged, Bot.Settings.FoodDuration = ImGui.SliderInt("Consume Food Mins##id_gui_food_duration", Bot.Settings.FoodDuration, 30, 90)

        end


        if ImGui.CollapsingHeader("Looting", "id_gui_looting", true, false) then
            _, Bot.Settings.LootSettings.TakeLoot = ImGui.Checkbox("Take loots##id_guid_looting_take_loot", Bot.Settings.LootSettings.TakeLoot)
        end

        if ImGui.CollapsingHeader("Death action", "id_gui_death_action", true, false) then
            if ImGui.RadioButton("Stop bot##death_action_stop_bot", Bot.Settings.DeathSettings.ReviveMethod == DeathState.SETTINGS_ON_DEATH_ONLY_CALL_WHEN_COMPLETED) then
            Bot.Settings.DeathSettings.ReviveMethod = DeathState.SETTINGS_ON_DEATH_ONLY_CALL_WHEN_COMPLETED
            end
            if ImGui.RadioButton("Revive at nearest node##death_action_revive_node", Bot.Settings.DeathSettings.ReviveMethod == DeathState.SETTINGS_ON_DEATH_REVIVE_NODE) then
            Bot.Settings.DeathSettings.ReviveMethod = DeathState.SETTINGS_ON_DEATH_REVIVE_NODE
            end
            if ImGui.RadioButton("Revive at nearest village##death_action_revive_village", Bot.Settings.DeathSettings.ReviveMethod == DeathState.SETTINGS_ON_DEATH_REVIVE_VILLAGE) then
            Bot.Settings.DeathSettings.ReviveMethod = DeathState.SETTINGS_ON_DEATH_REVIVE_VILLAGE
            end
        end

        MainWindow.UpdateInventoryList()

        if ImGui.CollapsingHeader("Vendor", "id_gui_vendor", true, false) then
            _, Bot.Settings.VendorSettings.VendorOnInventoryFull = ImGui.Checkbox("Vendor when inventory is full##id_guid_vendor_full_inventory", Bot.Settings.VendorSettings.VendorOnInventoryFull)
            _, Bot.Settings.VendorSettings.VendorOnWeight = ImGui.Checkbox("Vendor when you are too heavy##id_guid_vendor_weight", Bot.Settings.VendorSettings.VendorOnWeight)
            _, Bot.Settings.VendorSettings.VendorWhite = ImGui.Checkbox("##id_guid_vendor_sell_white", Bot.Settings.VendorSettings.VendorWhite)
            ImGui.SameLine()
            ImGui.TextColored(ImVec4(1, 1, 1, 1), "Sell white")
            _, Bot.Settings.VendorSettings.VendorGreen = ImGui.Checkbox("##id_guid_vendor_sell_green", Bot.Settings.VendorSettings.VendorGreen)
            ImGui.SameLine()
            ImGui.TextColored(ImVec4(0.20, 1, 0.20, 1), "Sell green")
            _, Bot.Settings.VendorSettings.VendorBlue = ImGui.Checkbox("##id_guid_vendor_sell_blue", Bot.Settings.VendorSettings.VendorBlue)
            ImGui.SameLine()
            ImGui.TextColored(ImVec4(0.40, 0.6, 1, 1), "Sell blue")

            valueChanged, MainWindow.InventoryComboSelectedIndex = ImGui.Combo("##id_guid_vendor_inventory_combo_select", MainWindow.InventoryComboSelectedIndex, MainWindow.InventoryName)
            if valueChanged then
                local inventoryName = MainWindow.InventoryName[MainWindow.InventoryComboSelectedIndex]
                if not table.find(Bot.Settings.VendorSettings.IgnoreItemsNamed, inventoryName) then

                    table.insert(Bot.Settings.VendorSettings.IgnoreItemsNamed, inventoryName)
                end
                MainWindow.InventoryComboSelectedIndex = 0
            end
            _, MainWindow.InventorySelectedIndex = ImGui.ListBox("##id_guid_vendor_neversell", MainWindow.InventorySelectedIndex, Bot.Settings.VendorSettings.IgnoreItemsNamed, 5)
            if ImGui.Button("Remove Item##id_guid_vendor_neversell_remove", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
                if MainWindow.InventorySelectedIndex > 0 and MainWindow.InventorySelectedIndex <= table.length(Bot.Settings.VendorSettings.IgnoreItemsNamed) then
                    table.remove(Bot.Settings.VendorSettings.IgnoreItemsNamed, MainWindow.InventorySelectedIndex)
                    MainWindow.InventorySelectedIndex = 0
                end
            end

        end
                if ImGui.CollapsingHeader("Warehouse", "id_gui_warehouse", true, false) then
            _, Bot.Settings.WarehouseAfterVendor = ImGui.Checkbox("Deposit after Vendor##id_guid_warehouse_after_vendor", Bot.Settings.WarehouseAfterVendor)
            _, Bot.Settings.WarehouseSettings.DepositMoney = ImGui.Checkbox("Deposit Money##id_guid_warehouse_deposit_money", Bot.Settings.WarehouseSettings.DepositMoney)
            _, Bot.Settings.WarehouseSettings.MoneyToKeep = ImGui.SliderInt("Money to Keep##id_gui_warehouse_keep_money", Bot.Settings.WarehouseSettings.MoneyToKeep, 0, 1000000)
            _, Bot.Settings.WarehouseSettings.DepositItems = ImGui.Checkbox("Deposit Items##id_guid_warehouse_deposit_items", Bot.Settings.WarehouseSettings.DepositItems)
            ImGui.Text("Never Deposit these Items")
            valueChanged, MainWindow.WarehouseComboSelectedIndex = ImGui.Combo("##id_guid_warehouse_inventory_combo_select", MainWindow.WarehouseComboSelectedIndex, MainWindow.InventoryName)
            if valueChanged then
                local inventoryName = MainWindow.InventoryName[MainWindow.WarehouseComboSelectedIndex]
                if not table.find(Bot.Settings.WarehouseSettings.IgnoreItemsNamed, inventoryName) then

                    table.insert(Bot.Settings.WarehouseSettings.IgnoreItemsNamed, inventoryName)
                end
                MainWindow.WarehouseComboSelectedIndex = 0
            end
            _, MainWindow.WarehouseSelectedIndex = ImGui.ListBox("##id_guid_warehouse_neverdeposit", MainWindow.WarehouseSelectedIndex, Bot.Settings.WarehouseSettings.IgnoreItemsNamed, 5)
            if ImGui.Button("Remove Item##id_guid_warehouse_neverdeposit_remove", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
                if MainWindow.WarehouseSelectedIndex > 0 and MainWindow.WarehouseSelectedIndex <= table.length(Bot.Settings.NeverWarehouse) then
                    table.remove(Bot.Settings.WarehouseSettings.IgnoreItemsNamed, MainWindow.WarehouseSelectedIndex)
                    MainWindow.WarehouseSelectedIndex = 0
                end
            end

        end


        --[[
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
			ImGui.Text("Never Sell these Items")

				MainWindow.UpdateInventoryList()
				valueChanged, MainWindow.InventoryComboSelectedIndex = ImGui.Combo("##id_guid_vendor_inventory_combo_select", MainWindow.InventoryComboSelectedIndex, MainWindow.InventoryName)
				if valueChanged then
					local inventoryName = MainWindow.InventoryName[MainWindow.InventoryComboSelectedIndex]
					if not table.find(Bot.Settings.NeverVendor, inventoryName) then

						table.insert(Bot.Settings.NeverVendor, inventoryName)
					end
					MainWindow.InventoryComboSelectedIndex = 0
				end
				_, MainWindow.InventorySelectedIndex = ImGui.ListBox("##id_guid_vendor_neversell", MainWindow.InventorySelectedIndex, Bot.Settings.NeverVendor, 5)
				if ImGui.Button("Remove Item##id_guid_vendor_neversell_remove", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
					if MainWindow.InventorySelectedIndex > 0 and MainWindow.InventorySelectedIndex <= table.length(Bot.Settings.NeverVendor) then
						table.remove(Bot.Settings.NeverVendor, MainWindow.InventorySelectedIndex)
						MainWindow.InventorySelectedIndex = 0
					end
				end
		end
        if ImGui.CollapsingHeader("Warehouse", "id_gui_warehouse", true, false) then
            _, Bot.Settings.WarehouseAfterVendor = ImGui.Checkbox("##id_guid_warehouse_after_vendor", Bot.Settings.WarehouseAfterVendor)
            ImGui.SameLine()
            ImGui.Text("Deposit Items after vendoring")
            _, Bot.Settings.WarehouseDepositMoney = ImGui.Checkbox("##id_guid_warehouse_deposit_money", Bot.Settings.WarehouseDepositMoney)
            ImGui.SameLine()
            ImGui.Text("Deposit Money")

            _, Bot.Settings.WarehouseKeepMoney = ImGui.SliderInt("Money to Keep##id_gui_warehouse_keep_money", Bot.Settings.WarehouseKeepMoney, 0, 1000000)

            _, Bot.Settings.WarehouseDepositItems = ImGui.Checkbox("##id_guid_warehouse_deposit_items", Bot.Settings.WarehouseDepositItems)
            ImGui.SameLine()
            ImGui.Text("Deposit Items")
            ImGui.Text("Never Deposit these Items")
            valueChanged, MainWindow.WarehouseComboSelectedIndex = ImGui.Combo("##id_guid_warehouse_inventory_combo_select", MainWindow.WarehouseComboSelectedIndex, MainWindow.InventoryName)
            if valueChanged then
                local inventoryName = MainWindow.InventoryName[MainWindow.WarehouseComboSelectedIndex]
                if not table.find(Bot.Settings.NeverWarehouse, inventoryName) then

                    table.insert(Bot.Settings.NeverWarehouse, inventoryName)
                end
                MainWindow.WarehouseComboSelectedIndex = 0
            end
            _, MainWindow.WarehouseSelectedIndex = ImGui.ListBox("##id_guid_warehouse_neverdeposit", MainWindow.WarehouseSelectedIndex, Bot.Settings.NeverWarehouse, 5)
            if ImGui.Button("Remove Item##id_guid_warehouse_neverdeposit_remove", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
                if MainWindow.WarehouseSelectedIndex > 0 and MainWindow.WarehouseSelectedIndex <= table.length(Bot.Settings.NeverWarehouse) then
                    table.remove(Bot.Settings.NeverWarehouse, MainWindow.WarehouseSelectedIndex)
                    MainWindow.WarehouseSelectedIndex = 0
                end
            end

        end
        --]]
        if ImGui.CollapsingHeader("Advanced", "id_gui_advanced", true, false) then
            ImGui.Text("Change with caution!!!")
            ImGui.Text(" ")
            _, Bot.Settings.Advanced.HotSpotRadius = ImGui.SliderInt("Hotspot Radius##id_gui_advanced_hs_radius", Bot.Settings.Advanced.HotSpotRadius, 500, 10000)
            _, Bot.Settings.LootSettings.LootRadius = ImGui.SliderInt("Loot Radius##id_gui_advanced_loot_radius", Bot.Settings.LootSettings.LootRadius, 500, 10000)
            _, Bot.Settings.Advanced.PullDistance = ImGui.SliderInt("Pull Distance##id_gui_advanced_pull_distance", Bot.Settings.Advanced.PullDistance, 500, 10000)
            _, Bot.Settings.Advanced.PullSecondsUntillIgnore = ImGui.SliderInt("Pull Seconds untill ignore##id_gui_advanced_pull_seconds", Bot.Settings.Advanced.PullSecondsUntillIgnore, 5, 30)
            _, Bot.Settings.Advanced.CombatMaxDistanceFromMe = ImGui.SliderInt("Combat Max Distance##id_gui_advanced_combat_maxdistance", Bot.Settings.Advanced.CombatMaxDistanceFromMe, 1000, 5000)
            ImGui.Text("Skip Pull between hotspots")
            ImGui.SameLine()
            _, Bot.Settings.Advanced.IgnorePullBetweenHotSpots = ImGui.Checkbox("##id_guid_advanced_pull_ignore_hotspots", Bot.Settings.Advanced.IgnorePullBetweenHotSpots)
            ImGui.Text("Ignore in combat between hotspots")
            ImGui.SameLine()
            _, Bot.Settings.Advanced.IgnoreInCombatBetweenHotSpots = ImGui.Checkbox("##id_guid_advanced_ignore_in_combat", Bot.Settings.Advanced.IgnoreInCombatBetweenHotSpots)
        end

        ImGui.End()
    end
end

function MainWindow.UpdateInventoryList()
    MainWindow.InventoryName = { }
    local selfPlayer = GetSelfPlayer()
    if selfPlayer then
        for k, v in pairs(selfPlayer.Inventory.Items) do

            if not table.find(MainWindow.InventoryName, v.ItemEnchantStaticStatus.Name) then
                table.insert(MainWindow.InventoryName, v.ItemEnchantStaticStatus.Name)
                --            print("Added: "..v.ItemEnchantStaticStatus.Name)
            end
        end
    end
end

function MainWindow.OnDrawGuiCallback()
    MainWindow.DrawMainWindow()
end

function MainWindow.RefreshAvailableProfiles()
    MainWindow.AvailablesCombats = { }
    for k, v in pairs(Pyx.FileSystem.GetFiles("Combats\\*.lua")) do
        table.insert(MainWindow.AvailablesCombats, v)

    end
end


function MainWindow.UpdatePotionComboBox()
    MainWindow.HPPotionsComboBoxItems = { "None" }
    MainWindow.MPPotionsComboBoxItems = { "None" }
    local selfPlayer = GetSelfPlayer()
    if selfPlayer then
        for k, v in pairs(selfPlayer.Inventory.Items) do
            if v.ItemEnchantStaticStatus.Type == 2 then
                if not table.find(MainWindow.HPPotionsComboBoxItems, v.ItemEnchantStaticStatus.Name) then
                    table.insert(MainWindow.HPPotionsComboBoxItems, v.ItemEnchantStaticStatus.Name)
                end
                if not table.find(MainWindow.MPPotionsComboBoxItems, v.ItemEnchantStaticStatus.Name) then
                    table.insert(MainWindow.MPPotionsComboBoxItems, v.ItemEnchantStaticStatus.Name)
                end
            end
        end
    end
end


function MainWindow.UpdateFoodComboBox()
    MainWindow.FoodComboBoxItems = { "None" }
    local selfPlayer = GetSelfPlayer()
    if selfPlayer then
        for k, v in pairs(selfPlayer.Inventory.Items) do
            if v.ItemEnchantStaticStatus.Type == 2 then
                if not table.find(MainWindow.FoodComboBoxItems, v.ItemEnchantStaticStatus.Name) then
                    table.insert(MainWindow.FoodComboBoxItems, v.ItemEnchantStaticStatus.Name)
                end
            end
        end
    end
end

MainWindow.RefreshAvailableProfiles()
