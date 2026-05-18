local BattleActionBase = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattleActionBase")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local Base = BattleActionBase
local BattleTerritoryTrialSendAgain = Base:Extend("BattleTerritoryTrialSendAgain")

function BattleTerritoryTrialSendAgain:Ctor()
  Base.Ctor(self)
end

function BattleTerritoryTrialSendAgain:OnEnter()
  self.onBattleRsp = false
  local traceNpc = BattleUtils.GetTraceNpc()
  local req = ProtoMessage:newZoneSceneCreateBattleReq()
  local battleConf = BattleUtils.GetBattleConfig()
  local battleConfId = battleConf and battleConf.id
  req.battle_conf_id = battleConfId
  local sceneNPC = traceNpc and traceNpc.npc
  if sceneNPC then
    req.npc_pt = sceneNPC:GetServerPoint()
    req.npc_obj_id = sceneNPC:GetServerId()
    local config = sceneNPC.config
    req.npc_conf_id = config and sceneNPC.config.id
    req.npc_level = config and config.npc_level or 1
    req.option_id = config and config.option_id[1]
  end
  local localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer then
    req.avatar_pt = localPlayer:GetServerPoint()
    req.npc_pt = localPlayer:GetServerPoint()
  end
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_SCENE_CREATE_BATTLE_REQ, req, self, self.OnBattleRsp, true, false)
  _G.DelayManager:DelaySeconds(5, self.SafeDelayTimeout, self)
end

function BattleTerritoryTrialSendAgain:OnBattleRsp(rsp)
  self.onBattleRsp = true
  local retInfo = rsp and rsp.ret_info
  local retCode = retInfo and retInfo.ret_code
  if 0 ~= retCode then
    Log.Error("BattleTerritoryTrialSendAgain:OnBattleRsp ret code", retCode)
    local closeReasonList = {
      BattleEnum.ShowBlackScreenReason.RestartEnterBattle
    }
    _G.NRCModeManager:DoCmd(BattleUIModuleCmd.CloseLoading, {closeReasonList = closeReasonList})
  end
  self:Finish()
end

function BattleTerritoryTrialSendAgain:SafeDelayTimeout()
  if not self.onBattleRsp then
    NRCModeManager:DoCmd(PlayerModuleCmd.HIDE_LOCAL_PLAYER, false)
    Log.Error("BattleTerritoryTrialSendAgain:SafeDelayTimeout")
    local closeReasonList = {
      BattleEnum.ShowBlackScreenReason.RestartEnterBattle
    }
    _G.NRCModeManager:DoCmd(BattleUIModuleCmd.CloseLoading, {closeReasonList = closeReasonList})
    self:Finish()
  end
end

return BattleTerritoryTrialSendAgain
