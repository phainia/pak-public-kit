local UILayerEvent = require("Core.NRCPanelLayer.UILayerEvent")
local StatusCheckerBase = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerBase")
local Base = StatusCheckerBase
local FullScreenStatusChecker = Base:Extend("FullScreenStatusChecker")

function FullScreenStatusChecker:Ctor()
  Base.Ctor(self)
end

function FullScreenStatusChecker:CheckPass()
  if 0 == _G.NRCPanelManager:GetLayerWindowCount(_G.Enum.UILayerType.UI_LAYER_FULLSCREEN) then
    return true
  else
    self:Log("\229\189\147\229\137\141\230\156\137FullScreen\231\149\140\233\157\162")
    return false
  end
end

function FullScreenStatusChecker:GetLayerCtrl()
  return _G.NRCPanelManager.layerCenter
end

function FullScreenStatusChecker:StartCheck()
  local Center = self:GetLayerCtrl()
  if not Center:HasListener(self, UILayerEvent.FULLSCREEN_LAYER_CLOSEWINDOW, self.OnFullScreenEnded) then
    Center:AddEventListener(self, UILayerEvent.FULLSCREEN_LAYER_CLOSEWINDOW, self.OnFullScreenEnded)
  end
end

function FullScreenStatusChecker:OnFullScreenEnded()
  if self:CheckPass() then
    self:FireCallback()
  end
end

function FullScreenStatusChecker:EndCheck()
  local Center = self:GetLayerCtrl()
  if Center:HasListener(self, UILayerEvent.FULLSCREEN_LAYER_CLOSEWINDOW, self.OnFullScreenEnded) then
    Center:RemoveEventListener(self, UILayerEvent.FULLSCREEN_LAYER_CLOSEWINDOW, self.OnFullScreenEnded)
  end
end

return FullScreenStatusChecker
