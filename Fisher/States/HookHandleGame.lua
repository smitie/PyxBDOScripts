HookFishHandleGameState = { }
HookFishHandleGameState.__index = HookFishHandleGameState
HookFishHandleGameState.Name = "Hook game"

setmetatable(HookFishHandleGameState, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function HookFishHandleGameState.new()
  local self = setmetatable({}, HookFishHandleGameState)
  self.LastHookFishTickCount = 0
  return self
end

function HookFishHandleGameState:NeedToRun()

    local selfPlayer = GetSelfPlayer()
    
    if not selfPlayer then
        return false
    end
    
    if not selfPlayer.IsAlive then
        return false
    end

    return selfPlayer.CurrentActionName == "FISHING_HOOK_START"
end

function HookFishHandleGameState:Run()
    local selfPlayer = GetSelfPlayer()
    if selfPlayer.CurrentActionName == "FISHING_HOOK_START" then
        selfPlayer:DoAction("FISHING_HOOK_GOOD")
        selfPlayer:DoAction("FISHING_HOOK_ING_HARDER")
        selfPlayer:DoAction("FISHING_HOOK_ING_SUCCESS")
        BDOLua.Execute("getSelfPlayer():get():SetMiniGameResult(2) ActionMiniGame_Stop()")
    end
end
