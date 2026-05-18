local Base = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local BornDieComponent = require("NewRoco.Modules.Core.Scene.Component.BornDie.BornDieComponent")
local Sending = false
local NPCActionCollectMagicTrace = Base:Extend("NPCActionCollectMagicTrace")
NPCActionCollectMagicTrace.LastErrorTime = 0

function NPCActionCollectMagicTrace:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
  self.DisableInterval = true
  self.npc = self:GetOwnerNPC()
  self.MagicFeedInfo = self.npc.serverData.MagicFeedInfo
end

function NPCActionCollectMagicTrace:OnNpcAction()
  if 1 == self.MagicFeedInfo.type then
    local HpFull = _G.NRCModuleManager:DoCmd(_G.MagicMessageModuleCmd.GetPlayerHpFull)
    if HpFull then
      return false
    end
  else
    local EnergyFull = _G.NRCModuleManager:DoCmd(_G.MagicMessageModuleCmd.GetPetEnergyFull)
    if EnergyFull then
      return false
    end
  end
  if Sending then
    self:Log("NPCActionCollectMagicTrace:Execute: Sending")
    return false
  end
  Sending = Base.OnNpcAction(self)
  return Sending
end

function NPCActionCollectMagicTrace:Execute(playerId, needSendReq)
  Base.Execute(self, playerId, false)
  local req = ProtoMessage:newZoneFeedFlowerPickupReq()
  req.uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  req.feed_id = self.OwnerNpc.serverData.MagicFeedInfo.feed_id
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_FEED_FLOWER_PICKUP_REQ, req, self, self.OnPickUpFlowerRsp)
end

function NPCActionCollectMagicTrace:Submit()
  Base.Submit(self)
  self.npc.InteractionComponent:TryDisableInteraction()
  local bornDie = self.npc:EnsureComponent(BornDieComponent)
  local action = _G.ProtoMessage:newSpaceAct_ActorDieBegin()
  action.die_reason = _G.ProtoEnum.ActorDieReason.ACTOR_DIE_REASON_AVATAR_PICKUP
  action.killer = 0
  bornDie:OnBeginDying(action, nil, true)
  _G.NRCEventCenter:RegisterEvent("NPCActionCollectMagicTrace", self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReConnect)
end

function NPCActionCollectMagicTrace:OnPickUpFlowerRsp(rsp)
  Sending = false
  if 0 == rsp.ret_info.ret_code and self.npc then
    local msg
    local magicInfo = self.npc.serverData.MagicFeedInfo
    if 1 == magicInfo.type then
      msg = _G.DataConfigManager:GetLocalizationConf("mark_get_life_flower").msg
      local name = magicInfo.name
      msg = string.format(msg, name)
    else
      msg = _G.DataConfigManager:GetLocalizationConf("mark_get_energe_flower").msg
      local name = magicInfo.name
      msg = string.format(msg, name)
    end
    if msg then
      _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, msg, nil, nil, 3, nil)
    end
    _G.NRCModuleManager:DoCmd(_G.MagicMessageModuleCmd.OnPickUpFlower, self.MagicFeedInfo)
    self.npc = nil
    self.MagicFeedInfo = nil
  end
end

function NPCActionCollectMagicTrace:OnSubmit(rsp)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReConnect)
  if 0 ~= rsp.ret_info.ret_code then
    self:Revert()
    local currentTime = os.msTime()
    if currentTime - NPCActionCollectMagicTrace.LastErrorTime > 1000 then
      local Desc = LuaText:GetErrorDesc(rsp.ret_info.ret_code)
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, Desc)
      NPCActionCollectMagicTrace.LastErrorTime = currentTime
    end
  end
end

function NPCActionCollectMagicTrace:OnReConnect()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReConnect)
  self:Revert()
end

function NPCActionCollectMagicTrace:Revert()
  Sending = false
  if not self.npc then
    Log.Error("We have no npc here")
    return
  end
  self.npc.InteractionComponent:TryEnableInteraction()
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
  local bornDie = self.npc:EnsureComponent(BornDieComponent)
  bornDie.BeginDiePlayed = false
end

function NPCActionCollectMagicTrace:IfActionNeedStatusNotify()
  return false
end

return NPCActionCollectMagicTrace
