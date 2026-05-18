local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PVE_Talent_Item_C = Base:Extend("UMG_PVE_Talent_Item_C")
local PVEModuleEnum = require("NewRoco.Modules.System.PVE.PVEModuleEnum")

function UMG_PVE_Talent_Item_C:OnConstruct()
  self:AddButtonListener(self.ClickButton, self.OnClickSelect)
end

function UMG_PVE_Talent_Item_C:OnDestruct()
  self:RemoveButtonListener(self.ClickButton)
end

function UMG_PVE_Talent_Item_C:OnActive(itemConf, callback)
  local nodeData = _G.NRCModeManager:DoCmd(_G.PVEModuleCmd.GetTalentNodeDataById, itemConf.id)
  self.itemData = nodeData
  self:InitItem(itemConf)
  self:RefreshLockStatus(nodeData)
  if callback then
    callback(itemConf, nodeData and nodeData.status or PVEModuleEnum.TalentNodeStatus.Locked)
  end
end

function UMG_PVE_Talent_Item_C:OnClickSelect()
  _G.NRCModuleManager:DoCmd(_G.PVEModuleCmd.OpenPveParticulars, self.itemData)
end

function UMG_PVE_Talent_Item_C:InitItem(itemConf)
  if not string.IsNilOrEmpty(itemConf.frame) then
    self.Contaminate:SetPath(itemConf.frame)
  end
  if not string.IsNilOrEmpty(itemConf.icon) then
    self.IconImage:SetPath(itemConf.icon)
  end
end

function UMG_PVE_Talent_Item_C:RefreshLockStatus(nodeData)
end

return UMG_PVE_Talent_Item_C
