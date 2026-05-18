local NPCActionModelBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionModelBase
local NPCActionRemoveCampingLockJiDian = Base:Extend("NPCActionRemoveCampingLockJiDian")

function NPCActionRemoveCampingLockJiDian:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionRemoveCampingLockJiDian:ExecuteWithModel()
  self:Finish(true)
end

return NPCActionRemoveCampingLockJiDian
