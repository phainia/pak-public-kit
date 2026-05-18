local Base = require("NewRoco.Modules.System.Activity.ActivityObject.CoCreationPreviewActivityObject")
local CoCreationStartActivityObject = Base:Extend("CoCreationStartActivityObject")

function CoCreationStartActivityObject:OnConstruct(_conf)
  self.bStart = true
  Base.OnConstruct(self, _conf)
end

return CoCreationStartActivityObject
