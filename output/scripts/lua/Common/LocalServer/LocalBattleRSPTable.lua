local Recorder = _G.ProtoRecorder
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local loginRsp, bagMessage, sceneEnterMsg, loadFinishAck, enterBattleNotify, normalEnterNotify, SinglePlayer2v2EnterNotify, skillPerformNotify, mySkillPerformNotify, enemySkillPerformNotify, CatchPetNotify, roundStartNotify, loadFinishRsp
local self = {}
enterBattleNotify = nil
local Kill = false

local function ChangePet(battle_pet_id, rest_pet_id)
  local pets = enterBattleNotify.init_info.player_team[1].pets
  pets[battle_pet_id].battle_inside_pet_info.in_battle = true
  pets[rest_pet_id].battle_inside_pet_info.in_battle = false
  self.battle_pet_id = battle_pet_id
end

local function PrepareBattle()
  self.player_team = enterBattleNotify.init_info.player_team
  self.enemy_team = enterBattleNotify.init_info.enemy_team
  self.battle_pet_id = 1
  roundStartNotify.state_info.player_team = self.player_team
  roundStartNotify.state_info.enemy_team = self.enemy_team
end

local RSPTable = {
  [_G.ProtoCMD.ZoneSvrCmd.ZONE_LOGIN_REQ] = function()
    local returnMsg = {}
    returnMsg[1] = {
      _G.ProtoCMD.ZoneSvrCmd.ZONE_LOGIN_RSP,
      loginRsp
    }
    return returnMsg
  end,
  [_G.ProtoCMD.ZoneSvrCmd.ZONE_ENTER_SCENE_REQ] = function()
    local returnMsg = {}
    returnMsg[1] = {
      _G.ProtoCMD.ZoneSvrCmd.ZONE_ENTER_SCENE_RSP,
      sceneEnterMsg
    }
    returnMsg[2] = {
      _G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_ENTER_NOTIFY,
      enterBattleNotify
    }
    PrepareBattle()
    return returnMsg
  end,
  [_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_CLIENT_ENTER_SCENE_FINISH_NTY] = function()
    local returnMsg = {}
    returnMsg[1] = {
      _G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_CLIENT_ENTER_SCENE_FINISH_NTY_ACK,
      loadFinishAck
    }
    return returnMsg
  end,
  [_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_BAG_REQ] = function()
    return {
      {
        _G.ProtoCMD.ZoneSvrCmd.ZONE_GET_BAG_RSP,
        bagMessage
      }
    }
  end,
  [_G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_CMD_PUSHBACK_REQ] = function(req)
    Log.Debug("LocalBattleRspTable : rsp xxxxxx")
    local returnMsg = {}
    returnMsg[1] = {
      _G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_CMD_PUSHBACK_RSP,
      _G.ProtoMessage:newZoneBattleCmdPushbackRsp()
    }
    if req.req_type == _G.ProtoEnum.BATTLE_REQ_TYPE.CMD_CAST_SKILL then
      if not self.performNotify then
        Log.Error("zgx \230\156\172\229\156\176\230\136\152\230\150\151\231\188\186\229\176\145 performNotify!  \232\175\183\230\163\128\230\181\139\230\136\152\230\150\151\230\182\136\230\129\175\229\140\133\230\152\175\229\144\166\230\173\163\231\161\174\229\189\149\229\136\182")
        return
      end
      Log.Debug("LocalBattleRspTable : rsp")
      local Flows = self.performNotify.perform_cmd.perform_info
      for i, v in ipairs(Flows) do
        if v.type == ProtoEnum.BattlePerformType.BPT_ENERGY then
          v.sync_data.pet_sync_info = {
            {
              pet_id = self.CurSelectedPetEnemy,
              energy_change = 0,
              energy_result = 10
            }
          }
        end
      end
      for i, v in ipairs(Flows) do
        if req.__local_isBuff then
          if v.type == ProtoEnum.BattlePerformType.BPT_BUFF_TRIGGER then
            local data = v.buff_trigger
            local BuffConf = _G.DataConfigManager:GetBuffConf(req.req.cast_skill.skill_id)
            if data.caster_id >= 100 and req.__local_isEnemy then
              data.buff_id = req.req[1].cast_skill.skill_id
              data.caster_id = self.CurSelectedPetEnemy
              data.target_id = self.CurSelectedPetEnemy
              if BuffConf then
                data.buffbase_ids = BuffConf.buff_base_ids
                if BuffConf.res_id_0 then
                  data.perform_type = 0
                  break
                end
                if BuffConf.res_id_1 then
                  data.perform_type = 1
                  break
                end
                if BuffConf.res_id_2 then
                  data.perform_type = 2
                end
              end
              break
            elseif data.caster_id < 50 and not req.__local_isEnemy then
              data.buff_id = req.req[1].cast_skill.skill_id
              data.caster_id = self.CurSelectedPetPlayer
              data.target_id = self.CurSelectedPetPlayer
              if BuffConf then
                data.buffbase_ids = BuffConf.buff_base_ids
                if BuffConf.res_id_0 then
                  data.perform_type = 0
                  break
                end
                if BuffConf.res_id_1 then
                  data.perform_type = 1
                  break
                end
                if BuffConf.res_id_2 then
                  data.perform_type = 2
                end
              end
              break
            end
          end
        elseif v.type == ProtoEnum.BattlePerformType.BPT_SKILL_CAST then
          local data = v.skill_cast
          if data.caster_id >= 100 and req.__local_isEnemy then
            data.skill_id = req.req[1].cast_skill.skill_id
            data.caster_id = self.CurSelectedPetEnemy
            data.target_id = {
              self.CurSelectedPetPlayer
            }
            break
          elseif data.caster_id < 50 and not req.__local_isEnemy then
            data.skill_id = req.req[1].cast_skill.skill_id
            data.caster_id = self.CurSelectedPetPlayer
            data.target_id = {
              self.CurSelectedPetEnemy
            }
            break
          end
        end
      end
      returnMsg[2] = {
        _G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_PERFORM_START_NOTIFY,
        self.performNotify
      }
    elseif req.req_type == _G.ProtoEnum.BATTLE_REQ_TYPE.CMD_CATCH_PET then
      local Flows = CatchPetNotify.perform_cmd.perform_info
      for i, v in ipairs(Flows) do
        if v.type == ProtoEnum.BattlePerformType.BPT_CATCH_PET then
          local data = v.catch_pet_info
          data.success = false
          data.pet_gid = self.CurSelectedPetPlayer
          data.monster_id = self.CurSelectedPetEnemy
          data.player_id = enterBattleNotify.init_info.player_team[1].base.role_uin
        end
      end
      returnMsg[2] = {
        _G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_PERFORM_START_NOTIFY,
        CatchPetNotify
      }
    end
    return returnMsg
  end,
  [_G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_ROUND_FLOW_FINISH_REQ] = function()
    local returnMsg = {}
    returnMsg[1] = {
      _G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_ROUND_FLOW_FINISH_RSP,
      _G.ProtoMessage:newZoneBattleRoundFlowFinishRsp()
    }
    returnMsg[2] = {
      _G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_ROUND_START_NOTIFY,
      roundStartNotify
    }
    _G.BattleEventCenter:Dispatch(BattleEvent.BATTLE_STATE_SETTLEMENT)
    return returnMsg
  end,
  [_G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_LOAD_FINISH_REQ] = function()
    local retMsg = {
      {
        _G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_LOAD_FINISH_RSP,
        loadFinishRsp
      },
      {
        _G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_ROUND_START_NOTIFY,
        roundStartNotify
      }
    }
    return retMsg
  end
}

function RSPTable.LoadProto()
  if not self.isLoaded then
    loginRsp = Recorder.GetJsonFile("258_Next_ZoneLoginRsp")
    bagMessage = Recorder.GetJsonFile("354_Next_ZoneGetBagRsp")
    sceneEnterMsg = Recorder.GetJsonFile("338_Next_ZoneEnterSceneRsp")
    loadFinishAck = Recorder.GetJsonFile("330_Next_ZoneSceneClientEnterSceneFinishNtyAck")
    enterBattleNotify = nil
    normalEnterNotify = Recorder.GetJsonFile("4886_9489_Next_BattleEnterNotify")
    SinglePlayer2v2EnterNotify = Recorder.GetJsonFile("790_5617_Next_BattleEnterNotify")
    skillPerformNotify = Recorder.GetJsonFile("4900_25643_Next_BattlePerformStartNotify")
    mySkillPerformNotify = Recorder.GetJsonFile("4900_31342_Next_BattlePerformStartNotify_enemy")
    enemySkillPerformNotify = Recorder.GetJsonFile("4900_25643_Next_BattlePerformStartNotify_self")
    CatchPetNotify = Recorder.GetJsonFile("804_Catach_Next_BattlePerformStartNotify")
    roundStartNotify = Recorder.GetJsonFile("4890_13899_Next_BattleRoundStartNotify")
    loadFinishRsp = Recorder.GetJsonFile("774_9271_Next_BattleLoadFinishRsp")
    self.isLoaded = true
  end
end

function RSPTable.GetPlayerBattlePetID()
  return self.CurSelectedPetPlayer
end

function RSPTable.GetEnemyBattlePetID()
  return self.CurSelectedPetEnemy
end

function RSPTable.GetPlayerBattlePetInfo()
  return self.player_team[1].pets[self.CurSelectedPlayerPetPos]
end

function RSPTable.GetEnemyBattlePetInfo()
  return self.enemy_team[1].pets[self.CurSelectedEnemyPetPos]
end

function RSPTable.GetPetGuidByPos(team, pos)
  if team == BattleEnum.Team.ENUM_TEAM then
    return pos
  elseif team == BattleEnum.Team.ENUM_ENEMY then
    return 400 + pos
  end
end

function RSPTable.SwitchToBossBattle()
  RSPTable.LoadProto()
  self.battleMode = "bossfight"
end

function RSPTable.SwitchToNormalBattle()
  RSPTable.LoadProto()
  enterBattleNotify = normalEnterNotify
  self.battleMode = "single"
end

function RSPTable.SwitchToSinglePlayer2V2Battle()
  RSPTable.LoadProto()
  enterBattleNotify = SinglePlayer2v2EnterNotify
  self.battleMode = "2v2"
end

function RSPTable.SwitchToAutoBattleCoping()
  RSPTable.LoadProto()
  enterBattleNotify = SinglePlayer2v2EnterNotify
  self.battleMode = "auto_coping"
end

function RSPTable.SwitchToAutoBattle()
  RSPTable.LoadProto()
  enterBattleNotify = normalEnterNotify
  self.battleMode = "auto"
end

function RSPTable.SwitchToAutoReplay()
  self.battleMode = "auto_replay"
end

function RSPTable.SetKill(isKill)
  Kill = isKill
end

function RSPTable.ChangeBattleType(caster)
  if "self" == caster then
    self.performNotify = mySkillPerformNotify
  elseif "enemy" == caster then
    self.performNotify = enemySkillPerformNotify
  else
    self.performNotify = skillPerformNotify
  end
end

function RSPTable.SetEnterBattleInfo(weather_id, pos, water_type)
  enterBattleNotify.weather_id = weather_id
  enterBattleNotify.battle_center = pos
  enterBattleNotify.water_battle_type = water_type or 0
end

RSPTable.values = self
RSPTable.AutoTestOver = false
self.performNotify = skillPerformNotify
return RSPTable
