local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Activity_CollegeCamp_Item1_C = Base:Extend("UMG_Activity_CollegeCamp_Item1_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")

function UMG_Activity_CollegeCamp_Item1_C:OnConstruct()
  self:AddButtonListener(self.Btn, self.OnClickBtn)
end

function UMG_Activity_CollegeCamp_Item1_C:OnDestruct()
  self:RemoveButtonListener(self.Btn)
end

function UMG_Activity_CollegeCamp_Item1_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  local icon, quality = ActivityUtils.GetItemIconAndQuality(_data.itemType, _data.itemId)
  self.Icon:SetPath(icon)
  self.Num:SetText("x" .. _data.itemNum)
  ActivityUtils.SetRewardItemQuality(self.Quality, quality)
end

function UMG_Activity_CollegeCamp_Item1_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:OnClickBtn()
  end
end

function UMG_Activity_CollegeCamp_Item1_C:OnClickBtn()
  local data = self.data
  if data then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, data.itemId, data.itemType)
  end
end

return UMG_Activity_CollegeCamp_Item1_C
