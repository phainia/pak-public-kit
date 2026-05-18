local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local RoleHpData = require("NewRoco.Modules.System.BattleUI.Res.RoleHP.RoleHPMinItem_Data")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local UMG_HPscreenfx_C = _G.NRCPanelBase:Extend("UMG_HPscreenfx_C")

function UMG_HPscreenfx_C:OnDestruct()
end

function UMG_HPscreenfx_C:Show()
  self:StopAllAnimations()
  if self.IsShowPVP then
    self:PlayAnimation(self.Open_Victory)
  else
    self:PlayAnimation(self.open)
  end
end

function UMG_HPscreenfx_C:UpdateScore(score, isLeft)
  if isLeft then
    self.LeftScore:SetText("x" .. score)
  else
    self.RightScore:SetText("x" .. score)
  end
end

function UMG_HPscreenfx_C:ShowPVP(leftName, leftScore, rightName, rightScore)
  self.IsShowPVP = true
  BattleUtils.SetPvpScoreIcon(self.icon)
  BattleUtils.SetPvpScoreIcon(self.icon_1)
  self.PVPInfo:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.LeftName:SetText(leftName)
  self.LeftScore:SetText("x" .. leftScore)
  self.RightName:SetText(rightName)
  self.RightScore:SetText("x" .. rightScore)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1275, "UMG_HPscreenfx_C:ShowPVP Score")
end

function UMG_HPscreenfx_C:HidePVP()
  self.IsShowPVP = false
  self.PVPInfo:SetVisibility(UE4.ESlateVisibility.Hidden)
end

return UMG_HPscreenfx_C
