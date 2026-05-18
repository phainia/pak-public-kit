local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local BattleField = require("NewRoco.Modules.Core.Battle.Common.BattleField")
local EnterTestBattleFiledAction = NRCModeAction:Extend("EnterTestBattleFiledAction")

function EnterTestBattleFiledAction:Ctor(name, properties)
  NRCModeAction.Ctor(self, name, properties)
end

function EnterTestBattleFiledAction:OnEnter()
  Log.Debug("yukaheTestMap EnterTestBattleFiledAction.OnEnter")
  local req = ProtoMessage:newZoneGmCreateBattleReq()
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local PlayerLocation = player.viewObj:Abs_K2_GetActorLocation()
  local PlayerTransform = player.viewObj:Abs_GetTransform()
  PlayerLocation.Z = PlayerLocation.Z - player:GetHalfHeight()
  local BattlePos, Rotation = BattleField.FindNearestBattlePoint(PlayerLocation, PlayerTransform)
  req.avatar_pt.pos.x = math.floor(BattlePos.X)
  req.avatar_pt.pos.y = math.floor(BattlePos.Y)
  req.avatar_pt.pos.z = math.floor(BattlePos.Z)
  req.battle_conf_id = 399019
  req.npc_level = 1
  Log.Debug("yukaheTestMap \229\176\157\232\175\149\232\191\155\229\133\165\230\136\152\230\150\151\239\188\140id=", 399019)
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CREATE_BATTLE_REQ, req)
  self:Finish()
end

function EnterTestBattleFiledAction:OnExit()
end

return EnterTestBattleFiledAction
