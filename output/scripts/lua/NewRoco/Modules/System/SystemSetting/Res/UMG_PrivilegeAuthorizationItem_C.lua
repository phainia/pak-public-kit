local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PrivilegeAuthorizationItem_C = Base:Extend("UMG_PrivilegeAuthorizationItem_C")

function UMG_PrivilegeAuthorizationItem_C:OnConstruct()
  self:AddButtonListener(self.BtnGoSet.btnLevelUp, self.OnBtnGoSetClick)
end

function UMG_PrivilegeAuthorizationItem_C:OnItemUpdate(data, dataList, index)
  self.index = index
  self:SetData(data)
end

function UMG_PrivilegeAuthorizationItem_C:SetData(data)
  if not data then
    return
  end
  self.PrivilegeName:SetText(data.PrivilegeName or "")
  self.PrivilegeDesc:SetText(data.PrivilegeDesc or "")
  self.data = data
end

function UMG_PrivilegeAuthorizationItem_C:OnItemSelected(_bSelect)
end

function UMG_PrivilegeAuthorizationItem_C:Destruct()
  self:ReleaseForce()
end

function UMG_PrivilegeAuthorizationItem_C:OnBtnGoSetClick()
  Log.Info("UMG_PrivilegeAuthorizationItem_C:OnBtnGoSetClick ", self.data.PrivilegeName, self.data.PrivilegeDesc, self.data.PrivilegeType)
  if self.data.OnBtnGoSetClickCallback then
    if self.data.OnBtnGoSetClickCallbackOwner then
      self.data.OnBtnGoSetClickCallback(self.data.OnBtnGoSetClickCallbackOwner, self.data.PrivilegeType)
    else
      self.data.OnBtnGoSetClickCallback(self.data.PrivilegeType)
    end
  end
end

return UMG_PrivilegeAuthorizationItem_C
