local Super = require("NewRoco/Modules/System/Home/IndoorSandbox/HomeTask")
local LoadMapTask = Super:Extend("LoadMapTask")

function LoadMapTask:Ctor()
  Super.Ctor(self)
end

function LoadMapTask:CheckFinish()
  if not self.SceneModule then
    self.SceneModule = NRCModuleManager:GetModule("SceneModule")
  end
  if self.SceneModule then
    local MapId = self.SceneModule:GetCurrentMapId()
    if 301 == MapId then
      self:NotifyFinish()
    end
  end
end

function LoadMapTask:OnStart()
  self:CheckFinish()
end

function LoadMapTask:OnUpdate()
  self:CheckFinish()
end

return LoadMapTask
