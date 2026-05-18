local NPCActionModelBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionModelBase
local NPCActionOpenWardRobe = Base:Extend("NPCActionPetSubmit")

function NPCActionOpenWardRobe:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionOpenWardRobe:ExecuteWithModel()
  Log.Error("NPCActionOpenWardRobe\229\183\178\231\187\143\232\162\171\229\186\159\229\188\131\228\186\134\239\188\129\239\188\129\239\188\129\239\188\129")
  self:Finish()
end

return NPCActionOpenWardRobe
