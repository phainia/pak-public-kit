local Fsm = require("NewRoco.Modules.Core.Fsm.Fsm")
local FsmState = require("NewRoco.Modules.Core.Fsm.FsmState")
local FsmEnum = require("NewRoco.Modules.Core.Fsm.FsmEnum")
local NRCModeBase = NRCClass:Extend("NRCModeBase")

function NRCModeBase:Ctor()
  Log.Debug("NRCModeBase ctor")
  NRCClass.Ctor(self)
  self.modeName = nil
  self.fsmDict = {}
  self.actionToFsm = {}
  self.moduleDataDict = {}
  self.moduleDict = {}
  self.fsmDataDict = {}
end

function NRCModeBase:Free()
  self:Destruct()
end

function NRCModeBase:Construct()
  Log.Debug("NRCModeBase Construct")
  self:OnConstruct()
end

function NRCModeBase:Destruct()
  self:OnDestruct()
end

function NRCModeBase:Active()
  Log.Debug("NRCModeBase Active:", self.modeName)
  self:OnActive()
end

function NRCModeBase:Deactive()
  self:OnDeactive()
  for moduleName, _ in pairs(self.moduleDict) do
    Log.Debug("NRCModeBase DeactiveModule:", moduleName)
    self:DeactiveModule(moduleName)
  end
  for fsmName, fsm in pairs(self.fsmDict) do
    fsm:Stop()
  end
end

function NRCModeBase:RegisterModule(moduleName, moduleType, moduleHeadPath, modulePath)
  if not self:IsModuleRegistered(moduleName) then
    self.moduleDict[moduleName] = moduleName
    local moduleData = {}
    moduleData.moduleName = moduleName
    moduleData.moduleType = moduleType
    moduleData.modulePath = modulePath
    moduleData.moduleHeadPath = moduleHeadPath
    self.moduleDataDict[moduleName] = moduleData
    NRCModuleManager:RegisterModule(moduleName, moduleType, moduleHeadPath, modulePath)
  end
end

function NRCModeBase:UnRegisterModule(moduleName)
  NRCModuleManager:UnRegisterModule(moduleName)
  self.moduleDict[moduleName] = nil
end

function NRCModeBase:IsModuleRegistered(moduleName)
  return self.moduleDataDict[moduleName]
end

function NRCModeBase:ActiveModule(moduleName)
  NRCModuleManager:ActiveModule(moduleName)
end

function NRCModeBase:DeactiveModule(moduleName)
  NRCModuleManager:DeactiveModule(moduleName)
end

function NRCModeBase:GetModule(moduleName)
  return NRCModuleManager:GetModule(moduleName)
end

function NRCModeBase:GetActivedModules(silent)
  if nil == silent then
    silent = true
  end
  local lst = {}
  for moduleName, _ in pairs(self.moduleDict) do
    local m = self:GetModule(moduleName)
    if m and m.isActive then
      table.insert(lst, m)
    elseif not silent then
      Log.Warning("Module\228\184\186\231\169\186", moduleName)
    end
  end
  return lst
end

function NRCModeBase:BroadcastActiveModeEvent()
  local moduleLst = self:GetActivedModules()
  for i = 1, #moduleLst do
    moduleLst[i]:OnReceiveActiveMode(self.modeName)
  end
end

function NRCModeBase:CloseAllPanel()
  for moduleName, _ in pairs(self.moduleDict) do
    local m = self:GetModule(moduleName)
    if m then
      m:CloseAllPanel()
    else
      Log.Warning("Module\228\184\186\231\169\186", moduleName)
    end
  end
end

function NRCModeBase:DisablePanelByLayer(panelLayer)
  for moduleName, _ in pairs(self.moduleDict) do
    local instance = self:GetModule(moduleName)
    if instance then
      instance:DisablePanelByLayer(panelLayer)
    end
  end
end

function NRCModeBase:GMDisablePanelByLayerExcept(panelLayer, ExceptUINameTable)
  for moduleName, _ in pairs(self.moduleDict) do
    local instance = self:GetModule(moduleName)
    if instance then
      instance:DisablePanelByLayer(panelLayer, ExceptUINameTable)
    end
  end
end

function NRCModeBase:RevertPanelEnableStateByLayer(panelLayer)
  for moduleName, _ in pairs(self.moduleDict) do
    local instance = self:GetModule(moduleName)
    if instance then
      instance:RevertPanelEnableStateByLayer(panelLayer)
    end
  end
end

function NRCModeBase:ClosePanelByLayer(panelLayer)
  for moduleName, _ in pairs(self.moduleDict) do
    local instance = self:GetModule(moduleName)
    if instance then
      instance:ClosePanelByLayer(panelLayer)
    end
  end
end

function NRCModeBase:CreateAction(groupName, actionName, actionPath, ...)
  self:Log("CreateAction:", groupName, actionPath)
  self.actionToFsm[actionName] = groupName
  if self.fsmDict[groupName] then
    self:Log("CreateAction:", groupName, actionPath)
    local ActionCla = require(actionPath)
    local fsmState = self.fsmDataDict[groupName].state
    fsmState:AddAction(ActionCla(actionName))
  else
    self:Log("CreateAction new fsm:", groupName, actionPath)
    local ActionCla = require(actionPath)
    local tempfsm = Fsm(groupName)
    local fsmState = FsmState("Init")
    fsmState:AddAction(ActionCla(actionName))
    tempfsm:SetInitState(fsmState)
    tempfsm:AddState(fsmState)
    self.fsmDict[groupName] = tempfsm
    self.fsmDataDict[groupName] = {fsm = tempfsm, state = fsmState}
    tempfsm:RegisterEvent(FsmEnum.Events.Stop, self, self.OnActionsFinish)
  end
end

function NRCModeBase:StartGroup(groupName)
  if self.fsmDict[groupName] then
    self:Log("EnterAction:", groupName)
    self.fsmDict[groupName]:Play()
  else
    Log.Error("\232\175\183\229\133\136\229\136\155\229\187\186FSM:", groupName)
  end
end

function NRCModeBase:OnActionsFinish(fsm)
  self:Log("OnActionsFinish:", fsm.name)
  if self.OnGroupFinish then
    self:OnGroupFinish(fsm.name)
  end
  local isAllDone = true
  for k, fsm in pairs(self.fsmDict) do
    if not fsm.finished then
      isAllDone = false
      return
    end
  end
  self:OnAllGroupFinished()
end

function NRCModeBase:OnAllGroupFinished()
end

function NRCModeBase:OnConstruct()
end

function NRCModeBase:OnDestruct()
end

function NRCModeBase:OnActive()
end

function NRCModeBase:OnDeactive()
end

function NRCModeBase:Log(...)
  Log.Debug(string.format("[%s]", self.modeName), ...)
end

function NRCModeBase:LogError(...)
  Log.Error(string.format("[%s]", self.modeName), ...)
end

return NRCModeBase
