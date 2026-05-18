local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Battle_Fsm_Action_C = Base:Extend("UMG_Battle_Fsm_Action_C")

function UMG_Battle_Fsm_Action_C:OnActive()
end

function UMG_Battle_Fsm_Action_C:OnDeactive()
end

function UMG_Battle_Fsm_Action_C:OnItemUpdate(_data, datalist, index)
  self.action = _data
  self.Size = UE4.FVector2D(0, 0)
  self:SetPanelInfo()
end

function UMG_Battle_Fsm_Action_C:Tick(MyGeometry, InDeltaTime)
  if not self.action then
    return
  end
  self:SetTextColor()
end

function UMG_Battle_Fsm_Action_C:SetTextColor()
  self.FsmText:SetColorAndOpacity(FsmUtils.GetColor(self.action))
end

function UMG_Battle_Fsm_Action_C:SetBtnColor(Color)
  self.NRCButton_38:SetColorAndOpacity(Color)
end

function UMG_Battle_Fsm_Action_C:SetData(FsmData)
  self.action = FsmData
  self:SetPanelInfo()
end

function UMG_Battle_Fsm_Action_C:SetPanelInfo()
  local action = self.action
  if action then
    self.FsmText:SetText(action:GetName())
  end
end

return UMG_Battle_Fsm_Action_C
