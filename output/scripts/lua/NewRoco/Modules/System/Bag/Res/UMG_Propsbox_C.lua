local BagModuleEvent = reload("NewRoco.Modules.System.Bag.BagModuleEvent")
local UMG_Propsbox_C = _G.NRCPanelBase:Extend("UMG_Propsbox_C")

function UMG_Propsbox_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_Propsbox_C:OnDestruct()
  self:OnRemoveEventListener()
end

function UMG_Propsbox_C:OnActive()
end

function UMG_Propsbox_C:OnDeactive()
end

function UMG_Propsbox_C:OnAddEventListener()
  self.Tab1:BindLuaCallBack({
    self,
    self.OnToggleGroupChanged
  }, {
    self,
    self.OnCheckBoxCondition
  })
  self.Tab2:BindLuaCallBack({
    self,
    self.OnToggleGroupChanged
  }, {
    self,
    self.OnCheckBoxCondition
  })
  self.Tab3:BindLuaCallBack({
    self,
    self.OnToggleGroupChanged
  }, {
    self,
    self.OnCheckBoxCondition
  })
  self.Tab4:BindLuaCallBack({
    self,
    self.OnToggleGroupChanged
  }, {
    self,
    self.OnCheckBoxCondition
  })
end

function UMG_Propsbox_C:OnRemoveEventListener()
end

function UMG_Propsbox_C:OnToggleGroupChanged(GroupId, CheckBoxName)
  if CheckBoxName == tostring(_G.Enum.BagItemType.BI_ITEM) then
    Log.Debug("UMG_Propsbox_C:OnToggleGroupChanged0")
    NRCModuleManager:GetModule("BagModule"):DispatchEvent(BagModuleEvent.ChooseBagItemType, _G.Enum.BagItemType.BI_ITEM)
  elseif CheckBoxName == tostring(_G.Enum.BagItemType.BI_PET_BALL) then
    Log.Debug("UMG_Propsbox_C:OnToggleGroupChanged1")
    NRCModuleManager:GetModule("BagModule"):DispatchEvent(BagModuleEvent.ChooseBagItemType, _G.Enum.BagItemType.BI_PET_BALL)
  elseif CheckBoxName == tostring(_G.Enum.BagItemType.BI_MATERIAL) then
    Log.Debug("UMG_Propsbox_C:OnToggleGroupChanged2")
    NRCModuleManager:GetModule("BagModule"):DispatchEvent(BagModuleEvent.ChooseBagItemType, _G.Enum.BagItemType.BI_MATERIAL)
  elseif CheckBoxName == tostring(_G.Enum.BagItemType.BI_PRECIOUS) then
    Log.Debug("UMG_Propsbox_C:OnToggleGroupChanged3")
    NRCModuleManager:GetModule("BagModule"):DispatchEvent(BagModuleEvent.ChooseBagItemType, _G.Enum.BagItemType.BI_PRECIOUS)
  end
end

function UMG_Propsbox_C:OnCheckBoxCondition(GroupId, CheckBoxName, IsClickable)
end

return UMG_Propsbox_C
