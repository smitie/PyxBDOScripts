---------------------------------------------
-- GUI Variables
---------------------------------------------

g_DoRefresh = false
g_Timer = nil
g_FirstTick = true
mode = 0 -- 0 = wait , 1 = after restore

---------------------------------------------
-- GUI Functions
---------------------------------------------

function Restore()
    BDOLua.Execute("Panel_WorkerManager:SetShow(true)")
    BDOLua.Execute("HandleClicked_workerManager_RestoreAll()")
    BDOLua.Execute("workerRestoreAll_Confirm(0)")
    mode = 1
end

function Resend()
    BDOLua.Execute("HandleClicked_workerManager_ReDoAll()")
    BDOLua.Execute("workerManager_Close()")
    --BDOLua.Execute("Panel_WorkerManager:SetShow(false)")
    g_Timer = Pyx.System.TickCount
    mode = 0
end

function RefreshWorkers()
    if mode == 0 then
        Restore()
    elseif mode == 1 then    
        Resend()
    end
end

function OnDrawGuiCallback()
	local shouldDisplay;
    
	_, shouldDisplay = ImGui.Begin("Worker refresh", true, ImVec2(300, 50), -1.0)
	if shouldDisplay then	
        if g_Timer == nil then
            _, g_DoRefresh = ImGui.Checkbox("Refreshing workers in 60 seconds", g_DoRefresh)
        else
            _, g_DoRefresh = ImGui.Checkbox("Refreshing workers in ".. 60-math.floor((Pyx.System.TickCount - g_Timer)/1000) ..  " seconds", g_DoRefresh)
        end
        
        if g_DoRefresh then
            if g_Timer == nil then
                -- Start
                RefreshWorkers()
            else
                -- No previous run
                if Pyx.System.TickCount - g_Timer > 60000 then
                    RefreshWorkers()
                end
            end            
        end
        ImGui.End()
	end
end

Pyx.System.RegisterCallback("OnDrawGui", OnDrawGuiCallback)
