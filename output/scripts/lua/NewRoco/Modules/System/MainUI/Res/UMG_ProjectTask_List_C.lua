local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ProjectTask_List_C = Base:Extend("UMG_ProjectTask_List_C")

function UMG_ProjectTask_List_C:OnConstruct()
end

function UMG_ProjectTask_List_C:OnDestruct()
end

function UMG_ProjectTask_List_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.Text_Describe:SetText(_data.desc)
  local topic = _data.topic
  self.Text_Quantity:SetText(tostring(math.max(topic.finish_cnt - 1, 0)))
  self.Text_Quantity:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#c3c1b4ff"))
  self.Text_Quantity_2:SetText(string.format("/%s", topic.max_cnt))
  self.StarList:Setvisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_ProjectTask_List_C:OnItemSelected(_bSelected)
end

function UMG_ProjectTask_List_C:RefreshTaskFinishCntWithAnimation()
  if not self.data then
    return
  end
  local topic = self.data.topic
  if not topic.finish_cnt then
    return
  end
  self.Text_Quantity:SetText(tostring(topic.finish_cnt))
  if topic.finish_cnt >= topic.max_cnt then
    self.Text_Quantity:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#ffc65fff"))
    self.Completed:Setvisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Text_Quantity:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#c3c1b4ff"))
    self.Completed:Setvisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:StopAllAnimations()
  self:PlayAnimation(self.Word_change)
end

return UMG_ProjectTask_List_C
