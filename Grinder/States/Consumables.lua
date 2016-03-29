ConsumablesState = { }
ConsumablesState.__index = ConsumablesState
ConsumablesState.Name = "Foods"

setmetatable(ConsumablesState, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function ConsumablesState.new()
  local self = setmetatable({}, ConsumablesState)
  self.FoodToUse = { }
	self.LastPositionUsedTickcount = 0
	return self
end

function ConsumablesState:NeedToRun()
    
    local selfPlayer = GetSelfPlayer()
	local foodItem = selfPlayer.Inventory:GetItemByName(Bot.Settings.FoodName)
    

	if not selfPlayer or not foodItem then
        return false
    end
    
    if not selfPlayer.IsAlive then
        return false
    end
    
	if self.FoodTimer == nil and not foodItem.IsInCooldown then
		self.FoodTimer = PyxTimer:New(Bot.Settings.FoodDuration*60)
		print("Set food timer for: "..(Bot.Settings.FoodDuration*60).." seconds")
		self.FoodTimer:Start()
		self.FoodToUse = foodItem;
		return true
	end

	if self.FoodTimer == nil then
		return false
	end

--	print(foodItem.IsInCooldown.." "..self.FoodTimer:Expired())
	if not foodItem.IsInCooldown and self.FoodTimer:Expired() then
		self.FoodToUse = foodItem;
		return true
	end

	return false
end

function ConsumablesState:Run()
    
    print("Use Food : " .. self.FoodToUse.ItemEnchantStaticStatus.Name)
    self.FoodToUse:UseItem()
    self.FoodTimer:Reset()
    
end
