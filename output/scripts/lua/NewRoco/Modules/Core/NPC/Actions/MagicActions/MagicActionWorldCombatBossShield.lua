local MagicActionBase = require("NewRoco.Modules.Core.NPC.Actions.MagicActions.MagicActionBase")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local Base = MagicActionBase
local MagicActionWorldCombatBossShield = Base:Extend("MagicActionWorldCombatBossShield")

function MagicActionWorldCombatBossShield:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function MagicActionWorldCombatBossShield:OnSubmit(rsp)
  Base.OnSubmit(self)
  if rsp.ret_info.ret_code == ProtoEnum.MOBA_RET.SceneErr.ERR_SCENE_PETBOSS_INVICIBLE and self.Config.action_type == _G.Enum.ActionType.ACT_WORLD_COMBAT_BOSS and self.Owner.owner.config.genre == _G.Enum.ClientNpcType.CNT_PETBOSS then
    _G.NRCEventCenter:DispatchEvent(MainUIModuleEvent.OnBarrierImmune)
  end
end

return MagicActionWorldCombatBossShield
