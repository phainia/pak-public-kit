local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local FriendModuleEvent = require("NewRoco.Modules.System.Friend.FriendModuleEvent")
local PlayerInteractionComponent = Base:Extend("PlayerInteractionComponent")

function PlayerInteractionComponent:Attach(owner)
  Base.Attach(self, owner)
  self.interactingAction = nil
  self.traceNpcs = {}
  _G.NRCEventCenter:RegisterEvent("PlayerInteractionComponent", self, NPCModuleEvent.NpcActionExecute, self.OnNpcActionExecute)
  _G.NRCEventCenter:RegisterEvent("PlayerInteractionComponent", self, NPCModuleEvent.NpcActionFinish, self.OnNpcActionFinish)
  _G.NRCEventCenter:RegisterEvent("PlayerInteractionComponent", self, FriendModuleEvent.OnEnterVisit, self.OnEnterOrLeaveVisit)
  _G.NRCEventCenter:RegisterEvent("PlayerInteractionComponent", self, FriendModuleEvent.OnLeaveVisit, self.OnEnterOrLeaveVisit)
end

function PlayerInteractionComponent:DeAttach()
  _G.NRCEventCenter:UnRegisterEvent(self, NPCModuleEvent.NpcActionExecute, self.OnNpcActionExecute)
  _G.NRCEventCenter:UnRegisterEvent(self, NPCModuleEvent.NpcActionFinish, self.OnNpcActionFinish)
  _G.NRCEventCenter:UnRegisterEvent(self, FriendModuleEvent.OnEnterVisit, self.OnEnterOrLeaveVisit)
  _G.NRCEventCenter:UnRegisterEvent(self, FriendModuleEvent.OnLeaveVisit, self.OnEnterOrLeaveVisit)
  self.interactingAction = nil
  Base.DeAttach(self)
end

function PlayerInteractionComponent:OnReConnect()
  self.interactingAction = nil
  _G.BattleManager.isSendWaiting = false
end

function PlayerInteractionComponent:OnEnterOrLeaveVisit()
  self.interactingAction = nil
end

function PlayerInteractionComponent:AddTraceNpc(serverId)
  table.insert(self.traceNpcs, serverId)
end

function PlayerInteractionComponent:RemoveTraceNpc(serverId)
  table.removeValue(self.traceNpcs, serverId)
end

function PlayerInteractionComponent:SetInteractingAction(Action)
  if not Action then
    Log.Error("\229\191\133\233\161\187\228\188\160\229\133\165\228\184\128\228\184\170\230\156\137\230\149\136\231\154\132Action")
    return
  end
  if self.interactingAction and Action then
    Log.Error("\230\173\163\229\156\168\230\137\167\232\161\140action\231\154\132\230\151\182\229\128\153\230\157\165\228\186\134\230\150\176\231\154\132action!!!!!!!!!", self.interactingAction:GetDesc(), Action:GetDesc())
  end
  self.interactingAction = Action
end

function PlayerInteractionComponent:ClearInteractingAction(Action)
  if not Action then
    Log.Error("\229\191\133\233\161\187\228\188\160\229\133\165\228\184\128\228\184\170\230\156\137\230\149\136\231\154\132Action")
    return
  end
  if self.interactingAction == Action then
    self.interactingAction = nil
  else
    Log.Error("\230\151\160\230\179\149\230\184\133\233\153\164\229\189\147\229\137\141\230\173\163\229\156\168\230\137\167\232\161\140\231\154\132Action", self.interactingAction and self.interactingAction:GetDesc(Log.LOG_LEVEL.ELogError) or "\230\151\160", Action:GetDesc(Log.LOG_LEVEL.ELogError))
  end
end

function PlayerInteractionComponent:HasInteractingAction()
  return self.interactingAction ~= nil
end

function PlayerInteractionComponent:GetInteractingActionDesc(LogLevel)
  return self.interactingAction:GetDesc(LogLevel)
end

function PlayerInteractionComponent:OnNpcActionExecute(action)
  local type = action.Config.action_type
  local controller = self.owner:GetUEController()
  if UE.UObject.IsValid(controller) then
    controller:SetDotsInteractAction(type, true)
  end
  local actionTarget = action:GetOwnerNPC()
  if not actionTarget then
    return
  end
  if not actionTarget.luaObj then
    return
  end
  if not actionTarget.luaObj.IntimateBondFindAIId then
    return
  end
  local npc = _G.NRCModuleManager:DoCmd(NPCModuleCmd.GetNpcByServerID, actionTarget.luaObj.IntimateBondFindAIId)
  if not npc then
    return
  end
  npc.AIComponent:SendBondBoxOpenEvent(actionTarget:GetActorLocation())
  Log.Debug("PlayerInteractionComponent:OnNpcActionFinish SendBondBoxOpenEvent : ", actionTarget.luaObj.IntimateBondFindAIId)
end

function PlayerInteractionComponent:OnNpcActionFinish(action)
  if not action then
    Log.Error("\228\188\160\229\133\165\231\154\132action\228\184\186\231\169\186")
    return
  end
  local type = action.Config.action_type
  local controller = self.owner:GetUEController()
  if UE4.UObject.IsValid(controller) then
    controller:SetDotsInteractAction(type, false)
  end
end

return PlayerInteractionComponent
