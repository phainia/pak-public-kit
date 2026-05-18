local UMG_BagIcon_Ani_99_C = _G.NRCPanelBase:Extend("UMG_BagIcon_Ani_99_C")
local BagModuleEvent = reload("NewRoco.Modules.System.Bag.BagModuleEvent")

function UMG_BagIcon_Ani_99_C:OnConstruct()
end

function UMG_BagIcon_Ani_99_C:OnDestruct()
end

function UMG_BagIcon_Ani_99_C:OnActive()
end

function UMG_BagIcon_Ani_99_C:OnDeactive()
end

function UMG_BagIcon_Ani_99_C:OnTouchEnded(MyGeometry, InTouchEvent)
  local IsFirstOpenPanel = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetIsFirstOpenPanel)
  if IsFirstOpenPanel then
    return UE.UWidgetBlueprintLibrary.Unhandled()
  end
  local curItemType = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetCurSelectItemType)
  if 5 ~= curItemType then
    Log.Error("UMG_BagIcon_Ani_5_C:RemoveSelected")
    _G.NRCAudioManager:PlaySound2DAuto(1004, "UMG_BagIcon_Ani_5_C:OnTouchEnded")
    _G.NRCModuleManager:GetModule("BagModule"):DispatchEvent(BagModuleEvent.ChangeTypeTab, 6)
    self:PlayAnimation(self.change1)
  end
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_BagIcon_Ani_99_C:RemoveSelected()
  self:StopAllAnimations()
  self:PlayAnimation(self.normal)
end

return UMG_BagIcon_Ani_99_C
