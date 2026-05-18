local UMG_BagIcon_Ani_4_C = _G.NRCPanelBase:Extend("UMG_BagIcon_Ani_4_C")
local BagModuleEvent = reload("NewRoco.Modules.System.Bag.BagModuleEvent")

function UMG_BagIcon_Ani_4_C:OnConstruct()
end

function UMG_BagIcon_Ani_4_C:OnDestruct()
  self:CancelDelay()
end

function UMG_BagIcon_Ani_4_C:OnActive()
end

function UMG_BagIcon_Ani_4_C:OnDeactive()
end

function UMG_BagIcon_Ani_4_C:OnTouchEnded(MyGeometry, InTouchEvent)
  local IsFirstOpenPanel = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetIsFirstOpenPanel)
  if IsFirstOpenPanel then
    return UE.UWidgetBlueprintLibrary.Unhandled()
  end
  local curItemType = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetCurSelectItemType)
  if 3 ~= curItemType then
    _G.NRCModuleManager:GetModule("BagModule"):DispatchEvent(BagModuleEvent.ChangeTypeTab, 4)
    self:StopAllAnimations()
    self:PlayAnimation(self.change1)
    self.isSelect = true
    self:DelaySeconds(3, function()
      self:PlayLoopAnim()
    end)
    _G.NRCAudioManager:PlaySound2DAuto(40001001, "UMG_BagIcon_Ani_4_C:OnTouchEnded")
  end
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_BagIcon_Ani_4_C:PlayLoopAnim()
  self:PlayAnimation(self.select_loop)
  self:CancelDelay()
  self:DelaySeconds(8, self.PlayLoopAnim, self)
end

function UMG_BagIcon_Ani_4_C:RemoveSelected(_CurItemType)
  if 3 == _CurItemType then
    self.isSelect = false
    self.CurItemType = _CurItemType
    self:PlayAnim()
  end
end

function UMG_BagIcon_Ani_4_C:PlayAnim()
  if 3 == self.CurItemType then
    self:PlayAnimation(self.normal)
    self:StopAllAnimations()
    self:CancelDelay()
    self:PlayAnimation(self.change2)
  end
end

function UMG_BagIcon_Ani_4_C:OnAnimationFinished(Anim)
  if Anim == self.change1 then
    local curItemType = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetCurSelectItemType)
    if 3 ~= curItemType and self.isSelect and self.isSelect == false then
      self:PlayAnimation(self.normal)
    end
  end
end

return UMG_BagIcon_Ani_4_C
