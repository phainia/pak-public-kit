local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = DebugTabBase
local DebugTabSceneIndoor = Base:Extend("DebugTabSceneIndoor")

function DebugTabSceneIndoor:Ctor()
  Base.Ctor(self)
end

function DebugTabSceneIndoor:SetupTabs()
  local dgnCfgs = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.DUNGEON_CONF):GetAllDatas()
  for _, dgnCfg in pairs(dgnCfgs) do
    if dgnCfg.name then
      local nameType = "\229\174\164\229\134\133"
      if string.find(dgnCfg.name, nameType) and dgnCfg.region_name ~= "A1" and dgnCfg.region_name ~= "A2" and dgnCfg.region_name ~= "A3" then
        self:Add(string.format([[
%d
%s]], dgnCfg.id, dgnCfg.name), function(Owner, name, panel)
          panel:DoClose()
          self:_EnableOrDisablePlayerInputState(false)
          local open_dungeon_req = ProtoMessage.newZoneGmOpenDungeonReq()
          open_dungeon_req.dungeon_cfg_id = dgnCfg.id
          Log.Warning("GM Open Dungeon:", open_dungeon_req.dungeon_cfg_id, dgnCfg.name)
          ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_OPEN_DUNGEON_REQ, open_dungeon_req, self, self._OnOpenDungeonRsp, true)
        end, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "\229\188\128\229\144\175\229\137\175\230\156\172")
      end
    end
  end
  self:Add("\230\156\172\229\156\176\228\188\160\233\128\129\nB1\229\174\164\229\134\133-\231\148\159\230\128\129\231\164\190", self.EnterIndoorB110, self, nil, "\231\190\142\230\156\175\233\170\140\230\148\182", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\156\172\229\156\176\228\188\160\233\128\129\nB1\229\174\164\229\134\133-\231\164\188\230\139\156\230\149\153\229\160\130", self.EnterIndoorB119, self, nil, "\231\190\142\230\156\175\233\170\140\230\148\182", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\156\172\229\156\176\228\188\160\233\128\129\nB1\229\174\164\229\134\133-\230\128\170\232\176\136\231\164\190", self.EnterIndoorB112, self, nil, "\231\190\142\230\156\175\233\170\140\230\148\182", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\156\172\229\156\176\228\188\160\233\128\129\n\229\153\169\230\162\166\230\162\166\229\162\131\239\188\136\229\185\191\229\156\186\239\188\137", self.EnterIndoorB1Nightmare, self, nil, "\231\190\142\230\156\175\233\170\140\230\148\182", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\156\172\229\156\176\228\188\160\233\128\129\nB1\229\174\164\229\134\133-\229\173\166\233\153\162\229\164\167\229\142\133", self.EnterIndoorB109, self, nil, "\231\190\142\230\156\175\233\170\140\230\148\182", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\156\172\229\156\176\228\188\160\233\128\129\nPlotB1\229\164\167\229\142\133\229\164\150\229\177\130", self.EnterPlotB1MirrorLevel1F, self, nil, "\231\190\142\230\156\175\233\170\140\230\148\182", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\156\172\229\156\176\228\188\160\233\128\129\nPlotB1\229\185\187\229\162\1311\229\177\130", self.EnterPlotB1MirrorLevel2F, self, nil, "\231\190\142\230\156\175\233\170\140\230\148\182", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\156\172\229\156\176\228\188\160\233\128\129\nPlotB1\229\185\187\229\162\1312\229\177\130", self.EnterPlotB1MirrorLevel3F, self, nil, "\231\190\142\230\156\175\233\170\140\230\148\182", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\156\172\229\156\176\228\188\160\233\128\129\nPlotB1\229\185\187\229\162\1313\229\177\130", self.EnterPlotB1MirrorLevel4F, self, nil, "\231\190\142\230\156\175\233\170\140\230\148\182", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\156\172\229\156\176\228\188\160\233\128\129\nA2\229\174\164\229\134\133-\228\190\166\230\142\162\231\164\190", self.EnterIndoorA203, self, nil, "\231\190\142\230\156\175\233\170\140\230\148\182", "\231\137\185\233\156\128", nil, "")
  self:Add("\230\156\172\229\156\176\228\188\160\233\128\129\n\228\184\180\230\151\182-\233\163\142\231\156\160\229\156\163\230\137\128", self.EnterDungeonfengmianshengsuo, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\228\188\160\233\128\129\232\135\179\230\151\182\232\163\133\229\186\151", self.TeleportToClothesShop, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\228\188\160\233\128\129\232\135\179\233\129\147\229\133\183\229\186\151", self.TeleportToItemShop, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\228\188\160\233\128\129\232\135\179\229\173\166\233\153\162\229\164\167\229\142\133", self.TeleportToSchoolHall, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\228\188\160\233\128\129\232\135\179\231\148\159\230\128\129\231\164\190", self.TeleportToEcologicalSociety, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\228\188\160\233\128\129\232\135\179\233\173\148\230\179\149\229\173\166\233\153\162", self.TeleportToMagicSchool, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\228\188\160\233\128\129\232\135\179\229\164\167\228\184\150\231\149\140A1\229\140\186\229\159\159", self.TeleportToBigWorldA1, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\228\188\160\233\128\129\232\135\179\233\128\154\231\148\168\230\149\153\229\174\164", self.TeleportToGeneralClassroom, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\228\188\160\233\128\129\232\135\179\230\128\170\232\176\136\231\164\190", self.TeleportToGhostStoryClub, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\228\188\160\233\128\129\232\135\179\231\164\188\230\139\156\230\149\153\229\160\130", self.TeleportToChurch, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\228\188\160\233\128\129\232\135\179\228\190\166\230\142\162\231\164\190", self.TeleportToDetectiveClub, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
end

function DebugTabSceneIndoor:DummyRsp()
end

function DebugTabSceneIndoor:_EnableOrDisablePlayerInputState(enable)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if nil == localPlayer then
    return
  end
  localPlayer.inputComponent:SetInputEnable(self, enable)
  localPlayer.inputComponent:SetCameraControlEnable(self, enable)
end

function DebugTabSceneIndoor:_OnOpenDungeonRsp(rsp)
  self:_EnableOrDisablePlayerInputState(true)
end

function DebugTabSceneIndoor:EnterIndoorB110(name, panel)
  NRCModeManager:ActiveMode("LocalMode")
  _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/Indoor/B1/L_Indoor_B1_10")
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneIndoor:EnterIndoorB119(name, panel)
  NRCModeManager:ActiveMode("LocalMode")
  _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/Indoor/B1/L_Indoor_B1_19")
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneIndoor:EnterIndoorB112(name, panel)
  NRCModeManager:ActiveMode("LocalMode")
  _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/Indoor/B1/L_Indoor_B1_12")
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneIndoor:EnterIndoorB1Nightmare(name, panel)
  NRCModeManager:ActiveMode("LocalMode")
  _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/Indoor/B1/L_Indoor_B1_Nightmare")
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneIndoor:EnterIndoorB109(name, panel)
  NRCModeManager:ActiveMode("LocalMode")
  _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/Indoor/B1/L_Indoor_B1_09")
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneIndoor:EnterPlotB1MirrorLevel1F(name, panel)
  NRCModeManager:ActiveMode("LocalMode")
  _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/Plot/B1/L_Plot_B1_MirrorLevel1F")
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneIndoor:EnterPlotB1MirrorLevel2F(name, panel)
  NRCModeManager:ActiveMode("LocalMode")
  _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/Plot/B1/L_Plot_B1_MirrorLevel2F")
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneIndoor:EnterPlotB1MirrorLevel3F(name, panel)
  NRCModeManager:ActiveMode("LocalMode")
  _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/Plot/B1/L_Plot_B1_MirrorLevel3F")
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneIndoor:EnterPlotB1MirrorLevel4F(name, panel)
  NRCModeManager:ActiveMode("LocalMode")
  _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/Plot/B1/L_Plot_B1_MirrorLevel4F")
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneIndoor:EnterIndoorA203(name, panel)
  NRCModeManager:ActiveMode("LocalMode")
  _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/Indoor/A2/L_Indoor_A2_03")
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneIndoor:EnterDungeonfengmianshengsuo(name, panel)
  NRCModeManager:ActiveMode("LocalMode")
  _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Game/Dungeon/Dungeon_FengMianShengSuo_01/Dungeon_FengMianShengSuo_01_MainRelease")
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
  if panel then
    panel:DoClose()
  end
end

function DebugTabSceneIndoor:TeleportToClothesShop()
  self:Teleport("103;-987500,937500,0,280")
end

function DebugTabSceneIndoor:TeleportToItemShop()
  self:Teleport("103;-986953,987973,0,240")
end

function DebugTabSceneIndoor:TeleportToSchoolHall()
  self:Teleport("103;-987718,837975,-10")
end

function DebugTabSceneIndoor:TeleportToEcologicalSociety()
  self:Teleport("103;-992423,889944,10027")
end

function DebugTabSceneIndoor:TeleportToMagicSchool()
  self:Teleport("103;-798617,-774567,29694,180")
end

function DebugTabSceneIndoor:TeleportToBigWorldA1()
  self:Teleport("103;426660,666747,818")
end

function DebugTabSceneIndoor:TeleportToGeneralClassroom()
  self:Teleport("103;-987500,737500,189")
end

function DebugTabSceneIndoor:TeleportToGhostStoryClub()
  self:Teleport("103;-987510,789440,189")
end

function DebugTabSceneIndoor:TeleportToChurch()
  self:Teleport("103;-989963,687495,-10")
end

function DebugTabSceneIndoor:TeleportToDetectiveClub()
  self:Teleport("103;-987870,636130,0")
end

function DebugTabSceneIndoor:Teleport(teleportText)
  local teleReq = ProtoMessage.newZoneSceneGmTeleportReq()
  local inputText = teleportText
  teleReq.to_scene_cfg_id = SceneUtils.GetSceneID()
  local sceneCfgIdSepPos = string.find(inputText, ";")
  local firstPosVecSepPos = string.find(inputText, ",")
  if sceneCfgIdSepPos or not firstPosVecSepPos then
    if sceneCfgIdSepPos then
      teleReq.to_scene_cfg_id = tonumber(string.sub(inputText, 1, sceneCfgIdSepPos - 1))
      inputText = string.sub(inputText, sceneCfgIdSepPos + 1)
    elseif tonumber(inputText) then
      teleReq.to_scene_cfg_id = tonumber(inputText)
      inputText = ""
    end
  end
  local posVecs = string.split(inputText, ",")
  local posVecsLen = #posVecs
  local toPoint = teleReq.to_point
  if posVecsLen >= 2 then
    toPoint.pos.x = tonumber(posVecs[1])
    toPoint.pos.y = tonumber(posVecs[2])
  end
  if posVecsLen >= 3 then
    toPoint.pos.z = tonumber(posVecs[3])
  end
  if posVecsLen >= 4 then
    toPoint.dir.x = 0
    toPoint.dir.y = 0
    toPoint.dir.z = tonumber(posVecs[4])
  end
  Log.DebugFormat("Teleport, toSceneCfgId:%s, toPos:(%s,%s,%s), toDirZ:%s", teleReq.to_scene_cfg_id, toPoint.pos.x, toPoint.pos.y, toPoint.pos.z, toPoint.dir.z)
  ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_TELEPORT_REQ, teleReq, self, self._OnTeleportRsp, false, true)
end

function DebugTabSceneIndoor:_OnTeleportRsp(rsp)
  self:ClosePanel()
  local retCode = rsp.ret_info.ret_code
  if 0 ~= retCode then
    Log.Error("Teleport failed")
    local promptTxt = string.format("\228\188\160\233\128\129\229\164\177\232\180\165, \233\148\153\232\175\175\231\160\129:%s", retCode)
    self:_ShowOKMsgBox(promptTxt)
    return
  end
  Log.Debug("Teleport succeed!")
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerLoc = player.viewObj:Abs_K2_GetActorLocation()
  local promptTxt = string.format("\228\188\160\233\128\129\230\136\144\229\138\159\n\229\156\186\230\153\175:%d\n\228\189\141\231\189\174:(%.0f, %.0f, %.0f)", SceneUtils.GetSceneID(), playerLoc.X, playerLoc.Y, playerLoc.Z)
  UE4.UNRCStatics.ClipboardCopy(string.format("(X=%.0f,Y=%.0f,Z=%.0f)", playerLoc.X, playerLoc.Y, playerLoc.Z))
  self:_ShowOKMsgBox(promptTxt)
end

function DebugTabSceneIndoor:_ShowOKMsgBox(txt)
  local dlgCtx = DialogContext()
  dlgCtx:SetContent(txt)
  dlgCtx:SetMode(DialogContext.Mode.OK)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, dlgCtx)
end

return DebugTabSceneIndoor
