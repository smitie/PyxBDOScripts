RepairState = { }
RepairState.__index = RepairState
RepairState.Name = "Repair"

setmetatable(RepairState, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function RepairState.new()
  local self = setmetatable({}, RepairState)
  self.LastRepairTickcount = 0
  self.ArrivedToRepairTickcount = 0
  self.HasRepaired = false
  return self
end

function RepairState:NeedToRun()
        
    local selfPlayer = GetSelfPlayer()
    
    if Pyx.System.TickCount - self.LastRepairTickcount < 60000 then
        return false
    end
    
    if not selfPlayer then
        return false
    end
    
    if not selfPlayer.IsAlive then
        return false
    end
    
    if not ProfileEditor.CurrentProfile:HasRepair() then
        return false
    end
    
    if Bot.RepairForced then
        return true
    end
    
    for k,v in pairs(selfPlayer.EquippedItems) do
        if v.HasEndurance and v.EndurancePercent <= 20 then
            if Navigator.CanMoveTo(ProfileEditor.CurrentProfile:GetRepairPosition()) then
                return true
            else
                return false
            end
        end
    end
    
    return false
end

function RepairState:Exit()
    if Dialog.IsTalking then
        Dialog.ClickExit()
    end
end

function RepairState:Run()
    
    local selfPlayer = GetSelfPlayer()
    local repairPosition = ProfileEditor.CurrentProfile:GetRepairPosition()
    
    if repairPosition.Distance3DFromMe > 300 then
        Bot.CallCombatRoaming()
        Navigator.MoveTo(repairPosition)
    else
        Navigator.Stop()
        local npcs = GetNpcs()
        if table.length(npcs) > 0 then
            table.sort(npcs, function(a,b) return a.Position:GetDistance3D(repairPosition) < b.Position:GetDistance3D(repairPosition) end)
            local npc = npcs[1]
            if repairPosition:GetDistance3D(repairPosition) < 1000 then
                if self.ArrivedToRepairTickcount == 0 then
                    self.ArrivedToRepairTickcount = Pyx.System.TickCount
                elseif Pyx.System.TickCount - self.ArrivedToRepairTickcount > 5000 then
                    print("Repair procedure done")
                    self.LastRepairTickcount = Pyx.System.TickCount
                    Bot.RepairForced = false
                    self.HasRepaired = false
                    self.ArrivedToRepairTickcount = 0
                    if Dialog.IsTalking then
                        Dialog.ClickExit()
                    end
                else
                    if Dialog.IsTalking then
                        if Pyx.System.TickCount - self.ArrivedToRepairTickcount > 2000 and not self.HasRepaired then
                            for k,v in pairs(selfPlayer.EquippedItems) do
                                if v.HasEndurance and v.EndurancePercent < 100 then
                                    print("Repair item : " .. v.ItemEnchantStaticStatus.Name)
                                    v:Repair(npc)
                                end
                            end
                            self.HasRepaired = true
                        end
                    else
                        npc:InteractNpc()
                    end
                end
            end
        end 
    end
    
end


