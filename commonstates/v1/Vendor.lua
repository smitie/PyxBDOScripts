VendorState = { }
VendorState.__index = VendorState
VendorState.Name = "Vendor"
VendorState.DefaultSettings =  {NpcName = "", NpcPosition = { X = 0, Y = 0, Z = 0}, VendorOnInventoryFull = true, VendorOnWeight = true, 
VendorWhite = true, VendorGreen = true, VendorBlue = false, VendorGold = false, IgnoreItemsNamed = {}}

setmetatable(VendorState, {
    __call = function(cls, ...)
        return cls.new(...)
    end,
} )

function VendorState.new()
    local self = setmetatable( { }, VendorState)
        self.Settings = VendorState.DefaultSettings

    self.State = 0
    -- 0 = Nothing, 1 = Moving, 2 = Arrived
    self.DepositList = nil

    self.LastUseTimer = nil
    self.SleepTimer = nil
    self.CurrentDepositList = { }
    self.Forced = false

    -- Overideable functions
    self.ItemCheckFunction = nil
    self.CallWhenCompleted = nil
    self.CallWhileMoving = nill

    return self
end

function VendorState:NeedToRun()

    local selfPlayer = GetSelfPlayer()

    if self.LastUseTimer ~= nil and not self.LastUseTimer:Expired() then
        return false
    end

    if not selfPlayer then
        return false
    end

    if not selfPlayer.IsAlive then
        return false
    end

    if not self:HasNpc() then
        return false
    end

    if self.Forced and Navigator.CanMoveTo(self:GetPosition()) then
        return true
    else
        self.Forced = false

    end

    if self.Settings.VendorOnInventoryFull and
        selfPlayer.Inventory.FreeSlots <= 1 and
        table.length(self:GetItemsToSell()) > 0 and
        Navigator.CanMoveTo(self:GetPosition()) then
        self.Forced = true
        return true
    end

    if self.Settings.VendorOnWeight and
        selfPlayer.WeightPercent >= 95 and
        table.length(self:GetItemsToSell()) > 0 and
        Navigator.CanMoveTo(self:GetPosition()) then
        self.Forced = true
        return true
    end

    return false
end

function VendorState:HasNpc()
    return string.len(self.Settings.NpcName) > 0
end

function VendorState:GetPosition()
    return Vector3(self.Settings.NpcPosition.X, self.Settings.NpcPosition.Y, self.Settings.NpcPosition.Z)
end


function VendorState:Exit()
    if self.State > 0 then
        if Dialog.IsTalking then
            Dialog.ClickExit()
        end
        self.State = 0
        self.LastUseTimer = PyxTimer:New(6000)
        self.LastUseTimer:Start()
        self.SleepTimer = nil
        self.Forced = false

    end
end

function VendorState:Run()
    local selfPlayer = GetSelfPlayer()
    local vendorPosition = self:GetPosition()

    if vendorPosition.Distance3DFromMe > 300 then
    if self.CallWhileMoving then
        self.CallWhileMoving(self)
    end

        Navigator.MoveTo(vendorPosition)
        if self.State > 1 then
            self:Exit()
        end
        self.State = 1
        return
    end
    Navigator.Stop()

    if self.SleepTimer ~= nil and self.SleepTimer:IsRunning() and not self.SleepTimer:Expired() then
        return
    end


    local npcs = GetNpcs()

    if table.length(npcs) < 1 then
        print("Vendor could not find any NPC's")
        self:Exit()
        return
    end
    table.sort(npcs, function(a, b) return a.Position:GetDistance3D(vendorPosition) < b.Position:GetDistance3D(vendorPosition) end)

    local npc = npcs[1]

    if self.State == 1 then
        npc:InteractNpc()
        self.SleepTimer = PyxTimer:New(1)
        self.SleepTimer:Start()
        self.State = 2
        return
    end


    if self.State == 2 then
        if not Dialog.IsTalking then
            print("Vendor Error Dialog didn't open")
            self:Exit()
            return
        end
        BDOLua.Execute("npcShop_requestList()")
        self.SleepTimer = PyxTimer:New(1)
        self.SleepTimer:Start()
        self.State = 3
        self.CurrentDepositList = self:GetItems()
        return
    end

    if self.State == 3 then

        if table.length(self.CurrentDepositList) < 1 then
            print("Vendor done list")
            self.State = 4
    if self.CallWhenCompleted then
        self.CallWhenCompleted(self)
    end
    self:Exit()
            return
        end

        local item = self.CurrentDepositList[1]
        local itemPtr = selfPlayer.Inventory:GetItemByName(item.name)
        if itemPtr ~= nil then
            print(itemPtr.InventoryIndex .. " Sell item : " .. itemPtr.ItemEnchantStaticStatus.Name)
            itemPtr:RequestSellItem(npc)
            self.SleepTimer = PyxTimer:New(0.5)
            self.SleepTimer:Start()
        end
        table.remove(self.CurrentDepositList, 1)
        return
    end

    self:Exit()

end


function VendorState:CanSellGrade(item)
  
    if self.Settings.VendorWhite and item.ItemEnchantStaticStatus.Grade == ITEM_GRADE_WHITE then
        return true
    end
    
    if self.Settings.VendorGreen and item.ItemEnchantStaticStatus.Grade == ITEM_GRADE_GREEN then
        return true
    end
    
    if self.Settings.VendorBlue and item.ItemEnchantStaticStatus.Grade == ITEM_GRADE_BLUE then
        return true
    end

    if self.Settings.VendorGold and item.ItemEnchantStaticStatus.Grade == ITEM_GRADE_GOLD then
        return true
    end

    return false
end


function VendorState:GetItems()
    local itemsToDeposit = { }
    local selfPlayer = GetSelfPlayer()
    if selfPlayer then
        for k, v in pairs(selfPlayer.Inventory.Items) do
        if self.ItemCheckFunction then
            if self.ItemCheckFunction(v) then
                table.insert(itemsToDeposit, { slot = v.InventoryIndex, name = v.ItemEnchantStaticStatus.Name, count = v.Count })
            end
        else
        if not table.find(self.Settings.IgnoreItemsNamed,v.ItemEnchantStaticStatus.Name)  and self:CanSellGrade(v) == true then
                table.insert(itemsToDeposit, { slot = v.InventoryIndex, name = v.ItemEnchantStaticStatus.Name, count = v.Count })
                end

        end
        end
    end
    return itemsToDeposit
end
