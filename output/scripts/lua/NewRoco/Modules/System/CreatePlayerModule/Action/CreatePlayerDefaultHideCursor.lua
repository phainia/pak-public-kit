local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = NRCModeAction
local CreatePlayerDefaultHideCursor = Base:Extend("CreatePlayerDefaultHideCursor")
FsmUtils.MergeMembers(Base, CreatePlayerDefaultHideCursor, {
  {
    name = "bDesireHide",
    type = "var"
  }
})

function CreatePlayerDefaultHideCursor:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.properties = properties
end

function CreatePlayerDefaultHideCursor:OnEnter()
  self:InjectProperties()
  if self.bDesireHide then
    UE4Helper.SetDesiredShowCursor(false, "CreatePlayerDefaultHideCursor")
  else
    UE4Helper.ReleaseDesiredShowCursor("CreatePlayerDefaultHideCursor")
  end
  self:Finish()
end

return CreatePlayerDefaultHideCursor
