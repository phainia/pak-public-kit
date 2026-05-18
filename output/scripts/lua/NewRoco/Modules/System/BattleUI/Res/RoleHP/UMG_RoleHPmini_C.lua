local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local RoleHpData = require("NewRoco.Modules.System.BattleUI.Res.RoleHP.RoleHPMinItem_Data")
local UMG_RoleHPmini_C = _G.NRCPanelBase:Extend("UMG_RoleHPmini_C")

function UMG_RoleHPmini_C:OnDestruct()
end

function UMG_RoleHPmini_C:Update(player)
  if not player then
    return
  end
  if self.RoleHpNum then
    self.RoleHpNum:SetText(tostring(player.roleInfo.base.hp))
  else
    Log.Error("UMG_RoleHPmini_C.RoleHpNum is nil")
  end
end

function UMG_RoleHPmini_C:Show()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:StopAllAnimations()
  self:PlayAnimation(self.open)
end

function UMG_RoleHPmini_C:Hide()
  self:StopAllAnimations()
  self:PlayAnimation(self.close)
end

return UMG_RoleHPmini_C
