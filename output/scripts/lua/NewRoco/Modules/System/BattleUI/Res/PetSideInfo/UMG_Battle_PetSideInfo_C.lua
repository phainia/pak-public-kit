local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local UMG_Battle_PetSideInfo_C = NRCUmgClass:Extend("")

function UMG_Battle_PetSideInfo_C:Construct()
  self.owner = nil
  self.battleManager = _G.BattleManager
  self:AddListener()
  self.isTick = true
  self.isShow = false
  self.ticker = 0
  self.tickerMax = 2
end

function UMG_Battle_PetSideInfo_C:Tick(g, t)
  if self.ticker > self.tickerMax and self.isTick and self.isShow then
    self:RefreshInViewport()
    self.ticker = self.ticker - self.tickerMax
  end
  self.ticker = self.ticker + t
end

function UMG_Battle_PetSideInfo_C:AddListener()
  _G.BattleEventCenter:Bind(self, BattleEvent.UI_HIDE, BattleEvent.UI_SHOW)
end

function UMG_Battle_PetSideInfo_C:RemoveListener()
  _G.BattleEventCenter:UnBind(self)
end

function UMG_Battle_PetSideInfo_C:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.UI_HIDE then
    self:Hide()
  elseif eventName == BattleEvent.UI_SHOW then
    self:Show()
  end
end

function UMG_Battle_PetSideInfo_C:SetTickEnabled(en)
  self.isTick = en
end

function UMG_Battle_PetSideInfo_C:Hide()
  if not self.owner then
    self.SideArea:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.isShow = false
    return
  end
  self.SideArea:SetVisibility(UE4.ESlateVisibility.Visible)
  self.isShow = true
end

function UMG_Battle_PetSideInfo_C:Show()
  if not self.owner then
    return
  end
  self.SideArea:SetVisibility(UE4.ESlateVisibility.Visible)
  self.isShow = true
end

function UMG_Battle_PetSideInfo_C:AddBuff(buff)
  _G.BattleResourceManager:LoadWidgetAsync(self, _G.UEPath.UMG_Battle_Buff, nil, function(caller, buffModel)
    buffModel:UpdateStack(buff.stack)
    buff.model = buffModel
    if self._BuffBox then
      self._BuffBox.BuffListingBox:AddChildToHorizontalBox(buff.model)
    end
    local buffIconPath = _G.DataConfigManager:GetBuffConf(buff.id).icon
    buffModel:ChangeIcon(buffIconPath)
  end, nil)
end

function UMG_Battle_PetSideInfo_C:ChangeBuff(buff)
  buff.model:SetBuffInfo(buff)
  buff.model:UpdateStack(buff.stack, true)
  buff.model:UpdateBurial(buff)
  buff.model:UpdateCornerIcon()
  local buffIconPath = _G.DataConfigManager:GetBuffConf(buff.id).icon
  buff.model:ChangeIcon(buffIconPath)
end

function UMG_Battle_PetSideInfo_C:RemoveBuff(buff)
  buff.model:RemoveFromParent()
end

function UMG_Battle_PetSideInfo_C:ChangeIntention()
  self._Operation:ChangeIntention()
end

function UMG_Battle_PetSideInfo_C:SetIntentionVisible(en)
  if en then
    self._Operation:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self._Operation:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_Battle_PetSideInfo_C:RefreshInViewport()
  if not self.owner then
    self:Hide()
    return
  end
  if not self.owner.model then
    self:Hide()
    return
  end
  local mHalfHeight = self.owner:GetHalfHeight()
  local mRadius = self.owner.model:GetRadius()
  if mRadius < 0 then
    mRadius = mHalfHeight
  end
  local uP = UE4.FVector2D(0, 0)
  UE4.UGameplayStatics.Abs_ProjectWorldToScreen(UE4.UGameplayStatics.GetPlayerController(self, 0), self.owner:GetActorLocation() + UE4.FVector(0, 0, mHalfHeight), uP, false)
  local dP = UE4.FVector2D(0, 0)
  UE4.UGameplayStatics.Abs_ProjectWorldToScreen(UE4.UGameplayStatics.GetPlayerController(self, 0), self.owner:GetActorLocation(), dP, false)
  local finalW = UE4.UKismetMathLibrary.Distance2D(uP, dP)
  local vP = UE4.FVector2D(0, 0)
  UE4.USlateBlueprintLibrary.ScreenToViewport(_G.UE4Helper.GetCurrentWorld(), UE4.UGameplayStatics.Abs_ProjectWorldToScreen(UE4.UGameplayStatics.GetPlayerController(self, 0), self.owner:GetActorLocation(), false) - UE4.FVector2D(0, finalW), vP)
  self:SetPositionInViewport(vP, false)
  UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.SideArea):SetSize(UE4.FVector2D(finalW * 2, finalW * 2))
end

return UMG_Battle_PetSideInfo_C
