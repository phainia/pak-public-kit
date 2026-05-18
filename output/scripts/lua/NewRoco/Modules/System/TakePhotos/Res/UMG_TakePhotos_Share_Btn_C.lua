local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_TakePhotos_Share_Btn_C = Base:Extend("UMG_TakePhotos_Share_Btn_C")

function UMG_TakePhotos_Share_Btn_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_TakePhotos_Share_Btn_C:OnDestruct()
  self:RemoveButtonListener(self.Btn, self.OnShareWayClick)
end

function UMG_TakePhotos_Share_Btn_C:OnAddEventListener()
  self:AddButtonListener(self.Btn, self.OnShareWayClick)
end

function UMG_TakePhotos_Share_Btn_C:OnItemUpdate(_data, datalist, index)
  self.Name = _data.name
  self.ShareIcon = _data.share_icon
  self.Index = index
  self.Icon:SetPath(self.ShareIcon)
  self:PlayAnimation(self.In, 0)
  self:PauseAnimation(self.In)
end

function UMG_TakePhotos_Share_Btn_C:OnShareWayClick()
  _G.NRCAudioManager:PlaySound2DAuto(40002003, "UMG_TakePhotos_Share_Btn_C:OnShareWayClick")
  local Module = NRCModuleManager:GetModule("TakePhotosModule")
  if Module then
    Module:SharePhoto(self.Name)
  end
end

function UMG_TakePhotos_Share_Btn_C:PlayInAnim()
  self:PlayAnimation(self.In)
end

return UMG_TakePhotos_Share_Btn_C
