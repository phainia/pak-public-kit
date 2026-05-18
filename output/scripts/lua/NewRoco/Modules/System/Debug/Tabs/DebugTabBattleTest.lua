local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local PopupData = require("NewRoco.Modules.Core.Battle.Entity.Components.BuffEffectPopup.PopupData")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local BattleField = require("NewRoco.Modules.Core.Battle.Common.BattleField")
local Base = DebugTabBase
local DebugTabBattleTest = Base:Extend("DebugTabBattleTest")

function DebugTabBattleTest:Ctor()
  Base.Ctor(self)
end

function DebugTabBattleTest:SetupTabs()
  self:Add("\230\159\165\232\175\162\230\136\152\230\150\151\233\128\137\231\130\185\231\187\147\230\158\156", self.QueryBattleFieldInfo, self)
  self:Add("\230\137\147\229\188\128\230\142\146\228\189\141\232\181\155\231\187\147\231\174\151\231\149\140\233\157\162", self.OpenPVPDanGradingPanel, self, nil, nil, nil, nil, "", "", "OpenPVPDanGradingPanel")
  local BATTLE_CONF = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.BATTLE_CONF):GetAllDatas()
  for k, v in pairs(BATTLE_CONF) do
    self:Add(string.format([[
%s
%d]], v.name, k), function(caller, Name, Panel)
      self:EnterBattleWithID(k, Panel)
    end, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "\230\136\152\230\150\151\230\181\139\232\175\149")
  end
end

function DebugTabBattleTest:NotifyBattleInfo(rsp)
  Log.Debug("DebugTabBattleTest: Enter test battle")
  if 0 ~= rsp.ret_info.ret_code then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "\229\144\142\229\143\176\233\128\137\231\130\185\229\188\130\229\184\184\239\188\129\239\188\129\239\188\129")
    return
  end
  local query_pos = UE4.FVector(math.floor(rsp.query_pos.x), math.floor(rsp.query_pos.y), math.floor(rsp.query_pos.z))
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local PlayerTransform = player.viewObj:Abs_GetTransform()
  local BattlePos, Rotation = BattleField.FindNearestBattlePoint(query_pos, PlayerTransform, rsp.is_full_station, rsp.data_layer)
  local InputParams = string.format("\231\142\169\229\174\182\228\189\141\231\189\174(%d, %d, %d) \229\133\168\231\171\153\228\189\141:\227\128\144%s\227\128\145 layer:\227\128\144%d\227\128\145\n\230\159\165\232\175\162\229\143\130\230\149\176: \230\159\165\232\175\162\231\130\185(%d, %d, %d)", math.floor(PlayerTransform.Translation.X), math.floor(PlayerTransform.Translation.Y), math.floor(PlayerTransform.Translation.Z), tostring(rsp.is_full_station), rsp.data_layer, math.floor(query_pos.X), math.floor(query_pos.Y), math.floor(query_pos.Z))
  local ClientResult = string.format("\229\137\141\229\143\176\231\187\147\230\158\156: \230\136\152\229\156\186\231\130\185(%d, %d, %d)", math.floor(BattlePos.x), math.floor(BattlePos.y), math.floor(BattlePos.z), tostring(rsp.is_full_station), rsp.data_layer)
  local ServerResult = string.format("\229\144\142\229\143\176\231\187\147\230\158\156:\227\128\144\231\187\147\230\158\156\229\188\130\229\184\184\227\128\145")
  if rsp.status == ProtoEnum.ZoneGmCreateBattleRsp.BattleFieldStatus.BATTLE_FIELD_STATUS_NOT_FOUND then
    ServerResult = string.format("\229\144\142\229\143\176\231\187\147\230\158\156:\227\128\144\230\156\170\230\137\190\229\136\176\230\136\152\229\156\186\231\130\185\227\128\145")
  elseif rsp.status == ProtoEnum.ZoneGmCreateBattleRsp.BattleFieldStatus.BATTLE_FIELD_STATUS_LOCAL then
    ServerResult = string.format(string.format("\229\144\142\229\143\176\231\187\147\230\158\156:\227\128\144\228\189\191\231\148\168\229\155\186\229\174\154\233\133\141\231\189\174\231\130\185, battle_id %d\227\128\145 \230\136\152\229\156\186\231\130\185(%d, %d, %d)"), rsp.battle_id, math.floor(rsp.result_pos.x), math.floor(rsp.result_pos.y), math.floor(rsp.result_pos.z))
  elseif rsp.status == ProtoEnum.ZoneGmCreateBattleRsp.BattleFieldStatus.BATTLE_FIELD_STATUS_SUCCESS then
    ServerResult = string.format("\229\144\142\229\143\176\231\187\147\230\158\156: \230\136\152\229\156\186\231\130\185(%d, %d, %d)", math.floor(rsp.result_pos.x), math.floor(rsp.result_pos.y), math.floor(rsp.result_pos.z))
  end
  local Context = DialogContext()
  Context:SetTitle(LuaText.TIPS):SetContent(string.format([[
%s
%s
%s]], InputParams, ClientResult, ServerResult)):SetMode(DialogContext.Mode.NotBtn):SetCloseOnCancel(true)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
end

function DebugTabBattleTest:QueryBattleFieldInfo(name, Panel)
  if not BattleField.debugLastEnterBattlePoint then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "\230\178\161\230\156\137\228\184\138\230\172\161\232\191\155\229\133\165\230\136\152\229\156\186\231\154\132\229\133\165\229\143\163\228\191\161\230\129\175\239\188\129\239\188\129\239\188\129")
    return
  end
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local PlayerLocation = player.viewObj:Abs_K2_GetActorLocation()
  PlayerLocation.Z = PlayerLocation.Z - player:GetHalfHeight()
  local req = ProtoMessage:newZoneGmQueryBattleFieldReq()
  req.avatar_pt.x = math.floor(PlayerLocation.X)
  req.avatar_pt.y = math.floor(PlayerLocation.Y)
  req.avatar_pt.z = math.floor(PlayerLocation.Z)
  req.npc_pt.x = math.floor(BattleField.debugLastEnterBattlePoint.X)
  req.npc_pt.y = math.floor(BattleField.debugLastEnterBattlePoint.Y)
  req.npc_pt.z = math.floor(BattleField.debugLastEnterBattlePoint.Z)
  req.full_station = tonumber(BattleField.debugLastUseFullStation)
  req.battle_conf_id = BattleUtils.GetBattleConfig().id
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_QUERY_BATTLE_FIELD_REQ, req, self, self.NotifyBattleInfo)
end

function DebugTabBattleTest:EnterBattleWithID(id, Panel)
  local PlayerLocation = BattleField.debugForceEnterLocation
  if not PlayerLocation then
    local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    PlayerLocation = player.viewObj:Abs_K2_GetActorLocation()
  end
  local level = 1
  local Input = Panel.InputBox:GetText()
  local Splatted = string.Split(Input, ";")
  local SplattedLen = #Splatted
  if SplattedLen >= 1 then
    level = tonumber(Splatted[1], 10) or 1
  end
  local NpcPos = PlayerLocation
  if SplattedLen >= 2 then
    local Pos = string.Split(Splatted[2], ",")
    local PosLen = #Pos
    if PosLen >= 3 then
      NpcPos = UE4.FVector(tonumber(Pos[1]), tonumber(Pos[2]), tonumber(Pos[3]))
    end
  end
  local req = ProtoMessage:newZoneGmCreateBattleReq()
  req.avatar_pt.pos.x = math.floor(PlayerLocation.X)
  req.avatar_pt.pos.y = math.floor(PlayerLocation.Y)
  req.avatar_pt.pos.z = math.floor(PlayerLocation.Z)
  if BattleField.debugForceForward then
    local BattleField = require("NewRoco.Modules.Core.Battle.Common.BattleField")
    if BattleField then
      local offset = BattleField.OffsetTable
      if BattleField.debugForceForward > 0 and BattleField.debugForceForward <= #offset then
        req.avatar_pt.pos.x = req.avatar_pt.pos.x + offset[BattleField.debugForceForward].x
        req.avatar_pt.pos.y = req.avatar_pt.pos.y + offset[BattleField.debugForceForward].y
        req.avatar_pt.pos.z = req.avatar_pt.pos.z + offset[BattleField.debugForceForward].z
      end
    end
  end
  req.npc_pt.pos.x = math.floor(NpcPos.X)
  req.npc_pt.pos.y = math.floor(NpcPos.Y)
  req.npc_pt.pos.z = math.floor(NpcPos.Z)
  req.battle_conf_id = id
  req.npc_level = level
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CREATE_BATTLE_REQ, req, self, self.NotifyBattleInfo)
end

function DebugTabBattleTest:OpenPVPDanGradingPanel()
  _G.NRCModeManager:DoCmd(_G.BattleUIModuleCmd.OpenPVPDanGradingPanel)
end

function DebugTabBattleTest:OpenUmgPVPQualifier()
  _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.OpenPVPRankedMatch)
end

return DebugTabBattleTest
