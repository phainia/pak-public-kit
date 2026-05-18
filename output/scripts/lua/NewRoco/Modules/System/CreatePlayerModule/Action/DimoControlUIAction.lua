local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local CreatePlayerEvent = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerEvent")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = NRCModeAction
local DimoControlUIAction = Base:Extend("DimoControlUIAction")
FsmUtils.MergeMembers(Base, DimoControlUIAction, {
  {
    name = "ParentModule",
    type = "var"
  },
  {name = "bOpen", type = "var"}
})

function DimoControlUIAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function DimoControlUIAction:OnEnter()
  self:InjectProperties()
  if self.ParentModule then
    if self.bOpen then
      if self.ParentModule:HasPanel("PlayerMain") then
        self:Finish()
      else
        self.ParentModule:RegisterEvent(self, CreatePlayerEvent.DimoControlUIOpen, self.OnDimoControlUIOpen)
        local tutorialData = NRCModuleManager:DoCmd(CreatePlayerModuleCmd.GetTutorialData)
        self.ParentModule:OpenPanel("PlayerMain", tutorialData)
      end
    else
      self.ParentModule:ClosePanel("PlayerMain")
      self:Finish()
    end
  else
    self:Finish()
  end
end

function DimoControlUIAction:OnDimoControlUIOpen()
  self:Finish()
end

return DimoControlUIAction
