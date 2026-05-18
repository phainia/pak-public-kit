local ProtoEnum = require("Data.PB.ProtoEnum")
local UMG_Battle_Buff_C = NRCUmgClass:Extend("")

function UMG_Battle_Buff_C:Construct()
  self.stack = 0
  self.stackToDisplay = 0
  self.exist = true
end

function UMG_Battle_Buff_C:UpdateBuffShowType()
  if not self.ShowType or self.ShowType == _G.BattleConst.BuffIconShowType.None then
    self.Icon:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.CanvasPanel_27:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.btnBuff:SetVisibility(UE4.ESlateVisibility.Hidden)
  elseif self.ShowType == _G.BattleConst.BuffIconShowType.WorldUI then
    self.Icon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.CanvasPanel_27:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.btnBuff:SetVisibility(UE4.ESlateVisibility.Hidden)
  elseif self.ShowType == _G.BattleConst.BuffIconShowType.ScreenBtn then
    self.Icon:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.CanvasPanel_27:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.btnBuff:SetVisibility(UE4.ESlateVisibility.Visible)
  elseif self.ShowType == _G.BattleConst.BuffIconShowType.ScreenBtnAndUI then
    self.Icon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.CanvasPanel_27:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.btnBuff:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  self:UpdateCornerIcon()
end

function UMG_Battle_Buff_C:IsCanShow()
  if self.ShowType == _G.BattleConst.BuffIconShowType.None or self.ShowType == _G.BattleConst.BuffIconShowType.ScreenBtn then
    return false
  end
  return true
end

function UMG_Battle_Buff_C:OnInitialized()
  if not self:IsCanShow() then
    return
  end
  if self.IconPath then
    self.Icon:SetPath(self.IconPath)
  end
end

function UMG_Battle_Buff_C:SetShowType(type)
  self.ShowType = type
  self:UpdateBuffShowType()
end

function UMG_Battle_Buff_C:Unclickableclick(InPos)
  if not self:IsCanShow() then
    return
  end
  if self.Icon and self.Icon.GetCachedGeometry then
    local PPosition, Position = UE4.USlateBlueprintLibrary.LocalToViewport(UE4Helper.GetCurrentWorld(), self.Icon:GetCachedGeometry(), UE4.FVector2D(15, 15))
    local InPosition = UE4.FVector2D(InPos.X, InPos.Y)
    local Diff = UE4.UKismetMathLibrary.Distance2D(PPosition, InPosition)
    if Diff < 20 then
      self.call(self.caller)
    end
  end
end

function UMG_Battle_Buff_C:SetBuffInfo(buff)
  self.buff = buff
end

function UMG_Battle_Buff_C:UpdateCornerIcon()
  if self.buff then
    local buffConfig = _G.DataConfigManager:GetBuffConf(self.buff.id)
    local corner_markers = buffConfig.corner_markers
    if corner_markers then
      if not self.ShowType or self.ShowType == _G.BattleConst.BuffIconShowType.None then
        self.Buff_CornerMark:SetVisibility(UE4.ESlateVisibility.Hidden)
      elseif self.ShowType == _G.BattleConst.BuffIconShowType.WorldUI then
        self.Buff_CornerMark:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      elseif self.ShowType == _G.BattleConst.BuffIconShowType.ScreenBtn then
        self.Buff_CornerMark:SetVisibility(UE4.ESlateVisibility.Hidden)
      elseif self.ShowType == _G.BattleConst.BuffIconShowType.ScreenBtnAndUI then
        self.Buff_CornerMark:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      self.Buff_CornerMark:SetPath(corner_markers)
    else
      self.Buff_CornerMark:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self.Buff_CornerMark:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Battle_Buff_C:UpdateBurial(buff)
  self.BuffStackText_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Battle_Buff_C:UpdateStack(stack, syncDisplay)
  if not self:IsCanShow() then
    return
  end
  self.stack = stack
  if syncDisplay then
    self:UpdateStackDisplay(stack)
  end
end

function UMG_Battle_Buff_C:UpdateStackDisplay(stackToDisplay)
  self.stackToDisplay = stackToDisplay
  if self.BuffStackText then
    if stackToDisplay >= 2 then
      self.BuffStackText:SetText(stackToDisplay)
    else
      self.BuffStackText:SetText("")
    end
  end
end

function UMG_Battle_Buff_C:ChangeIcon(IconPath)
  if not self:IsCanShow() then
    return
  end
  local result = self.Icon:SetPath(IconPath)
  if not result then
    self.IconPath = IconPath
  end
end

function UMG_Battle_Buff_C:OnTriggerFlash()
  if not self:IsCanShow() then
    return
  end
  self:PlayAnimation(self.FlashAnim)
end

function UMG_Battle_Buff_C:OnTriggerNumberChange(isAdd)
  if not self:IsCanShow() then
    return
  end
  self.NumberSubAnimCallback = nil
  local stackToDisplay = self.stack
  if isAdd then
    self:UpdateStackDisplay(stackToDisplay)
    self:PlayAnimation(self.NumberAdd)
  else
    function self.NumberSubAnimCallback()
      self:UpdateStackDisplay(stackToDisplay)
    end
    
    self:PlayAnimation(self.NumberSub)
  end
end

function UMG_Battle_Buff_C:RunRemoveCall()
  if self.removeCaller and self.removeCall then
    self.removeCall(self.removeCaller)
  end
  self.removeCaller = nil
  self.removeCall = nil
end

function UMG_Battle_Buff_C:OnAnimationFinished(animation)
  if animation == self.DestructAnim and not self.exist then
    self:RemoveFromParent()
    self:RunRemoveCall()
  end
  if animation == self.NumberSub then
    local callback = self.NumberSubAnimCallback
    self.NumberSubAnimCallback = nil
    if callback then
      callback()
      self:PlayAnimation(self.NumberSub_2)
    end
  end
end

function UMG_Battle_Buff_C:Remove(immediate, removeCaller, removeCall)
  if immediate then
    self:RemoveFromParent()
    removeCall(removeCaller)
  else
    self.removeCaller = removeCaller
    self.removeCall = removeCall
    self:TriggerDestructAnimation()
  end
end

function UMG_Battle_Buff_C:TriggerDestructAnimation()
  if not self:IsCanShow() then
    self:RemoveFromParent()
    return
  end
  self:PlayAnimation(self.DestructAnim)
  self.exist = false
end

function UMG_Battle_Buff_C:TriggerConstructAnimation()
  if not self:IsCanShow() then
    return
  end
  self:PlayAnimation(self.ConstructAnim)
  self.exist = true
end

function UMG_Battle_Buff_C:SetShowState(needShow)
  self:UpdateBuffShowType()
  self.needShow = needShow
  if needShow then
    self:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Battle_Buff_C:GetNeedShow(Caller, CallBack)
  return self.needShow
end

function UMG_Battle_Buff_C:SetCallBack(Caller, CallBack)
  self.Caller = Caller
  self.CallBack = CallBack
end

function UMG_Battle_Buff_C:OnDestruct()
  if self.Caller and self.CallBack then
    self.CallBack(self.Caller)
    self.Caller = nil
    self.CallBack = nil
  end
end

return UMG_Battle_Buff_C
