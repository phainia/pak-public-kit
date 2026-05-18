local NPCActionModelBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = NPCActionModelBase
local NPCActionExitCamp = Base:Extend("NPCActionExitCamp")

function NPCActionExitCamp:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
  self.PlayHpMaxAnimDelegate = nil
  self.OpenThrowInputDelegate = nil
end

function NPCActionExitCamp:ExecuteWithModel()
  local CampFire = self:GetOwnerNPCView()
  local skillProxy = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/Luying/ExitCamp.ExitCamp", CampFire.RocoSkill, PriorityEnum.Active_Player_Action)
  skillProxy:RegisterEventCallback("BlackScreen", self, self.BlackScreen)
  skillProxy:RegisterEventCallback("CloseBlack", self, self.CloseBlackScreen)
  skillProxy:RegisterEventCallback("LuluFlyOutAudio", self, self.LuluFlyOutAudio)
  _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.PlayCampingSkill, CampFire, skillProxy, self, self.OnCameraStartEnd)
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.OpenOrCloseThrowInputPcMode, false)
  local DelaySeconds = 0
  if self.Config.action_param1 then
    DelaySeconds = tonumber(self.Config.action_param1) / 1000
  end
  self.PlayHpMaxAnimDelegate = _G.DelayManager:DelaySeconds(DelaySeconds, self.PlayHpMaxAnim, self)
  self.OpenThrowInputDelegate = _G.DelayManager:DelaySeconds(3, self.OpenThrowInput, self)
end

function NPCActionExitCamp:LuluFlyOutAudio(Event, Skill)
  _G.NRCModeManager:DoCmd(_G.CampingModuleCmd.ClearCampingCamera, Skill)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerController = localPlayer:GetUEController()
  playerController:ReleaseRocoCamera()
end

function NPCActionExitCamp:OnCameraStartEnd(Event, Skill)
  if self.PlayHpMaxAnimDelegate then
    _G.DelayManager:CancelDelayById(self.PlayHpMaxAnimDelegate)
    self.PlayHpMaxAnimDelegate = nil
  end
  if self.OpenThrowInputDelegate then
    _G.DelayManager:CancelDelayById(self.OpenThrowInputDelegate)
    self.OpenThrowInputDelegate = nil
  end
  _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.ClearCampingData)
  _G.NRCEventCenter:DispatchEvent(_G.CampingModuleEvent.ON_EXIT_CAMPING)
  self:ReLinkHand()
  self:Finish()
end

function NPCActionExitCamp:BlackScreen(Event, Skill)
  local DialogueConf = {}
  local ExtraConf = {}
  DialogueConf.speed = 0
  ExtraConf.fade_in_speed = 4
  ExtraConf.fade_out_speed = 4
  ExtraConf.show_time = 0.25
  ExtraConf.numberCharacter = 30
  ExtraConf.autoCloseOff = true
  local TipText = _G.DataConfigManager:GetLocalizationConf(self.Config.action_param2).msg
  DialogueConf.text = TipText
  _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.ShowBlackScreen, DialogueConf, nil, ExtraConf)
end

function NPCActionExitCamp:PlayHpMaxAnim()
  self.PlayHpMaxAnimDelegate = nil
  local player = self:GetPlayer()
  if player then
    player:RecoverPlayerPos()
  end
  local localPlayer = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  localPlayer:PlayAddRoleHpEffect()
end

function NPCActionExitCamp:OpenThrowInput()
  self.OpenThrowInputDelegate = nil
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.OpenOrCloseThrowInputPcMode, true)
end

function NPCActionExitCamp:CloseBlackScreen(Event, Skill)
  local LocalPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local NowHeroPos = LocalPlayer:GetActorLocation()
  local normalleaf_hidden_distance = DataConfigManager:GetMapGlobalConfig("normalleaf_hidden_distance").num
  UE4.UNRCStatics.Abs_SetBattleGrassVisibleAndDist(NowHeroPos, 0, 30, normalleaf_hidden_distance)
  local player = self:GetPlayer()
  if player then
    player:RecoverPlayerPos()
  end
end

return NPCActionExitCamp
