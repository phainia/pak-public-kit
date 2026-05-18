local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local UMG_Battle_PVE_RoleHpPanel_C = _G.NRCPanelBase:Extend("UMG_Battle_PVE_RoleHpPanel_C")

function UMG_Battle_PVE_RoleHpPanel_C:Construct()
  self.battleManager = _G.BattleManager
  self.uiData = {}
  self:AddListener()
  self:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_Battle_PVE_RoleHpPanel_C:Destruct()
  self:RemoveListener()
  self.uiData = nil
  NRCUmgClass.Destruct(self)
end

function UMG_Battle_PVE_RoleHpPanel_C:OnActive()
  if self:IsPCMode() then
    self:PCModeScreenSetting()
  end
  self.PveBattleRoleHpShow:Show()
  self.UMG_HPscreenfx_82:Show()
end

function UMG_Battle_PVE_RoleHpPanel_C:OnDeactive()
end

function UMG_Battle_PVE_RoleHpPanel_C:AddListener()
end

function UMG_Battle_PVE_RoleHpPanel_C:RemoveListener()
end

function UMG_Battle_PVE_RoleHpPanel_C:IsPCMode()
  return UE.UGameplayStatics.GetGameInstance(self):IsPCMode()
end

function UMG_Battle_PVE_RoleHpPanel_C:PCModeScreenSetting()
  local Padding = UE4.FMargin()
  Padding.Left = -164
  Padding.Top = -74
  Padding.Right = -164
  Padding.Bottom = -74
  self.PveBattleRoleHpShow:SetRenderScale(UE4.FVector2D(0.88, 0.88))
  self.PveBattleRoleHpShow.Slot:SetOffsets(Padding)
end

return UMG_Battle_PVE_RoleHpPanel_C
