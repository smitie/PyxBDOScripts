---------------------------------------------
-- GUI Variables
---------------------------------------------

g_ShowTraceline = false


---------------------------------------------
-- GUI Functions
---------------------------------------------

function DrawPlayers()
    _, g_ShowTraceline = ImGui.Checkbox("Draw tracelines", g_ShowTraceline)
    ImGui.Columns(2, "Horses")
    ImGui.Separator()
    ImGui.Text("Name")
    ImGui.NextColumn()
    ImGui.Text("Distance")
    ImGui.NextColumn()
    ImGui.Separator()
    local characters = GetActors();
    table.sort(characters, function(a,b) return a.Position.Distance3DFromMe < b.Position.Distance3DFromMe end)
    for k,v in pairs(characters) do
        if string.find(v.Name,"horse") then         
            ImGui.Text(v.Name)
            ImGui.NextColumn()

            ImGui.Text(tostring(math.floor(v.Position.Distance3DFromMe)) .. " yards")
            ImGui.NextColumn()
        end
    end
    ImGui.Columns(1)
    ImGui.Spacing()
end

function OnRender3D()
    if g_ShowTraceline then
        local characters = GetActors();
        table.sort(characters, function(a,b) return a.Position.Distance3DFromMe < b.Position.Distance3DFromMe end)
        local linesList = { }
        local selfPlayer = GetSelfPlayer()
        local count = 0
        for k,v in pairs(characters) do
            if string.find(v.Name,"horse") then 
                local distance = v.Position.Distance3DFromMe
                local color = 0xFFFF0000
                if distance < 1000 then -- Red 
                    color = 0xFFFF0000
                elseif distance < 2000 then -- Yellow 
                    color = 0xFFFFFF00
                else -- Green
                    color = 0xFF00FF00
                end
                table.insert(linesList,{selfPlayer.Position.X,selfPlayer.Position.Y+150,selfPlayer.Position.Z,color})
                table.insert(linesList,{v.Position.X,v.Position.Y+150,v.Position.Z,color})
                count = count + 1
            end
        end
        
        if count > 0 then
            Renderer.Draw3DLinesList(linesList)
        end
    end
end

function OnDrawGuiCallback()
	local shouldDisplay;
	_, shouldDisplay = ImGui.Begin("Horse radar", true, ImVec2(300, 300), -1.0)
	if shouldDisplay then	
        DrawPlayers()
        ImGui.End()
	end
end

Pyx.System.RegisterCallback("OnDrawGui", OnDrawGuiCallback)
Pyx.System.RegisterCallback("OnRender3D", OnRender3D)