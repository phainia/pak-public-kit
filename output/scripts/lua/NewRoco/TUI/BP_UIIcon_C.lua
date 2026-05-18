local BP_UIIcon_C = NRCUmgClass:Extend("BP_UIIcon_C")
local PriorityEnum = require("PriorityEnum")

function BP_UIIcon_C:Construct()
  if self.SetOpacity then
    self:SetOpacity(0)
  end
end

function BP_UIIcon_C:SetPath(assetPath, priorityEnum, callback, caller)
  if not assetPath then
    if _G.RocoEnv.IS_EDITOR then
      Log.Warning("assetpath is nil:", assetPath)
    else
      Log.Debug("assetpath is nil:", assetPath)
    end
    return
  end
  if callback then
    self._onLoadedCallback = callback
  end
  if caller then
    self._onLoadedCaller = caller
  end
  self.Overridden.SetPath(self, assetPath, priorityEnum or PriorityEnum.UI_UIICon_Default)
end

function BP_UIIcon_C:OnIconLoaded(assetPath, object)
  if self.SetOpacity then
    self:SetOpacity(1)
  end
  if self._onLoadedCallback then
    if self._onLoadedCaller then
      self._onLoadedCallback(self._onLoadedCaller, assetPath, object)
    else
      self._onLoadedCallback(assetPath, object)
    end
    self._onLoadedCallback = nil
    self._onLoadedCaller = nil
  end
end

function BP_UIIcon_C:OnIconLoadFailed(assetPath, errMsg)
  Log.WarningFormat("Icon Load Error %s", assetPath)
  self:SetOpacity(0)
end

function BP_UIIcon_C:CancelLoad()
  self.Overridden.CancelLoad(self)
end

function BP_UIIcon_C:SetOpacity(alpha)
  self:SetRenderOpacity(alpha)
end

function BP_UIIcon_C:SetIconByBagItemID(bagItemID)
  local bagItemConf = _G.DataConfigManager:GetBagItemConf(bagItemID)
  if bagItemConf then
    self:SetPath(bagItemConf.icon)
  end
end

return BP_UIIcon_C
