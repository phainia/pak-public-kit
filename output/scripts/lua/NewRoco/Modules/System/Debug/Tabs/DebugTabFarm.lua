local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local FarmUtils = require("NewRoco.Modules.System.Farm.FarmUtils")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabFarm = Base:Extend("DebugTabFarm")

function DebugTabFarm:Ctor()
  Base.Ctor(self)
end

function DebugTabFarm:SetupTabs()
end

function DebugTabFarm:FarmPlantReset(Name, Panel)
  local req = ProtoMessage:newZoneSceneHomePlantGmResetReq()
  _G.ZoneServer:Send(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_HOME_PLANT_GM_RESET_REQ, req, false)
end

function DebugTabFarm:FarmPlantRipe(Name, Panel)
  local req = ProtoMessage:newZoneSceneHomePlantGmRipeReq()
  _G.ZoneServer:Send(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_HOME_PLANT_GM_RIPE_REQ, req, false)
end

function DebugTabFarm:FarmPlantReap(Name, Panel)
  local inputText
  if Panel then
    inputText = Panel.InputBox:GetText()
  else
    inputText = InputText
  end
  if string.IsNilOrEmpty(inputText) then
    Log.Error("FarmPlantReap Failed!!! \232\175\183\232\190\147\229\133\165\233\156\128\232\166\129\231\148\159\230\136\144land_id!")
    return
  end
  local inputTextArr = string.Split(inputText, " ")
  local land_id = tonumber(inputTextArr[1])
  local reap = -1
  if #inputTextArr >= 2 then
    reap = toNumber(inputTextArr[2], -1)
  end
  local req = ProtoMessage:newZoneSceneHomePlantGmReapReq()
  req.land_id = land_id
  req.reap = reap
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_HOME_PLANT_GM_REAP_REQ, req, self, function(this, rsp)
    if 0 ~= rsp.ret_info.ret_code then
      Log.Error("FarmPlantReap Failed: " .. rsp.ret_info.ret_code)
      return
    end
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, string.format("\229\156\159\229\156\176ID: %d, \228\184\176\230\148\182\230\166\130\231\142\135: %d", land_id, rsp.reap))
    Log.Debug("\229\156\159\229\156\176ID: %d, \228\184\176\230\148\182\230\166\130\231\142\135: %d", land_id, rsp.reap)
  end, false, true)
end

function DebugTabFarm:FarmPlantStealLimit(Name, Panel)
  local inputText
  if Panel then
    inputText = Panel.InputBox:GetText()
  end
  local limit = toNumber(inputText, -1)
  local req = ProtoMessage:newZoneSceneHomePlantGmStealLimitReq()
  req.limit = limit
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_HOME_PLANT_GM_STEAL_LIMIT_REQ, req, self, function(this, rsp)
    if 0 ~= rsp.ret_info.ret_code then
      Log.Error("FarmPlantStealLimit Failed: " .. rsp.ret_info.ret_code)
      return
    end
    Log.Warning("\229\189\147\229\137\141\229\143\175\229\129\183\229\143\150\228\184\138\233\153\144: " .. rsp.limit)
  end, false, true)
end

function DebugTabFarm:ShowAllLandPlantInfo(Name, Panel)
  local Player = FarmUtils.GetPlayer()
  if not Player then
    Log.Error("DebugTabFarm:ShowAllLandPlantInfo no player found")
    return
  end
  if not (Player.serverData and Player.serverData.home_plant_info) or not Player.serverData.home_plant_info.cell_home_plant_info then
    Log.Error("DebugTabFarm:ShowAllLandPlantInfo no player farm data found")
  end
  NRCModuleManager:DoCmd(_G.DebugModuleCmd.ShowTable, Player.serverData.home_plant_info.cell_home_plant_info, "All land info")
end

function DebugTabFarm:ShowCurrentLandPlantInfo(Name, Panel)
  local landId = _G.NRCModeManager:DoCmd(_G.FarmModuleCmd.GetCurrentStandingLandId)
  local Ctx = DialogContext()
  if landId and 0 ~= landId then
    local txtId = string.format("\229\189\147\229\137\141\229\156\176\229\157\151\231\188\150\229\143\183: %d", landId)
    local landInfoTxt = self:GetLandInfoTxtById(landId)
    Ctx:SetContent(string.format([[
%s
%s]], txtId, landInfoTxt))
    local landInfo = FarmUtils.GetLandInfo(landId)
    if landInfo then
      NRCModuleManager:DoCmd(_G.DebugModuleCmd.ShowTable, landInfo, "Single land Info")
    end
  else
    Ctx:SetContent("\230\178\161\230\156\137\231\171\153\229\156\168\229\156\176\229\157\151\228\184\138")
  end
  Ctx:SetMode(DialogContext.Mode.OK)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function DebugTabFarm:GetLandInfoTxtById(landId)
  local txtInfo = ""
  if landId and 0 ~= landId then
    local landInfo = FarmUtils.GetLandInfo(landId)
    Log.Dump(landInfo, 3, string.format("Show landInfo %d", landId))
    if landInfo then
      local plant_seed_id = string.format("\228\189\156\231\137\169\231\188\150\229\143\183: %d", landInfo.plant_seed_id)
      local plant_actor_id = string.format("\228\189\156\231\137\169ActorId: %d", landInfo.plant_actor_id)
      local plant_tab_id = string.format("\228\189\156\231\137\169\230\161\163\228\189\141\239\188\154%d", landInfo.plant_tab_id or 0)
      local plant_time = string.format("\231\167\141\230\164\141\230\151\182\233\151\180: %s(%d)", landInfo.plant_time > 0 and os.date("%Y-%m-%d %H:%M:%S", landInfo.plant_time) or "", landInfo.plant_time)
      local plant_rip_time = string.format("\230\148\182\232\142\183\233\156\128\232\166\129\230\151\182\233\149\191\239\188\136\229\174\158\233\153\133\239\188\137: %s(%d)", landInfo.plant_rip_time > 0 and os.date("%Y-%m-%d %H:%M:%S", landInfo.plant_rip_time) or "", landInfo.plant_rip_time - landInfo.plant_time)
      local plant_rip_cfg_time = string.format("\230\148\182\232\142\183\233\156\128\232\166\129\230\151\182\233\149\191\239\188\136\229\142\159\229\167\139\239\188\137: %s(%d)", landInfo.plant_rip_cfg_time > 0 and os.date("%Y-%m-%d %H:%M:%S", landInfo.plant_rip_cfg_time) or "", landInfo.plant_rip_cfg_time - landInfo.plant_time)
      local plant_harvest_id = string.format("\230\148\182\232\142\183\228\189\156\231\137\169Id: %d", landInfo.plant_harvest_id)
      local plant_harvest_num = string.format("\230\148\182\232\142\183\230\128\187\230\149\176\233\135\143: %d", landInfo.plant_harvest_num)
      local plant_steal_account = string.format("\229\183\178\232\162\171\229\129\183\229\143\150\231\154\132\230\149\176\233\135\143: %d", landInfo.plant_steal_account)
      local plant_water_time = string.format("\228\184\138\230\172\161\230\181\135\230\176\180\231\154\132\230\151\182\233\151\180: %s(%d)", landInfo.plant_water_time > 0 and os.date("%Y-%m-%d %H:%M:%S", landInfo.plant_water_time) or "", landInfo.plant_water_time)
      local plant_manure_time = string.format("\228\184\138\230\172\161\230\150\189\232\130\165\231\154\132\230\151\182\233\151\180:%s(%d)", landInfo.plant_manure_time > 0 and os.date("%Y-%m-%d %H:%M:%S", landInfo.plant_manure_time) or "", landInfo.plant_manure_time)
      local land_op = FarmUtils.GetLandOptionStatus(landId)
      local land_op_str = string.format("\229\156\176\229\157\151\229\143\175\231\148\168\230\147\141\228\189\156\239\188\136\233\153\164\233\147\178\233\153\164\228\187\165\229\164\150\239\188\137: %s", FarmUtils.GetLandOpStr(land_op))
      txtInfo = string.format([[
%s
%s
%s
%s
%s
%s
%s
%s, %s
%s
%s
%s]], plant_seed_id, plant_actor_id, plant_tab_id, plant_time, plant_rip_time, plant_rip_cfg_time, plant_harvest_id, plant_harvest_num, plant_steal_account, plant_water_time, plant_manure_time, land_op_str)
    end
  end
  return txtInfo
end

return DebugTabFarm
