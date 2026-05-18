require("UnLuaEx")
local Enum = require("Data.Config.Enum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = _G.NRCUmgClass
local UMG_Battle_ClickTipUI_C = Base:Extend("UMG_Battle_ClickTipUI_C")
UMG_Battle_ClickTipUI_C.Data = NRCUmgClass:Extend("")
UMG_Battle_ClickTipUI_C.ColorSchemeType = {
  Default = 1,
  Restraint = 2,
  Catch = 3
}
UMG_Battle_ClickTipUI_C.GradeColorType = {
  White = 1,
  Red = 2,
  Yellow = 3,
  Green = 4
}
UMG_Battle_ClickTipUI_C.ColorScheme = {
  [UMG_Battle_ClickTipUI_C.ColorSchemeType.Default] = {
    [1] = UMG_Battle_ClickTipUI_C.GradeColorType.Red,
    [2] = UMG_Battle_ClickTipUI_C.GradeColorType.Yellow,
    [3] = UMG_Battle_ClickTipUI_C.GradeColorType.White
  },
  [UMG_Battle_ClickTipUI_C.ColorSchemeType.Restraint] = {
    [1] = UMG_Battle_ClickTipUI_C.GradeColorType.Red,
    [2] = UMG_Battle_ClickTipUI_C.GradeColorType.White,
    [3] = UMG_Battle_ClickTipUI_C.GradeColorType.Green
  },
  [UMG_Battle_ClickTipUI_C.ColorSchemeType.Catch] = {
    [1] = UMG_Battle_ClickTipUI_C.GradeColorType.Red,
    [2] = UMG_Battle_ClickTipUI_C.GradeColorType.Yellow,
    [3] = UMG_Battle_ClickTipUI_C.GradeColorType.White
  }
}

function UMG_Battle_ClickTipUI_C.Data:Ctor(stt, sftt, catchGrade, colorSchemeType)
  self.stt = stt
  self.sftt = sftt
  self.catchGrade = catchGrade
  self.colorSchemeType = colorSchemeType or UMG_Battle_ClickTipUI_C.ColorSchemeType.Default
end

function UMG_Battle_ClickTipUI_C:Construct()
  self.ClickBtn.OnClicked:Add(self, self.OnClickPet)
end

function UMG_Battle_ClickTipUI_C:Destruct()
  self.ClickBtn.OnClicked:Remove(self, self.OnClickPet)
  self.ownerPet = nil
end

function UMG_Battle_ClickTipUI_C:CallCtrlUserWidgetEvent(funcName, ...)
  if self.ctrl and self.ctrl[funcName] then
    return tcall(self.ctrl, self.ctrl[funcName], ...)
  elseif self.Overridden[funcName] then
    return tcall(self, self.Overridden[funcName], ...)
  end
end

function UMG_Battle_ClickTipUI_C:OnClickPet()
  if self.ownerPet and not BattleUtils.IsWatchingBattle() then
    self.ownerPet:OnPetClick()
    if BattleUtils.IsFinalBattleP1() then
      _G.NRCEventCenter:DispatchEvent(NRCGlobalEvent.FinalBattleCloseTutorial)
    end
  end
end

function UMG_Battle_ClickTipUI_C:PlayClickAnim(Caller, CallBack)
  if not self.isClick then
    self.isClick = true
    self.clickCaller = Caller
    self.clickCallerFun = CallBack
    if not self.ClickAnim then
      self.ClickAnim = self.SphereAnim_Ones_W_N
    end
    self:StopAllAnimations()
    self:PlayAnimation(self.ClickAnim)
    if self.ClickAnim == self.SphereAnim_Loop_Y_N then
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1181, "UMG_Battle_ClickTipUI_C:PlayClickAnim")
    elseif self.ClickAnim == self.SphereAnim_Ones_W_N then
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1184, "UMG_Battle_ClickTipUI_C:PlayClickAnim")
    elseif self.ClickAnim == self.SphereAnim_Ones_R_N then
    end
  end
end

function UMG_Battle_ClickTipUI_C:SetData(_data, ownerPet)
  self.data = _data
  self.ownerPet = ownerPet
  self:SetActiveAnimation()
end

function UMG_Battle_ClickTipUI_C:SetActiveAnimation()
  self.isClick = false
  self:StopAllAnimations()
  if not self.data then
    self:PlayAnimation(self.In_W_N)
    return
  end
  local stt = self.data.stt
  local sftt = self.data.sftt
  local catchGrade = self.data.catchGrade
  local colorSchemeType = self.data.colorSchemeType or UMG_Battle_ClickTipUI_C.ColorSchemeType.Default
  local colorScheme = UMG_Battle_ClickTipUI_C.ColorScheme[colorSchemeType]
  if not (not catchGrade and stt) or not sftt then
    local colorType = colorScheme and colorScheme[catchGrade]
    if colorType then
      if colorType == UMG_Battle_ClickTipUI_C.GradeColorType.Red then
        self:PlayAnimation(self.In_R_N)
        return
      elseif colorType == UMG_Battle_ClickTipUI_C.GradeColorType.White then
        self:PlayAnimation(self.In_W_N)
        return
      elseif colorType == UMG_Battle_ClickTipUI_C.GradeColorType.Green then
        self:PlayAnimation(self.In_G_N)
        return
      elseif colorType == UMG_Battle_ClickTipUI_C.GradeColorType.Yellow then
        self:PlayAnimation(self.In_Y_N)
        return
      end
    end
  end
  if sftt == Enum.SkillFilterTitleType.SFTT_NEGATIVE and stt == Enum.SkillTargetType.STT_RANDOM_ENEMY then
    self.ClickAnim = self.SphereAnim_Loop_Y_N
    self:PlayAnimation(self.SphereAnim_Loop_Y_N, 0, 0)
  elseif sftt == Enum.SkillFilterTitleType.SFTT_NEGATIVE and (stt == Enum.SkillTargetType.STT_ALL_ENEMY or stt == Enum.SkillTargetType.STT_ALL_OTHER) then
    self.ClickAnim = self.SphereAnim_Ones_Y_N
    self:PlayAnimation(self.SphereAnim_Ones_Y_N, 0, 0)
  elseif sftt == Enum.SkillFilterTitleType.SFTT_POSITIVE and (stt == Enum.SkillTargetType.STT_RANDOM_ALLY or stt == Enum.SkillTargetType.STT_ONE_OTHER_ALLY or stt == Enum.SkillTargetType.STT_MYSELF) then
    self.ClickAnim = self.SphereAnim_Loop_W_N
    self:PlayAnimation(self.SphereAnim_Loop_W_N, 0, 0)
  elseif sftt == Enum.SkillFilterTitleType.SFTT_POSITIVE and (stt == Enum.SkillTargetType.STT_ALL_ALLY or stt == Enum.SkillTargetType.STT_ALL_OTHER or stt == Enum.SkillTargetType.STT_ALL_OTHER_ALLY) then
    self.ClickAnim = self.SphereAnim_Ones_W_N
    self:PlayAnimation(self.SphereAnim_Ones_W_N, 0, 0)
  else
    self.ClickAnim = self.SphereAnim_Ones_W_N
    self:PlayAnimation(self.SphereAnim_Ones_W_N, 0, 0)
  end
end

function UMG_Battle_ClickTipUI_C:OnAnimationFinished(Animation)
  if Animation == self.ClickAnim then
    if self.clickCallerFun then
    end
  elseif not self.isClick then
    if Animation == self.In_W_N then
      self:PlayAnimation(self.SphereAnim_Loop_W_N, 0, 0)
    elseif Animation == self.In_Y_N then
      self:PlayAnimation(self.SphereAnim_Loop_Y_N, 0, 0)
    elseif Animation == self.In_R_N then
      self:PlayAnimation(self.SphereAnim_Loop_R_N, 0, 0)
    elseif Animation == self.In_G_N then
      self:PlayAnimation(self.SphereAnim_Loop_G_N, 0, 0)
    end
  end
end

return UMG_Battle_ClickTipUI_C
