local NPCActionModelBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionModelBase
local NPCActionOpenCampingLevel = Base:Extend("NPCActionOpenCampingLevel")

function NPCActionOpenCampingLevel:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionOpenCampingLevel:ExecuteWithModel()
  Log.Error("NPCActionOpenCampingLevel \232\162\171\229\186\159\229\188\131\228\186\134\239\188\129\239\188\129\239\188\129")
  self:Finish()
end

return NPCActionOpenCampingLevel
