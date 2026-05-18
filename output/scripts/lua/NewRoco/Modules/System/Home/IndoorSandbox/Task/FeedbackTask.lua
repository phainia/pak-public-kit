local Super = require("NewRoco/Modules/System/Home/IndoorSandbox/HomeTask")
local FeedbackTask = Super:Extend("FeedbackTask")

function FeedbackTask:Ctor(Callback)
  Super.Ctor(self)
  HomeIndoorSandbox:Ensure(Callback, "invalid callback delegate")
  self.Callback = Callback
end

function FeedbackTask:OnStart()
  self:NotifyFinish()
  if self.Callback then
    self.Callback()
  end
end

return FeedbackTask
