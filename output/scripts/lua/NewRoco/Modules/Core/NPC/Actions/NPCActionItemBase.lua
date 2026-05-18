local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionItemBase = Base:Extend("NPCActionItemBase")

function NPCActionItemBase:Ctor(Owner, Config, Info, OwnerNpc)
  Base.Ctor(self, Owner, Config, Info, OwnerNpc)
end

function NPCActionItemBase:Execute(playerId, needSendReq)
  Base.Execute(self, playerId, needSendReq)
  if self.Owner then
    self:SetViewObjOption()
  end
end

return NPCActionItemBase
