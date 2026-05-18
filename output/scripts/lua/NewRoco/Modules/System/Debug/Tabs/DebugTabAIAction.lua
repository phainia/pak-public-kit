local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")
local HiddenComponent = require("NewRoco.Modules.Core.Scene.Component.Hidden.HiddenComponent")
local StunComponent = require("NewRoco.Modules.Core.Scene.Component.Boss.StunComponent")
local HangingComponent = require("NewRoco.Modules.Core.Scene.Component.Movement.HangingComponent")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabAIAction = Base:Extend("DebugTabAIAction")

function DebugTabAIAction:Ctor()
  Base.Ctor(self)
end

function DebugTabAIAction:SetupTabs()
end

function DebugTabAIAction:TestHidden()
  local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
  if not npc then
    return Log.Warning("\233\153\132\232\191\145\230\178\161\230\156\137NPC")
  end
  local comp = npc:EnsureComponent(HiddenComponent)
  if comp:CanHide() then
    Log.Warning(npc.config.name, "\230\181\139\232\175\149\232\191\155\229\133\165\229\140\191\232\184\170, AI\229\183\178\228\184\180\230\151\182\229\133\179\233\151\173", comp:BeginHide())
  else
    Log.Warning("\230\156\128\232\191\145\231\154\132NPC\230\152\175" .. npc.config.name .. "\239\188\140\228\184\141\232\131\189\229\140\191\232\184\170")
    return
  end
  local upv = {}
  MakeWeakTable(upv)
  upv.npc = npc
  local wait_for_end = a.task(function()
    local still_hidding = true
    while upv.npc and still_hidding do
      a.wait(au.DelayFrames(10))
      still_hidding = upv.npc.HiddenComponent:IsHidden()
    end
    if upv.npc then
      Log.Warning(npc.config.name, "\230\181\139\232\175\149\229\140\191\232\184\170\231\187\147\230\157\159, AI\229\183\178\230\129\162\229\164\141")
    end
  end)
  wait_for_end()
end

function DebugTabAIAction:TestSetHidden()
  local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
  if not npc then
    return Log.Warning("\233\153\132\232\191\145\230\178\161\230\156\137NPC")
  end
  local comp = npc:EnsureComponent(HiddenComponent)
  if comp:CanHide() then
    Log.Warning(npc.config.name, "\230\181\139\232\175\149\232\191\155\229\133\165\229\140\191\232\184\170, AI\229\183\178\228\184\180\230\151\182\229\133\179\233\151\173", comp:SetHide())
  else
    Log.Warning("\230\156\128\232\191\145\231\154\132NPC\230\152\175" .. npc.config.name .. "\239\188\140\228\184\141\232\131\189\229\140\191\232\184\170")
    return
  end
  local upv = {}
  MakeWeakTable(upv)
  upv.npc = npc
  local wait_for_end = a.task(function()
    local still_hidding = true
    while upv.npc and still_hidding do
      a.wait(au.DelayFrames(10))
      still_hidding = upv.npc.HiddenComponent:IsHidden()
    end
    if upv.npc then
      Log.Warning(npc.config.name, "\230\181\139\232\175\149\229\140\191\232\184\170\231\187\147\230\157\159, AI\229\183\178\230\129\162\229\164\141")
    end
  end)
  wait_for_end()
end

function DebugTabAIAction:TestUnhidden()
  local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
  if not npc then
    return Log.Warning("\233\153\132\232\191\145\230\178\161\230\156\137NPC")
  end
  local comp = npc:GetComponent(HiddenComponent)
  if comp then
    comp:EndHide(self, function(tab, result)
      Log.Warning(npc.config.name, "\233\128\128\229\135\186\229\140\191\232\184\170", result)
    end)
  else
    Log.Warning("\230\156\128\232\191\145\231\154\132NPC\230\152\175" .. npc.config.name .. "\239\188\140\228\184\141\232\131\189\229\140\191\232\184\170")
  end
end

function DebugTabAIAction:TestSetUnhidden()
  local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
  if not npc then
    return Log.Warning("\233\153\132\232\191\145\230\178\161\230\156\137NPC")
  end
  local comp = npc:GetComponent(HiddenComponent)
  if comp then
    comp:ResetHide(false)
  else
    Log.Warning("\230\156\128\232\191\145\231\154\132NPC\230\152\175" .. npc.config.name .. "\239\188\140\228\184\141\232\131\189\229\140\191\232\184\170")
  end
end

function DebugTabAIAction:TestStun(name, panel, id)
  if panel then
    local inputText = panel.InputBox:GetText()
    if nil == inputText or "" == inputText then
      inputText = "60"
    end
    local time = tonumber(inputText) or 60
    local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
    if not npc then
      return Log.Warning("\233\153\132\232\191\145\230\178\161\230\156\137NPC")
    end
    Log.WarningFormat("\232\176\131\232\175\149\232\167\166\229\143\145\231\156\169\230\153\149\239\188\129\230\151\182\233\149\191=%d", time)
    local comp = npc:EnsureComponent(StunComponent)
    comp:SetStunLevel(2)
    comp:Stun(time)
  elseif id then
    local time = tonumber(id) or 60
    local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
    if not npc then
      return Log.Warning("\233\153\132\232\191\145\230\178\161\230\156\137NPC")
    end
    Log.WarningFormat("\232\176\131\232\175\149\232\167\166\229\143\145\231\156\169\230\153\149\239\188\129\230\151\182\233\149\191=%d", time)
    local comp = npc:EnsureComponent(StunComponent)
    comp:SetStunLevel(2)
    comp:Stun(time)
  end
end

function DebugTabAIAction:TestUnstun()
  local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
  if not npc then
    return Log.Warning("\233\153\132\232\191\145\230\178\161\230\156\137NPC")
  end
  local comp = npc:EnsureComponent(StunComponent)
  comp:StopStun()
end

function DebugTabAIAction:TestLowFly(Name, Panel, id)
  if Panel then
    local inputText = Panel.InputBox:GetText()
    if nil == inputText or "" == inputText then
      inputText = "150"
    end
    local hoverHeight = tonumber(inputText) or 60
    local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
    local npc = NPCModule:GetNearestNPC()
    if npc and npc.viewObj then
      local view = npc.viewObj
      local comp = view.CharacterMovement
      if hoverHeight > 0 then
        comp:SetMovementMode(UE.EMovementMode.MOVE_Custom, UE.ERocoCustomMovementMode.MOVE_Hovering)
        comp.HoverHeightTarget = hoverHeight
      else
        comp.HoverHeightTarget = 0
      end
    end
  elseif id then
    local hoverHeight = tonumber(id) or 60
    local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
    local npc = NPCModule:GetNearestNPC()
    if npc and npc.viewObj then
      local view = npc.viewObj
      local comp = view.CharacterMovement
      if hoverHeight > 0 then
        comp:SetMovementMode(UE.EMovementMode.MOVE_Custom, UE.ERocoCustomMovementMode.MOVE_Hovering)
        comp.HoverHeightTarget = hoverHeight
      else
        comp.HoverHeightTarget = 0
      end
    end
  end
end

function DebugTabAIAction:TestDive(Name, Panel, id)
  if Panel then
    local inputText = Panel.InputBox:GetText()
    if nil == inputText or "" == inputText then
      inputText = "150"
    end
    local DiveHeight = tonumber(inputText) or 60
    local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
    local npc = NPCModule:GetNearestNPC()
    if npc and npc.viewObj then
      local view = npc.viewObj
      local comp = view.CharacterMovement
      comp:SetAdditionalSwimPosOffsetZ(DiveHeight, 100)
    end
  elseif id then
    local DiveHeight = tonumber(id) or 60
    local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
    local npc = NPCModule:GetNearestNPC()
    if npc and npc.viewObj then
      local view = npc.viewObj
      local comp = view.CharacterMovement
      comp:SetAdditionalSwimPosOffsetZ(DiveHeight, 100)
    end
  end
end

function DebugTabAIAction:LockForBattleReason()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npc = NPCModule:GetNearestNPC()
  if npc and npc.AIComponent then
    if npc.AIComponent:IsLockedForReason(AIDefines.LockReason.INTERNAL_LEGACY_BATTLE) then
      npc.AIComponent:UnlockForBattleReason()
    else
      npc.AIComponent:LockForBattleReason()
    end
  end
end

function DebugTabAIAction:OverrideBehavior(name, panel, in_id)
  local behaviorId
  if panel then
    local inputText = panel.InputBox:GetText()
    if not string.IsNilOrEmpty(inputText) then
      behaviorId = tonumber(inputText)
    end
  end
  behaviorId = behaviorId or in_id
  if not behaviorId then
    Log.PrintScreenMsg("DebugTabAIAction:OverrideBehavior no valid behaviorId")
    return
  end
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npc = NPCModule:GetNearestNPC()
  if npc and npc.AIComponent then
    local conf = _G.DataConfigManager:GetNrcAiBehaviorGroupConf(behaviorId, true)
    if conf then
      Log.Warning("\232\166\134\231\155\150\232\161\140\228\184\186\231\187\132\239\188\129", behaviorId, conf.editor_name, npc:DebugNPCNameAndID())
      npc.AIComponent:OverrideBehavior(behaviorId, 0)
    else
      Log.Warning("\230\137\190\228\184\141\229\136\176\232\161\140\228\184\186\231\187\132\228\186\142AI_BEHAVIOR_GROUP_CONF", behaviorId)
    end
  else
    Log.Warning("\233\153\132\232\191\145\230\178\161\230\156\137npc with ai")
  end
end

function DebugTabAIAction:AddWorldEvent(name, panel, id)
  if panel then
    local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
    local npc = NPCModule:GetNearestNPC()
    if npc and npc.AIComponent then
      local worldEventId = 1
      local inputText = panel.InputBox:GetText()
      if not string.IsNilOrEmpty(inputText) then
        worldEventId = tonumber(inputText)
      end
      npc.AIComponent.AIController:NotifyDotsWorldEvent(worldEventId)
      local i = 0
    else
      Log.Warning("\233\153\132\232\191\145\230\178\161\230\156\137npc with ai")
    end
  elseif id then
    local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
    local npc = NPCModule:GetNearestNPC()
    if npc and npc.AIComponent then
      local worldEventId = 1
      worldEventId = tonumber(id)
      npc.AIComponent.AIController:NotifyDotsWorldEvent(worldEventId)
      local i = 0
    else
      Log.Warning("\233\153\132\232\191\145\230\178\161\230\156\137npc with ai")
    end
  end
end

function DebugTabAIAction:BoudDebug(name, panel)
  local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
  if not npc then
    return
  end
  local DotsCompData = npc.AIComponent.AIController:GetComponentData()
  local req = _G.ProtoMessage:newZoneDotsComponentSyncReq()
  req.actor_id = npc.serverData.base.actor_id
  for HashID, Data in pairs(DotsCompData) do
    local component_data = _G.ProtoMessage:newBytesData()
    component_data.id = HashID
    component_data.data = Data
    table.insert(req.component_datas, component_data)
  end
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_DOTS_COMPONENT_SYNC_REQ, req, self, self.BoudDebugRsp, false, false)
end

function DebugTabAIAction:BoudDebugRsp(rsp)
  if not rsp or 0 == rsp.ret_info.ret_code then
  end
end

function DebugTabAIAction:IntimateDebug(name, panel, InputText)
  local inputText
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  if nil == inputText or "" == inputText then
    inputText = "11"
  end
  local params = {}
  for w in string.gmatch(inputText, "%S+") do
    table.insert(params, w)
  end
  local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
  if not npc then
    return
  end
  local worldEventId = #params > 0 and tonumber(params[1]) or 11
  local Loc = UE4.FVector({})
  if #params >= 4 then
    Loc.X = tonumber(params[2])
    Loc.Y = tonumber(params[3])
    Loc.Z = tonumber(params[4])
  else
    local NPCLoc = npc:GetActorLocation()
    Loc.X = NPCLoc.X + 1000
    Loc.Y = NPCLoc.Y + 1000
    Loc.Z = NPCLoc.Z + 1000
  end
  npc.AIComponent.AIController:NotifyDotsWorldEvent(worldEventId, 1, Loc)
end

function DebugTabAIAction:SimulateStarMagic(name, panel)
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npc = NPCModule:GetNearestNPC()
  if npc and npc.AIComponent then
    npc.AIComponent:OnBeHitByStar()
  end
end

function DebugTabAIAction:ABBAnimTest()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npc = NPCModule:GetNearestNPC()
  if npc and npc.viewObj then
    local animComp = npc.viewObj:GetComponentByClass(UE.URocoAnimComponent)
    animComp:PlayBeginLoopAnimByName("SleepStart", "SleepLoop", 1, 0.15)
  end
end

function DebugTabAIAction:PauseEndAnimTest()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local npc = NPCModule:GetNearestNPC()
  if npc and npc.viewObj then
    local animComp = npc.viewObj:GetComponentByClass(UE.URocoAnimComponent)
    animComp:PlayAnimByName("SleepStart", 1, 0, 0.15, -1, 1, 0)
  end
end

return DebugTabAIAction
