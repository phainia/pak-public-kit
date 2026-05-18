local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = BattleActionBase
local BattleUnLoadOtherPlayerAvatar = Base:Extend("BattleUnLoadOtherPlayerAvatar")
FsmUtils.MergeMembers(Base, BattleUnLoadOtherPlayerAvatar, {})

function BattleUnLoadOtherPlayerAvatar:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleUnLoadOtherPlayerAvatar:OnEnter()
  _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.UnloadAvatar, 0, PlayerModuleCmd.AvatarUnloadReason.Battle)
  self:Finish()
end

return BattleUnLoadOtherPlayerAvatar
