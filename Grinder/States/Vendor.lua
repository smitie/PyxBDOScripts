VendorState = { }
VendorState.__index = VendorState
VendorState.Name = "Vendor"

setmetatable(VendorState, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function VendorState.new()
  local self = setmetatable({}, VendorState)
  self.LastVendorTickcount = 0
  self.ArrivedToVendorTickcount = 0
  self.RequestedItemsList = false
  self.RequestedItemListTickcount = 0
  self.ItemSold = false
  return self
end

function VendorState:NeedToRun()
        
    local selfPlayer = GetSelfPlayer()
    
    if Pyx.System.TickCount - self.LastVendorTickcount < 60000 then
        return false
    end
    
    if not selfPlayer then
        return false
    end
    
    if not selfPlayer.IsAlive then
        return false
    end
    
    if not ProfileEditor.CurrentProfile:HasVendor() then
        return false
    end
    
    if Bot.VendorForced then
        return true
    end
    
    if Bot.Settings.VendorOnInventoryFull and
        selfPlayer.Inventory.FreeSlots <= 1 and
        table.length(self:GetItemsToSell()) > 0 and
        Navigator.CanMoveTo(ProfileEditor.CurrentProfile:GetVendorPosition()) then
        return true
    end
    
    if Bot.Settings.VendorOnWeight and
        selfPlayer.WeightPercent >= 95 and
        table.length(self:GetItemsToSell()) > 0 and
        Navigator.CanMoveTo(ProfileEditor.CurrentProfile:GetVendorPosition()) then
        return true
    end
    
    return false
end

function VendorState:Exit()
    if Dialog.IsTalking then
        Dialog.ClickExit()
    end
end

function VendorState:Run()
    
    local selfPlayer = GetSelfPlayer()
    local vendorPosition = ProfileEditor.CurrentProfile:GetVendorPosition()
    
    if vendorPosition.Distance3DFromMe > 300 then
        Bot.CallCombatRoaming()
        Navigator.MoveTo(vendorPosition)
    else
        Navigator.Stop()
        local npcs = GetNpcs()
        if table.length(npcs) > 0 then
            table.sort(npcs, function(a,b) return a.Position:GetDistance3D(vendorPosition) < b.Position:GetDistance3D(vendorPosition) end)
            local npc = npcs[1]
            if vendorPosition:GetDistance3D(vendorPosition) < 1000 then
                if self.ArrivedToVendorTickcount == 0 then
                    self.ArrivedToVendorTickcount = Pyx.System.TickCount
                elseif Pyx.System.TickCount - self.ArrivedToVendorTickcount > 5000 then
                    print("Vendor procedure done")
                    self.LastVendorTickcount = Pyx.System.TickCount
                    self.RequestedItemsList = false
                    self.ItemSold = false
                    Bot.VendorForced = false
                    if ProfileEditor.CurrentProfile:HasWarehouse() and Bot.Settings.WarehouseAfterVendor then
                    Bot.WarehouseForced = true
                    end
                    if Dialog.IsTalking then
                        Dialog.ClickExit()
                    end
                else
                    if Dialog.IsTalking then
                        if not self.RequestedItemsList then
                            print("Request items list ...")
                            BDOLua.Execute("npcShop_requestList(2)")
                            self.RequestedItemsList = true
                            self.RequestedItemListTickcount = Pyx.System.TickCount
                        end
                        if self.RequestedItemsList and Pyx.System.TickCount - self.RequestedItemListTickcount > 2000 and not self.ItemSold then
                            for k,v in pairs(self:GetItemsToSell()) do
                                print("Sell item : " .. v.ItemEnchantStaticStatus.Name)
                                v:RequestSellItem(npc)
                            end
                            self.ItemSold = true
                        end
                    else
                        npc:InteractNpc()
                    end
                end
            end
        end 
    end
    
end

function VendorState:GetItemsToSell()
    local itemsToSell = { }
    local selfPlayer = GetSelfPlayer()
    if selfPlayer then
        for k,v in pairs(selfPlayer.Inventory.Items) do
            if Bot.Settings:CanSellItem(v) then
                table.insert(itemsToSell, v)
            end
        end
    end
    return itemsToSell
end



