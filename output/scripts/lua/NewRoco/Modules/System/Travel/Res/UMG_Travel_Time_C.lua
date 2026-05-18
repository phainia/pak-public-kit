local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local TravelModuleEvent = reload("NewRoco.Modules.System.Travel.TravelModuleEvent")
local UMG_Travel_Time_C = Base:Extend("UMG_Travel_Time_C")

function UMG_Travel_Time_C:OnConstruct()
end

function UMG_Travel_Time_C:OnDestruct()
end

function UMG_Travel_Time_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self:PlayAnimationReverse(self.Press)
  self.Text_Time:SetText(self.data.timeStr)
  self.Text_Time:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_Travel_Time_C:OnClickeBtn()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1072, "UMG_Travel_Time_C:OnClickeBtn")
  _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.SelectTimeTab, self.index, self.data)
end

function UMG_Travel_Time_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:OnClickeBtn()
  end
end

function UMG_Travel_Time_C:PlaySelect()
  self.isSelect = true
  self:PlayAnimation(self.Press)
end

function UMG_Travel_Time_C:PlayUnSelect()
  if self.isSelect then
    self:PlayAnimationReverse(self.Press)
  end
  self.isSelect = false
end

function UMG_Travel_Time_C:OnDeactive()
end

return UMG_Travel_Time_C
