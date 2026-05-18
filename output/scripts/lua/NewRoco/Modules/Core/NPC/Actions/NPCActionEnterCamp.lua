local NPCActionModelBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local HoldingItemComponent = require("NewRoco.Modules.Core.Scene.Component.Show.HoldingItemComponent")
local Base = NPCActionModelBase
local NPCActionEnterCamp = Base:Extend("NPCActionEnterCamp")

function NPCActionEnterCamp:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionEnterCamp:ExecuteWithModel()
  self:UnLinkHand()
  self.skipSkill = nil
  self.isSkip = false
  _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.HIDE_LOCAL_PLAYER, false)
  _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.RecycleAllThrowPets)
  local player = self:GetPlayer()
  if player then
    player:RecordPlayerPos()
  end
  self:BlackScreen()
end

function NPCActionEnterCamp:ShowSkill()
  local DialogueModule = _G.NRCModuleManager:GetModule("DialogueModule")
  DialogueModule:UnRegisterEvent(self, DialogueModuleEvent.DialogueBlackFadeInDone)
  local CampFire = self:GetOwnerNPCView()
  local skillProxy = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/Luying/EnterCampm.EnterCampm", CampFire.RocoSkill, PriorityEnum.Active_Player_Action)
  skillProxy:RegisterEventCallback("LuluFlyInAudio", self, self.LuluFlyInAudio)
  skillProxy:RegisterEventCallback("BlackScreenEnd", self, self.BlackScreenEnd)
  _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.PlayCampingSkill, CampFire, skillProxy, self, self.OnCameraStartEnd)
end

function NPCActionEnterCamp:LuluFlyInAudio()
  if _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.LuluAlreadyAppeared) then
    _G.NRCAudioManager:PlaySound2DAuto(1228, "NPCActionEnterCamp:LuluFlyInAudio")
  end
end

function NPCActionEnterCamp:OnCameraStartEnd(Event, Skill)
  if self.isSkip then
    return
  end
  self:Finish()
end

function NPCActionEnterCamp:BlackScreen(Event, Skill)
  local DialogueConf = {}
  local ExtraConf = {}
  DialogueConf.speed = 0
  ExtraConf.fade_in_speed = 8
  ExtraConf.fade_out_speed = 3
  ExtraConf.show_time = 0.2
  ExtraConf.autoCloseOff = true
  local DialogueModule = _G.NRCModuleManager:GetModule("DialogueModule")
  DialogueModule:RegisterEvent(self, DialogueModuleEvent.DialogueBlackFadeInDone, self.ShowSkill)
  if self.Config.action_param2 then
    local TipText = _G.DataConfigManager:GetLocalizationConf(self.Config.action_param2).msg
    DialogueConf.text = TipText
    _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.ShowBlackScreen, DialogueConf, nil, ExtraConf)
  else
    DialogueConf.text = ""
    _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.ShowBlackScreen, DialogueConf, nil, ExtraConf)
  end
end

function NPCActionEnterCamp:BlackScreenEnd()
  local LocalPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local NowHeroPos = LocalPlayer:GetActorLocation()
  local normalleaf_hidden_distance = DataConfigManager:GetMapGlobalConfig("normalleaf_hidden_distance").num
  UE4.UNRCStatics.Abs_SetBattleGrassVisibleAndDist(NowHeroPos, 1, 30, normalleaf_hidden_distance)
  _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.FadeOutDialogueBlack)
end

function NPCActionEnterCamp:BeforeBeginAction(Action)
  Base.BeforeBeginAction(self)
  if Action.begin_act_params and #Action.begin_act_params > 0 then
    _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.ShowNpcInCamp, Action.begin_act_params)
  end
end

function NPCActionEnterCamp:SkipCameraSkill()
  self:LuluFlyInAudio()
  self:OnCameraStartEnd()
  _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.SetCampfire, self.OwnerNpc.viewObj)
end

function NPCActionEnterCamp:OnSkipInDialogue()
  local CampFire = self:GetOwnerNPCView()
  if not CampFire then
    self:OnSkipSkillComplete()
    return
  end
  local skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/Luying/EnterCampSkip.EnterCampSkip", CampFire.RocoSkill, PriorityEnum.Active_Player_Action)
  local characters = {
    [UE4.EBattleStaticActorType.Player_1] = CampFire
  }
  skill:SetPassive(true)
  skill:SetCaster(CampFire)
  skill:SetCharacters(characters)
  skill:SetWithLoadAndPlay(true)
  skill:RegisterEventCallback("PreEnd", self, self.OnSkipSkillComplete)
  skill:RegisterEventCallback("End", self, self.OnSkipSkillComplete)
  skill:RegisterEventCallback("Interrupt", self, self.OnSkipSkillComplete)
  skill:PlaySkill(self, self.OnSkipSkillStart)
  self.skipSkill = skill
  self.isSkip = true
end

function NPCActionEnterCamp:OnSkipSkillStart(Skill, Result)
  if Result == UE.ESkillStartResult.Success then
    self.SkillStarted = true
  else
    self:OnSkipSkillFailed()
  end
end

function NPCActionEnterCamp:OnSkipSkillFailed()
  self:OnSkipSkillComplete()
end

function NPCActionEnterCamp:OnSkipSkillComplete()
  local holdingItemComponent = self:GetOwnerNPC():EnsureComponent(HoldingItemComponent)
  local skillShowComponent = self:GetOwnerNPC().SkillShowComponent
  if holdingItemComponent and skillShowComponent and self.skipSkill and self.skipSkill.SkillObject and self.skipSkill.SkillObject.Blackboard then
    if skillShowComponent.performConf.skill_blackboard_value then
      for idx, blackboard_value in ipairs(skillShowComponent.performConf.skill_blackboard_value) do
        if blackboard_value.key == "camActor_0001" or blackboard_value.key == "camActor_0001_SA" then
          skillShowComponent.performConf.skill_blackboard_value[idx] = nil
        end
      end
    end
    if holdingItemComponent then
      holdingItemComponent:DestroyItem("camActor_0001")
      holdingItemComponent:DestroyItem("camActor_0001_SA")
    end
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

function NPCActionEnterCamp:CanSkipInDialogue()
  return true
end

return NPCActionEnterCamp
