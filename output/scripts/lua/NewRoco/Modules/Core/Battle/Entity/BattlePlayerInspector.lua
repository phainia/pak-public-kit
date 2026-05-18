local CastSkillObject = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.CastSkillObject")
local BattleObject = require("NewRoco.Modules.Core.Battle.Entity.BattleObject")
local BattleOnLookerBase = require("NewRoco.Modules.Core.Battle.Entity.BattleOnLookerBase")
local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")
local Base = BattleOnLookerBase
local BattlePlayerInspector = Base:Extend("BattlePlayerSpector")

function BattlePlayerInspector:Ctor()
  Base.Ctor(self)
  self.name = ""
  self.idleAnimationNameList = {
    "RolePlayCheer",
    "RolePlayCheer"
  }
end

function BattlePlayerInspector:SetInfo(uin, fashionInfo, attachPointInField)
  self.uin = uin
  self.fashionInfo = fashionInfo
  self.attachPoint = self:GetOnLookerAttachPointInField(attachPointInField)
  local gender = fashionInfo and fashionInfo.gender
  if gender == ProtoEnum.ESexValue.SEX_FEMALE then
    self.fadeInAnimList = {"Walk", "Walk"}
  end
end

function BattlePlayerInspector:GetModelPath()
  local gender = self.fashionInfo and self.fashionInfo.gender
  local modelPath = ""
  local ModelConfID = 1010001
  if gender == ProtoEnum.ESexValue.SEX_MALE then
    ModelConfID = 1010001
  else
    ModelConfID = 1010002
  end
  local modelConfig = _G.DataConfigManager:GetModelConf(ModelConfID)
  modelPath = modelConfig and modelConfig.path or ""
  return modelPath
end

function BattlePlayerInspector:GetId()
  return self.uin
end

function BattlePlayerInspector:PostInit()
  Base.PostInit(self)
  self:SetVisibility(false)
  local model = self:GetModel()
  if model.DisableFalling then
    local playerModel = model
    playerModel:DisableFalling()
  end
  local aSetFashionSuit = a.wrap(self.SetFashionSuit)
  a.wait(aSetFashionSuit(self))
  local positionOk, errorMessage = self:InitPosition()
  if not positionOk then
    return false, errorMessage
  end
  local status, messageOrResult = a.wait(self:InitOutSceneAsyncTask())
  if not status then
    Log.Error("BattleNpc:Init InitOutScene error", messageOrResult)
  end
  self:PinOnTheGround()
  self:LoadBPComponents()
  self:SetVisibility(true)
  return true
end

function BattlePlayerInspector:PostShowWithFadeAndAnim()
  self:StartPlayIdleSkill()
end

function BattlePlayerInspector:SetFashionSuit(callback)
  local fashionInfo = self.fashionInfo
  local appearanceInfo = fashionInfo and fashionInfo.appearance_info
  local wearing_item = appearanceInfo and appearanceInfo.wearing_item or appearanceInfo and appearanceInfo.fashion_id or {}
  local salonIds = appearanceInfo and appearanceInfo.salon_item_data or {}
  local gender = fashionInfo and fashionInfo.gender
  self.model:SetDefaultSuit(self.model.Mesh, gender, wearing_item, salonIds, callback, nil)
end

function BattlePlayerInspector:SetVisibility(isVisible)
  local player = self.model
  if UE.UObject.IsValid(player) then
    if player:IsA(UE.ARocoCharacter) then
      local model = self.model
      model:SetForceHidden(not isVisible)
    else
      player:SetActorHiddenInGame(not isVisible)
    end
  end
end

function BattlePlayerInspector:GetPlayAnimDelayTime()
  local showTimeIntervalConfig = _G.DataConfigManager:GetBattleGlobalConfig("player_show_time interval")
  local showTimeInterval = showTimeIntervalConfig and showTimeIntervalConfig.num or 0
  local showTimeIntervalRandomDeviationConfig = _G.DataConfigManager:GetBattleGlobalConfig("player_show_time interval_random_deviation")
  local showTimeIntervalRandomDeviation = showTimeIntervalRandomDeviationConfig and showTimeIntervalRandomDeviationConfig.num or 0
  local min = showTimeInterval - showTimeIntervalRandomDeviation
  local max = showTimeInterval + showTimeIntervalRandomDeviation
  local nextPlayDelay = min + math.random() * (max - min)
  local animSeconds = 0
  local delaySeconds = math.max(animSeconds, nextPlayDelay)
  return delaySeconds
end

function BattlePlayerInspector:StartPlayIdleAnim()
  if self.currentPlayAnimContext then
    local cdDelayId = self.currentPlayAnimContext.cdDelayId
    _G.DelayManager:CancelDelayById(cdDelayId)
    self.currentPlayAnimContext = nil
  end
  local animName
  if #self.idleAnimationNameList > 0 then
    local randomIndex = math.random(#self.idleAnimationNameList)
    animName = self.idleAnimationNameList[randomIndex]
  end
  local animSeconds = 0
  if UE.UObject.IsValid(self.model) and animName then
    animSeconds = self.model:PlayAnimByName(animName)
  end
  local delaySeconds = self:GetPlayAnimDelayTime()
  if 0 == delaySeconds then
    delaySeconds = 1
  end
  local context = {}
  self.currentPlayAnimContext = context
  local cdDelayId = _G.DelayManager:DelaySeconds(delaySeconds, self.OnPlayAnimCdComplete, self, context)
  context.animName = animName
  context.cdDelayId = cdDelayId
end

function BattlePlayerInspector:StartPlayIdleSkill()
  local skillPathConfig = _G.DataConfigManager:GetBattleGlobalConfig("player_animation_name1")
  local skillPath = skillPathConfig and skillPathConfig.str or ""
  if string.IsNilOrEmpty(skillPath) then
    Log.Error("BattlePlayerInspector:StartPlayIdleSkill skillPath is nil or empty")
    return
  end
  local context = {}
  context.skillPath = skillPath
  self.currentPlayAnimContext = context
  _G.BattleSkillManager:PreLoadSingleRes(skillPath, true, self, self.OnLoadIdleSkillComplete, context)
end

function BattlePlayerInspector:OnLoadIdleSkillComplete(isLoadSucceed, skillPath, context)
  if not isLoadSucceed then
    Log.Warning("BattlePlayerInspector:OnLoadIdleSkillComplete skill failed to load", skillPath)
    self:OnPlayAnimCdComplete(context)
    return
  end
  local model = self:GetModel()
  local CastParam = CastSkillObject.Create()
  CastParam.ResID = skillPath
  CastParam:SetIsPassive(true)
  CastParam:SetCaster(model)
  if UE.UObject.IsValid(model) then
    local skillComponent = model and model.RocoSkill
    local _, skillObject = _G.BattleSkillManager:PrepareSkill(self, skillComponent, CastParam)
    context.skillObject = skillObject
    skillObject:RegisterEventCallback("SkillEnd", self, function()
      Log.Info("BattlePlayerInspector:OnLoadIdleSkillComplete skill end")
    end)
    _G.BattleSkillManager:PlaySkill(skillObject)
  end
  local delaySeconds = self:GetPlayAnimDelayTime()
  local cdDelayId = _G.DelayManager:DelaySeconds(delaySeconds, self.OnPlayAnimCdComplete, self, context)
  context.cdDelayId = cdDelayId
end

function BattlePlayerInspector:OnPlayAnimCdComplete(context)
  if context ~= self.currentPlayAnimContext then
    return
  end
  self.currentPlayAnimContext = nil
  self:StartPlayIdleSkill()
end

function BattlePlayerInspector:Destroy()
  Log.Info("BattlePlayerInspector:Destroy", self.name)
  if self.destroyed then
    return
  end
  if self.currentPlayAnimContext then
    local cdDelayId = self.currentPlayAnimContext.cdDelayId
    _G.DelayManager:CancelDelayById(cdDelayId)
    self.currentPlayAnimContext = nil
  end
  if UE.UObject.IsValid(self.model) then
    self.model:K2_DestroyActor()
  end
  self.model = nil
  Base.Destroy(self)
end

return BattlePlayerInspector
