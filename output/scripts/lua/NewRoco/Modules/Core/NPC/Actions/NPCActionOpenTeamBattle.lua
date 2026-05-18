local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionBase
local TeamBattleModuleEnum = require("NewRoco.Modules.System.TeamBattle.TeamBattleModuleEnum")
local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local NPCActionOpenTeamBattle = Base:Extend("NPCActionOpenTeamBattle")

function NPCActionOpenTeamBattle:ExecuteWithModel()
end

function NPCActionOpenTeamBattle:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
  local ErrorCode = rsp.ret_info.ret_code
  if ErrorCode == ProtoEnum.MOBA_RET.ErrorCode.ERR_COMMON_SYS_FUNC_BANNED or ErrorCode == ProtoEnum.MOBA_RET.ZoneErr.ERR_ZONE_COMMON_BANNED then
    self.needSendReq = false
    self:EndAction()
  else
    _G.NRCModuleManager:DoCmd(_G.LegendaryBattleModuleCmd.CheckLegendaryBattleMatchState, self, self.OpenPreWarPanel)
  end
end

function NPCActionOpenTeamBattle:OpenPreWarPanel(bOpen)
  if bOpen then
    local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    local HeadComp = player:GetHeadLookAtComponent()
    if HeadComp then
      DialogueUtils.StopTurn(player.viewObj)
      HeadComp:SetAutoLookAtParam(UE4.ELookAtParamType.Target, self:GetOwnerNPC().viewObj)
      HeadComp:ActiveAutoLookAt(false, nil, true)
      HeadComp:EnableManualOverride()
    end
    _G.NRCModuleManager:DoCmd(_G.TeamBattleModuleCmd.SendZoneTeamBattleInfoQueryReq, self:GetOwnerNPC().serverData.base.logic_id, TeamBattleModuleEnum.EntranceType.NPC, self)
  else
    self:EndAction()
  end
end

function NPCActionOpenTeamBattle:EndAction()
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local HeadComp = player:GetHeadLookAtComponent()
  if HeadComp then
    HeadComp:DisableManualOverride()
  end
  self:Finish()
end

return NPCActionOpenTeamBattle
