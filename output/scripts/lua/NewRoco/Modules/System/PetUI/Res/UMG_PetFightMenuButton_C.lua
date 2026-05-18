local UMG_PetFightMenuButton_C = _G.NRCViewBase:Extend("UMG_PetFightMenuButton_C")

function UMG_PetFightMenuButton_C:Initialize(Initializer)
end

function UMG_PetFightMenuButton_C:OnConstruct()
end

function UMG_PetFightMenuButton_C:OnDestruct()
  table.clear(self.data)
  self.data = nil
  self.icon2:ReleaseForce()
  self.icon1:ReleaseForce()
end

function UMG_PetFightMenuButton_C:OnEnable()
end

function UMG_PetFightMenuButton_C:OnDisable()
end

function UMG_PetFightMenuButton_C:SetData(_data)
  self.data = _data
  self:UpdateMenuInfo()
  self:SetSelectState(false)
end

function UMG_PetFightMenuButton_C:SetSelectState(_flag)
  self.selectFlag = _flag
  if _flag then
    self:PlayAnimation(self.Select, 0, 0, 0)
    self.activeState:SetVisibility(UE4.ESlateVisibility.Visible)
    self.normalState:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self.normalState:SetVisibility(UE4.ESlateVisibility.Visible)
    self.activeState:SetVisibility(UE4.ESlateVisibility.Hidden)
    self:StopAllAnimations()
  end
end

function UMG_PetFightMenuButton_C:UpdateMenuInfo()
  self.icon1:SetPath(self.data.icon1)
  self.icon2:SetPath(self.data.icon2)
end

function UMG_PetFightMenuButton_C:OnTouchEnded(_myGeometry, _inTouchEvent)
  local data = self.data
  if data then
    if data.callbackCaller and data.callbackFunc then
      tcall(data.callbackCaller, data.callbackFunc, data.index or -1, true)
    end
    if data.soundId then
      _G.NRCAudioManager:PlaySound2DAuto(data.soundId, "UMG_PetFightMenuButton_C:OnTouchEnded")
    end
  end
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

return UMG_PetFightMenuButton_C
