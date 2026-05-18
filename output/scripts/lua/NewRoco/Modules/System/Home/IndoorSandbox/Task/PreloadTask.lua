local Super = require("NewRoco/Modules/System/Home/IndoorSandbox/HomeTask")
local PreloadTask = Super:Extend("PreloadTask")

function PreloadTask:Ctor(ResourcePath)
  Super.Ctor(self)
  self.bAsync = true
  self.Request = HomeIndoorSandbox.ResMgr:ReqResource(FPartial(self.NotifyFinish, self), ResourcePath)
end

function PreloadTask:OnClean()
end

return PreloadTask
