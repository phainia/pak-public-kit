local BagModuleEvent = reload("NewRoco.Modules.System.Bag.BagModuleEvent")
local UMG_BagIcon_Ani_8_C = _G.NRCPanelBase:Extend("UMG_BagIcon_Ani_8_C")

function UMG_BagIcon_Ani_8_C:OnConstruct()
end

function UMG_BagIcon_Ani_8_C:OnDestruct()
  self:CancelDelay()
end

function UMG_BagIcon_Ani_8_C:OnActive()
end

function UMG_BagIcon_Ani_8_C:OnDeactive()
end

function UMG_BagIcon_Ani_8_C:OnTouchEnded(MyGeometry, InTouchEvent)
  local IsFirstOpenPanel = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetIsFirstOpenPanel)
  if IsFirstOpenPanel then
    return UE.UWidgetBlueprintLibrary.Unhandled()
  end
  local curItemType = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetCurSelectItemType)
  if 7 ~= curItemType then
    _G.NRCModuleManager:GetModule("BagModule"):DispatchEvent(BagModuleEvent.ChangeTypeTab, 8)
    self:PlayAnimation(self.change1)
    self:DelaySeconds(3, function()
      self:PlayLoopAnim()
    end)
    _G.NRCAudioManager:PlaySound2DAuto(40001001, "UMG_BagIcon_Ani_1_C:OnTouchEnded")
  end
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_BagIcon_Ani_8_C:PlayLoopAnim()
  self:PlayAnimation(self.select_loop)
  self:CancelDelay()
  self:DelaySeconds(8, self.PlayLoopAnim, self)
end

function UMG_BagIcon_Ani_8_C:RemoveSelected(_CurItemType)
  if 7 == _CurItemType then
    self:PlayAnimation(self.normal)
    self:StopAllAnimations()
    self:PlayAnimation(self.change2)
    self:CancelDelay()
  end
end

function UMG_BagIcon_Ani_8_C:PlayDefauleSelecteAnim()
  self:PlayAnimation(self.select)
end

function UMG_BagIcon_Ani_8_C:OnAnimationFinished(Anim)
  if Anim == self.change1 then
    local curItemType = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetCurSelectItemType)
    if 7 ~= curItemType then
      self:PlayAnimation(self.normal)
    end
  end
end

return UMG_BagIcon_Ani_8_C
