local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_PetSkillMenuButton_C = _G.NRCViewBase:Extend("UMG_PetSkillMenuButton_C")

function UMG_PetSkillMenuButton_C:Initialize(Initializer)
end

function UMG_PetSkillMenuButton_C:OnConstruct()
end

function UMG_PetSkillMenuButton_C:OnDestruct()
  self.icon1:ReleaseForce()
  self.icon2:ReleaseForce()
end

function UMG_PetSkillMenuButton_C:OnEnable()
end

function UMG_PetSkillMenuButton_C:OnDisable()
end

function UMG_PetSkillMenuButton_C:SetData(_data)
  self.data = _data
  self:UpdateMenuInfo()
  self:SetSelectState(false)
end

function UMG_PetSkillMenuButton_C:SetSelectState(_flag)
  self.selectFlag = _flag
  if _flag then
    self:PlayAnimation(self.Selct, 0, 0, 0)
    self.activeState:SetVisibility(UE4.ESlateVisibility.Visible)
    self.normalState:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self:StopAllAnimations()
    self.normalState:SetVisibility(UE4.ESlateVisibility.Visible)
    self.activeState:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_PetSkillMenuButton_C:UpdateMenuInfo()
  self.icon1:SetPath(self.data.icon1)
  self.icon2:SetPath(self.data.icon2)
end

function UMG_PetSkillMenuButton_C:OnTouchEnded(_myGeometry, _inTouchEvent)
  local data = self.data
  if data then
    if data.callbackCaller and data.callbackFunc then
      tcall(data.callbackCaller, data.callbackFunc, data.index or -1, true)
    end
    if data.soundId then
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(data.soundId, "UMG_PetSkillMenuButton_C:OnTouchEnded")
    end
  end
  return UE.UWidgetBlueprintLibrary.Unhandled()
end

return UMG_PetSkillMenuButton_C
