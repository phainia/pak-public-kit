local NPCActionModelBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionModelBase
local NPCActionOpenActivity = Base:Extend("NPCActionOpenActivity")

function NPCActionOpenActivity:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionOpenActivity:ExecuteWithModel()
  if self.Config.action_param1 == Enum.ActivityType.ATP_TREASURE_HUNT then
    _G.NRCModuleManager:DoCmd(ActivityModuleCmd.OpenMainPanel, Enum.ActivityType.ATP_TREASURE_HUNT)
    self:EndAction()
  end
end

function NPCActionOpenActivity:EndAction()
  self:Finish(true)
end

return NPCActionOpenActivity
