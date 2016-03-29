WarehouseState = { }
WarehouseState.__index = WarehouseState
WarehouseState.Name = "Warehouse"

setmetatable(WarehouseState, {
    __call = function (cls, ...)
      return cls.new(...)
    end,
  })

function WarehouseState.new()
  local self = setmetatable({}, WarehouseState)
  self.LastVendorTickcount = 0
  self.ArrivedToVendorTickcount = 0
  self.RequestedItemsList = false
  self.RequestedItemListTickcount = 0
  self.ItemSold = false

  self.State = 0 -- 0 = Nothing, 1 = Moving, 2 = Arrived
  self.DepositList = nil

	self.LastWarehouseUseTimer = nil
	self.SleepTimer = nil
	self.CurrentDepositList = {}

	return self
end

function WarehouseState:NeedToRun()

  local selfPlayer = GetSelfPlayer()


  if self.LastWarehouseUseTimer ~= nil and not self.LastWarehouseUseTimer:Expired() then
    return false
  end

  if not selfPlayer then
    return false
  end

  if not selfPlayer.IsAlive then
    return false
  end

  if not ProfileEditor.CurrentProfile:HasWarehouse() then
    return false
  end

  if Bot.WarehouseForced and Navigator.CanMoveTo(ProfileEditor.CurrentProfile:GetWarehousePosition()) then
    return true
    else
                        Bot.WarehouseForced = false

  end

  if  Bot.Settings.WarehouseDepositItems and selfPlayer.Inventory.FreeSlots <= 1 and
  table.length(self:GetItemsToWarehouse()) > 0 and
  Navigator.CanMoveTo(ProfileEditor.CurrentProfile:GetWarehousePosition()) then
    return true
  end

  if  selfPlayer.WeightPercent >= 95 and
  table.length(self:GetItemsToSell()) > 0 and
  Navigator.CanMoveTo(ProfileEditor.CurrentProfile:GetWarehousePosition()) then
    return true
  end

  return false
end

function WarehouseState:Exit()

	if self.State > 0 then
		if Dialog.IsTalking then
			Dialog.ClickExit()
		end
	self.State = 0
	self.LastWarehouseUseTimer = PyxTimer:New(6000)
	self.LastWarehouseUseTimer:Start()
	self.SleepTimer = nil
    Bot.WarehouseForced = false
	end

end

function WarehouseState:Run()
	local selfPlayer = GetSelfPlayer()
	local vendorPosition = ProfileEditor.CurrentProfile:GetWarehousePosition()

	if vendorPosition.Distance3DFromMe > 300 then
		Bot.CallCombatRoaming()
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
		print("Warehouse could not find any NPC's")
		self:Exit()
		return
	end
	table.sort(npcs, function(a,b) return a.Position:GetDistance3D(vendorPosition) < b.Position:GetDistance3D(vendorPosition) end)

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
			print("Warehouse Error Dialog didn't open")
			self:Exit()
			return	
		end
			BDOLua.Execute ("Warehouse_OpenPanelFromDialog()")
		self.SleepTimer = PyxTimer:New(1)
		self.SleepTimer:Start()
		self.State = 3
		self.CurrentDepositList = self:GetItemsToDeposit()
		return
	end

	if self.State == 3 then
		if table.length(self.CurrentDepositList) < 1 then
			print ("Warehouse done list")
			self:Exit()
			return
		end

		local item = self.CurrentDepositList[1]
-- Get current Pointer to Item as it will change on deposit
		local itemPtr = selfPlayer.Inventory:GetItemByName(item.name)
		if itemPtr ~= nil then
			print(itemPtr.InventoryIndex.." Deposit item : " .. itemPtr.ItemEnchantStaticStatus.Name)
--			selfPlayer:WarehousePushItem(npc,itemPtr.InventoryIndex+2,1)
--			BDOLua.Execute ("Inventory_SlotRClick("..itemPtr.InventoryIndex..", -1 )")
			itemPtr:PushToWarehouse(npc)
			self.SleepTimer = PyxTimer:New(0.5)
			self.SleepTimer:Start()
--			BDOLua.Execute ("Inventory_updateSlotData()")
--			BDOLua.Execute ("Warehouse_updateSlotData()")
		end
		table.remove(self.CurrentDepositList,1)
		--[[
		print(item.slot.." "..item.name.." "..item.count)
		selfPlayer:WarehousePushItem(npc,item.slot+2,item.count)
		self.SleepTimer = PyxTimer:New(1)
		self.SleepTimer:Start()
		--]]
		return
	end



	self:Exit()

end


function WarehouseState:GetItemsToDeposit()
  local itemsToDeposit = { }
  local selfPlayer = GetSelfPlayer()
  if selfPlayer then
    for k,v in pairs(selfPlayer.Inventory.Items) do
			if Bot.Settings:CanWarehouseItem(v) then
--				v.TriedDeposit = false
				table.insert(itemsToDeposit, {slot = v.InventoryIndex, name = v.ItemEnchantStaticStatus.Name, count = v.Count})
      end
    end
  end
  return itemsToDeposit
end



