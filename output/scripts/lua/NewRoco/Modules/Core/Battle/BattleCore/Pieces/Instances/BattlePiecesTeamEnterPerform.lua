local BattlePiecesPlaySkill = require("NewRoco.Modules.Core.Battle.BattleCore.Pieces.Instances.BattlePiecesPlaySkill")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local CastSkillObject = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.CastSkillObject")
local LineTraceUtils = require("NewRoco.Modules.Core.Battle.Common.LineTraceUtils")
local Base = BattlePiecesPlaySkill
local BattlePiecesTeamEnterPerform = Base:Extend("BattlePiecesTeamEnterPerform")

function BattlePiecesTeamEnterPerform:Play(action, finishCallBack)
  self.TriggerAction = action
  self.FinishCallBack = finishCallBack
  if not BattleUtils.IsPlayerCanSeeTarget() then
    self.skillPath = BattleConst.BloodTeamEnterFarBattle
  else
    self.skillPath = BattleConst.TeamBloodPerEnterBattle
  end
  self.resList = {
    self.skillPath
  }
  BattleEventCenter:Bind(self, BattleEvent.OnSkillResLoaded, BattleEvent.TransformLoadingOpened)
  Base.Play(self)
end

function BattlePiecesTeamEnterPerform:OnResLoadFinish(resPath)
  local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not localPlayer or not localPlayer.viewObj then
    Log.Warning("There is no model in localPlayer !!!")
    self:Complete()
    return
  end
  NRCModeManager:DoCmd(PlayerModuleCmd.HIDE_OTHER_PLAYER, true)
  local npcs = _G.NRCModeManager:DoCmd(NPCModuleCmd.GetAllNPC)
  if npcs then
    for i, NPC in pairs(npcs) do
      if NPC then
        NPC:SetVisibleForBattleReason(false)
      end
    end
  end
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local Target = BattleUtils.GetTraceNpc()
  if not (Target and Target.npc) or not Target.npc.viewObj then
    Log.Warning("There is no model in Target !!!")
    Target = localPlayer
  elseif self.skillPath == BattleConst.TeamPerEnterFarBattle then
    Target = localPlayer
  else
    Target = Target.npc
    Target:SetVisibleForBattleReason(true)
  end
  local bossType = BattleUtils.GetEnemyPetBlood() or 1
  if self.TriggerAction then
    self.TriggerAction.fsm:SetProperty("BloodPetType", BattleConst.BloodType2AttrType[bossType])
  end
  local skillComponent = localPlayer.viewObj.RocoSkill
  if not skillComponent then
    Log.Warning("There is no skillComponent")
    self:Complete()
    return
  end
  local MyCastObject = CastSkillObject.FromSkillResID(self.skillPath)
  if MyCastObject then
    local characters = {}
    characters[0] = localPlayer.viewObj
    characters[8] = Target.viewObj
    MyCastObject:SetCallbackOwner(self)
    MyCastObject:SetInterrupt(true)
    MyCastObject:SetCaster(localPlayer.viewObj)
    MyCastObject:SetCharacters(characters)
    MyCastObject:SetCompleteCallback(self.SkillFinish)
    MyCastObject:SetExtraEvents({
      SaveCamera = self.SaveCamera
    })
    local skillObj = self:PlaySkill(localPlayer, skillComponent, MyCastObject, true)
    if skillObj then
      local blackboard = skillObj:GetBlackboard()
      if blackboard then
        blackboard:SetValueAsInt("IsSkip", 1)
        local cameraManager = player.viewObj:GetController().PlayerCameraManager
        local cameraTransform = UE4.FTransform(cameraManager:GetCameraRotation():ToQuat(), cameraManager:GetCameraLocation(), _G.FVectorOne)
        blackboard:SetValueAsTransform("StartTransform", cameraTransform)
      end
      skillObj:SetTargets({
        Target.viewObj
      })
      skillComponent:PlaySkill(skillObj)
    end
  else
    Log.Error("zgx res is vaild!!", self.skillPath)
    self:Complete()
  end
end

function BattlePiecesTeamEnterPerform:SaveCamera(name, skill)
  if skill then
    local blackboard = skill:GetBlackboard()
    if blackboard and self.TriggerAction then
      self.TriggerAction:SaveBlackboard(blackboard, "camActor_0001")
      self.TriggerAction:SaveBlackboard(blackboard, "camActor_0001_SA")
      local camera = self.TriggerAction.fsm:GetProperty("camActor_0001")
      self.TriggerAction.fsm:SetProperty("camActor_0001", nil)
      self.TriggerAction.fsm:SetProperty(BattleConst.BattleSkipCamera, _G.ObjectRefBoxing(camera))
      local cameraBone = self.TriggerAction.fsm:GetProperty("camActor_0001_SA")
      self.TriggerAction.fsm:SetProperty("camActor_0001_SA", nil)
      self.TriggerAction.fsm:SetProperty(BattleConst.BattleSkipCameraAS, _G.ObjectRefBoxing(cameraBone))
    end
  end
end

function BattlePiecesTeamEnterPerform:SkillFinish(name, skill)
  self.SkillObj = skill
  skill:SetPlayRate(0)
  NRCModeManager:DoCmd(BattleUIModuleCmd.OpenTransformLoadingUI)
  self:SafeDelaySeconds("d_Complete", 1, self.Complete, self)
end

function BattlePiecesTeamEnterPerform:OnBattleEvent(event, value)
  Base.OnBattleEvent(self, event, value)
  if event == BattleEvent.TransformLoadingOpened then
    self:Complete()
    return true
  end
end

function BattlePiecesTeamEnterPerform:OnComplete()
  if self.isOver then
    return
  end
  Log.Warning("BattlePiecesTeamEnterPerform:OnComplete")
  if self.SkillObj then
    self.SkillObj:SetPlayRate(1)
  end
  if self.DelayOver then
    _G.DelayManager:CancelDelayById(self.DelayOver)
    self.DelayOver = nil
  end
  BattleEventCenter:UnBind(self)
  if self.TriggerAction then
    self.TriggerAction:Finish()
  end
  self.TriggerAction = nil
  self.FinishCallBack = nil
  self.SkillObj = nil
end

return BattlePiecesTeamEnterPerform
