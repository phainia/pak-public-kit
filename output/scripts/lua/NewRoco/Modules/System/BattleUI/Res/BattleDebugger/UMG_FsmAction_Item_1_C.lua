local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_FsmAction_Item_1_C = Base:Extend("UMG_FsmAction_Item_1_C")

function UMG_FsmAction_Item_1_C:OnConstruct()
end

function UMG_FsmAction_Item_1_C:OnDestruct()
end

function UMG_FsmAction_Item_1_C:OnItemUpdate(_data, datalist, index)
  self.FsmName:SetText(_data:GetName())
  self.FsmName:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#FFFFFFFF"))
  if _data:GetName() == "BattleInitAction" then
  end
  Log.Debug(_data.finishTime, _data.enterTime, _data:GetName(), "UMG_FsmAction_Item_1_C:OnItemUpdate")
  if _data.finishTime and _data.enterTime then
    self.FinishTime:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local Text = string.format("%sms", _data.finishTime - _data.enterTime)
    self.FinishTime:SetText(Text)
  else
    self.FinishTime:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_FsmAction_Item_1_C:OnItemSelected(_bSelected)
end

function UMG_FsmAction_Item_1_C:OnDeactive()
end

return UMG_FsmAction_Item_1_C
