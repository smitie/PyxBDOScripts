TradeManagerState = { }
TradeManagerState.__index = TradeManagerState
TradeManagerState.Name = "TradeManager"

setmetatable(TradeManagerState, {
    __call = function(cls, ...)
        return cls.new(...)
    end,
} )

function TradeManagerState.new()
    local self = setmetatable( { }, TradeManagerState)
    self.LastTradeManagerTickcount = 0
    self.ArrivedToTradeManagerTickcount = 0
    self.RequestedItemsList = false
    self.RequestedItemListTickcount = 0
    return self
end

function TradeManagerState:NeedToRun()

    local selfPlayer = GetSelfPlayer()

    if not selfPlayer then
        return false
    end

    if selfPlayer.CurrentActionName == "FISHING_WAIT" then
        return false
    end

    if not selfPlayer.IsAlive then
        return false
    end

    if not ProfileEditor.CurrentProfile:HasTradeManager() then
        return false
    end

    if Bot.TradeManagerForced and Navigator.CanMoveTo(ProfileEditor.CurrentProfile:GetTradeManagerPosition()) then
        return true
    end

    if Pyx.System.TickCount - self.LastTradeManagerTickcount < 120000 then
        return false
    end

    if Bot.Settings.TradeManagerOnInventoryFull and
        selfPlayer.Inventory.FreeSlots <= 2 and
        table.length(self:GetItemsToSell()) > 0 and
        Navigator.CanMoveTo(ProfileEditor.CurrentProfile:GetTradeManagerPosition()) then
        return true
    end

    return false
end

function TradeManagerState:Exit()
    if Dialog.IsTalking then
        Dialog.ClickExit()
    end
end

function TradeManagerState:Run()

    local selfPlayer = GetSelfPlayer()
    local TradeManagerPosition = ProfileEditor.CurrentProfile:GetTradeManagerPosition()

    if TradeManagerPosition.Distance3DFromMe > 300 then
        Navigator.MoveTo(TradeManagerPosition)
        local equippedItem = selfPlayer:GetEquippedItem(INVENTORY_SLOT_RIGHT_HAND)
        if equippedItem ~= nil then
            if equippedItem.ItemEnchantStaticStatus.IsFishingRod then
                selfPlayer:UnequipItem(INVENTORY_SLOT_RIGHT_HAND)

            end

        end
    else
        Navigator.Stop()
        local npcs = GetNpcs()
        if table.length(npcs) > 0 then
            table.sort(npcs, function(a, b) return a.Position:GetDistance3D(TradeManagerPosition) < b.Position:GetDistance3D(TradeManagerPosition) end)
            local npc = npcs[1]
            if TradeManagerPosition:GetDistance3D(TradeManagerPosition) < 1000 then
                if self.ArrivedToTradeManagerTickcount == 0 then
                    self.ArrivedToTradeManagerTickcount = Pyx.System.TickCount
                elseif Pyx.System.TickCount - self.ArrivedToTradeManagerTickcount > 5000 then
                    print("TradeManager procedure done")
                    self.ArrivedToTradeManagerTickcount = 0
                    self.LastTradeManagerTickcount = Pyx.System.TickCount
                    self.RequestedItemsList = false
                    Bot.TradeManagerForced = false
                    if ProfileEditor.CurrentProfile:HasWarehouse() and Bot.Settings.WarehouseAfterTradeManager then
                        Bot.WarehouseForced = true
                    end
                    if ProfileEditor.CurrentProfile:HasVendor() and Bot.Settings.VendorafterTradeManager then
                        Bot.VendorForced = true
                    end
                    if TradeMarket.IsTrading then
                        TradeMarket.Close()
                    end
                    Dialog.ClickExit()
                else
                    if Dialog.IsTalking then
                        if not self.RequestedItemsList then
                            print("Request items list ...")
                            BDOLua.Execute("npcShop_requestList()")
                            self.RequestedItemsList = true
                            self.RequestedItemListTickcount = Pyx.System.TickCount
                        end
                        if TradeMarket.IsTrading then
                            TradeMarket.SellAll()
                        end
                    else
                        npc:InteractNpc()
                    end
                end
            end
        end
    end

end

function TradeManagerState:GetItemsToSell()
    local itemsToSell = { }
    local selfPlayer = GetSelfPlayer()
    if selfPlayer then
        for k, v in pairs(selfPlayer.Inventory.Items) do
            if v.ItemEnchantStaticStatus.IsTradeAble then
                table.insert(itemsToSell, v)
            end
        end
    end
    return itemsToSell
end



