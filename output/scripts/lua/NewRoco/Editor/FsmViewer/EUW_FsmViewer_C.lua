require("UnLuaEx")
local FsmEnum = require("NewRoco.Modules.Core.Fsm.FsmEnum")
local EUW_FsmViewer_C = NRCClass()
local Dummy = {}

function EUW_FsmViewer_C:Construct()
  Log.Debug("EUW_FsmViewer_C:Construct")
  self:PrepFsmManager()
  if not self.FsmList then
    Log.Debug("FsmList is missing")
    return
  end
  self:UpdateList()
end

function EUW_FsmViewer_C:PrepFsmManager()
  if self.FsmManager then
    return
  end
  Log.Trace("EUW_FsmViewer_C:PrepFsmManager")
  self.FsmList.BP_OnItemClicked:Add(self, self.OnFsmSelected)
  self.StateList.BP_OnItemClicked:Add(self, self.OnStateSelected)
  self.ActionList.BP_OnItemClicked:Add(self, self.OnActionSelected)
  self.FsmManager = _G.FsmManager
  self.FsmManager:AddEventListener(self, FsmEnum.ManagerEvents.Changed, self.UpdateList)
  self.FsmList.BP_OnItemClicked:Add(self, self.OnFsmSelected)
  self.StateList.BP_OnItemClicked:Add(self, self.OnStateSelected)
  self.ActionList.BP_OnItemClicked:Add(self, self.OnActionSelected)
end

function EUW_FsmViewer_C:CleanFsmManager()
  if self.FsmManager then
    Log.Trace("EUW_FsmViewer_C:CleanFsmManager")
    self.FsmManager:RemoveEventListener(self, FsmEnum.ManagerEvents.Changed, self.UpdateList)
    self.FsmManager = nil
    self.FsmList.BP_OnItemClicked:Remove(self, self.OnFsmSelected)
    self.StateList.BP_OnItemClicked:Remove(self, self.OnStateSelected)
    self.ActionList.BP_OnItemClicked:Remove(self, self.OnActionSelected)
  end
end

function EUW_FsmViewer_C:Destruct()
  Log.Debug("EUW_FsmViewer_C:Construct")
  self:CleanFsmManager()
end

function EUW_FsmViewer_C:UpdateList(fsm)
  if not self.FsmList then
    return
  end
  self.FsmList:SetDatas(self.FsmManager.runningFsms)
end

function EUW_FsmViewer_C:OnFsmSelected(item)
  local fsm = item.data
  Log.Debug("EUW_FsmViewer_C:OnFsmSelected")
  if self.selectedFsm ~= fsm then
    self.selectedFsm = fsm
    self.StateList:SetDatas(self.selectedFsm.states)
    self.StateList:SetSelectedIndex(0)
  end
end

function EUW_FsmViewer_C:OnStateSelected(item)
  local state = item.data
  if self.selectedState ~= state then
    self.selectedState = state
    self.ActionList:SetDatas(self.selectedState.actions)
    self.ActionList:SetSelectedIndex(0)
  end
end

function EUW_FsmViewer_C:OnActionSelected(item)
  local action = item.data
  self.selectedAction = action
  self:SetEditableProperties(self.selectedAction)
end

function EUW_FsmViewer_C:SetEditableProperties(action)
  local defines = action.class.__members__
  if defines then
    local PropertyArray = {}
    for _, m in ipairs(defines) do
      local item = {}
      item.properties = action.properties
      item.define = m
      table.insert(PropertyArray, item)
    end
    self.PropertyList:SetDatas(PropertyArray)
  else
    self.PropertyList:SetDatas(Dummy)
  end
end

function EUW_FsmViewer_C:OnLuaContextInitialized()
  Log.Debug("Lua Context Created")
  self:PrepFsmManager()
end

function EUW_FsmViewer_C:OnLuaContextCleanup(Full)
  Log.DebugFormat("Lua Context Cleanup %s", Full and "Full" or "Not Full")
end

function EUW_FsmViewer_C:OnPrePIEEnded(IsSimulating)
  Log.Debug("EUW_FsmViewer_C:OnPrePIEEnded")
  self:CleanFsmManager()
  self.FsmList:ClearListItems()
  self.StateList:ClearListItems()
  self.ActionList:ClearListItems()
  self.PropertyList:ClearListItems()
end

function EUW_FsmViewer_C:OnPostPIEStarted(IsSimulating)
  Log.Debug("EUW_FsmViewer_C:OnPostPIEStarted")
  self.FsmList:ClearListItems()
  self.StateList:ClearListItems()
  self.ActionList:ClearListItems()
  self.PropertyList:ClearListItems()
  self.FsmList:BP_ClearSelection()
  self:PrepFsmManager()
  self:UpdateList()
end

function EUW_FsmViewer_C:OnLuaStateCreated()
  Log.Debug("EUW_FsmViewer_C:OnLuaStateCreated")
end

return EUW_FsmViewer_C
