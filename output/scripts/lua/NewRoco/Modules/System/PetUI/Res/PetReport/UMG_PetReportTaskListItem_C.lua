local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetReportTaskListItem_C = Base:Extend("UMG_PetReportTaskListItem_C")

function UMG_PetReportTaskListItem_C:OnConstruct()
  self.CanvasPanel_0:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_PetReportTaskListItem_C:OnDestruct()
end

function UMG_PetReportTaskListItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:InitUI()
end

function UMG_PetReportTaskListItem_C:InitUI()
  if self.data and self.data.enum_name and self.data.param_name and self.data.ratio then
    self.TitleText:SetText(self.data.enum_name)
    self.DetailsText:SetText(self.data.param_name)
    local showTip = _G.DataConfigManager:GetLocalizationConf("report_ratio")
    if showTip and showTip.msg then
      if _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.IsInteger, self.data.ratio) then
        self.MultiplyingPowerText:SetText(string.format(showTip.msg, tostring(math.floor(self.data.ratio))))
      else
        self.MultiplyingPowerText:SetText(string.format(showTip.msg, string.format("%.1f", self.data.ratio)))
      end
    end
  end
end

function UMG_PetReportTaskListItem_C:OnDeactive()
end

return UMG_PetReportTaskListItem_C
