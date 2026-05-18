require("UnLuaEx")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local EUW_FsmItem_C = _G.Class()

function EUW_FsmItem_C:Ctor()
  Log.Trace("Show Fsm Item Construct")
end

function EUW_FsmItem_C:Construct()
  Log.Trace("Show Fsm Item Construct")
  self.RemoveButton.OnClicked:Add(self, self.OnRemoveClick)
end

function EUW_FsmItem_C:Destruct()
  self.RemoveButton.OnClicked:Remove(self, self.OnRemoveClick)
end

function EUW_FsmItem_C:OnRemoveClick()
  self.fsm:Stop()
end

function EUW_FsmItem_C:Tick(MyGeometry, InDeltaTime)
  if not self.fsm then
    return
  end
  self.FsmName:SetColorAndOpacity(FsmUtils.GetColor(self.fsm))
end

function EUW_FsmItem_C:SetData(ItemData)
  Log.Debug("Setting Up Fsm Item")
  self.fsm = ItemData.data
  self.Parent = ItemData.Parent
  if self.fsm then
    self.FsmName:SetText(self.fsm:GetName())
  end
  self.SelectIndicator:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function EUW_FsmItem_C:OnItemSelected(selected)
  self.SelectIndicator:SetVisibility(selected and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.Collapsed)
end

return EUW_FsmItem_C
