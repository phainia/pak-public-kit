local UMG_TravelSwitchBtn_C = NRCClass()

function UMG_TravelSwitchBtn_C:Init(index)
  self.CurIndex = index
  local icons = {
    "img_Iconditu_png.img_Iconditu_png",
    "img_Iconlvxing_png.img_Iconlvxing_png"
  }
  local path = "PaperSprite'/Game/NewRoco/Modules/System/BigMap/Raw/Atlas/BigMap/Frames/%s'"
  local iconPath = string.format(path, icons[index])
  self:SetIconPath(iconPath)
  self.Button.OnClicked:Add(self, self.SelectTable)
  if 2 == index then
    self.Dot:SetupKey(201)
  end
end

function UMG_TravelSwitchBtn_C:SetIconPath(path)
  self.Icon:SetPath(path)
end

function UMG_TravelSwitchBtn_C:SelectTable()
  if self:CheckIsSelectBtn() then
    return
  end
  local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "MainBigMap").SWITCH
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.LockIsSelectBtn, "BigMapModule", "MainBigMap", touchReasonType)
  _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.SetIsTravel, 2 == self.CurIndex)
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_TravelSwitchBtn_C:SelectTable")
end

function UMG_TravelSwitchBtn_C:OnChangeAim(isSelect)
  self:StopAllAnimations()
  if isSelect then
    self:PlayAnimation(self.Press)
  else
    self:PlayAnimation(self.Normal)
  end
end

function UMG_TravelSwitchBtn_C:OnAnimationFinished(aim)
end

function UMG_TravelSwitchBtn_C:CheckIsSelectBtn()
  return _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetIsSelectBtn, "BigMapModule", "MainBigMap")
end

return UMG_TravelSwitchBtn_C
