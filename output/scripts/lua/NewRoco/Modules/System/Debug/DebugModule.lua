_G.DebugModuleCmd = reload("NewRoco.Modules.System.Debug.DebugModuleCmd")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local DebugModuleEvent = reload("NewRoco.Modules.System.Debug.DebugModuleEvent")
local JsonUtils = require("Common.JsonUtils")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local DebugModule = NRCModuleBase:Extend("DebugModule")

function DebugModule:OnConstruct()
  self:Log("OnConstruct")
  self.isLocalRecording = false
  self.isAutoMoving = false
  self.isAddCachedDebugData = false
  self.moveDatas = nil
  self.CachedDebugData = {}
  self.CurrentActorNum = false
  self.History = {}
  self.allShowMultipleArea = {}
  self.result = ""
  self.IsLoop = false
  self.Delegate = nil
  self.call = nil
  self.BaseId = nil
  self.rolePlayItem = nil
  local LoginConfig = require("NewRoco.Modes.LoginMode.LoginConfig")
  self.KeyPointconfig = LoginConfig.GetRecord("KeyPointConf.non")
  self.TeleportTime = 200
  self.CurrentIndex = 1
  self.KeyPointPosition = {}
  for i, v in pairs(self.KeyPointconfig) do
    table.insert(self.KeyPointPosition, {name = i, pos = v})
  end
  self.bShowHudPetInfo = false
  self.NPCList = {}
  self.NPCList.Anni = {
    NPCID = 62218,
    ConfID = 2201309,
    AutoPlayActionId = 6221801
  }
  self.NPCList.PiKa = {
    NPCID = 61006,
    ConfID = 506006,
    AutoPlayActionId = 6100601,
    AutoPlayActionId1 = 6100602
  }
  self.NPCList.PiKa1 = {
    NPCID = 62123,
    ConfID = 2201149,
    AutoPlayActionId = 6212301
  }
  self.NPCList.BoDe = {NPCID = 20000, ConfID = 506000}
  self.NPCList.MianXiao = {NPCID = 13074, ConfID = 1300001}
  self.NPCList.Camp = {NPCID = 60280, ConfID = 1200492}
  self.NPCList.Alchemy = {NPCID = 65324, ConfID = 140002}
  self.GMPetCounterPercentage = {}
  self.ReDebugPanelLock()
  self.data = self:SetData("DebugModuleData", "NewRoco.Modules.System.Debug.DebugModuleData")
  self:RegisterCmd(_G.DebugModuleCmd.Open, self.Open)
  self:RegisterCmd(_G.DebugModuleCmd.OpenLocalBattleDebug, self.OpenLocalBattleDebug)
  self:RegisterCmd(_G.DebugModuleCmd.ShowTable, self.ShowLuaTable)
  self:RegisterCmd(_G.DebugModuleCmd.OpenOrClosePanel, self.OnCmdOpenOrClosePanel)
  self:RegisterCmd(_G.DebugModuleCmd.SetHistory, self.OnCmdSetHistory)
  self:RegisterCmd(_G.DebugModuleCmd.GetHistory, self.OnCmdGetHistory)
  self:RegisterCmd(_G.DebugModuleCmd.RefreshHistory, self.RefreshHistory)
  self:RegisterCmd(_G.DebugModuleCmd.ClearResult, self.OnCmdClearResult)
  self:RegisterCmd(_G.DebugModuleCmd.ShortcutKeyMatching, self.OnCmdShortcutKeyMatching)
  self:RegisterCmd(_G.DebugModuleCmd.OpenCachedDebugData, self.DOpenCachedDebugData)
  self:RegisterCmd(_G.DebugModuleCmd.AddCachedDebugData, self.DAddCachedDebugData)
  self:RegisterCmd(_G.DebugModuleCmd.DeleteFileCMD, self.OnCmdDeleteFileCMD)
  self:RegisterCmd(_G.DebugModuleCmd.SetSvrTime, self.SetSvrTime)
  self:RegisterCmd(_G.DebugModuleCmd.ShowPlayerLoction, self.ShowPlayerLoction)
  self:RegisterCmd(_G.DebugModuleCmd.ShowTimeAndWeather, self.OnCmdShowTimeAndWeather)
  self:RegisterCmd(_G.DebugModuleCmd.RefreshWeather, self.OnCmdRefreshWeather)
  self:RegisterCmd(_G.DebugModuleCmd.ShowVisiblePoolInfo, self.OnCmdShowVisiblePoolInfo)
  self:RegisterCmd(_G.DebugModuleCmd.ShowDungeonStageInfo, self.OnCmdShowDungeonStageInfo)
  self:RegisterCmd(_G.DebugModuleCmd.ShowOrHideDungeonStageInfoText, self.OnCmdShowOrHideDungeonStageInfoText)
  self:RegisterCmd(_G.DebugModuleCmd.RefreshVisiblePoolInfo, self.OnCmdRefreshVisiblePoolInfo)
  self:RegisterCmd(_G.DebugModuleCmd.OpenDebugHomePetPopUp, self.OnCmdOpenDebugHomePetPopUp)
  self:RegisterCmd(_G.DebugModuleCmd.SetGMPetCounterPercentage, self.OnCmdSetGMPetCounterPercentage)
  self:RegisterCmd(_G.DebugModuleCmd.GetGMPetCounterPercentage, self.OnCmdGetGMPetCounterPercentage)
  self:RegisterCmd(_G.DebugModuleCmd.ClearGMPetCounterPercentage, self.OnCmdClearGMPetCounterPercentage)
  self:RegisterCmd(_G.DebugModuleCmd.SetTemperature, self.OnCmdSetTemperature)
  self:RegisterCmd(_G.DebugModuleCmd.ShowTemperature, self.OnCmdShowTemperature)
  self:RegisterCmd(_G.DebugModuleCmd.OpenTuiIconTest, self.OnCmdOpenTuiIconTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenTuiFontTest, self.OnCmdOpenTuiFontTest)
  self:RegisterCmd(_G.DebugModuleCmd.OnIconTextItemSelected, self.OnCmdIconTextItemSelected)
  self:RegisterCmd(_G.DebugModuleCmd.OnIconTextItemSelected1, self.OnCmdIconTextItemSelected1)
  self:RegisterCmd(_G.DebugModuleCmd.OpenWB_FontTest, self.OnCmdOpenWB_FontTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenWB_FontTest1, self.OnCmdOpenWB_FontTest1)
  self:RegisterCmd(_G.DebugModuleCmd.OpenWB_FontTest2, self.OnCmdOpenWB_FontTest2)
  self:RegisterCmd(_G.DebugModuleCmd.OpenWB_FontTestIOS1, self.OnCmdOpenWB_FontTestIOS1)
  self:RegisterCmd(_G.DebugModuleCmd.OpenWB_FontTestIOS2, self.OnCmdOpenWB_FontTestIOS2)
  self:RegisterCmd(_G.DebugModuleCmd.OpenLuaErrorPanel, self.OpenLuaErrorPanel)
  self:RegisterCmd(_G.DebugModuleCmd.TryCloseControlText, self.TryCloseControlText)
  self:RegisterCmd(_G.DebugModuleCmd.ShowActorNum, self.ShowActorNum)
  self:RegisterCmd(_G.DebugModuleCmd.ToggleNPCStat, self.ToggleNPCStat)
  self:RegisterCmd(_G.DebugModuleCmd.Tips_ShowZoneTip, self.OnShowZoneTip)
  self:RegisterCmd(_G.DebugModuleCmd.OpenPetAdjustVisualTool, self.OpenPetAdjustVisualTool)
  self:RegisterCmd(_G.DebugModuleCmd.ClosePetAdjustVisualTool, self.OnClosePetAdjustVisualTool)
  self:RegisterCmd(_G.DebugModuleCmd.UpdateVisualToolParam, self.OnUpdateVisualToolParam)
  self:RegisterCmd(_G.DebugModuleCmd.OpenPetUIAdjustTool, self.OpenPetUIAdjustTool)
  self:RegisterCmd(_G.DebugModuleCmd.SetNewOffsetInfo, self.OnSetNewOffsetInfo)
  self:RegisterCmd(_G.DebugModuleCmd.GetCharacterDesignSketch, self.OnCmdGetCharacterDesignSketch)
  self:RegisterCmd(_G.DebugModuleCmd.NPCPressure, self.OnNPCPressure)
  self:RegisterCmd(_G.DebugModuleCmd.LuaWriteGMDataToConfig, self.LuaWriteGMDataToConfig)
  self:RegisterCmd(_G.DebugModuleCmd.GetGMPanel, self.GetGMPanel)
  self:RegisterCmd(_G.DebugModuleCmd.OpenRuntimeDebugConfig, self.OpenRuntimeDebugConfig)
  self:RegisterCmd(_G.DebugModuleCmd.OpenRuntimeDebugSkill, self.OpenRuntimeDebugSkill)
  self:RegisterCmd(_G.DebugModuleCmd.ExecGMGroup, self.ExecGMGroup)
  self:RegisterCmd(_G.DebugModuleCmd.ShowPerfStutter, self.ShowPerfStutter)
  self:RegisterCmd(_G.DebugModuleCmd.GmOpenAnnouncement, self.CmdGmOpenAnnouncement)
  self:RegisterCmd(_G.DebugModuleCmd.SetShowHudPetInfoFlg, self.SetShowHudPetInfoFlg)
  self:RegisterCmd(_G.DebugModuleCmd.OpenNeedNpcPanel, self.OpenNeedNpcPanel)
  self:RegisterCmd(_G.DebugModuleCmd.OpenAnNiNpcShopPanel, self.OpenNeedNpcShopPanel)
  self:RegisterCmd(_G.DebugModuleCmd.OpenPikaNpcShopPanel, self.OpenPikaNpcShopPanel)
  self:RegisterCmd(_G.DebugModuleCmd.OpenPika1NpcShopPanel, self.OpenPika1NpcShopPanel)
  self:RegisterCmd(_G.DebugModuleCmd.OpenBattleMainTest, self.OpenBattleMainTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenSceneMatchStartTest, self.OpenSceneMatchStartTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenChatMainPanelTest, self.OpenChatMainPanelTest)
  self:RegisterCmd(_G.DebugModuleCmd.OnOpenChangeCardLabelTest, self.OnOpenChangeCardLabelTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenChangeCardBGTest, self.OpenChangeCardBGTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenEnterPanelTest, self.OpenEnterPanelTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenRecoveryTimeTest, self.OpenRecoveryTimeTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenLobbyInnerPanelTest, self.OpenLobbyInnerPanelTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenPreWarInfoPanelTest, self.OpenPreWarInfoPanelTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenTravelPanelTest, self.OpenTravelPanelTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenFastLoadingUITest, self.OpenFastLoadingUITest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenLoadingUITest, self.OpenLoadingUITest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenRepairToolsPanelTest, self.OpenRepairToolsPanelTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenMagicExtractPanelTest, self.OpenMagicExtractPanelTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenScrapBookPanelTest, self.OpenScrapBookPanelTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenNightmarePotionPanelTest, self.OpenNightmarePotionPanelTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenUpdateUIPanelTest, self.OpenUpdateUIPanelTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenTailorShopTest, self.OpenTailorShopTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenTreasureSpotTest, self.OpenTreasureSpotTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenPVPFirstRewardTest, self.OpenPVPFirstRewardTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenPetRightPanelTest, self.OpenPetRightPanelTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenHomePetChoosingTest, self.OpenHomePetChoosingTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenHomeFurnitureCreationTest, self.OpenHomeFurnitureCreationTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenHomeExpandPanelTest, self.OpenHomeExpandPanelTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenFriendBlackListTest, self.OpenFriendBlackListTest)
  self:RegisterCmd(_G.DebugModuleCmd.OnClickPhotoTest, self.OnClickPhotoTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenPVPHistoricalRecordTest, self.OpenPVPHistoricalRecordTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenPVPDailyChallengeTest, self.OpenPVPDailyChallengeTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenPVPCuttoTest, self.OpenPVPCuttoTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenHomeLevelRewardPanelTest, self.OpenHomeLevelRewardPanelTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenSeedBagTest, self.OpenSeedBagTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenHomeVisitPanelTest, self.OpenHomeVisitPanelTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenAppearanceUpgradeTest, self.OpenAppearanceUpgradeTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenMagicVideoDetailsTest, self.OpenMagicVideoDetailsTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenLeveBattleSilhouetteTest, self.OpenLeveBattleSilhouetteTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenBeautyLoginPanelTest, self.OpenBeautyLoginPanelTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenDisplayCutoutAdjustPanel, self.OpenDisplayCutoutAdjustPanel)
  self:RegisterCmd(_G.DebugModuleCmd.SwitchDebugEntryBattle, self.SwitchDebugEntryBattle)
  self:RegisterCmd(_G.DebugModuleCmd.CloseDebugEntryBattle, self.CloseDebugEntryBattle)
  self:RegisterCmd(_G.DebugModuleCmd.OpenSwapEggsTest, self.OpenSwapEggsTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenBattlePVPResultPanelTest, self.OpenBattlePVPResultPanelTest)
  self:RegisterCmd(_G.DebugModuleCmd.OpenGameVideoPlayer, self.OpenGameVideoPlayer)
  self:RegisterCmd(_G.DebugModuleCmd.CloseGameVidePlayer, self.CloseGameVideoPlayer)
  self:RegisterCmd(_G.DebugModuleCmd.OpenLeveBattleArrayTest, self.CmdOpenLeveBattleArrayTest)
  self:RegisterCmd(_G.DebugModuleCmd.SetAllShowMultipleArea, self.SetAllShowMultipleArea)
  self:RegisterCmd(_G.DebugModuleCmd.GetAllShowMultipleArea, self.GetAllShowMultipleArea)
  self:RegisterCmd(_G.DebugModuleCmd.OpenDebugGmTips, self.OnCmoOpenDebugGmTips)
  self:RegisterCmd(_G.DebugModuleCmd.GMExecCommGmCmd, self.OnCmdGMExecCommGmCmd)
  self:RegisterCmd(_G.DebugModuleCmd.GetTabData, self.GetTabData)
  self:RegisterCmd(_G.DebugModuleCmd.OpenBattleTestSkillListWidget, self.OpenBattleTestSkillListWidget)
  self:RegisterCmd(_G.DebugModuleCmd.GetBattleTestSkillListWidget, self.GetBattleTestSkillListWidget)
  self:RegisterCmd(_G.DebugModuleCmd.CheckIsInPhotoEditorMode, self.CheckIsInPhotoEditorMode)
  self:RegisterCmd(_G.DebugModuleCmd.ReportPetUIAdjustTool, self.ReportPetUIAdjustTool)
  self:RegisterCmd(_G.DebugModuleCmd.OpenClothingScreenRecordingTips, self.OnCmdOpenClothingScreenRecordingTips)
  self:RegisterCmd(_G.DebugModuleCmd.OpenDebugTips, self.OnCmdOpenDebugTips)
  self:RegisterCmd(_G.DebugModuleCmd.GmSetFashionSuit, self.OnCmdGmSetFashionSuit)
  self:RegisterCmd(_G.DebugModuleCmd.PetTeamFriendGetMirrorPetData, self.OnCmdPetTeamFriendGetMirrorPetData)
  self:RegisterCmd(_G.DebugModuleCmd.AddRewardInfo, self.OnCmdAddRewardInfo)
  self:RegisterCmd(_G.DebugModuleCmd.SetLoop, self.OnCmdSetLoop)
  self:RegisterCmd(_G.DebugModuleCmd.TryClearTabCache, self.TryClearTabCache)
  self:RegisterCmd(_G.DebugModuleCmd.SwitchDebugDrawSyncAura, self.SwitchDebugDrawSyncAura)
  self:RegisterCmd(_G.DebugModuleCmd.ClientSceneDebugDrawCall, self.ClientSceneDebugDrawCall)
  _G.NRCEventCenter:RegisterEvent("DebugModule", self, DebugModuleEvent.StopRpBehavior, self.OnStopRpBehavior)
  self:RegPanel("DebugEntry", "/Game/NewRoco/Modules/System/Debug/Res/UMG_DebugEntry")
  self:RegPanel("DebugPanel", "/Game/NewRoco/Modules/System/Debug/Res/UMG_DebugPanel")
  self:RegPanel("DebugHomePetPopUp", "/Game/NewRoco/Modules/System/Debug/Res/UMG_DebugHomePetPopup")
  self:RegPanel("TUIFontTEST", "/Game/NewRoco/Modules/System/Debug/Res/UMG_TUIFontTest")
  self:RegPanel("DebugLocalBattle", "/Game/NewRoco/Modules/System/Debug/Res/UMG_LocalBattle_Debug_Panel")
  self:RegPanel("LuaTableReflector", "/Game/NewRoco/Modules/System/Debug/Res/UMG_LuaTableReflector")
  self:RegPanel("DebugEntryBattle", "/Game/NewRoco/Modules/System/Debug/Res/UMG_DebugEntry_Battle")
  self:RegPanel("WB_FontTest", "/Game/NewRoco/Modules/System/Debug/Res/NewRoco/WB_FontTest")
  self:RegPanel("WB_FontTest1", "/Game/NewRoco/Modules/System/Debug/Res/NewRoco/WB_FontTest1")
  self:RegPanel("WB_FontTest2", "/Game/NewRoco/Modules/System/Debug/Res/NewRoco/WB_FontTest2")
  self:RegPanel("WB_FontTestIOS1", "/Game/NewRoco/Modules/System/Debug/Res/NewRoco/WB_FontTestIOS1")
  self:RegPanel("WB_FontTestIOS2", "/Game/NewRoco/Modules/System/Debug/Res/NewRoco/WB_FontTestIOS2")
  self:RegPanel("UMG_ErrorPanel", "/Game/NewRoco/Modules/System/Debug/Res/ErrorPanel/UMG_ErrorPanel")
  self:RegPanel("PetAdjustVisualTool", "/Game/NewRoco/Modules/System/Debug/Res/UMG_PetModelAdjust_DebugPanel")
  self:RegPanel("PetUIAdjustTool", "/Game/NewRoco/Modules/System/Debug/Res/UMG_PetUIAdjust_DebugPanel")
  self:RegPanel("RuntimeDebugConfig", "/Game/NewRoco/Modules/System/BattleUI/Res/BattleDebugger/UMG_Battle_RuntimeDebug_Config_Panel")
  self:RegPanel("RuntimeDebugSkill", "/Game/NewRoco/Modules/System/BattleUI/Res/BattleDebugger/UMG_Battle_RuntimeDebug_Skill_Panel")
  self:RegPanel("DisplayCutoutAdjust", "/Game/NewRoco/Modules/System/Debug/Res/UMG_DisplayCutoutAdjust_DebugPanel")
  self:RegPanel("UMG_TestRecordViedeo", "/Game/NewRoco/Modules/System/Debug/Res/UMG_TestRecordVideo")
  self:RegPanel("DebugGmTips", "/Game/NewRoco/Modules/System/Debug/Res/CommonGM/UMG_DebugGmTips")
  self:RegPanel("UMG_BattleSkillList", "/Game/NewRoco/Modules/System/BattleUI/Res/Skill/UMG_Battle_Skill_List")
  self:RegPanel("StarLightPhotoEditor", "/Game/NewRoco/Modules/System/Debug/Res/StarLightPhotoEditor")
  self:RegPanel("ReportPetAdjustVisualTool", "/Game/NewRoco/Modules/System/Debug/Res/UMG_ReportPetUIAdjust_DebugPanel")
  self:RegPanel("ClothingScreenRecordingTips", "/Game/NewRoco/Modules/System/Debug/Res/ClothingScreenRecording/UMG_ClothingScreenRecordingTips")
  self:RegPanel("DebugTips", "/Game/NewRoco/Modules/System/Debug/Res/ClothingScreenRecording/UMG_DebugTips")
end

function DebugModule:OnCmdIconTextItemSelected(iconName)
  self:DispatchEvent(DebugModuleEvent.OnIconTextItemSelected, iconName)
end

function DebugModule:OnCmdIconTextItemSelected1(iconName)
  self:DispatchEvent(DebugModuleEvent.OnIconTextItemSelected1, iconName)
end

function DebugModule:ReDebugPanelLock()
  JsonUtils.DumpSaved("LockSeting", {
    true,
    true,
    "",
    ""
  })
end

function DebugModule:OnCmdOpenTuiIconTest()
end

function DebugModule:OnCmdOpenWB_FontTest()
  self:OpenPanel("WB_FontTest")
end

function DebugModule:OnCmdOpenWB_FontTest1()
  self:OpenPanel("WB_FontTest1")
end

function DebugModule:OnCmdOpenWB_FontTest2()
  self:OpenPanel("WB_FontTest2")
end

function DebugModule:OnCmdOpenWB_FontTestIOS1()
  self:OpenPanel("WB_FontTestIOS1")
end

function DebugModule:OnCmdOpenWB_FontTestIOS2()
  self:OpenPanel("WB_FontTestIOS2")
end

function DebugModule:OnCmdOpenTuiFontTest()
  self:OpenPanel("TUIFontTEST")
end

function DebugModule:OpenLuaErrorPanel(ErrorString, ErrorTrace)
  local bEnableLuaDebugPanel = UE4.UNRCStatics.EnableLuaDebugPanel()
  if _G.GlobalConfig.CloseDebugPanel or not bEnableLuaDebugPanel then
    return
  else
    self:OpenPanel("UMG_ErrorPanel", ErrorString, ErrorTrace)
  end
end

function DebugModule:TryCloseControlText()
  self:DispatchEvent(DebugModuleEvent.CloseControlText)
end

function DebugModule:OpenLocalBattleDebug()
  self:OpenPanel("DebugLocalBattle")
end

function DebugModule:OpenRuntimeDebugConfig()
  self:OpenPanel("RuntimeDebugConfig")
end

function DebugModule:OpenRuntimeDebugSkill()
  local panelName = "RuntimeDebugSkill"
  if self:HasPanel(panelName) then
    local panel = self:GetPanel(panelName)
    if panel then
      panel:Enable()
      return
    end
  end
  self:OpenPanel(panelName)
end

function DebugModule:SwitchDebugEntryBattle()
  if _G.BattleManager:IsInBattle() then
    local hasPanel = self:HasPanel("DebugEntryBattle")
    if hasPanel then
      local panel = self:GetPanel("DebugEntryBattle")
      panel:OnCmdSendZoneBattleGmReq()
    else
      self:OpenPanel("DebugEntryBattle")
    end
  end
end

function DebugModule:OpenBattlePVPResultPanelTest()
  _G.GlobalConfig.DebugOpenUI = true
  NRCModeManager:GetCurMode():DisablePanelByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.OpenBattlePVPResultPanel)
end

function DebugModule:OpenSwapEggsTest()
  _G.GlobalConfig.DebugOpenUI = true
  _G.NRCModuleManager:DoCmd(BagModuleCmd.OpenSwapEggsUI)
end

function DebugModule:CloseDebugEntryBattle()
  self:ClosePanel("DebugEntryBattle")
end

function DebugModule:RegPanel(name, path)
  local PanelData = NRCPanelRegisterData()
  PanelData.panelName = name
  PanelData.panelPath = path
  PanelData.panelLayer = _G.Enum.UILayerType.UI_LAYER_DEBUG
  PanelData.enablePcEsc = false
  self:RegisterPanel(PanelData)
end

function DebugModule:Open(arg)
  if RocoEnv.IS_SHIPPING and not _G.AppMain:HasLaunchParams() then
    return
  end
  if self:HasPanel("DebugPanel") then
    self:ClosePanel("DebugPanel")
  else
    self:OpenPanel("DebugPanel")
  end
end

function DebugModule:OnCmdOpenOrClosePanel(_IsClose)
  if RocoEnv.IS_SHIPPING and not _G.AppMain:HasLaunchParams() then
    return
  end
  Log.Debug(_IsClose, "DebugModule:OpenOrClosePanel")
  if _IsClose then
    self:OpenPanel("DebugPanel")
  else
    self:ClosePanel("DebugPanel")
  end
end

function DebugModule:OnCmdSetHistory(GMCommand)
  local historyMessage = string.format("%s", GMCommand)
  table.insert(self.History, 1, historyMessage)
  local resultMessage = ""
  for i = 1, #self.History do
    local result = self.History[i]
    if 1 == i then
      resultMessage = string.format("%s%s", resultMessage, result)
    else
      resultMessage = string.format([[
%s
%s]], resultMessage, result)
    end
  end
  self:DispatchEvent(DebugModuleEvent.RefreshResult, resultMessage)
  self.result = resultMessage
end

function DebugModule:OnCmdGetHistory()
  return self.result
end

function DebugModule:RefreshHistory()
  self:DispatchEvent(DebugModuleEvent.RefreshHistory)
end

function DebugModule:OnCmdClearResult()
  self.History = {}
  self.result = ""
end

function DebugModule:OnCmdShortcutKeyMatching(_KeyDict)
  if RocoEnv.IS_SHIPPING then
    return
  end
  local ShortcutKeyList = self.data:GetShortcutKey()
  local IsMatchingSucceed
  for i, ShortcutKey in ipairs(ShortcutKeyList) do
    IsMatchingSucceed = true
    if _KeyDict and #_KeyDict > 0 and ShortcutKeyList[2] and #ShortcutKeyList[2] > 0 and #_KeyDict == #ShortcutKey[2] then
      for j, Key in ipairs(_KeyDict) do
        local ShortcutKeyUpper = string.upper(ShortcutKey[2][j])
        local KeyUpper = string.upper(Key)
        if KeyUpper ~= ShortcutKeyUpper then
          IsMatchingSucceed = false
          break
        end
      end
      if IsMatchingSucceed then
        self:OpenPanel("DebugPanel", ShortcutKey[1][1])
        break
      end
    end
  end
end

function DebugModule:ShowLuaTable(data, name)
  if self:HasPanel("LuaTableReflector") then
    local Panel = self:GetPanel("LuaTableReflector")
    Panel:AddContent({
      {
        data,
        name,
        debug.traceback("", 2)
      }
    })
  else
    self:OpenPanel("LuaTableReflector", {
      {
        data,
        name,
        debug.traceback("", 2)
      }
    })
  end
end

function DebugModule:SetSvrTime(svr_time)
  self:DispatchEvent(DebugModuleEvent.UpdateSvrTime, svr_time)
end

function DebugModule:OnCmdSetTemperature(bt, diffTime, btFinal)
  self:DispatchEvent(DebugModuleEvent.SetTemperature, bt, diffTime, btFinal)
end

function DebugModule:OnCmdShowTemperature()
  self:DispatchEvent(DebugModuleEvent.ShowTemperature)
end

function DebugModule:ShowPlayerLoction(_leftPanel)
  if nil ~= _leftPanel then
    self:DispatchEvent(DebugModuleEvent.ShowPlayerLoction, _leftPanel)
  else
    self:DispatchEvent(DebugModuleEvent.ShowNpcInfo)
  end
end

function DebugModule:OnCmdShowTimeAndWeather()
  self:DispatchEvent(DebugModuleEvent.ShowTimeAndWeather)
end

function DebugModule:OnCmdRefreshWeather(weather)
  if self:HasPanel("DebugEntry") then
    local panel = self:GetPanel("DebugEntry")
    panel:RefreshWeather(weather)
  end
end

function DebugModule:OnCmdShowVisiblePoolInfo()
  self:DispatchEvent(DebugModuleEvent.ShowVisiblePoolInfo)
end

function DebugModule:OnCmdShowDungeonStageInfo(cur_stage)
  self:DispatchEvent(DebugModuleEvent.ShowDungeonStageInfo, cur_stage)
end

function DebugModule:OnCmdShowOrHideDungeonStageInfoText(bShow)
  self:DispatchEvent(DebugModuleEvent.ShowOrHideDungeonStageInfoText, bShow)
end

function DebugModule:OnCmdRefreshVisiblePoolInfo(zone)
  if self:HasPanel("DebugEntry") then
    local panel = self:GetPanel("DebugEntry")
    panel:RefreshVisiblePoolInfo(zone)
  end
end

function DebugModule:OnCmdOpenDebugHomePetPopUp(data)
  self:OpenPanel("DebugHomePetPopUp", data)
end

function DebugModule:OnCmdSetGMPetCounterPercentage(actorId, data)
  self.GMPetCounterPercentage[actorId] = data
end

function DebugModule:OnCmdGetGMPetCounterPercentage(actorId)
  if self.GMPetCounterPercentage[actorId] then
    return self.GMPetCounterPercentage[actorId]
  end
end

function DebugModule:OnCmdClearGMPetCounterPercentage()
  self.GMPetCounterPercentage = {}
end

function DebugModule:ToggleNPCStat()
  self:DispatchEvent(DebugModuleEvent.ToggleNPCStat)
end

function DebugModule:DOpenCachedDebugData(data, name)
  if self:HasPanel("LuaTableReflector") then
    local Panel = self:GetPanel("LuaTableReflector")
    Panel:AddContent(self.CachedDebugData)
  else
    self:OpenPanel("LuaTableReflector", self.CachedDebugData)
  end
  self.isAddCachedDebugData = true
end

function DebugModule:DAddCachedDebugData(data, name)
  table.insert(self.CachedDebugData, {
    data,
    name,
    debug.traceback("", 2)
  })
end

function DebugModule:OnCmdDeleteFileCMD()
  self:DispatchEvent(DebugModuleEvent.DeleteFile)
end

function DebugModule:SetCachedDebugData(DataList, isClear)
  if isClear then
    table.clear(self.CachedDebugData)
  end
  for i = 1, #DataList do
    if DataList[i][4] then
      table.insert(self.CachedDebugData, {
        DataList[i][1],
        DataList[i][2],
        DataList[i][3]
      })
    end
  end
  self.isAddCachedDebugData = false
end

function DebugModule:GetChachedDebugData()
  return self.CachedDebugData
end

function DebugModule:ClearChachedDebugData()
  table.clear(self.CachedDebugData)
end

function DebugModule:GetIsAddCachedDebugData()
  return self.isAddCachedDebugData
end

function DebugModule:OnActive()
  self:Log("DebugModule OnActive")
  self:OpenPanel("DebugEntry")
  _G.ZoneServer:AddProtocolListener(self, ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_DEBUG_DRAW_CALL, self.OnSceneDebugDrawCalls)
  _G.ZoneServer:AddProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_SCENE_PLAYER_SERVER_INFO_NOTIFY, self.OnReceiveServerInfo)
  _G.ZoneServer:AddProtocolListener(self, ProtoCMD.ZoneSvrGmCmd.ZONE_GM_SHOW_TIPS_NOTIFY, self.OnShowTipsNotify)
  _G.NRCEventCenter:RegisterEvent("DebugModule", self, SceneEvent.OnEnterSceneFinishNtyAck, self.OnEnterSceneFinishNtyAck)
  if self:CheckIsInPhotoEditorMode() then
    self:OpenPanel("StarLightPhotoEditor")
  end
end

local movedataIndex = 1
local movedataDelta = 0

function DebugModule:UpdatePlayerControllerRotation(Delta)
  if movedataIndex + 1 > #self.moveDatas then
    return
  end
  movedataDelta = movedataDelta + Delta * 1000
  local total = self.moveDatas[movedataIndex + 1].time_stamp - self.moveDatas[movedataIndex].time_stamp
  local percent = math.min(movedataDelta / total, 1)
  local playerContoller = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER).ueController
  local startrot = SceneUtils.ServerPos2ClientRotator(self.moveDatas[movedataIndex].cam_rot)
  local endrot = SceneUtils.ServerPos2ClientRotator(self.moveDatas[movedataIndex + 1].cam_rot)
  local rotator = UE4.FQuat.Slerp(startrot:ToQuat(), endrot:ToQuat(), percent):ToRotator()
  playerContoller:SetControlRotation(rotator)
  local diff = movedataDelta - total
  if diff > 0 then
    movedataDelta = diff
    movedataIndex = movedataIndex + 1
  end
end

local localRecordingCD = 6

function DebugModule:OnTick(Delta)
  if self.isLocalRecording then
    localRecordingCD = localRecordingCD - 1
    if localRecordingCD <= 0 then
      localRecordingCD = 6
      local playerModule = NRCModuleManager:GetModule("PlayerModule")
      playerModule.movementRecorder:RecordLocal()
    end
  end
  if self.isAutoMoving then
    local playerModule = NRCModuleManager:GetModule("PlayerModule")
    if not playerModule then
      return
    end
    self:UpdatePlayerControllerRotation(Delta)
    local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
    localPlayer.nativeMoveComp:IsOnLand()
    if not localPlayer.nativeMoveComp:isMoving() then
      movedataIndex = 1
      self.isAutoMoving = false
      OpenMessageBox("\230\143\144\231\164\186", "\228\184\187\232\167\146\232\135\170\229\138\168\232\183\145\229\155\190\229\174\140\230\136\144", "\231\161\174\229\174\154", "\229\143\150\230\182\136", DialogContext.Mode.OK, nil)
    end
  end
  if _G.GlobalConfig.KeyPointAutoTest then
    if self.TeleportTime >= 500 then
      self:Log("\232\135\170\229\138\168\229\140\150\230\181\139\232\175\149\228\188\160\233\128\129\229\188\128\229\167\139")
      local Position = self.KeyPointPosition[self.CurrentIndex].pos
      local PointName = self.KeyPointPosition[self.CurrentIndex].name
      self:Log("Begin to Transport to ", PointName)
      local TransportCommand = "NRCTransport " .. Position
      UE4.UKismetSystemLibrary.ExecuteConsoleCommand(nil, TransportCommand)
      self.CollectDataTime = 250
      UE4.UNRCStatics.KeyPointProfile(PointName)
      self.TeleportTime = 0
      self.CurrentIndex = self.CurrentIndex + 1
      if self.CurrentIndex > #self.KeyPointPosition then
        _G.GlobalConfig.KeyPointAutoTest = false
        self.CurrentIndex = 1
        UE4.UNRCStatics.DumpSceneDensity()
      end
    else
      self.TeleportTime = self.TeleportTime + 1
    end
  end
  if self:CheckShowPetInfo() then
    self:ShowPetInfoByDistance()
  end
end

function DebugModule:OnCmdSetLoop(_IsLoop, Delegate, call, rolePlayItem)
  self.Delegate = Delegate
  self.call = call
  self.IsLoop = _IsLoop
  self.rolePlayItem = rolePlayItem
  self.DelayTime = 0
end

function DebugModule:OnStopRpBehavior(abortFlag)
  if not abortFlag and self.IsLoop then
    if self.Delegate and self.call and self.rolePlayItem then
      self.Delegate(self.call, self.rolePlayItem)
    end
  else
    self:OnCmdSetLoop()
  end
end

function DebugModule:StartAutoMove()
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  self.moveDatas = playerModule.movementRecorder:GetRecord("SendMoveData.json")
  local testPlayer = playerModule:GetTestPlayer()
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  localPlayer:GetUEController():SetViewTargetWithBlend(testPlayer.viewObj)
  local nativeMovementComponent = testPlayer.viewObj.CharacterMovement
  nativeMovementComponent.EnableReplicateMove = true
  self.isAutoMoving = true
end

function DebugModule:StartRecordLocal()
  localRecordingCD = 60
  self.isLocalRecording = true
end

function DebugModule:StopRecordLocal()
  self.isLocalRecording = false
end

function DebugModule:StartMainPlayerAutoMove()
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  if _G.GlobalConfig.MemoryAutoTest then
    self.moveDatas = playerModule.movementRecorder:GetRecord("SendMoveData_Bus.json")
  else
    self.moveDatas = playerModule.movementRecorder:GetRecord("SendMoveData.json")
  end
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local nativeMovementComponent = localPlayer.viewObj:AddComponentByClass(UE4.UCharacterReplicateMovementComponent, false, UE4.FTransform(UE4.FQuat(), UE4.FVector(0, 0, 0)), false)
  localPlayer.nativeMoveComp = nativeMovementComponent
  nativeMovementComponent.EnableReplicateMove = true
  for i = 1, #self.moveDatas do
    local moveData = self.moveDatas[i]
    local targetPos = SceneUtils.ServerPos2ClientPos(moveData.to_pos)
    local targetRot = SceneUtils.ServerPos2ClientRotator(moveData.to_rot)
    local velocity = SceneUtils.ServerPos2ClientPos(moveData.speed)
    local acceleration = SceneUtils.ServerPos2ClientPos(moveData.acceleration)
    local moveMode = moveData.move_mode
    local timeStamp = moveData.time_stamp
    nativeMovementComponent:ReplicateMoveData(targetPos, targetRot, moveMode, velocity, acceleration, timeStamp)
  end
  self.isAutoMoving = true
end

function DebugModule:StopAutoMove()
  self.isAutoMoving = false
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  localPlayer:GetUEController():SetViewTargetWithBlend(localPlayer.viewObj)
  local playerModule = NRCModuleManager:GetModule("PlayerModule")
  local testPlayer = playerModule:GetTestPlayer()
  local nativeMovementComponent = testPlayer.viewObj.CharacterMovement
  nativeMovementComponent.EnableReplicateMove = false
end

function DebugModule:EnterTextInLogin(inText)
  NRCEventCenter:DispatchEvent(LoginModuleEvent.AutoTestEnterText, inText)
end

function DebugModule:OnDeactive()
  _G.ZoneServer:RemoveProtocolListener(self, ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_GM_DEBUG_DRAW_CALL, self.OnSceneDebugDrawCalls)
  _G.ZoneServer:RemoveProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_SCENE_PLAYER_SERVER_INFO_NOTIFY, self.OnReceiveServerInfo)
  _G.ZoneServer:RemoveProtocolListener(self, ProtoCMD.ZoneSvrGmCmd.ZONE_GM_SHOW_TIPS_NOTIFY, self.OnShowTipsNotify)
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnEnterSceneFinishNtyAck, self.OnEnterSceneFinishNtyAck)
end

function DebugModule:OnDestruct()
  self.bShowHudPetInfo = false
end

local DebugStringMaxDistSquare = 25000000

function DebugModule:OnSceneDebugDrawCall(notify)
  if nil == notify then
    return
  end
  if notify.type == ProtoEnum.DEBUG_DRAW_CALL_TYPE.POINT then
    UE4.UKismetSystemLibrary.Abs_DrawDebugPoint(_G.UE4Helper.GetCurrentWorld(), UE4.FVector(notify.point_data.point_pos.x, notify.point_data.point_pos.y, notify.point_data.point_pos.z), notify.point_data.point_size, UE4.FColor(notify.point_data.color.R, notify.point_data.color.G, notify.point_data.color.B, notify.point_data.color.A):ToLinearColor(), notify.point_data.show_time)
  elseif notify.type == ProtoEnum.DEBUG_DRAW_CALL_TYPE.LINE then
    if 0 ~= notify.line_data.arrow_size then
      UE4.UKismetSystemLibrary.Abs_DrawDebugArrow(_G.UE4Helper.GetCurrentWorld(), UE4.FVector(notify.line_data.start_pos.x, notify.line_data.start_pos.y, notify.line_data.start_pos.z), UE4.FVector(notify.line_data.end_pos.x, notify.line_data.end_pos.y, notify.line_data.end_pos.z), notify.line_data.arrow_size, UE4.FColor(notify.line_data.color.R, notify.line_data.color.G, notify.line_data.color.B, notify.line_data.color.A):ToLinearColor(), notify.line_data.show_time, notify.line_data.thickness)
    else
      UE4.UKismetSystemLibrary.Abs_DrawDebugLine(_G.UE4Helper.GetCurrentWorld(), UE4.FVector(notify.line_data.start_pos.x, notify.line_data.start_pos.y, notify.line_data.start_pos.z), UE4.FVector(notify.line_data.end_pos.x, notify.line_data.end_pos.y, notify.line_data.end_pos.z), UE4.FColor(notify.line_data.color.R, notify.line_data.color.G, notify.line_data.color.B, notify.line_data.color.A):ToLinearColor(), notify.line_data.show_time, notify.line_data.thickness)
    end
  elseif notify.type == ProtoEnum.DEBUG_DRAW_CALL_TYPE.SPHERE then
    UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(_G.UE4Helper.GetCurrentWorld(), UE4.FVector(notify.sphere_data.center.x, notify.sphere_data.center.y, notify.sphere_data.center.z), notify.sphere_data.radius, notify.sphere_data.segments, UE4.FColor(notify.sphere_data.color.R, notify.sphere_data.color.G, notify.sphere_data.color.B, notify.sphere_data.color.A):ToLinearColor(), notify.sphere_data.show_time, notify.sphere_data.thickness)
  elseif notify.type == ProtoEnum.DEBUG_DRAW_CALL_TYPE.BOX then
    UE4.UKismetSystemLibrary.Abs_DrawDebugBoxWithQuat(_G.UE4Helper.GetCurrentWorld(), UE4.FVector(notify.box_data.center.x, notify.box_data.center.y, notify.box_data.center.z), UE4.FVector(notify.box_data.extent.x, notify.box_data.extent.y, notify.box_data.extent.z), UE4.FColor(notify.box_data.color.R, notify.box_data.color.G, notify.box_data.color.B, notify.box_data.color.A):ToLinearColor(), UE4.FQuat(notify.box_data.rotator.x, notify.box_data.rotator.y, notify.box_data.rotator.z, notify.box_data.rotator.w), notify.box_data.show_time, notify.box_data.thickness)
  elseif notify.type == ProtoEnum.DEBUG_DRAW_CALL_TYPE.CAPSULE then
    UE4.UKismetSystemLibrary.Abs_DrawDebugCapsuleWithQuat(_G.UE4Helper.GetCurrentWorld(), UE4.FVector(notify.capsule_data.center.x, notify.capsule_data.center.y, notify.capsule_data.center.z), notify.capsule_data.half_height, notify.capsule_data.radius, UE4.FQuat(notify.capsule_data.rotator.x, notify.capsule_data.rotator.y, notify.capsule_data.rotator.z, notify.capsule_data.rotator.w), UE4.FColor(notify.capsule_data.color.R, notify.capsule_data.color.G, notify.capsule_data.color.B, notify.capsule_data.color.A):ToLinearColor(), notify.capsule_data.show_time, notify.capsule_data.thickness)
  elseif notify.type == ProtoEnum.DEBUG_DRAW_CALL_TYPE.MESH then
    if nil == notify.mesh_data.verts or nil == notify.mesh_data.indices then
      self.Log("mesh_data data verts or indices is nil")
      return
    end
    local vert_array = UE4.TArray(UE4.FVector)
    for _, vert in ipairs(notify.mesh_data.verts) do
      vert_array:Add(UE4.FVector(vert.x, vert.y, vert.z))
    end
    local indices = {}
    for _, index in ipairs(notify.mesh_data.indices) do
      table.insert(indices, index)
    end
    UE4.UKismetSystemLibrary.Abs_DrawDebugMesh(_G.UE4Helper.GetCurrentWorld(), vert_array, indices, UE4.FColor(notify.mesh_data.color.R, notify.mesh_data.color.G, notify.mesh_data.color.B, notify.mesh_data.color.A):ToLinearColor(), notify.mesh_data.show_time)
  elseif notify.type == ProtoEnum.DEBUG_DRAW_CALL_TYPE.WIRE_FRAME then
    if nil == notify.wire_frame_data.lines then
      self.Log("wire_frame_data lines is nil")
      return
    end
    for _, line in ipairs(notify.wire_frame_data.lines) do
      if 0 ~= notify.wire_frame_data.arrow_size then
        UE4.UKismetSystemLibrary.Abs_DrawDebugArrow(_G.UE4Helper.GetCurrentWorld(), UE4.FVector(line.start_pos.x, line.start_pos.y, line.start_pos.z), UE4.FVector(line.end_pos.x, line.end_pos.y, line.end_pos.z), notify.wire_frame_data.arrow_size, UE4.FColor(notify.wire_frame_data.color.R, notify.wire_frame_data.color.G, notify.wire_frame_data.color.B, notify.wire_frame_data.color.A):ToLinearColor(), notify.wire_frame_data.show_time, notify.wire_frame_data.thickness)
      else
        UE4.UKismetSystemLibrary.Abs_DrawDebugLine(_G.UE4Helper.GetCurrentWorld(), UE4.FVector(line.start_pos.x, line.start_pos.y, line.start_pos.z), UE4.FVector(line.end_pos.x, line.end_pos.y, line.end_pos.z), UE4.FColor(notify.wire_frame_data.color.R, notify.wire_frame_data.color.G, notify.wire_frame_data.color.B, notify.wire_frame_data.color.A):ToLinearColor(), notify.wire_frame_data.show_time, notify.wire_frame_data.thickness)
      end
    end
  elseif notify.type == ProtoEnum.DEBUG_DRAW_CALL_TYPE.POINT_SET then
    if nil == notify.point_set_data.verts then
      self.Log("point_set_data verts is nil")
      return
    end
    for _, point in ipairs(notify.point_set_data.verts) do
      UE4.UKismetSystemLibrary.Abs_DrawDebugPoint(_G.UE4Helper.GetCurrentWorld(), UE4.FVector(point.x, point.y, point.z), notify.point_set_data.point_size, UE4.FColor(notify.point_set_data.color.R, notify.point_set_data.color.G, notify.point_set_data.color.B, notify.point_set_data.color.A):ToLinearColor(), notify.point_set_data.show_time)
    end
  elseif notify.type == ProtoEnum.DEBUG_DRAW_CALL_TYPE.NAV_MESH then
    if nil == notify.nav_mesh_data.raw_data.tiles then
      self.Log("nav_mesh_data tile is nil")
      return
    end
    for _, tile in ipairs(notify.nav_mesh_data.raw_data.tiles) do
      if nil ~= tile.polys then
        for _, poly in ipairs(tile.polys) do
          local vert_array = UE4.TArray(UE4.FVector)
          local indices = {}
          for i, vert in ipairs(poly.verts) do
            vert_array:Add(UE4.FVector(vert.x, vert.y, vert.z))
            table.insert(indices, i - 1)
          end
          UE4.UKismetSystemLibrary.Abs_DrawDebugMesh(_G.UE4Helper.GetCurrentWorld(), vert_array, indices, UE4.FColor(poly.color.R, poly.color.G, poly.color.B, poly.color.A):ToLinearColor(), notify.nav_mesh_data.show_time)
        end
      end
      if nil ~= tile.inner_boundaries and nil ~= tile.inner_color then
        for _, line in ipairs(tile.inner_boundaries) do
          UE4.UKismetSystemLibrary.Abs_DrawDebugLine(_G.UE4Helper.GetCurrentWorld(), UE4.FVector(line.begin_pos.x, line.begin_pos.y, line.begin_pos.z), UE4.FVector(line.end_pos.x, line.end_pos.y, line.end_pos.z), UE4.FColor(tile.inner_color.R, tile.inner_color.G, tile.inner_color.B, tile.inner_color.A):ToLinearColor(), notify.nav_mesh_data.show_time, notify.nav_mesh_data.inner_line_thickness)
        end
      end
      if nil ~= tile.outer_boundaries and nil ~= tile.outer_color then
        for _, line in ipairs(tile.outer_boundaries) do
          UE4.UKismetSystemLibrary.Abs_DrawDebugLine(_G.UE4Helper.GetCurrentWorld(), UE4.FVector(line.begin_pos.x, line.begin_pos.y, line.begin_pos.z), UE4.FVector(line.end_pos.x, line.end_pos.y, line.end_pos.z), UE4.FColor(tile.outer_color.R, tile.outer_color.G, tile.outer_color.B, tile.outer_color.A):ToLinearColor(), notify.nav_mesh_data.show_time, notify.nav_mesh_data.outer_line_thickness)
        end
      end
    end
  elseif notify.type == ProtoEnum.DEBUG_DRAW_CALL_TYPE.CYLINDER then
    UE4.UKismetSystemLibrary.Abs_DrawDebugCylinder(_G.UE4Helper.GetCurrentWorld(), UE4.FVector(notify.cylinder_data.center_pos.x, notify.cylinder_data.center_pos.y, notify.cylinder_data.center_pos.z - notify.cylinder_data.half_height), UE4.FVector(notify.cylinder_data.center_pos.x, notify.cylinder_data.center_pos.y, notify.cylinder_data.center_pos.z + notify.cylinder_data.half_height), notify.cylinder_data.radius, notify.cylinder_data.segments, UE4.FColor(notify.cylinder_data.color.R, notify.cylinder_data.color.G, notify.cylinder_data.color.B, notify.cylinder_data.color.A):ToLinearColor(), notify.cylinder_data.show_time, notify.cylinder_data.thickness)
  elseif notify.type == ProtoEnum.DEBUG_DRAW_CALL_TYPE.CIRCLE then
    UE4.UKismetSystemLibrary.Abs_DrawDebugCircle(_G.UE4Helper.GetCurrentWorld(), UE4.FVector(notify.circle_data.center_pos.x, notify.circle_data.center_pos.y, notify.circle_data.center_pos.z), notify.circle_data.radius, notify.circle_data.segments, UE4.FColor(notify.circle_data.color.R, notify.circle_data.color.G, notify.circle_data.color.B, notify.circle_data.color.A):ToLinearColor(), notify.circle_data.show_time, notify.circle_data.thickness, UE.FVector(1, 0, 0), UE.FVector(0, 1, 0))
  elseif notify.type == ProtoEnum.DEBUG_DRAW_CALL_TYPE.TEXT then
    local DrawPos = UE4.FVector(notify.text_data.pos.x, notify.text_data.pos.y, notify.text_data.pos.z)
    local PlayerPos = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER):GetActorLocation()
    if UE.FVector.DistSquared(DrawPos, PlayerPos) <= DebugStringMaxDistSquare then
      UE4.UKismetSystemLibrary.Abs_DrawDebugString(_G.UE4Helper.GetCurrentWorld(), UE4.FVector(notify.text_data.pos.x, notify.text_data.pos.y, notify.text_data.pos.z), notify.text_data.text, nil, UE4.FColor(notify.text_data.color.R, notify.text_data.color.G, notify.text_data.color.B, notify.text_data.color.A):ToLinearColor(), notify.text_data.show_time)
    end
  end
end

function DebugModule:OnSceneDebugDrawCalls(notify)
  if notify.draws == nil then
    return
  end
  self.Log("===========================OnSceneDebugDrawCall===========================")
  for _, v in pairs(notify.draws) do
    self:OnSceneDebugDrawCall(v)
  end
end

function DebugModule:OnReceiveServerInfo(notify)
  self.ServerInfoNotify = notify
  local Entry = self:GetPanel("DebugEntry")
  if Entry then
    Entry:SetServerInfo(self.ServerInfoNotify)
  end
end

function DebugModule:OnShowTipsNotify(Notify)
  if nil == Notify or nil == Notify.tips_str then
    Log.Error("DebugTabTips:OnShowTipsNotify Notify is empty!")
    return
  end
  _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, Notify.tips_str)
end

function DebugModule:ShowActorNum(Action)
  local Entry = self:GetPanel("DebugEntry")
  if Entry then
    Entry:SetNPCData(Action)
  end
end

function DebugModule:OpenPetAdjustVisualTool()
  if not UE4.UNRCStatics.IsEditor() then
    return
  end
  local PetMainUIIsOpen = false
  local PetUIModule = _G.NRCModuleManager:GetModule("PetUIModule")
  if PetUIModule then
    PetMainUIIsOpen = PetUIModule:HasPanel("PetInfoMain")
  end
  if PetMainUIIsOpen then
    self:OpenPanel("PetAdjustVisualTool")
    _G.NRCModeManager:DoCmd(_G.DebugModuleCmd.OpenOrClosePanel, false)
  else
    self:ClosePanel("PetAdjustVisualTool")
  end
end

function DebugModule:OnClosePetAdjustVisualTool()
  self:ClosePanel("PetAdjustVisualTool")
end

function DebugModule:OnUpdateVisualToolParam(_PetVisualParam, _IsUIEditor)
  if _IsUIEditor then
    if self:HasPanel("PetUIAdjustTool") then
      local Entry = self:GetPanel("PetUIAdjustTool")
      if Entry then
        Entry:RefreshPetVisualParam(_PetVisualParam)
      end
    end
  elseif self:HasPanel("PetAdjustVisualTool") then
    local Entry = self:GetPanel("PetAdjustVisualTool")
    if Entry then
      Entry:RefreshPetVisualParam(_PetVisualParam)
    end
  end
end

function DebugModule:OnShowZoneTip(zoneId)
  local funcConf = _G.DataConfigManager:GetAreaFuncConf(zoneId)
  self:DispatchEvent(DebugModuleEvent.TopHud_ShowZoneTip, funcConf.name)
end

function DebugModule:OpenPetUIAdjustTool()
  if not UE4.UNRCStatics.IsEditor() then
    return
  end
  local HandBookPanelIsOpen = false
  local HandbookModule = _G.NRCModuleManager:GetModule("HandbookModule")
  if HandbookModule then
    HandBookPanelIsOpen = HandbookModule:HasPanel("HandbookMain")
  end
  if HandBookPanelIsOpen then
    self:OpenPanel("PetUIAdjustTool")
    _G.NRCModeManager:DoCmd(_G.DebugModuleCmd.OpenOrClosePanel, false)
  else
    self:ClosePanel("PetUIAdjustTool")
  end
end

function DebugModule:OnSetNewOffsetInfo(_Param)
  if not UE4.UNRCStatics.IsEditor() then
    return
  end
  if self:HasPanel("PetUIAdjustTool") then
    local Entry = self:GetPanel("PetUIAdjustTool")
    Entry:RefreshOffsetInfo(_Param)
  end
end

function DebugModule:OnCmdGetCharacterDesignSketch()
  if not UE4.UNRCStatics.IsEditor() then
    return
  end
  if self:HasPanel("PetUIAdjustTool") then
    local Entry = self:GetPanel("PetUIAdjustTool")
    return Entry:GetCharacterDesignSketchIsChecked()
  end
  return false
end

function DebugModule:OnNPCPressure(distance, NpcNum, SpriteNum)
  if NpcNum > 60 then
    NpcNum = 60
  end
  if SpriteNum > 60 then
    SpriteNum = 60
  end
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerPos = localPlayer.viewObj:Abs_K2_GetActorLocation()
  
  local function CreatePosition(index, num, dist)
    local angle = 0
    if 1 == index then
      angle = 0
    elseif 2 == index then
      angle = 1
    else
      local Max2Index = math.ceil(math.log(index, 2))
      local StartAngle = 1 / Max2Index
      local Diff = 1 / (Max2Index - 1)
      angle = StartAngle + (index - 2 ^ (Max2Index - 1) - 1) * Diff
    end
    local radius = 100
    if index > 1 then
      radius = 100 + (index - 1) * (dist - 100) / (num - 1)
    end
    local x = radius * math.sin(angle * math.pi)
    local y = radius * math.cos(angle * math.pi)
    return x, y
  end
  
  local NPCPool = {
    20000014,
    20000015,
    20000016,
    20000017,
    20000018,
    2201288,
    506006,
    506007,
    2200250,
    2200251,
    2201287,
    2201272,
    2201276,
    2200253,
    2200252,
    2200254,
    2201281,
    2201280,
    2201283,
    2201286,
    2400017,
    3600014,
    3600012,
    3600011,
    3600010,
    3600013,
    2201100,
    4000041,
    4000043,
    3600015,
    2200260,
    2200256,
    2200255,
    2200259,
    2200258,
    2201217,
    4000047,
    4000046,
    4000045,
    4000044,
    4000042,
    4000038,
    4000037,
    4000035,
    4000031,
    2201140,
    4000061,
    4000050,
    4000051,
    4000054,
    2201183,
    4000070,
    4000094,
    4000048,
    4000049,
    4000055,
    4000056,
    4000059,
    4000060,
    4000061
  }
  local SpritePool = {
    100001,
    100047,
    100003,
    100004,
    100005,
    100006,
    100007,
    100008,
    100009,
    100010,
    100011,
    100012,
    100013,
    100014,
    100016,
    100017,
    100019,
    100020,
    100078,
    100022,
    100023,
    100025,
    100028,
    100029,
    100030,
    100031,
    100033,
    100036,
    100038,
    100039,
    100041,
    100043,
    100045,
    100046,
    100050,
    100053,
    100076,
    100055,
    100057,
    100059,
    100061,
    100063,
    100064,
    100066,
    100067,
    100069,
    100070,
    100071,
    100073,
    100075,
    100080,
    100085,
    100087,
    100089,
    100091,
    100093,
    100096,
    100098,
    100099,
    100103
  }
  for i = 1, NpcNum do
    local Point = ProtoMessage:newPoint()
    local offset_x, offset_y = CreatePosition(i, NpcNum, distance)
    Point.pos.x = math.round(playerPos.X + offset_x)
    Point.pos.y = math.round(playerPos.Y + offset_y)
    Point.pos.z = math.round(playerPos.Z + 1000)
    Point.dir.z = 1
    Point.dir.x = 0
    Point.dir.y = 0
    local req = ProtoMessage:newZoneGmCreateNpcReq()
    req.content_cfg_id = NPCPool[i]
    req.npc_pos = Point
    req.only_test = false
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CREATE_NPC_REQ, req, false)
  end
  for i = 1, SpriteNum do
    local Point = ProtoMessage:newPoint()
    local offset_x, offset_y = CreatePosition(i, SpriteNum, distance)
    Point.pos.x = math.round(playerPos.X + offset_x)
    Point.pos.y = math.round(playerPos.Y + offset_y)
    Point.pos.z = math.round(playerPos.Z + 1000)
    Point.dir.z = 1
    Point.dir.x = 0
    Point.dir.y = 0
    local req = ProtoMessage:newZoneGmCreateNpcReq()
    req.content_cfg_id = SpritePool[i]
    req.npc_pos = Point
    req.only_test = false
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CREATE_NPC_REQ, req, false)
  end
end

function DebugModule:LuaWriteGMDataToConfig()
  if self:HasPanel("DebugPanel") then
    local panel = self:GetPanel("DebugPanel")
    panel:LuaWriteGMDataToConfig()
  end
end

function DebugModule:GetGMPanel()
  if self:HasPanel("DebugPanel") then
    local panel = self:GetPanel("DebugPanel")
    return panel
  end
end

function DebugModule:GetGMPanel()
  if self:HasPanel("DebugPanel") then
    local panel = self:GetPanel("DebugPanel")
    return panel
  end
end

function DebugModule:ExecGMGroup(CommandGroup)
  local ExecResult = CommandGroup
  local GMCommandDataConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.GM_COMMAND_CONF):GetAllDatas()
  local commandParts = {}
  for part in string.gmatch(CommandGroup, "%S+") do
    table.insert(commandParts, part)
  end
  local gm = commandParts[1]
  if "gm" ~= gm then
    ExecResult = ExecResult .. " \230\137\167\232\161\140\229\164\177\232\180\165\239\188\154gm\230\140\135\228\187\164\230\160\188\229\188\143\228\184\141\229\175\185\239\188\140\229\186\148\228\187\165gm\229\188\128\229\164\180"
    UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), CommandGroup)
    return
  end
  local gmcommand = commandParts[1] .. " " .. commandParts[2]
  local findComma = false
  if string.find(CommandGroup, ",") or string.find(CommandGroup, "\239\188\140") then
    findComma = true
  end
  local params = {}
  local GMGroupDataConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.GM_GROUP_CONF):GetAllDatas()
  local maxGroupIndex = self:GetMaxTableIndex(GMGroupDataConf)
  local buttonName = ""
  for i = 1, maxGroupIndex do
    if GMGroupDataConf[i] and string.lower(GMGroupDataConf[i].gm_group) == string.lower(gmcommand) then
      buttonName = GMGroupDataConf[i].button_name
      break
    end
  end
  table.insert(params, buttonName)
  local debugPanel = NRCModuleManager:DoCmd(DebugModuleCmd.GetGMPanel)
  local consoleFlag = false
  if debugPanel then
    table.insert(params, debugPanel)
  else
    consoleFlag = true
  end
  local params2 = {}
  if findComma then
    for number in string.gmatch(commandParts[3], "%d+") do
      if consoleFlag then
        table.insert(params2, tonumber(number))
      else
        table.insert(params, tonumber(number))
      end
    end
  else
    for i = 3, #commandParts do
      local num = tonumber(commandParts[i])
      if consoleFlag then
        if num then
          table.insert(params2, num)
        else
          table.insert(params2, commandParts[i])
        end
      elseif num then
        table.insert(params, num)
      else
        table.insert(params, commandParts[i])
      end
    end
  end
  local Commands = {}
  local maxCommandIndex = self:GetMaxTableIndex(GMCommandDataConf)
  for i = 1, maxCommandIndex do
    if GMCommandDataConf[i] then
      local CommandConf = GMCommandDataConf[i]
      local str1 = string.lower(CommandConf.gm_group)
      local str2 = string.lower(gmcommand)
      if str1 == str2 then
        table.insert(Commands, CommandConf.gm_command)
      end
    end
  end
  if #Commands > 0 then
    for i, Command in ipairs(Commands) do
      if self:CheckGMCommandIfIsPath(Command) == true then
        local FilePath, funcName = string.match(Command, "(.-)%.([^%.]+)$")
        local LuaFile = require(FilePath)
        if LuaFile then
          local CommandFunc = LuaFile[funcName]
          if CommandFunc then
            if consoleFlag then
              CommandFunc(LuaFile, buttonName, nil, table.unpack(params2))
            else
              CommandFunc(LuaFile, table.unpack(params))
            end
            ExecResult = ExecResult .. " \230\137\167\232\161\140\230\136\144\229\138\159"
          else
            ExecResult = ExecResult .. " \230\137\167\232\161\140\229\164\177\232\180\165\239\188\154\232\175\165\230\140\135\228\187\164\228\184\141\229\173\152\229\156\168\231\155\184\229\186\148\231\154\132\230\137\167\232\161\140\229\135\189\230\149\176"
          end
        else
          ExecResult = ExecResult .. " \230\137\167\232\161\140\229\164\177\232\180\165\239\188\154\230\140\135\228\187\164\233\148\153\232\175\175\239\188\140\228\184\141\229\173\152\229\156\168\232\175\165Lua\233\161\181\231\173\190\229\175\185\229\186\148\231\154\132\230\150\135\228\187\182"
        end
      end
    end
  else
    ExecResult = ExecResult .. " \230\137\167\232\161\140\229\164\177\232\180\165\239\188\154\228\184\141\229\173\152\229\156\168gm\230\140\135\228\187\164\229\175\185\229\186\148\231\154\132\229\135\189\230\149\176"
  end
  return ExecResult
end

function DebugModule:ShowPerfStutter(stutter)
  local Entry = self:GetPanel("DebugEntry")
  if Entry then
    Entry:SetPerfStutter(stutter)
  end
end

function DebugModule:OpenSceneMatchStartTest()
  _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.OpenPVP_PreparePanel)
end

function DebugModule:OnChangePetTeamsInfoTestRsp()
  _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.SendZoneSceneMatchStartReq, 5001)
end

function DebugModule:CmdGmOpenAnnouncement()
  NRCModuleManager:RegisterModule("LoginModule", "Type_System", "NewRoco.Modules.System.LoginModule.LoginModuleHead", "NewRoco.Modules.System.LoginModule.LoginModule")
  NRCModuleManager:ActiveModule("LoginModule")
  local LoginModule = _G.NRCModuleManager:GetModule("LoginModule")
  _G.GlobalConfig.DebugOpenUI = true
  local panelData = _G.NRCPanelRegisterData()
  panelData.panelName = "AnnouncementPanel"
  panelData.panelPath = "/Game/NewRoco/Modules/System/LoginModule/Res/UMG_Announcement"
  panelData.customDisableRendering = true
  panelData.isSingleTouchPanel = true
  panelData.panelLayer = _G.Enum.UILayerType.UI_LAYER_POPUP
  panelData.panelCacheType = 1
  LoginModule:RegisterPanel(panelData)
  NRCModeManager:GetCurMode():DisablePanelByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  LoginModule:OpenAnnouncementPanel()
end

function DebugModule:CheckGMCommandIfIsPath(command)
  local commandParts = {}
  for part in string.gmatch(command, "%S+") do
    table.insert(commandParts, part)
  end
  if "gm" == commandParts[1] then
    self:ExecGMGroup(command)
    return false
  else
    return true
  end
end

function DebugModule:GetMaxTableIndex(table)
  local maxIndex = 1
  for i, val in pairs(table) do
    if type(i) == "number" and i > maxIndex then
      maxIndex = i
    end
  end
  return maxIndex
end

function DebugModule:SetShowHudPetInfoFlg(flg)
  self.bShowHudPetInfo = flg
end

function DebugModule:OpenPikaNpcShopPanel()
  _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.OpenAppearanceClosetPanel)
end

function DebugModule:OpenPika1NpcShopPanel()
  self:OpenNeedNpcPanel(self.NPCList.PiKa1.ConfID, self.NPCList.PiKa1.AutoPlayActionId)
end

function DebugModule:OpenNeedNpcShopPanel()
  _G.GlobalConfig.DebugOpenUI = true
  _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.FinishNPCActionOpenShop)
end

function DebugModule:OpenNightmarePotionPanelTest()
  _G.GlobalConfig.DebugOpenUI = true
  _G.NRCModuleManager:DoCmd(TaskModuleCmd.OpenNightmarePotionPanel)
end

function DebugModule:OpenScrapBookPanelTest()
  _G.GlobalConfig.DebugOpenUI = true
  _G.NRCModuleManager:DoCmd(TaskModuleCmd.OpenScrapBookPanel)
end

function DebugModule:OpenMagicExtractPanelTest()
  _G.GlobalConfig.DebugOpenUI = true
  _G.NRCModuleManager:DoCmd(TaskModuleCmd.OpenMagicExtractPanel)
end

function DebugModule:OpenRepairToolsPanelTest()
  _G.GlobalConfig.DebugOpenUI = true
  _G.NRCModuleManager:DoCmd(UpdateUIModuleCmd.OpenRepairToolsPanel)
end

function DebugModule:OpenUpdateUIPanelTest()
  _G.GlobalConfig.DebugOpenUI = true
  local UpdateUIModule = _G.NRCModuleManager:GetModule("UpdateUIModule")
  UpdateUIModule:OpenUpdateUIPanel()
end

function DebugModule:OpenTailorShopTest()
  _G.GlobalConfig.DebugOpenUI = true
  _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.FinishNPCActionOpenShop, nil, 107)
end

function DebugModule:OpenTreasureSpotTest()
  _G.GlobalConfig.DebugOpenUI = true
  _G.NRCModuleManager:DoCmd(ActivityModuleCmd.OpenActivityTreasureSpot)
end

function DebugModule:OpenPVPFirstRewardTest()
  _G.GlobalConfig.DebugOpenUI = true
  _G.NRCModuleManager:DoCmd(PVPRankedMatchModuleCmd.OpenPVPFirstReward)
end

function DebugModule:OpenPetRightPanelTest()
  _G.GlobalConfig.DebugOpenUI = true
  local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(1)
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenRightPanel, nil, petData)
end

function DebugModule:OpenAppearanceUpgradeTest()
  _G.GlobalConfig.DebugOpenUI = true
  _G.NRCModuleManager:DoCmd(MainUIModuleCmd.ClosePanelLobbyMain)
  local AppearanceModule = _G.NRCModuleManager:GetModule("AppearanceModule")
  if AppearanceModule then
    AppearanceModule:DebugOpenAppearanceUpgradeTest()
  end
end

function DebugModule:OpenMagicVideoDetailsTest()
  _G.GlobalConfig.DebugOpenUI = true
  _G.NRCModuleManager:DoCmd(MainUIModuleCmd.ClosePanelLobbyMain)
  local AppearanceModule = _G.NRCModuleManager:GetModule("AppearanceModule")
  if AppearanceModule then
    AppearanceModule:DebugOpenMagicVideoDetailsTest()
  end
end

function DebugModule:OpenSeedBagTest()
  _G.GlobalConfig.DebugOpenUI = true
  _G.NRCModuleManager:DoCmd(MainUIModuleCmd.ClosePanelLobbyMain)
  local HomeModule = _G.NRCModuleManager:GetModule("HomeModule")
  if HomeModule then
    HomeModule:DebugSeedBagTest()
  end
end

function DebugModule:OpenHomeVisitPanelTest()
  _G.GlobalConfig.DebugOpenUI = true
  _G.NRCModuleManager:DoCmd(MainUIModuleCmd.ClosePanelLobbyMain)
  local HomeModule = _G.NRCModuleManager:GetModule("HomeModule")
  if HomeModule then
    HomeModule:DebugHomeVisitPanelTest()
  end
end

function DebugModule:OpenHomeLevelRewardPanelTest()
  _G.GlobalConfig.DebugOpenUI = true
  _G.NRCModuleManager:DoCmd(MainUIModuleCmd.ClosePanelLobbyMain)
  local HomeModule = _G.NRCModuleManager:GetModule("HomeModule")
  if HomeModule then
    HomeModule:DebugHomeLevelRewardPanelTest()
  end
end

function DebugModule:OpenHomePetChoosingTest()
  _G.GlobalConfig.DebugOpenUI = true
  local HomeModule = _G.NRCModuleManager:GetModule("HomeModule")
  if HomeModule then
    HomeModule:DebugOpenHomePetChoosingTest()
  end
end

function DebugModule:OpenHomeFurnitureCreationTest()
  _G.GlobalConfig.DebugOpenUI = true
  local HomeModule = _G.NRCModuleManager:GetModule("HomeModule")
  if HomeModule then
    HomeModule:DebugHomeFurnitureCreationTest()
  end
end

function DebugModule:OpenHomeExpandPanelTest()
  _G.GlobalConfig.DebugOpenUI = true
  local HomeModule = _G.NRCModuleManager:GetModule("HomeModule")
  if HomeModule then
    HomeModule:DebugHomeExpandPanelTest()
  end
end

function DebugModule:OpenFriendBlackListTest()
  _G.NRCModuleManager:DoCmd(FriendModuleCmd.OpenFriendBlackList)
end

function DebugModule:OnClickPhotoTest()
  _G.NRCModuleManager:DoCmd(FriendModuleCmd.OnClickPhoto)
end

function DebugModule:OpenPVPHistoricalRecordTest()
  _G.NRCModuleManager:DoCmd(PVPRankedMatchModuleCmd.OpenPVPHistoricalRecord)
end

function DebugModule:OpenPVPDailyChallengeTest()
  _G.NRCModuleManager:DoCmd(PVPRankedMatchModuleCmd.OpenPVPDailyChallenge)
end

function DebugModule:OpenPVPCuttoTest()
  _G.NRCModuleManager:DoCmd(PVPRankedMatchModuleCmd.OpenPVPCutto)
end

function DebugModule:OpenLeveBattleSilhouetteTest()
  _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.SetLeveBattleSilhouetteIndex, 0)
end

function DebugModule:OpenBeautyLoginPanelTest()
  _G.GlobalConfig.DebugOpenUI = true
  NRCModeManager:GetCurMode():DisablePanelByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  _G.NRCModuleManager:DoCmd(_G.AppearanceLoginModuleCmd.OpenBeautyLoginPanel, true)
end

function DebugModule:OpenLoadingUITest()
  _G.GlobalConfig.DebugOpenUI = true
  local LoadingUIModule = _G.NRCModuleManager:GetModule("LoadingUIModule")
  LoadingUIModule:OnOpenLoadingUI()
end

function DebugModule:OpenFastLoadingUITest()
  _G.GlobalConfig.DebugOpenUI = true
  _G.NRCModuleManager:DoCmd(LoadingUIModuleCmd.OpenLoadingUI)
end

function DebugModule:OpenTravelPanelTest()
  local info = {
    entry_id = 0,
    logic_id = 0,
    moduleCfg = _G.DataConfigManager:GetModelConf(13002),
    npcCfg = _G.DataConfigManager:GetNpcConf(60280),
    npc_cfg_id = 60280,
    npc_level = 1,
    npc_pos = {
      x = 426929,
      y = 660927,
      z = 1749
    },
    npc_refresh_id = 130309,
    npc_remain_time = -1,
    status = 2,
    world_map_cfg_id = 70002
  }
  _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.OpenTravelPanel, info, 0, false)
end

function DebugModule:OpenPreWarInfoPanelTest()
  _G.GlobalConfig.DebugOpenUI = true
  local TeamBattleModule = _G.NRCModuleManager:GetModule("TeamBattleModule")
  local teamBattleInfo = {
    activity_id = 0,
    battle_npc_attack_talent = 0,
    battle_npc_defense_talent = 0,
    battle_npc_gender = 0,
    battle_npc_hp_talent = 0,
    battle_npc_lv = 44,
    battle_npc_nature = 0,
    battle_npc_shine_color_id = 0,
    battle_npc_special_attack_talent = 0,
    battle_npc_special_defense_talent = 0,
    battle_npc_speed_talent = 0,
    battle_petbase_id = 3114,
    blood = 7,
    camp_cfg_id = 0,
    catch_vitem_quantity = 0,
    end_timestamp = 0,
    npc_cfg_id = 20134,
    npc_obj_id = 0,
    npc_logic_id = 0,
    spec_flower_seed_id = 0,
    star = 4
  }
  local bOwner = _G.DataModelMgr.PlayerDataModel:IsVisitOwner()
  TeamBattleModule:OpenPreWarInfoPanel(_G.ProtoEnum.TeamBattleChallengeType.TBCT_BLOOD_SINGLE, teamBattleInfo, bOwner)
end

function DebugModule:OpenEnterPanelTest()
  _G.GlobalConfig.DebugOpenUI = true
  _G.NRCModuleManager:DoCmd(InstanceModuleCmd.OpenEnterPanel, nil, 210110)
end

function DebugModule:OpenRecoveryTimeTest()
  _G.GlobalConfig.DebugOpenUI = true
  _G.NRCModuleManager:DoCmd(StarChainModuleCmd.OpenRecoveryTime)
end

function DebugModule:OpenLobbyInnerPanelTest()
  _G.GlobalConfig.DebugOpenUI = true
  _G.NRCModuleManager:DoCmd(MainUIModuleCmd.OpenPanelLobbyMainInner)
end

function DebugModule:OpenChangeCardBGTest()
  _G.GlobalConfig.DebugOpenUI = true
  _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.OpenChangeCardBG)
end

function DebugModule:OnOpenChangeCardLabelTest()
  _G.GlobalConfig.DebugOpenUI = true
  _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.OpenChangeCardLabel)
end

function DebugModule:OpenChatMainPanelTest()
  _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.OpenChatMainPanel, 0, nil)
end

function DebugModule:OpenBattleMainTest()
  _G.GlobalConfig.DebugOpenUI = true
  _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.OpenMain)
end

function DebugModule:OnEnterBattle()
end

function DebugModule:OpenNeedNpcPanel(NpcContentId, AutoPlayActionId)
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local Pos = Player:GetActorLocationFrameCache()
  local Rot = Player:GetActorRotationFrameCache()
  local Point = ProtoMessage:newPoint()
  Pos = Pos + Rot:RotateVector(UE.FVector(100, 0, 0))
  Point.pos.x = math.round(Pos.X)
  Point.pos.y = math.round(Pos.Y)
  Point.pos.z = math.round(Pos.Z)
  local Rotator = Rot:ToRotator()
  Point.dir.z = math.round((-Rotator.Yaw or 0) * 10)
  Point.dir.x = 0
  Point.dir.y = 0
  local SceneNpc = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByRefreshID, NpcContentId)
  if SceneNpc then
    local pos = UE4.FVector(Point.pos.x, Point.pos.y, Point.pos.z)
    SceneNpc:SetActorLocation(pos)
    local MainUiModule = _G.NRCModuleManager:GetModule("MainUIModule")
    MainUiModule:AutoPlayAction(AutoPlayActionId)
  else
    local debugTabNPCDestroy = require("NewRoco.Modules.System.Debug.Tabs.DebugTabNPCDestroy")
    debugTabNPCDestroy:DestroyAllNPC()
    if SceneUtils.debugCloseCreateNPC then
      SceneUtils.debugCloseCreateNPC = false
    end
    local req = ProtoMessage:newZoneGmCreateNpcReq()
    req.content_cfg_id = NpcContentId
    req.npc_pos = Point
    req.only_test = false
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CREATE_NPC_REQ, req, self, self.OnServerCreateDebugNPC)
  end
end

function DebugModule:OnServerCreateDebugNPC(rsp)
  if 0 == rsp.ret_info.ret_code then
    local MainUiModule = _G.NRCModuleManager:GetModule("MainUIModule")
    MainUiModule:AutoPlayAction(20001)
  end
end

function DebugModule:CheckShowPetInfo()
  return self.bShowHudPetInfo
end

function DebugModule:ShowPetInfoByDistance()
  local NPCModule = _G.NRCModuleManager:GetModule("NPCModule")
  local dis = 2000
  local World = _G.UE4Helper.GetCurrentWorld()
  for _, n in pairs(NPCModule._npcDic) do
    local npc = n
    if npc and npc.squaredDis2Local and npc.squaredDis2Local < dis * dis and npc.viewObj and npc.serverData and npc.config and (npc.serverData.base.detail_type == ProtoEnum.SpaceEnum_ActorDetailType.ENUM.Npc_Scene or npc.serverData.base.detail_type == ProtoEnum.SpaceEnum_ActorDetailType.ENUM.Npc_Pet) then
      local petBaseConf = self:GetPetBaseConf(npc)
      if petBaseConf then
        local petTypeNames = ""
        for _, type in pairs(petBaseConf.unit_type) do
          local typeName = table.getKeyName(Enum.SkillDamType, type)
          petTypeNames = petTypeNames .. typeName .. " "
        end
        local bloodName = ""
        local petBloodConfs = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.PET_BLOOD_CONF):GetAllDatas()
        local mixBloodType = npc.serverData.npc_base.blood_mix_skill_dam_type
        local normalBloodType = npc.serverData.npc_base.blood_normal_skill_dam_type
        if mixBloodType and 0 ~= mixBloodType then
          for _, bloodConf in pairs(petBloodConfs) do
            if bloodConf.blood_type == mixBloodType then
              bloodName = bloodConf.name
              break
            end
          end
        elseif normalBloodType and 0 ~= normalBloodType then
          for _, bloodConf in pairs(petBloodConfs) do
            if bloodConf.blood_type == normalBloodType then
              bloodName = bloodConf.name
              break
            end
          end
        end
        local loc = npc.viewObj:Abs_K2_GetActorLocation()
        loc.Z = loc.Z - 20
        local debugString = string.format("%s (%s %s)", npc.serverData.base.name, petTypeNames, bloodName)
        UE4.UKismetSystemLibrary.Abs_DrawDebugString(World, loc, debugString, nil, UE4.FLinearColor(1, 1, 1, 1), 0, false, 3.0)
      end
    end
  end
end

function DebugModule:GetPetBaseConf(NPC)
  local DataConfigManager = _G.DataConfigManager
  local PetBaseID = 0
  local NPCBase = NPC.serverData.npc_base
  local NPCConfigID = NPCBase.npc_cfg_id
  local monsterConfID = 0
  local NPCConf = DataConfigManager:GetNpcConf(NPCConfigID)
  if not NPCConf then
    return nil, nil
  end
  local FirstOption = NPCConf.option_id and NPCConf.option_id[1]
  if not FirstOption then
    return nil, nil
  end
  local OptionConf = DataConfigManager:GetNpcOptionConf(FirstOption)
  if not OptionConf or not OptionConf.action then
    return nil, nil
  end
  if OptionConf.action.action_type ~= Enum.ActionType.ACT_BATTLE and OptionConf.action.action_type ~= Enum.ActionType.ACT_TOUCHBATTLE then
    return nil, nil
  end
  if string.IsNilOrEmpty(OptionConf.action.action_param2) then
    return nil, nil
  end
  local BattleID = tonumber(OptionConf.action.action_param2)
  local BattleConf = DataConfigManager:GetBattleConf(BattleID)
  if not BattleConf then
    return nil, nil
  end
  local NPCList = BattleConf.npc_battle_list and BattleConf.npc_battle_list[1]
  if not NPCList then
    return nil, nil
  end
  monsterConfID = NPCList.pos1_1st and NPCList.pos1_1st[1] or 0
  if 0 == monsterConfID then
    return nil, nil
  end
  local MonsterConf = DataConfigManager:GetMonsterConf(monsterConfID)
  if not MonsterConf then
    return nil, nil
  end
  PetBaseID = MonsterConf and MonsterConf.base_id or 0
  local PetBaseConf = DataConfigManager:GetPetbaseConf(PetBaseID)
  return PetBaseConf, MonsterConf
end

function DebugModule:OpenDisplayCutoutAdjustPanel()
  if self:HasPanel("DisplayCutoutAdjust") then
    return
  end
  self:OpenPanel("DisplayCutoutAdjust")
end

function DebugModule:OpenGameVideoPlayer()
  if self:HasPanel("UMG_TestRecordViedeo") then
    return
  end
  self:OpenPanel("UMG_TestRecordViedeo")
end

function DebugModule:CloseGameVideoPlayer()
  self:ClosePanel("UMG_TestRecordViedeo")
end

function DebugModule:CmdOpenLeveBattleArrayTest()
  _G.GlobalConfig.DebugOpenUI = true
  _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.OnCmdOpenBattleBossPanel, 1001)
end

function DebugModule:SetAllShowMultipleArea(allShowMultipleArea)
  self.allShowMultipleArea = allShowMultipleArea
end

function DebugModule:GetAllShowMultipleArea()
  return self.allShowMultipleArea
end

function DebugModule:GetTabData(path)
  return self.data:GetTabDataFromCache(path)
end

function DebugModule:OnCmoOpenDebugGmTips(Param)
  self:OpenPanel("DebugGmTips", Param)
end

function DebugModule:OnCmdGMExecCommGmCmd(_cmd)
  local Req = _G.ProtoMessage:newZoneGmExecCommGmCmdReq()
  Req.cmd = _cmd
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_EXEC_COMM_GM_CMD_REQ, Req, self, self.GMExecCommGmCmdRsp, false, false)
end

function DebugModule:GMExecCommGmCmdRsp(Rsp)
  local IsSucceed = 0 == Rsp.ret_info.ret_code and true or false
  local Text = string.format("%s,%s,%s", IsSucceed, Rsp.ret_info.ret_code, Rsp.ret_info.ret_msg)
  self:DispatchEvent(DebugModuleEvent.RefreshResult, Text, Rsp)
end

function DebugModule:OpenBattleTestSkillListWidget()
  self:OpenPanel("UMG_BattleSkillList")
end

function DebugModule:GetBattleTestSkillListWidget()
  return self:GetPanel("UMG_BattleSkillList")
end

function DebugModule:CheckIsInPhotoEditorMode()
  local CurLevelName = LevelHelper:GetLevelName()
  if "L_WorldView_StarLightPhoto" == CurLevelName then
    return true
  end
  return false
end

function DebugModule:ReportPetUIAdjustTool()
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.GMOpenPetReportParticulars)
  self:OpenPanel("ReportPetAdjustVisualTool")
end

function DebugModule:OnCmdOpenClothingScreenRecordingTips()
  self:OpenPanel("ClothingScreenRecordingTips")
end

function DebugModule:OnCmdOpenDebugTips(Text)
  if self:HasPanel("DebugTips") then
    local Panel = self:GetPanel("DebugTips")
    if Panel then
      Panel:PlayTweenIn(Text)
    end
  else
    self:OpenPanel("DebugTips", Text)
  end
end

function DebugModule:OnCmdGmSetFashionSuit(suit_id)
  self.suit_id = suit_id
  local req = ProtoMessage:newZoneGmSetFashionSuitReq()
  req.suit_id = suit_id
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_SET_FASHION_SUIT_REQ, req, self, self.GmSetFashionSuitRsp, false, false)
end

function DebugModule:GmSetFashionSuitRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    local Index = rsp.fashion_info.current_wardrobe_index + 1
    _G.DataModelMgr.PlayerDataModel:SetPlayerFashionWardrobeInfo(Index, rsp.fashion_info.wardrobe_data[Index])
    self:DispatchEvent(DebugModuleEvent.SetFashionInfo, self.suit_id, rsp.fashion_info.wardrobe_data[Index].salon_item_wear_id, rsp.fashion_info.wardrobe_data[Index].item_wear_id)
  end
end

function DebugModule:OnCmdPetTeamFriendGetMirrorPetData()
  self:DispatchEvent(DebugModuleEvent.PetTeamFriendGetMirrorPetData)
end

function DebugModule:OnCmdAddRewardInfo(opType, itemType, itemId, num, Delegate, call, BaseId)
  opType = string.upper(opType)
  local opItemReq = ProtoMessage.newZoneGmOperateItemReq()
  if "ADD" == opType then
    opItemReq.op_type = ProtoEnum.OpType.OT_ADD
  elseif "SUB" == opType then
    opItemReq.op_type = ProtoEnum.OpType.OT_SUB
  elseif "SET" == opType then
    opItemReq.op_type = ProtoEnum.OpType.OT_SET
  else
    Log.WarningFormat("Operate item failed, invalid opType:%s", opType)
    return
  end
  itemType = string.upper(itemType)
  if "BAGITEM" == itemType then
    opItemReq.item_type = ProtoEnum.GoodsType.GT_BAGITEM
  elseif "VITEM" == itemType then
    opItemReq.item_type = ProtoEnum.GoodsType.GT_VITEM
  elseif "REWARD" == itemType then
    opItemReq.item_type = ProtoEnum.GoodsType.GT_REWARD
  elseif "PET" == itemType then
    opItemReq.item_type = ProtoEnum.GoodsType.GT_PET
  elseif "FASHION" == itemType then
    opItemReq.item_type = ProtoEnum.GoodsType.GT_FASHION
  elseif "SALON" == itemType then
    opItemReq.item_type = ProtoEnum.GoodsType.GT_SALON
  elseif "CARD_ICON" == itemType then
    opItemReq.item_type = ProtoEnum.GoodsType.GT_CARD_ICON
  elseif "CARD_SKIN" == itemType then
    opItemReq.item_type = ProtoEnum.GoodsType.GT_CARD_SKIN
  elseif "CARD_LABEL" == itemType then
    opItemReq.item_type = ProtoEnum.GoodsType.GT_CARD_LABEL
  elseif "TASK_TOKEN" == itemType then
    opItemReq.item_type = ProtoEnum.GoodsType.GT_TASK_TOKEN
  elseif "RP_BEHAVIOR" == itemType then
    opItemReq.item_type = ProtoEnum.GoodsType.GT_RP_BEHAVIOR
  elseif "FASHION_SUITS" == itemType then
    opItemReq.item_type = ProtoEnum.GoodsType.GT_FASHION_SUITS
  elseif "FASHION_PACKAGE" == itemType then
    opItemReq.item_type = ProtoEnum.GoodsType.GT_FASHION_PACKAGE
  elseif "FASHION_BOND" == itemType then
    opItemReq.item_type = ProtoEnum.GoodsType.GT_FASHION_BOND
  elseif "EMOJI" == itemType then
    opItemReq.item_type = ProtoEnum.GoodsType.GT_EMOJI
  else
    Log.ErrorFormat("Operate item failed, unsupp(or ukn) itemType:%s", itemType)
    return
  end
  opItemReq.item_id = itemId
  opItemReq.item_num = num
  self.Delegate = Delegate
  self.call = call
  self.BaseId = BaseId
  Log.DebugFormat("Operate item, opType:%s, itemType:%s, itemId:%s, num:%s", opType, itemType, itemId, num)
  ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_OPERATE_ITEM_REQ, opItemReq, self, self._OnOperateItemRsp)
end

function DebugModule:_OnOperateItemRsp(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    Log.ErrorFormat("OperateItem failed, errCode:%s", rsp.ret_info.ret_code)
    return
  end
  if self.Delegate then
    self.Delegate(self.call, self.BaseId)
  end
  self.Delegate = nil
  self.call = nil
  self.BaseId = nil
  Log.Debug("Operate item succ")
end

function DebugModule:TryClearTabCache()
  self.data:TryClearTabCache()
end

function DebugModule:SwitchDebugDrawSyncAura()
  self.EnableDebugDrawSyncAura = not self.EnableDebugDrawSyncAura
end

function DebugModule:ClientSceneDebugDrawCall(nty)
  self:OnSceneDebugDrawCall(nty)
end

function DebugModule:OnEnterSceneFinishNtyAck(notify, isReconnecting, isEnteringCell, preMapId, mapID)
  local Req = _G.ProtoMessage:newZoneGmGetCommGmCmdsReq()
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_GET_COMM_GM_CMDS_REQ, Req, self, self.OnGetCommGmCmdsRsp, false, false)
end

function DebugModule:OnGetCommGmCmdsRsp(Rsp)
  local DebugTabServerGmCmds = JsonUtils.LoadSaved("DebugTabServerGmCmds", {})
  DebugTabServerGmCmds.cmds = Rsp.cmds
  JsonUtils.DumpSaved("DebugTabServerGmCmds", DebugTabServerGmCmds)
end

return DebugModule
