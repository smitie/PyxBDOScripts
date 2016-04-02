------------------------------------------------------------------------------
-- Variables
-----------------------------------------------------------------------------

MainWindow = { }
------------------------------------------------------------------------------
-- Internal variables (Don't touch this if you don't know what you are doing !)
-----------------------------------------------------------------------------
MainWindow.InventoryComboSelectedIndex = 0
MainWindow.InventoryName = { }
MainWindow.InventorySelectedIndex = 0

MainWindow.WarehouseComboSelectedIndex = 0
MainWindow.WarehouseSelectedIndex = 0
MainWindow.WarehouseName = { }

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
            ImGui.Text(( function() if Bot.Running and Bot.Fsm.CurrentState then return Bot.Fsm.CurrentState.Name else return 'N/A' end end)(player))
            ImGui.NextColumn()
            ImGui.Text("Name")
            ImGui.NextColumn()
            ImGui.Text(( function(player) if player then return player.Name else return 'Disconnected' end end)(player))
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
                if ImGui.Button("Force trade manager##btn_force_trademanager", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
                    Bot.TradeManagerState.Forced = true
                end
            end
        end
        if ImGui.CollapsingHeader("Looting", "id_gui_looting", true, false) then
            _, Bot.Settings.IgnoreUntradeAbleItems = ImGui.Checkbox("Ignore untradeable items##id_guid_looting_ignore_untradeable", Bot.Settings.IgnoreUntradeAbleItems)
        end
        MainWindow.UpdateInventoryList()
        if ImGui.CollapsingHeader("Inventory Management", "id_gui_inv_manage", true, false) then
        ImGui.Text("Always Delete these Items")
                    valueChanged, MainWindow.InventoryComboSelectedIndex = ImGui.Combo("##id_guid_inv_inventory_combo_select", MainWindow.InventoryComboSelectedIndex, MainWindow.InventoryName)
            if valueChanged then
                local inventoryName = MainWindow.InventoryName[MainWindow.InventoryComboSelectedIndex]
                if not table.find(Bot.Settings.InventoryDeleteSettings.DeleteItems, inventoryName) then

                    table.insert(Bot.Settings.InventoryDeleteSettings.DeleteItems, inventoryName)
                end
                MainWindow.InventoryComboSelectedIndex = 0
            end
            _, MainWindow.InventorySelectedIndex = ImGui.ListBox("##id_guid_inv_Delete", MainWindow.InventorySelectedIndex,Bot.Settings.InventoryDeleteSettings.DeleteItems, 5)
            if ImGui.Button("Remove Item##id_guid_inv_delete_remove", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
                if MainWindow.InventorySelectedIndex > 0 and MainWindow.InventorySelectedIndex <= table.length(Bot.Settings.InventoryDeleteSettings.DeleteItems) then
                    table.remove(Bot.Settings.InventoryDeleteSettings.DeleteItems, MainWindow.InventorySelectedIndex)
                    MainWindow.InventorySelectedIndex = 0
                end
            end

end
        if ImGui.CollapsingHeader("Vendor", "id_gui_vendor", true, false) then
            _, Bot.Settings.VendorSettings.VendorOnInventoryFull = ImGui.Checkbox("Vendor when inventory is full##id_guid_vendor_full_inventory", Bot.Settings.VendorSettings.VendorOnInventoryFull)
            _, Bot.Settings.VendorafterTradeManager = ImGui.Checkbox("Vendor after Trader##id_guid_vendor_full_inventory", Bot.Settings.VendorafterTradeManager)
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
            _, Bot.Settings.WarehouseAfterTradeManager = ImGui.Checkbox("Deposit after trader##id_guid_warehouse_after_trader", Bot.Settings.WarehouseAfterTradeManager)
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

        if ImGui.CollapsingHeader("Trade Manager", "id_gui_trademanager", true, false) then
            _, Bot.Settings.TradeManagerSettings.TradeManagerOnInventoryFull = ImGui.Checkbox("Sell at trade manager when inventory is full##id_guid_trademanager_full_inventory", Bot.Settings.TradeManagerSettings.TradeManagerOnInventoryFull)
        end
        ImGui.End()
    end
end

function MainWindow.OnDrawGuiCallback()
    MainWindow.DrawMainWindow()
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
