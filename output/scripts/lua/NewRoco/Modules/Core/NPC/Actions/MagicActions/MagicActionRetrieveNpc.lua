local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local MagicCreationUtils = require("NewRoco.Modules.System.MagicCreation.MagicCreationUtils")
local Base = NPCActionBase
local MagicActionRetrieveNpc = Base:Extend("MagicActionRetrieveNpc")

function MagicActionRetrieveNpc:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function MagicActionRetrieveNpc:Execute()
  Base.Execute(self)
  MagicCreationUtils.PlayDeletingSkill(self.OwnerNpc)
  self:Finish(true, nil, nil)
end

function MagicActionRetrieveNpc:PostOnCommit(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    MagicCreationUtils.UndoDeleteEffect(self.OwnerNpc)
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\229\155\158\230\148\182\229\164\177\232\180\165")
    Log.Error("retrieve npc failed", rsp.ret_info.ret_code, rsp.ret_info.ret_msg)
  end
end

return MagicActionRetrieveNpc
