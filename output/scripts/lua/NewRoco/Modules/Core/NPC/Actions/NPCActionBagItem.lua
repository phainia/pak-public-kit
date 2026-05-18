local Base = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local BornDieComponent = require("NewRoco.Modules.Core.Scene.Component.BornDie.BornDieComponent")
local NPCActionBagItem = Base:Extend("NPCActionBagItem")
NPCActionBagItem.LastErrorTime = 0

function NPCActionBagItem:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
  self.DisableInterval = true
end

function NPCActionBagItem:Submit()
  Base.Submit(self)
  local npc = self:GetOwnerNPC()
  if 1 == self.Owner.optionInfo.executable_times then
    npc.InteractionComponent:TryDisableInteraction()
    local bornDie = npc:EnsureComponent(BornDieComponent)
    local action = _G.ProtoMessage:newSpaceAct_ActorDieBegin()
    action.die_reason = _G.ProtoEnum.ActorDieReason.ACTOR_DIE_REASON_AVATAR_PICKUP
    action.killer = 0
    bornDie:OnBeginDying(action, nil, true)
    _G.NRCEventCenter:RegisterEvent("NPCActionBagItem", self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReConnect)
  end
end

function NPCActionBagItem:OnSubmit(rsp)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReConnect)
  if 0 ~= rsp.ret_info.ret_code then
    self:Revert()
    local currentTime = os.msTime()
    if currentTime - NPCActionBagItem.LastErrorTime > 1000 then
      local Desc = LuaText:GetErrorDesc(rsp.ret_info.ret_code)
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, Desc)
      NPCActionBagItem.LastErrorTime = currentTime
    end
  end
end

function NPCActionBagItem:OnReConnect()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReConnect)
  self:Revert()
end

function NPCActionBagItem:Revert()
  local npc = self:GetOwnerNPC()
  if not npc then
    Log.Error("We have no npc here")
    return
  end
  npc.InteractionComponent:TryEnableInteraction()
  local npc_view = self:GetOwnerNPCView()
  if npc_view then
    if npc_view.RocoSkill then
      npc_view.RocoSkill:StopCurrentSkill()
    end
    npc_view:SetActorHiddenInGame(false)
    if npc_view.BeamComponent and not npc_view.bHidden then
      npc_view.BeamComponent:Show()
    end
  else
    Log.Error("We have no npc view here")
  end
  local bornDie = npc:EnsureComponent(BornDieComponent)
  bornDie.BeginDiePlayed = false
end

function NPCActionBagItem:IfActionNeedStatusNotify()
  return false
end

return NPCActionBagItem
