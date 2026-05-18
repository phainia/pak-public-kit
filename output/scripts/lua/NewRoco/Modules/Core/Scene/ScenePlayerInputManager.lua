local ScenePlayerInputManager = NRCClass:Extend("ScenePlayerInputManager")
local keyEventDic = {}
local KeyAxisEvent = "AxisEvent"
local KeyActionEvent = "KeyActionEvent"
local isPause = false
local BlockTrigger

function ScenePlayerInputManager.RegisterInputEvent(event_name, event_type_name, listener, handler)
  local handlers = keyEventDic[event_type_name]
  if not handlers then
    keyEventDic[event_type_name] = {}
  end
  if not keyEventDic[event_type_name][event_name] then
    keyEventDic[event_type_name][event_name] = Array()
  end
  local handlerList = keyEventDic[event_type_name][event_name]
  for _, item in ipairs(handlerList:Items()) do
    if item and item.handler == handler and item.listener == listener then
      return
    end
  end
  local event = {listener = listener, handler = handler}
  handlerList:Push(event)
end

function ScenePlayerInputManager.UnRegisterInputEvent(event_name, event_type_name, listener, handler)
  local handlers = keyEventDic[event_type_name]
  if not handlers then
    return
  end
  if not keyEventDic[event_type_name][event_name] then
    return
  end
  local handlerList = keyEventDic[event_type_name][event_name]
  for i, item in ipairs(handlerList:Items()) do
    if item and item.handler == handler and item.listener == listener then
      handlerList:RemoveAt(i)
      return
    end
  end
end

function ScenePlayerInputManager.RegisterAxisEvent(axis_name, listener, handler)
  ScenePlayerInputManager.RegisterInputEvent(axis_name, KeyAxisEvent, listener, handler)
end

function ScenePlayerInputManager.UnRegisterAxisEvent(axis_name, listener, handler)
  ScenePlayerInputManager.UnRegisterInputEvent(axis_name, KeyAxisEvent, listener, handler)
end

function ScenePlayerInputManager.RegisterActionEvent(key_name, listener, handler)
  ScenePlayerInputManager.RegisterInputEvent(key_name, KeyActionEvent, listener, handler)
end

function ScenePlayerInputManager.UnRegisterActionEvent(key_name, listener, handler)
  ScenePlayerInputManager.UnRegisterInputEvent(key_name, KeyActionEvent, listener, handler)
end

function ScenePlayerInputManager.BlueprintInputAxisEvent(name, value)
  if true == isPause then
    return
  end
  local handlers = keyEventDic[KeyAxisEvent]
  if not handlers then
    return
  end
  if not keyEventDic[KeyAxisEvent][name] then
    return
  end
  local handlerList = keyEventDic[KeyAxisEvent][name]
  for i, item in ipairs(handlerList:Items()) do
    if item and item.handler and item.listener then
      item.handler(item.listener, value, name)
    end
  end
end

function ScenePlayerInputManager.BlueprintInputActionEvent(name, type)
  if true == isPause then
    return
  end
  local handlers = keyEventDic[KeyActionEvent]
  if not handlers then
    return
  end
  if not keyEventDic[KeyActionEvent][name] then
    return
  end
  local handlerList = keyEventDic[KeyActionEvent][name]
  for i, item in ipairs(handlerList:Items()) do
    if item and item.handler and item.listener then
      item.handler(item.listener, type, name)
    end
  end
end

function ScenePlayerInputManager.Clear()
  keyEventDic = {}
  if RocoEnv.PLATFORM_WINDOWS then
    Log.Debug("[IMC] Rebuild exit trigger events")
    NRCPanelManager:UnBindInputAction()
    NRCPanelManager:BindInputAction()
  end
end

function ScenePlayerInputManager.SetInputEnable(enable)
  if _G.PlayerModuleCmd then
    local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    if localPlayer and localPlayer.inputComponent then
      localPlayer.inputComponent:SetInputEnable(ScenePlayerInputManager, enable, "ScenePlayerInputManager")
    end
  end
end

function ScenePlayerInputManager.Pause()
  isPause = true
  ScenePlayerInputManager.SetInputEnable(false)
  if RocoEnv.PLATFORM_WINDOWS and not BlockTrigger then
    local Trigger = NRCPanelManager:GetOrCreateBlockTrigger()
    if Trigger then
      local TriggerObj = ObjectRefUnBoxing(Trigger)
      _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperAddInputMappingContext, TriggerObj, 0)
      BlockTrigger = Trigger
    end
  end
end

function ScenePlayerInputManager.PlayerContronBeginPlay()
  if RocoEnv.PLATFORM_WINDOWS and BlockTrigger then
    local TriggerObj = ObjectRefUnBoxing(BlockTrigger)
    _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperAddInputMappingContext, TriggerObj, 0)
  end
end

function ScenePlayerInputManager.Resume()
  isPause = false
  ScenePlayerInputManager.SetInputEnable(true)
  if RocoEnv.PLATFORM_WINDOWS and BlockTrigger then
    NRCPanelManager:RemoveBlockIMC(BlockTrigger)
    BlockTrigger = nil
  end
end

function ScenePlayerInputManager.IsPause()
  return isPause
end

return ScenePlayerInputManager
