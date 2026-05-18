local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local Base = ActorComponent
local AIDebuggerComponent = Base:Extend("AIDebuggerComponent")

function AIDebuggerComponent:Attach(...)
  Base.Attach(self, ...)
  UpdateManager:Register(self)
end

function AIDebuggerComponent:DeAttach()
  UpdateManager:UnRegister(self)
end

function AIDebuggerComponent:OnTick(dt)
  local view = self.owner.viewObj
  if view and UE.UObject.IsValid(view) then
    local str = ""
    str = self:AppendControlFlag(str)
    str = self:AppendBattleState(str)
    str = self:AppendInteractionLock(str)
    str = self:AppendAILock(str)
    local World = view:GetWorld()
    UE4.UKismetSystemLibrary.Abs_DrawDebugString(World, view:Abs_K2_GetActorLocation(), str, nil, UE4.FLinearColor(1, 1, 0, 1), 0)
  end
end

function AIDebuggerComponent:AppendControlFlag(str)
  local AIComp = self.owner.AIComponent
  if not AIComp then
    return str
  end
  str = string.format([=[
%s
[ControlFlags]]=], str)
  for _, flag in pairs(Enum.SceneAiControlFlags) do
    if AIComp:HasControlFlags(flag) then
      str = string.format([[
%s
%s]], str, table.getKeyName(Enum.SceneAiControlFlags, flag))
    end
  end
  return str
end

function AIDebuggerComponent:AppendBattleState(str)
  local AIComp = self.owner.AIComponent
  if not AIComp then
    return str
  end
  str = string.format([=[
%s
[BattleStatus]]=], str)
  for _, flag in pairs(Enum.BattleAIStatus) do
    if AIComp:HasBattleState(flag) then
      str = string.format([[
%s
%s]], str, table.getKeyName(Enum.BattleAIStatus, flag))
    end
  end
  return str
end

function AIDebuggerComponent:AppendLogicStatus(str)
  local statusComp = self.owner.LogicStatusComponent
  if not statusComp then
    return str
  end
  str = string.format([=[
%s
[LogicStatus]]=], str)
  if statusComp.StatusInfo then
    for _, item in pairs(statusComp.StatusInfo) do
      str = string.format([[
%s
%s]], str, table.getKeyName(Enum.SpaceActorLogicStatus, item.status))
    end
  end
  return str
end

function AIDebuggerComponent:AppendInteractionLock(str)
  local interactionComp = self.owner.InteractionComponent
  if not interactionComp then
    return str
  end
  str = string.format([=[
%s
[InteractionLock]]=], str)
  for _, flag in pairs(NPCModuleEnum.NpcInteractDisableFlag) do
    if 0 ~= interactionComp.DisableFlagTemp & 1 << flag then
      str = string.format([[
%s
%s(T)]], str, table.getKeyName(NPCModuleEnum.NpcInteractDisableFlag, flag))
    end
    if 0 ~= interactionComp.DisableFlag & 1 << flag then
      str = string.format([[
%s
%s]], str, table.getKeyName(NPCModuleEnum.NpcInteractDisableFlag, flag))
    end
  end
  return str
end

function AIDebuggerComponent:AppendAILock(str)
  local AIComp = self.owner.AIComponent
  if not AIComp then
    return str
  end
  str = string.format([=[
%s
[AILock]]=], str)
  for _, flag in pairs(_G.AIDefines.LockReason) do
    if AIComp.ForceLockFlag & 1 << flag > 0 then
      str = string.format([[
%s
%s]], str, table.getKeyName(AIDefines.LockReason, flag))
    end
  end
  return str
end

return AIDebuggerComponent
