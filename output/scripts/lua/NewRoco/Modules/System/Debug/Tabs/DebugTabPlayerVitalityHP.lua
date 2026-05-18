local Base = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local PlayerDataEvent = require("Data.Global.PlayerDataEvent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local ScenePlayerPet = require("NewRoco.Modules.Core.Scene.Actor.ScenePlayerPet")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local BattleField = require("NewRoco.Modules.Core.Battle.Common.BattleField")
local DebugTabPlayerVitalityHP = Base:Extend("DebugTabPlayerVitalityHP")

function DebugTabPlayerVitalityHP:Ctor()
  Base.Ctor(self)
end

function DebugTabPlayerVitalityHP:SetupTabs()
  self:Add("\232\174\190\231\189\174\228\189\147\230\184\169", self.OverrideBodyTemp, self)
  self:Add("\229\188\128\229\133\179\228\189\147\229\138\155\230\151\165\229\191\151", self.ToggleVitalityLog, self)
  self:Add("\232\174\190\231\189\174\228\189\147\229\138\155\228\184\138\233\153\144", self.SetStaminaLimit, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil)
end

function DebugTabPlayerVitalityHP:FreeVitality()
  GlobalConfig.FreeVitality = not GlobalConfig.FreeVitality
  local Req = _G.ProtoMessage:newZoneSceneGmOperateStaminaReq()
  Req.op_type = _G.ProtoEnum.ZoneSceneGmOperateStaminaReq.OpType.OT_FORIBID
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_OPERATE_STAMINA_REQ, Req, self, self.OnRsp)
end

function DebugTabPlayerVitalityHP:SwitchPlayerHit()
  GlobalConfig.IgnorePlayerHit = not GlobalConfig.IgnorePlayerHit
  GlobalConfig.DisablePetAttack = not GlobalConfig.DisablePetAttack
end

function DebugTabPlayerVitalityHP:SetLocalMaxVitality(name, Panel, InputNumber)
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  local localPlayer = playerModule.playerModuleData.localPlayer
  local newVitality
  if Panel then
    newVitality = Panel:GetInputNumber()
  else
    newVitality = tonumber(InputNumber)
  end
  if 0 == newVitality then
    newVitality = 3000
  end
  if localPlayer then
    localPlayer.vitalityComponent._mainVitality._curVitality = newVitality
    localPlayer.vitalityComponent._mainVitality._maxVitality = newVitality
  end
end

function DebugTabPlayerVitalityHP:ShowFallingTime()
  GlobalConfig.ShowShowFallingTime = not GlobalConfig.ShowShowFallingTime
end

function DebugTabPlayerVitalityHP:AddPalyerZ(name, Panel, InputNumber)
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  local localPlayer = playerModule.playerModuleData.localPlayer
  local num
  if Panel then
    num = Panel:GetInputNumber()
  else
    num = tonumber(InputNumber)
  end
  if localPlayer then
    localPlayer.viewObj:K2_AddActorLocalOffset(UE4.FVector(0, 0, num), false, nil, false)
  end
end

function DebugTabPlayerVitalityHP:SimHeavyHit(name, Panel, InputNumber)
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  local localPlayer = playerModule.playerModuleData.localPlayer
  if localPlayer then
    local direction = UE.UKismetMathLibrary.GetForwardVector(localPlayer:GetUEController().PlayerCameraManager:GetCameraRotation())
    local isHeavy
    if Panel then
      isHeavy = Panel:GetInputNumber()
    else
      isHeavy = tonumber(InputNumber)
    end
    local attackType
    if nil == isHeavy or 0 ~= isHeavy then
      if 3 == isHeavy then
        attackType = 3
      end
      isHeavy = true
    else
      isHeavy = false
    end
    localPlayer.playerAttackedInteractionComponent:OnAttacked(0, direction, isHeavy, true, attackType)
  end
end

function DebugTabPlayerVitalityHP:UseLocalRoleHp()
  GlobalConfig.UseLocalRoleHp = true
end

function DebugTabPlayerVitalityHP:SetEnableTeleport()
  GlobalConfig.EnableDeahTeleport = not GlobalConfig.EnableDeahTeleport
  Log.Debug("EnableDeathTeleport=", GlobalConfig.EnableDeahTeleport)
end

function DebugTabPlayerVitalityHP:ToggleTempLog(name, panel)
  self._Player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  self._Player.TemperatureComponent.isDebug = not self._Player.TemperatureComponent.isDebug
end

function DebugTabPlayerVitalityHP:ChangeBtTo0(name, panel)
  self._Player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  self._Player.TemperatureComponent.isGMBt = true
  self._Player.TemperatureComponent.body_temp_final_val = 0
  self._Player.TemperatureComponent.reach_final_time = _G.ZoneServer:GetServerTime() / 1000 + 12
  Log.Debug("#### ChangeBtTo0", _G.ZoneServer:GetServerTime())
end

function DebugTabPlayerVitalityHP:ChangeBtToHot(name, panel)
  self._Player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  self._Player.TemperatureComponent.isGMBt = true
  self._Player.TemperatureComponent.body_temp_final_val = 10000
  self._Player.TemperatureComponent.reach_final_time = _G.ZoneServer:GetServerTime() / 1000 + 12
  Log.Debug("#### ChangeBtToHot", _G.ZoneServer:GetServerTime())
end

function DebugTabPlayerVitalityHP:ChangeBtToCold(name, panel)
  self._Player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  self._Player.TemperatureComponent.isGMBt = true
  self._Player.TemperatureComponent.body_temp_final_val = -10000
  self._Player.TemperatureComponent.reach_final_time = _G.ZoneServer:GetServerTime() / 1000 + 12
  Log.Debug("#### ChangeBtToCold", _G.ZoneServer:GetServerTime())
end

function DebugTabPlayerVitalityHP:ChangeBtToNormal(name, panel)
  self._Player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  self._Player.TemperatureComponent.isGMBt = false
  self._Player.TemperatureComponent.bt = 0
end

function DebugTabPlayerVitalityHP:ChangeHP(name, panel, id)
  if panel then
    self._Player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    local value = tonumber(panel.InputBox:GetText())
    if value and value > 1000 then
      Log.ErrorFormat("\232\174\190\231\189\174\231\154\132HP\229\128\188[%d]\229\164\170\229\164\167\228\186\134,\228\188\154\229\175\188\232\135\180\229\180\169\230\186\131!", value)
      return
    end
    if value then
      self._Player:SendEvent(PlayerModuleEvent.ON_ROLE_HP_CHANGE, value, 0)
    end
  elseif id then
    self._Player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    local value = id
    if value and value > 1000 then
      Log.ErrorFormat("\232\174\190\231\189\174\231\154\132HP\229\128\188[%d]\229\164\170\229\164\167\228\186\134,\228\188\154\229\175\188\232\135\180\229\180\169\230\186\131!", value)
      return
    end
    if value then
      self._Player:SendEvent(PlayerModuleEvent.ON_ROLE_HP_CHANGE, value, 0)
    end
  end
end

function DebugTabPlayerVitalityHP:PrintCurrentHP()
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player then
    local msg = string.format("\229\189\147\229\137\141HP\230\152\175\239\188\154%d\239\188\140\230\156\172\229\156\176HP\230\152\175\239\188\154%d", player.serverData.attrs.hp, player.roleHPComponent._locRoleHP)
    UE4Helper.PrintScreenMsg(msg)
  end
end

function DebugTabPlayerVitalityHP:ReduceHP(Name, Panel)
  local Player = self:GetPlayer()
  local Comp = Player.roleHPComponent
  Comp:ReduceAllRoleHP(ProtoEnum.RoleHpReduceReason.HP_REDUCE_REASON_FALLING)
end

function DebugTabPlayerVitalityHP:ShowVitalitySyncInfo()
  GlobalConfig.ShowVitalitySyncInfo = not GlobalConfig.ShowVitalitySyncInfo
end

function DebugTabPlayerVitalityHP:ShowVitalityValue()
  GlobalConfig.ShowVitalityValue = not GlobalConfig.ShowVitalityValue
end

function DebugTabPlayerVitalityHP:OverrideBodyTemp(Name, Panel, InputNumber)
  local NewTemp
  if Panel then
    NewTemp = Panel:GetInputNumber(100)
  else
    NewTemp = tonumber(InputNumber) or 100
  end
  local Req = _G.ProtoMessage:newZoneSceneGmReq()
  Req.gm_type = _G.ProtoEnum.SceneGmType.SGT_BODYTEMP
  Req.gm_op_type = _G.ProtoEnum.SceneGmOpType.SGOT_SET
  Req.param1 = NewTemp
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, Req, self, self.OnRsp)
end

function DebugTabPlayerVitalityHP:OnRsp(rsp)
end

function DebugTabPlayerVitalityHP:ToggleVitalityLog()
  GlobalConfig.EnableVitalityLog = not GlobalConfig.EnableVitalityLog
end

function DebugTabPlayerVitalityHP:SetStaminaLimit(Name, Panel)
  local inputText = tonumber(self:GetInputString())
  if inputText and inputText > 0 and inputText <= 10 then
    local staminaLevel = _G.DataConfigManager:GetPowerMaxConf(inputText, true).id
    local Req = _G.ProtoMessage:newZoneSceneGmReq()
    Req.gm_type = _G.ProtoEnum.SceneGmType.SGT_SET_STAMINA_MAX
    Req.param1 = staminaLevel
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, Req, self, self.OnStaminaLimitRsp)
  else
    Log.Error("\229\143\130\230\149\176\228\184\141\230\173\163\231\161\174\239\188\140\232\175\183\229\161\171\229\133\1651-10\231\154\132\230\161\163\228\189\141\230\149\176\229\173\151")
  end
end

function DebugTabPlayerVitalityHP:AutoTestSetStaminaLimit(inputStr)
  local inputText = tonumber(inputStr)
  if inputText and inputText > 0 and inputText <= 10 then
    local staminaLevel = _G.DataConfigManager:GetPowerMaxConf(inputText, true).id
    local Req = _G.ProtoMessage:newZoneSceneGmReq()
    Req.gm_type = _G.ProtoEnum.SceneGmType.SGT_SET_STAMINA_MAX
    Req.param1 = staminaLevel
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_REQ, Req, self, self.OnStaminaLimitRsp)
  else
    Log.Error("\229\143\130\230\149\176\228\184\141\230\173\163\231\161\174\239\188\140\232\175\183\229\161\171\229\133\1651-10\231\154\132\230\161\163\228\189\141\230\149\176\229\173\151")
  end
end

function DebugTabPlayerVitalityHP:OnStaminaLimitRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    Log.Error("\228\189\147\229\138\155\228\184\138\233\153\144\230\161\163\228\189\141\232\174\190\231\189\174\229\174\140\230\136\144")
  else
    Log.Error("\228\189\147\229\138\155\228\184\138\233\153\144\230\161\163\228\189\141\232\174\190\231\189\174\229\164\177\232\180\165!!!!!")
  end
end

return DebugTabPlayerVitalityHP
