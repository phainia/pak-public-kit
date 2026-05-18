local EventDispatcher = require("Common.EventDispatcher")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local CastSkillObject = require("NewRoco.Modules.Core.Battle.BattleCore.Skill.CastSkillObject")
local BattlePlayerBase = require("NewRoco.Modules.Core.Battle.BattleCore.BattlePlayerBase")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BattleCheersSwitchPlayer = BattlePlayerBase:Extend()

function BattleCheersSwitchPlayer:Ctor(owner)
  BattlePlayerBase.Ctor(self)
  EventDispatcher():Attach(self)
  self.BattleManager = _G.BattleManager
  self.PawnManager = self.BattleManager.battlePawnManager
end

function BattleCheersSwitchPlayer:Play(performNode)
  self.performNode = performNode
  self.performInfo = performNode:GetInfo()
  self.cheersSwitch = self.performInfo.cheers_switch
  self.cheerPet = self.PawnManager:GetPetByGuid(self.cheersSwitch.pet_id)
  self.battlePet = self.PawnManager:GetPetByGuid(self.cheersSwitch.old_pet_id)
  if self.battlePet and not self.battlePet.card:IsExistAtField() then
    self.battlePet = nil
  end
  self:SafeDelayFrames("d_OnSyncData", 1, self.OnSyncData, self)
end

function BattleCheersSwitchPlayer:OnSyncData()
  if self.cheerPet then
    if self.battlePet then
      self.battlePet.card.posInField = self.cheerPet.card.posInField
      self.battlePet:SetAttachPoint()
    end
    self.cheerPet.card.posInField = self.cheersSwitch.to_pos
    self.cheerPet:SetAttachPoint()
    if self.cheerPet.card:IsCheerPet() then
      self.targetPos = self.BattleManager.vBattleField:GetPositionInElliptic(self.cheerPet.card.petInfo.battle_inside_pet_info.cheers_tag)
    else
      local tTransform = self.BattleManager.vBattleField:GetPositionInBattleMap(self.cheerPet.teamEnm, self.cheersSwitch.to_pos)
      self.targetPos = UE4.FVector(tTransform.Translation.X, tTransform.Translation.Y, tTransform.Translation.Z)
    end
    if 2 == self.cheersSwitch.type then
      self:StartMove()
    else
      self:ShowPopup()
      self:StartMove()
    end
  else
    Log.Error("zgx can not find cheer pet at BattleCheersSwitchPlayer!!!! ", self.cheersSwitch.pet_id)
    self:Finish()
  end
end

function BattleCheersSwitchPlayer:ShowPopup()
  if self.performNode.IsFastPlay then
    return
  end
  _G.BattleEventCenter:Dispatch(BattleEvent.UI_SHOW_INFO_POPUP, {
    BattleEnum.InfoPopupType.CheerPetEnter,
    self.cheerPet
  }, self)
end

function BattleCheersSwitchPlayer:FocusCheerPet()
  local skillClass = BattleSkillManager:GetLoadedClass(BattleConst.FocusPet)
  if skillClass then
    local Skill = self.cheerPet.model.RocoSkill:AddSkillObjFromClassAndReturn(skillClass)
    Skill:SetCaster(self.cheerPet.model):RegisterEventCallback("End", self, self.StartMove):RegisterEventCallback("PreEnd", self, self.StartMove):RegisterEventCallback("Interrupt", self, self.StartMove)
    local activeSkill = self.cheerPet.model.RocoSkill:GetActiveSkill()
    if activeSkill then
      self.cheerPet.model.RocoSkill:CancelSkill(activeSkill, UE4.ESkillActionResult.SkillActionResultInterrupted)
    end
    self.cheerPet.model.RocoSkill:LoadAndPlaySkill(Skill)
  else
    self:StartMove()
  end
end

function BattleCheersSwitchPlayer:StartMove()
  if self.battlePet then
    if self.performNode.IsFastPlay then
      local targetPos = self.cheerPet.model:Abs_K2_GetActorLocation()
      local RightPos = UE4.UNRCStatics.PinActorOnGround(nil, self.battlePet.model, SceneUtils.ConvertAbsoluteToRelative(targetPos), self.battlePet.model)
      self.battlePet.model:K2_SetActorLocation(RightPos)
    else
      self.battlePet:MoveTo(self.cheerPet.model:Abs_K2_GetActorLocation(), true)
    end
  end
  if self.targetPos then
    if self.performNode.IsFastPlay then
      local RightPos = UE4.UNRCStatics.PinActorOnGround(nil, self.cheerPet.model, SceneUtils.ConvertAbsoluteToRelative(self.targetPos), self.cheerPet.model)
      self.cheerPet.model:K2_SetActorLocation(RightPos)
      self:Finish()
    else
      self.cheerPet:MoveTo(self.targetPos, true, self.Finish, self)
    end
  else
    self:Finish()
  end
end

function BattleCheersSwitchPlayer:HidePopup()
  _G.BattleEventCenter:Dispatch(BattleEvent.UI_HIDE_INFO_POPUP, nil, self)
end

function BattleCheersSwitchPlayer:Reset()
  self.cheerPet = nil
  self.battlePet = nil
  self.targetPos = nil
  self.cheersSwitch = nil
  self.performNode = nil
  self.performInfo = nil
end

function BattleCheersSwitchPlayer:Finish()
  if self.cheerPet then
    _G.BattleEventCenter:Dispatch(BattleEvent.CHEER_SWITCH, self.cheerPet)
  end
  self.performNode:PerformComplete()
  self:Reset()
end

return BattleCheersSwitchPlayer
