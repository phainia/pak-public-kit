local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionBase
local NPCActionOpenLegendaryBattle = Base:Extend("NPCActionOpenLegendaryBattle")

function NPCActionOpenLegendaryBattle:ExecuteWithModel()
end

function NPCActionOpenLegendaryBattle:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
  local ErrorCode = rsp.ret_info.ret_code
  if ErrorCode == ProtoEnum.MOBA_RET.ErrorCode.ERR_COMMON_SYS_FUNC_BANNED or ErrorCode == ProtoEnum.MOBA_RET.ZoneErr.ERR_ZONE_COMMON_BANNED then
    self.needSendReq = false
    self:EndAction()
  else
    _G.NRCModuleManager:DoCmd(_G.LegendaryBattleModuleCmd.OnCheckChallenge, self)
  end
end

function NPCActionOpenLegendaryBattle:EndAction()
  self:Finish()
end

return NPCActionOpenLegendaryBattle
