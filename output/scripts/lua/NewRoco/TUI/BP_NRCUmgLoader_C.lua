local Delegate = require("Utils.Delegate")
local PriorityEnum = require("PriorityEnum")
local BP_NRCUmgLoader_C = _G.NRCClass:Extend("BP_NRCUmgLoader_C")

local function ActivePanel(umgPanel, ...)
  umgPanel.loaderPanelActive = true
  if umgPanel.OnActive then
    umgPanel:OnActive(...)
  end
end

local function DeactivePanel(umgPanel, ...)
  if not umgPanel.loaderPanelActive then
    return
  end
  umgPanel.loaderPanelActive = false
  if umgPanel.OnDeactive then
    umgPanel:OnDeactive(...)
  end
end

local function EnablePanel(umgPanel, ...)
  umgPanel.loaderPanelEnable = true
  if umgPanel.OnEnable then
    umgPanel:OnEnable(...)
  end
end

local function DisablePanel(umgPanel, ...)
  if not umgPanel.loaderPanelEnable then
    return
  end
  umgPanel.loaderPanelEnable = false
  if umgPanel.OnDisable then
    umgPanel:OnDisable(...)
  end
end

local function OnDestructOverridden(umgPanel)
  umgPanel.OnDestructBackup = umgPanel.OnDestruct
  
  function umgPanel.OnDestruct(panelInst)
    DisablePanel(panelInst)
    DeactivePanel(panelInst)
    if panelInst.OnDestructBackup then
      panelInst.OnDestructBackup(panelInst)
    end
  end
end

function BP_NRCUmgLoader_C:Ctor()
  self.isDestruct = false
  self.OnLoadPanelCallbackDelegate = Delegate()
  self.OnUnLoadPanelCallbackDelegate = Delegate()
end

function BP_NRCUmgLoader_C:OnPostConstruct()
  self.isDestruct = false
end

function BP_NRCUmgLoader_C:OnPostDestruct()
  self.isDestruct = true
end

function BP_NRCUmgLoader_C:SetPool(_pool)
  self.pool = _pool
end

function BP_NRCUmgLoader_C:SetPriority(value)
  self.priority = value
end

function BP_NRCUmgLoader_C:LoadPanel(parent, ...)
  self:LoadPanel_Internal(parent, true, ...)
end

function BP_NRCUmgLoader_C:LoadPanelSync(parent, ...)
  self:LoadPanel_Internal(parent, false, ...)
end

function BP_NRCUmgLoader_C:LoadPanel_Internal(parent, bAsync, ...)
  if self.isDestruct then
    return
  end
  self._loaderEnable = true
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local panelInst = self.Overridden.GetPanel(self)
  if panelInst then
    EnablePanel(panelInst, ...)
    self.OnLoadPanelCallbackDelegate:Invoke(true, panelInst)
  else
    self._loadArgs = {}
    self._loadArgs.parent = parent
    self._loadArgs.extraArg = table.pack(...)
    self.Overridden.LoadPanel(self, bAsync, self.priority or PriorityEnum.UI_WidgetLoader_Default)
  end
end

function BP_NRCUmgLoader_C:GetPanel()
  if self.isDestruct then
    return
  end
  if self and UE4.UObject.IsValid(self) then
    return self.Overridden.GetPanel(self)
  end
end

function BP_NRCUmgLoader_C:UnLoadPanel(_forceUnload, ...)
  if self.isDestruct then
    return
  end
  self._loaderEnable = false
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if _forceUnload then
    self._unLoadArgs = {}
    self._unLoadArgs.extraArg = table.pack(...)
    return self.Overridden.UnLoadPanel(self)
  else
    local panelInst = self.Overridden.GetPanel(self)
    if panelInst then
      DisablePanel(panelInst, ...)
      self.OnUnLoadPanelCallbackDelegate:Invoke(true)
      return true
    else
      self.OnUnLoadPanelCallbackDelegate:Invoke(false)
    end
  end
end

function BP_NRCUmgLoader_C:SetWidgetClass(softClassPath)
  if self.isDestruct then
    return
  end
  self:SetWidgetCls(softClassPath)
end

function BP_NRCUmgLoader_C:CreatePanel()
  if self.pool then
    return self.pool:Get()
  end
  return nil
end

function BP_NRCUmgLoader_C:OnLoadPanel(_umgPanel)
  if UE4.UObject.IsValid(_umgPanel) then
    local _parent = self._loadArgs and self._loadArgs.parent
    if UE4.UObject.IsValid(_parent) and _parent.DynamicAddChildView then
      _parent:DynamicAddChildView(_umgPanel)
    end
    local extraArgs = self._loadArgs and self._loadArgs.extraArg
    if extraArgs then
      ActivePanel(_umgPanel, table.unpack(extraArgs, 1, extraArgs.n))
      if self._loaderEnable then
        EnablePanel(_umgPanel, table.unpack(extraArgs, 1, extraArgs.n))
      end
    else
      ActivePanel(_umgPanel)
      if self._loaderEnable then
        EnablePanel(_umgPanel)
      end
    end
    self._loadArgs = nil
    self.OnLoadPanelCallbackDelegate:Invoke(true, _umgPanel)
  else
    self.OnLoadPanelCallbackDelegate:Invoke(false, "false to load panel")
  end
end

function BP_NRCUmgLoader_C:OnUnLoadPanel(_umgPanel)
  if UE4.UObject.IsValid(_umgPanel) then
    local extraArgs = self._unLoadArgs and self._unLoadArgs.extraArg
    if extraArgs then
      DisablePanel(_umgPanel, table.unpack(extraArgs, 1, extraArgs.n))
      DeactivePanel(_umgPanel, table.unpack(extraArgs, 1, extraArgs.n))
    else
      DisablePanel(_umgPanel)
      DeactivePanel(_umgPanel)
    end
    if self.pool then
      self.pool:Recycle(_umgPanel)
    end
    self._unLoadArgs = nil
    self.OnUnLoadPanelCallbackDelegate:Invoke(true)
  else
    self.OnUnLoadPanelCallbackDelegate:Invoke(false)
  end
end

return BP_NRCUmgLoader_C
