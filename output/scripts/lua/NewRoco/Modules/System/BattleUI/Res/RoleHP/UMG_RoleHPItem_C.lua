local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local RoleHpData = require("NewRoco.Modules.System.BattleUI.Res.RoleHP.RoleHPMinItem_Data")
local UMG_RoleHPItem_C = Base:Extend("UMG_RoleHPItem_C")

function UMG_RoleHPItem_C:OnDestruct()
end

function UMG_RoleHPItem_C:HideAll()
  self.CanvasPanelEnemy:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.CanvasPanelTeam:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.NRCImagehp_team:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.NRCImagehp_enemy:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.NRCImage_teamgrey:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.NRCImage_enemygrey:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.NRCImage_black:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.NRCImage_black_1:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_RoleHPItem_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  Log.Dump(self.uiData, 2, "UMG_RoleHPMinItem_C:OnItemUpdate")
  self:updateItemInfo()
end

function UMG_RoleHPItem_C:updateItemInfo()
  self:HideAll()
  self.CanvasPanelEnemy:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.CanvasPanelTeam:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.CanvasPanelNightmare:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.un_lock_new:SetVisibility(UE4.ESlateVisibility.Hidden)
  if self.uiData.isLock == true then
    self.CanvasPanelNightmare:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif true == self.uiData.isUnlock then
    self.un_lock_new:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.CanvasPanelTeam:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRCImagehp_team:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif self.uiData.teamFlag == BattleEnum.Team.ENUM_TEAM then
    self.CanvasPanelEnemy:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.CanvasPanelTeam:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if self.uiData.isFull then
      self.NRCImagehp_team:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.NRCImage_black:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif self.uiData.teamFlag == BattleEnum.Team.ENUM_ENEMY then
    self.CanvasPanelTeam:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.CanvasPanelEnemy:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if self.uiData.isFull then
      self.NRCImagehp_enemy:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.NRCImage_black_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  if true == self.uiData.isBroken then
    self:StopAllAnimations()
    self:PlayAnimation(self.broken)
    if self.uiData.teamFlag == BattleEnum.Team.ENUM_ENEMY then
      self.NRCImage_enemygrey:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1155, "UMG_RoleHPItem_C.breakEnemy")
    elseif self.uiData.teamFlag == BattleEnum.Team.ENUM_TEAM then
      self.NRCImage_teamgrey:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1154, "UMG_RoleHPItem_C.breakTeam")
    end
  elseif true == self.uiData.isGrey then
    self:StopAllAnimations()
    self:PlayAnimation(self.gray)
  elseif true == self.uiData.isShow then
    self:StopAllAnimations()
    self:PlayAnimation(self.open)
  elseif self.uiData.isUnlock then
    self:StopAllAnimations()
    self:PlayAnimation(self.unlock)
  end
end

function UMG_RoleHPItem_C:OnAnimationFinished(Animation)
  if self.uiData and Animation == self.broken then
    if self.uiData.teamFlag == BattleEnum.Team.ENUM_TEAM then
      self.CanvasPanelEnemy:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.CanvasPanelTeam:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    elseif self.uiData.teamFlag == BattleEnum.Team.ENUM_ENEMY then
      self.CanvasPanelTeam:SetVisibility(UE4.ESlateVisibility.Hidden)
      self.CanvasPanelEnemy:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end

return UMG_RoleHPItem_C
