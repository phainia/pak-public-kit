local HandbookModuleEvent = reload("NewRoco.Modules.System.Handbook.HandbookModuleEvent")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local HandbookModuleEnum = reload("NewRoco.Modules.System.Handbook.HandbookModuleEnum")
local UMG_DistrictMapGuideTabIcon_Ani_C = Base:Extend("UMG_DistrictMapGuideTabIcon_Ani_C")

function UMG_DistrictMapGuideTabIcon_Ani_C:OnConstruct()
end

function UMG_DistrictMapGuideTabIcon_Ani_C:OnDestruct()
end

function UMG_DistrictMapGuideTabIcon_Ani_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  local iconPath_1 = self.data.iconPath_1
  local iconPath_2 = self.data.iconPath_2
  self:PlayAnimation(self.Open)
  self.icon_1:SetPath(iconPath_1)
  self.icon_2:SetPath(iconPath_2)
  local titleStr = HandbookModuleEnum.DistrictDesc[self.data.type] or ""
  self.Title:SetText(titleStr)
end

function UMG_DistrictMapGuideTabIcon_Ani_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:PlayAnimation(self.change1)
    _G.NRCModuleManager:GetModule("HandbookModule"):DispatchEvent(HandbookModuleEvent.OnClickDistrictIconItemData, self.data.type)
  else
    self:StopAllAnimations()
    self:PlayAnimation(self.change2)
  end
end

function UMG_DistrictMapGuideTabIcon_Ani_C:OnAnimationFinished(anim)
  if anim == self.change1 then
    self:PlayAnimation(self.select_loop)
  elseif anim == self.Open then
  end
end

function UMG_DistrictMapGuideTabIcon_Ani_C:OnDeactive()
end

return UMG_DistrictMapGuideTabIcon_Ani_C
