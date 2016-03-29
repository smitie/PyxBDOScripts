---------------------------------------------
-- GUI Variables
---------------------------------------------

g_drawActors_ShowNpcs = false
g_drawActors_ShowCharacters = false
g_drawActors_ShowPlayers = false
g_drawActors_ShowCollects = false
g_drawActors_ShowDeadBodies = false
g_drawActors_ShowMonsters = false
g_drawActors_ShowVehicles = false

---------------------------------------------
-- GUI Functions
---------------------------------------------

function DrawActorsInfo()
    if ImGui.CollapsingHeader("World actors", "id_world_actors") then
        _, g_drawActors_ShowPlayers = ImGui.Checkbox("Show Players", g_drawActors_ShowPlayers)
        ImGui.SameLine()
        _, g_drawActors_ShowNpcs = ImGui.Checkbox("Show NPCs", g_drawActors_ShowNpcs)
        ImGui.SameLine()
        _, g_drawActors_ShowMonsters = ImGui.Checkbox("Show Monsters", g_drawActors_ShowMonsters)
        ImGui.SameLine()
        _, g_drawActors_ShowCharacters = ImGui.Checkbox("Show Characters", g_drawActors_ShowCharacters)
        _, g_drawActors_ShowDeadBodies = ImGui.Checkbox("Show Dead Bodies", g_drawActors_ShowDeadBodies)
        ImGui.SameLine()
        _, g_drawActors_ShowCollects = ImGui.Checkbox("Show Collects", g_drawActors_ShowCollects)
        ImGui.SameLine()
        _, g_drawActors_ShowVehicles = ImGui.Checkbox("Show Vehicles", g_drawActors_ShowVehicles)
        ImGui.Columns(4, "Actors")
        ImGui.Separator()
        ImGui.Text("Name")
        ImGui.NextColumn()
        ImGui.Text("Distance")
        ImGui.NextColumn()
        ImGui.Text("More")
        ImGui.NextColumn()
        ImGui.Text("Action")
        ImGui.NextColumn()
        ImGui.Separator()
        local characters = GetActors();
        table.sort(characters, function(a,b) return a.Position.Distance3DFromMe < b.Position.Distance3DFromMe end)
        for k,v in pairs(characters) do
            if 
            (v.IsNpc and g_drawActors_ShowNpcs) or
            (v.IsCharacter and g_drawActors_ShowCharacters) or
            (v.IsMonster and g_drawActors_ShowMonsters) or
            (v.IsDeadBody and g_drawActors_ShowDeadBodies) or
            (v.IsVehicle and g_drawActors_ShowVehicles) or
            (v.IsCollect and g_drawActors_ShowCollects) or
            (v.IsPlayer and g_drawActors_ShowPlayers) 
            then
                ImGui.Text(v.Name)
                ImGui.NextColumn()

                ImGui.Text(tostring(math.floor(v.Position.Distance3DFromMe)) .. " yards")
                ImGui.NextColumn()

                if ImGui.CollapsingHeader("Expand", tostring(v.Key)) then
                    ImGui.Text("Pointer :")
                    ImGui.SameLine();
                    ImGui.Text(v.Pointer)
                    
                    ImGui.Text("Key :")
                    ImGui.SameLine();
                    ImGui.Text(v.Key)
                    
                    ImGui.Text("Action :")
                    ImGui.SameLine();
                    ImGui.Text(v.CurrentActionName)

                    ImGui.Text("Health :")
                    ImGui.SameLine();
                    ImGui.Text(tostring(v.Health) .. " / " .. tostring(v.MaxHealth))

                    ImGui.Text("CanAttack :")
                    ImGui.SameLine();
                    ImGui.Text(tostring(v.CanAttack))

                    ImGui.Text("Interactable :")
                    ImGui.SameLine();
                    ImGui.Text(tostring(v.IsInteractable))

                    ImGui.Text("IsLootInteraction :")
                    ImGui.SameLine();
                    ImGui.Text(tostring(v.IsLootInteraction))

                    ImGui.Text("BodySize :")
                    ImGui.SameLine();
                    ImGui.Text(tostring(v.BodySize))

                    ImGui.Text("BodyHeight :")
                    ImGui.SameLine();
                    ImGui.Text(tostring(v.BodyHeight))

                    ImGui.Text("Tribe :")
                    ImGui.SameLine();
                    ImGui.Text(tostring(v.CharacterStaticStatus.TribeType))
                end
                ImGui.NextColumn()

                if ImGui.Button("Move##" .. tostring(v.Key)) then
                    GetSelfPlayer():MoveTo(v.Position)
                end
                ImGui.SameLine()
                if ImGui.Button("Interact##" .. tostring(v.Key)) then
                    GetSelfPlayer():Interact(v)
                end
                ImGui.NextColumn()
            end
        end
        ImGui.Columns(1)
        ImGui.Spacing()
    end
end

function DrawInventoryInfo()
    local selfPlayer = GetSelfPlayer()
    if selfPlayer and ImGui.CollapsingHeader("Inventory items", "id_inventory_items") then
        ImGui.Columns(3, "inventory_items")
        ImGui.Separator()
        ImGui.Text("Name")
        ImGui.NextColumn()
        ImGui.Text("More")
        ImGui.NextColumn()
        ImGui.Text("Action")
        ImGui.NextColumn()
        ImGui.Separator()
        for k,v in pairs(selfPlayer.Inventory.Items) do
            ImGui.Text(v.ItemEnchantStaticStatus.Name)
            ImGui.NextColumn()

            if ImGui.CollapsingHeader("Expand", tostring(v.InventoryIndex)) then
                ImGui.Text("ItemId :")
                ImGui.SameLine();
                ImGui.Text(v.ItemEnchantStaticStatus.ItemId)
                
                ImGui.Text("Inventory index :")
                ImGui.SameLine();
                ImGui.Text(v.InventoryIndex)
                
                ImGui.Text("Count :")
                ImGui.SameLine();
                ImGui.Text(v.Count)
                
                ImGui.Text("Type :")
                ImGui.SameLine();
                ImGui.Text(v.ItemEnchantStaticStatus.Type)
                
                ImGui.Text("Classify :")
                ImGui.SameLine();
                ImGui.Text(v.ItemEnchantStaticStatus.Classify)
                
                ImGui.Text("Grade :")
                ImGui.SameLine();
                ImGui.Text(v.ItemEnchantStaticStatus.Grade)
                
                ImGui.Text("Endurance :")
                ImGui.SameLine();
                ImGui.Text(v.Endurance .. " / " .. v.MaxEndurance)
                
                ImGui.Text("IsFishingRod :")
                ImGui.SameLine();
                ImGui.Text(tostring(v.ItemEnchantStaticStatus.IsFishingRod))
            end
            ImGui.NextColumn()

            if ImGui.Button("Use##" .. tostring(v.InventoryIndex)) then
                v:UseItem()
            end
            ImGui.NextColumn()
        end
        ImGui.Columns(1)
        ImGui.Spacing()
    end
end

function OnDrawGuiCallback()
	local shouldDisplay;
	_, shouldDisplay = ImGui.Begin("BDO :: Debug", true, ImVec2(600, 600), -1.0)
	if shouldDisplay then
	
            DrawActorsInfo()
            DrawInventoryInfo()

            ImGui.End()
	end
end

Pyx.System.RegisterCallback("OnDrawGui", OnDrawGuiCallback)