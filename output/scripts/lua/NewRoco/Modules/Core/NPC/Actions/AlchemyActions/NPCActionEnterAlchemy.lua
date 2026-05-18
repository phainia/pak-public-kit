local NPCActionModelBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local HoldingItemComponent = require("NewRoco.Modules.Core.Scene.Component.Show.HoldingItemComponent")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = NPCActionModelBase
local NPCActionEnterAlchemy = Base:Extend("NPCActionOpenAlchemy")

function NPCActionEnterAlchemy:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionEnterAlchemy:ExecuteWithModel()
  self.skipSkill = nil
  self.normalSkill = nil
  self.isSkip = false
  local req = _G.ProtoMessage:newZoneCheckVisualItemUpgradeRedPointReq()
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_CHECK_VISUAL_ITEM_UPGRADE_RED_POINT_REQ, req)
  local IronPan = self:GetOwnerNPCView()
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.RegisterIronPan, IronPan)
  _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.HIDE_LOCAL_PLAYER, false)
  local player = self:GetPlayer()
  self:UnLinkHand()
  if player then
    player:RecordPlayerPos()
  end
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.PlayPerformById, 101, self, self.EndAction, nil, self, self.PreStart)
end

function NPCActionEnterAlchemy:PreStart(skillObj)
  skillObj:RegisterEventCallback("Land", self, self.LandPlayer)
  self.normalSkill = skillObj
end

function NPCActionEnterAlchemy:LandPlayer()
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:Land()
end

function NPCActionEnterAlchemy:EndAction()
  if self.isSkip then
    return
  end
  local localPlayer = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local holdingItemComponent = localPlayer:EnsureComponent(HoldingItemComponent)
  local skillShowComponent = localPlayer.SkillShowComponent
  if holdingItemComponent and skillShowComponent and self.normalSkill and self.normalSkill.Blackboard then
    local skillObj = self.normalSkill
    local cam = skillObj.Blackboard:GetValueAsObject("camActor_0001")
    holdingItemComponent:RegisterItem("camActor_0001", cam, 0, true)
    skillObj.Blackboard:RemoveObjectValue("camActor_0001")
    local cam_SA = skillObj.Blackboard:GetValueAsObject("camActor_0001_SA")
    holdingItemComponent:RegisterItem("camActor_0001_SA", cam_SA, 0, true)
    skillObj.Blackboard:RemoveObjectValue("camActor_0001_SA")
  end
  self:Finish()
end

function NPCActionEnterAlchemy:OnSkipInDialogue()
  local localPlayer = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local IronPan = self:GetOwnerNPCView()
  local skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/Alchemy/EnterAlchemySkip.EnterAlchemySkip", IronPan.RocoSkill, PriorityEnum.Active_Player_Action)
  skill:SetPassive(true)
  skill:SetCaster(localPlayer)
  skill:SetTargets({IronPan})
  skill:SetWithLoadAndPlay(true)
  skill:RegisterEventCallback("PreEnd", self, self.OnSkipSkillComplete)
  skill:RegisterEventCallback("End", self, self.OnSkipSkillComplete)
  skill:RegisterEventCallback("Interrupt", self, self.OnSkipSkillComplete)
  skill:PlaySkill(self, self.OnSkipSkillStart)
  self.skipSkill = skill
  self.isSkip = true
end

function NPCActionEnterAlchemy:OnSkipSkillStart(Skill, Result)
  if Result == UE.ESkillStartResult.Success then
    self.SkillStarted = true
  else
    self:OnSkipSkillFailed()
  end
end

function NPCActionEnterAlchemy:OnSkipSkillFailed()
  self:OnSkipSkillComplete()
end

function NPCActionEnterAlchemy:OnSkipSkillComplete()
  local localPlayer = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local holdingItemComponent = localPlayer:EnsureComponent(HoldingItemComponent)
  local skillShowComponent = localPlayer.SkillShowComponent
  if holdingItemComponent and skillShowComponent and self.skipSkill and self.skipSkill.SkillObject and self.skipSkill.SkillObject.Blackboard then
    local skillObj = self.skipSkill.SkillObject
    local cam = skillObj.Blackboard:GetValueAsObject("camActor_0001")
    holdingItemComponent:RegisterItem("camActor_0001", cam, 0, true)
    skillObj.Blackboard:RemoveObjectValue("camActor_0001")
    local cam_SA = skillObj.Blackboard:GetValueAsObject("camActor_0001_SA")
    holdingItemComponent:RegisterItem("camActor_0001_SA", cam_SA, 0, true)
    skillObj.Blackboard:RemoveObjectValue("camActor_0001_SA")
  end
  self:Finish()
end

function NPCActionEnterAlchemy:CanSkipInDialogue()
  return true
end

return NPCActionEnterAlchemy
