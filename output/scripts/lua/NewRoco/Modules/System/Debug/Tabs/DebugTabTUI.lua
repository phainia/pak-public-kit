local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local UpdateUIModuleEvent = require("NewRoco.Modules.System.UpdateUIModule.UpdateUIModuleEvent")
local DebugModuleEvent = require("NewRoco.Modules.System.Debug.DebugModuleEvent")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local TUIModuleCmd = reload("NewRoco.Modules.System.TUI.TUIModuleCmd")
local DebugModuleCmd = reload("NewRoco.Modules.System.Debug.DebugModuleCmd")
local TipObject = require("NewRoco.Modules.System.TipsModule.Utils.TipObject")
local mcw = require("Debug.MemoryCheckWrapper")
local Base = DebugTabBase
local DebugTabTUI = Base:Extend("DebugTabTUI")

function DebugTabTUI:Ctor()
  Base.Ctor(self)
  self.bSubUMGPanelOpen = false
  self.bNoSubUMGPanelOpen = false
  self.cycleTimes = 0
  self.bBugTestBOpen = false
  self.intervalTime = 0
  self.bChooseSubUMG = false
end

function DebugTabTUI:SetupTabs()
  self:Add("GM\230\181\139\232\175\149\229\173\151\228\189\147", self.FontText, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "OpenShop")
  self:Add("\231\149\140\233\157\162\230\140\137\233\146\174\231\131\173\229\140\186\230\152\190\231\164\186", self.ShowTouchHotArea, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "ShowTouchHotArea")
  self:Add("\229\133\168\229\177\143\231\149\140\233\157\162\229\143\160\229\138\160\230\181\139\232\175\149", self.EnableFullScreenPanelCollapsed, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "EnableFullScreenPanelCollapsed")
  self:Add("\229\164\150\232\167\130\230\181\129\229\170\146\228\189\147\230\146\173\230\148\190\230\181\139\232\175\149", self.PlayAppearanceMedia, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "PlayAppearanceMedia")
  self:Add("\232\176\131\232\175\149\230\180\187\229\138\168\230\149\176\230\141\174", self.DebugActivityData, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\232\176\131\232\175\149PC\233\148\174\231\155\152\230\152\160\229\176\132\230\149\176\230\141\174", self.DebugEnhancedInputData, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\137\147\229\141\176\230\156\141\229\138\161\229\153\168\231\186\162\231\130\185\230\149\176\230\141\174", self.DebugSvrRedPointData, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\149\153\229\173\166\230\137\139\229\134\140\230\181\139\232\175\149\231\138\182\230\128\129", self.DebugEditorAsPcInTeachManual, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("RolePlay\232\176\131\232\175\149", self.DebugRolePlayData, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\231\170\151\229\143\163\228\191\161\230\129\175", self.DebugWindowsData, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("UI\228\191\161\230\129\175\230\177\135\230\128\187", self.DebugUISummaryData, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\156\176\229\155\190\229\136\155\229\187\186item \228\184\170/s", self.MapCreateItemNumPerSecond, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\137\147\229\188\128\229\145\168\233\170\140\232\175\129\230\180\187\229\138\168\231\149\140\233\157\162", self.DebugOpenWeeklyChallengeBattle, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "DebugOpenWeeklyChallengeBattle")
  self:Add("\231\155\180\230\142\165\229\188\128\229\144\175\229\190\133\230\156\186\229\138\159\232\131\189", self.DebugStartSleepMode, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "DebugStartSleepMode")
  self:Add("\230\137\147\229\188\128\231\178\190\231\129\181\229\133\179\231\179\187\230\160\145\228\186\178\230\152\181\229\138\168\231\148\187\229\188\185\231\170\151", self.DebugOpenRelationTreeShiningMedalPopUp, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "DebugOpenRelationTreeShiningMedalPopUp")
  self:Add("\230\181\139\232\175\149\233\154\144\232\151\1438070\229\149\134\229\186\151Tab", self.DebugHideShop8070Tab, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "DebugHideShop8070Tab")
  self:Add("\230\181\139\232\175\149\230\152\190\231\164\1868070\229\149\134\229\186\151Tab", self.DebugShowShop8070Tab, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "DebugShowShop8070Tab")
end

function DebugTabTUI:PlayAppearanceMedia()
  _G.NRCModuleManager:DoCmd(_G.TUIModuleCmd.OpenAppearanceMediaTestPanel)
end

function DebugTabTUI:FontText(name, panel, InputText)
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local Title = "\229\173\151\228\189\147\230\181\139\232\175\149"
  local inputText
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  local Ctx = DialogContext()
  Ctx:SetTitle(Title)
  Ctx:SetContent(inputText)
  Ctx:SetMode(DialogContext.Mode.OK_CANCEL)
  Ctx:SetCloseOnCancel(true)
  Ctx:SetButtonText(LuaText.umg_dialog_2, LuaText.umg_dialog_1)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function DebugTabTUI:TestIconUObjectCount()
  local world = UE4.UNRCPlatformGameInstance.GetInstance()
  local asset = _G.NRCResourceManager:LoadForDebugOnly("/Game/UMG_TestIcon.UMG_TestIcon")
  local umgPanel = UE4.UWidgetBlueprintLibrary.Create(world, asset)
end

function DebugTabTUI:CloseDebugErrorPanel()
  _G.GlobalConfig.CloseDebugPanel = not _G.GlobalConfig.CloseDebugPanel
end

function DebugTabTUI:OnDoCmd(name, panel, InputText)
  local inputText
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  NRCModuleManager:DoCmd(inputText)
end

function DebugTabTUI:TestLockRotate()
  if _G.DebugPreview and _G.DebugPreview[1] then
    _G.DebugPreview[1].PreviewWorld:UnlockScroll(false, false, false)
  else
    Log.Error("_G.DebugPreview Or _G.DebugPreview[1] Not Found")
  end
end

function DebugTabTUI:TestUnLockRotate()
  if _G.DebugPreview and _G.DebugPreview[1] then
    _G.DebugPreview[1].PreviewWorld:UnlockScroll(true, true, true)
  else
    Log.Error("_G.DebugPreview Or _G.DebugPreview[1] Not Found")
  end
end

function DebugTabTUI:UseNewNourishPanel()
  _G.GlobalConfig.bUseNewNourishPanel = not _G.GlobalConfig.bUseNewNourishPanel
  if _G.GlobalConfig.bUseNewNourishPanel then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\228\189\191\231\148\168\230\150\176\231\137\136\230\187\139\229\133\187\231\149\140\233\157\162\239\188\140\229\166\130\230\158\156\229\156\168\230\187\139\229\133\187\231\149\140\233\157\162\239\188\140\233\135\141\230\150\176\230\137\147\229\188\128\228\184\128\228\184\139\231\149\140\233\157\162")
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\228\189\191\231\148\168\230\151\167\231\137\136\230\187\139\229\133\187\231\149\140\233\157\162\239\188\140\229\166\130\230\158\156\229\156\168\230\187\139\229\133\187\231\149\140\233\157\162\239\188\140\233\135\141\230\150\176\230\137\147\229\188\128\228\184\128\228\184\139\232\175\165\231\149\140\233\157\162")
  end
end

function DebugTabTUI:TestSetRotation()
  _G.DebugPreview[1].PreviewWorld:LockRotation(0, 0, 100)
end

function DebugTabTUI:SetModelLocation()
  _G.DebugPreview[1].PreviewWorld:LockLocation(10, 10, 10)
end

function DebugTabTUI:TestFunctionGrid()
  _G.DebugGridView[1]:TestFunc()
end

function DebugTabTUI:ShowTUITestDemo()
  _G.NRCModuleManager:DoCmd(TUIModuleCmd.OpenMainPanel)
end

function DebugTabTUI:ChangeBackground()
  local pointList = self:GetAirWallPoints()
  UE4.UNRCTUIStatics.DrawDebugAirWall(0, 0, 0, pointList)
end

function DebugTabTUI:GetAirWallPoints()
  local wallId = 71030024
  local wall = _G.NRCModuleManager:DoCmd(_G.AirWallModuleCmd.GetWall, wallId)
  local splineLength = wall.Spline:GetSplineLength()
  local step = 100
  local pointList = {}
  for i = 100, splineLength, step do
    local Loc = wall.Spline:GetLocationAtDistanceAlongSpline(i, UE.ESplineCoordinateSpace.World)
    local x, y = self:ScenePositonToImagePositon(Loc.X, Loc.Y, wallId)
    local pos = UE4.FVector2D(x, y)
    table.insert(pointList, pos)
  end
  Log.Dump(pointList, 3, "\231\169\186\230\176\148\229\162\153\228\184\138\231\154\132\231\130\185")
  return pointList
end

function DebugTabTUI:ScenePositonToImagePositon(scenePosX, scenePosY, wallId)
  local scale = 0.01003921568627451
  local x = (scenePosX - 306000.0) * scale
  local y = (scenePosY - 408000.0) * scale
  if 81030006 == wallId then
    scale = 0.022755555555555557
    x = (scenePosX - -886161.0) * scale
    y = (scenePosY - -891000.0) * scale
  end
  return math.ceil(x), math.ceil(y)
end

function DebugTabTUI:Test()
  local player = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player:SendEvent(PlayerModuleEvent.ON_PLAYER_ATTACKED_BY_NPC, 3, UE4.FVector(0, 0, 1), false)
end

function DebugTabTUI:OpenFastLoadingWorldRendering()
  GlobalConfig.SetFastLoadingWorldRendering = not GlobalConfig.SetFastLoadingWorldRendering
  UE4Helper.SetEnableWorldRendering(GlobalConfig.SetFastLoadingWorldRendering)
end

function DebugTabTUI:OpenUIAutoTestPanel()
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.OpenUIAutoTestPanel)
end

function DebugTabTUI:DontShowUI()
  GlobalConfig.DontShowUI = not GlobalConfig.DontShowUI
end

function DebugTabTUI:ANNITest()
  local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
  local FVector = npc.viewObj:Abs_K2_GetActorLocation()
  local FVector1 = FVector(FVector.X, FVector.Y + 10, FVector.Z)
  npc.viewObj:Abs_K2_SetActorLocation_WithoutHit(FVector1)
end

function DebugTabTUI:ChangeMainUIStyle()
  GlobalConfig.NewLobbyMainStyle = not GlobalConfig.NewLobbyMainStyle
  _G.NRCModuleManager:DoCmd(MainUIModuleCmd.ChangeLobbyMainStyle, GlobalConfig.NewLobbyMainStyle)
end

function DebugTabTUI:ChangeLobbyCompassStyle()
  GlobalConfig.NewLobbyCompassStyle = not GlobalConfig.NewLobbyCompassStyle
end

function DebugTabTUI:ChangePVPStyle()
  GlobalConfig.NewPVPStyle = not GlobalConfig.NewPVPStyle
end

function DebugTabTUI:OpenLobbyMainGyroscope()
  GlobalConfig.EnableLobbyMainGyroscope = not GlobalConfig.EnableLobbyMainGyroscope
end

function DebugTabTUI:TestMiracleReq(Name, Panel, InputNumber)
  local petGid
  if Panel then
    petGid = Panel:GetInputNumber()
  else
    petGid = tonumber(InputNumber)
  end
  local req = _G.ProtoMessage:newZoneSceneMiracleChangeReq()
  local player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local position = player.viewObj:Abs_K2_GetActorLocation()
  local pt1 = {
    pos = UE4.FVector(),
    dir = UE4.FVector()
  }
  local pos1 = {
    x = math.floor(position.X),
    y = math.floor(position.Y),
    z = math.floor(position.Z)
  }
  pt1.pos = pos1
  table.insert(req.miracle_change_pets, {pet_gid = petGid, pt = pt1})
  Log.Dump(req, 6, "DebugTabTUI:TestMiracleReq")
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_MIRACLE_CHANGE_REQ, req, self, self.TestMiracleRsp, true, false)
end

function DebugTabTUI:TestMiracleRsp(_rsp)
end

function DebugTabTUI:OpenTempPanel()
  _G.GlobalConfig.bShowPetViewingGM = not _G.GlobalConfig.bShowPetViewingGM
end

function DebugTabTUI:OpenTuiIconTest()
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.OpenTuiIconTest)
end

function DebugTabTUI:OpenTuiFontTest()
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.OpenTuiFontTest)
end

function DebugTabTUI:OpenWB_FontTest()
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.OpenWB_FontTest)
end

function DebugTabTUI:OpenWB_FontTest1()
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.OpenWB_FontTest1)
end

function DebugTabTUI:OpenWB_FontTest2()
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.OpenWB_FontTest2)
end

function DebugTabTUI:OpenWB_FontTestIOS1()
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.OpenWB_FontTestIOS1)
end

function DebugTabTUI:OpenWB_FontTestIOS2()
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.OpenWB_FontTestIOS2)
end

function DebugTabTUI:ShowTestAimRect()
  GlobalConfig.ShowAimRect = not GlobalConfig.ShowAimRect
end

function DebugTabTUI:ShowNiagaraTestBtn()
  GlobalConfig.ShowTestNiagaraBtn = not GlobalConfig.ShowTestNiagaraBtn
end

function DebugTabTUI:LoadAtlas()
  local RunAtlas = UE4.UNRCTUIStatics.GetRuntimeLoadAtlas():ToTable()
  Log.Dump(RunAtlas, 5, "DebugTabTUI:LoadAtlas")
  _G.NRCModuleManager:DoCmd(TUIModuleCmd.OpenPicturesListPanel)
end

function DebugTabTUI:CloseDebugEntryControlText()
  _G.NRCModuleManager:DoCmd(DebugModuleCmd.TryCloseControlText)
end

function DebugTabTUI:OpenProfilerLog()
  GlobalConfig.bShowProfilerLog = true
end

function DebugTabTUI:ExportOpenPanelData()
  _G.NRCProfilerLog:ExportCSVData()
end

function DebugTabTUI:ClearOpenPanelData()
  _G.NRCProfilerLog:ClearCSVData()
end

function DebugTabTUI:SetRedPoint(name, panel, InputText)
  local value
  if panel then
    value = string.split(panel.InputBox:GetText(), ",")
  else
    value = string.split(InputText, ",")
  end
  if #value < 3 then
    return
  end
  Log.Error(value[1], value[2], value[3])
  value[3] = value[3]:gsub("^%s*(.-)%s*$", "%1")
  _G.NRCModuleManager:DoCmd(_G.RedPointModuleCmd.GmUpdateRedPoint, tonumber(value[1]), tonumber(value[2]), value[3])
end

function DebugTabTUI:OpenDebugRedPoint(name, panel)
  _G.NRCModuleManager:DoCmd(_G.RedPointModuleCmd.ShowDebugInfo, true)
end

function DebugTabTUI:CloseDebugRedPoint(name, panel)
  _G.NRCModuleManager:DoCmd(_G.RedPointModuleCmd.ShowDebugInfo, false)
end

function DebugTabTUI:ChangeBagBackGround(name, panel)
  _G.NRCModuleManager:GetModule("BagModule"):DispatchEvent(BagModuleEvent.ChangeBagBackGround)
end

local _positionIdx = 0

function DebugTabTUI:ChangeDebugRedPointPostion(name, panel, InputText)
  local text
  if panel then
    text = panel.InputBox:GetText()
  else
    text = InputText
  end
  if #text > 0 then
    _positionIdx = tonumber(text)
  else
    _positionIdx = _positionIdx + 1
  end
  _G.NRCModuleManager:DoCmd(_G.RedPointModuleCmd.ChangeDebugInfoPostion, _positionIdx)
end

local _colorIdx = 0

function DebugTabTUI:ChangeDebugRedPointColor(name, panel, InputText)
  local text
  if panel then
    text = panel.InputBox:GetText()
  else
    text = InputText
  end
  if #text > 0 then
    _colorIdx = tonumber(text)
  else
    _colorIdx = _colorIdx + 1
  end
  _G.NRCModuleManager:DoCmd(_G.RedPointModuleCmd.ChangeDebugInfoColor, _colorIdx)
end

function DebugTabTUI:UsePackTexture()
  _G.GlobalConfig.bUsePackTexture = not _G.GlobalConfig.bUsePackTexture
  if _G.GlobalConfig.bUsePackTexture then
    _G.GlobalConfig.bUsePackTexture190 = false
  end
  Log.Error("\228\189\191\231\148\168\229\155\190\233\155\134" .. tostring(_G.GlobalConfig.bUsePackTexture))
end

function DebugTabTUI:UsePackTexture190()
  _G.GlobalConfig.bUsePackTexture190 = not _G.GlobalConfig.bUsePackTexture190
  if _G.GlobalConfig.bUsePackTexture190 then
    _G.GlobalConfig.bUsePackTexture = false
  else
    _G.GlobalConfig.bUsePackTexture = true
  end
  Log.Error("\228\189\191\231\148\168\230\149\163\229\155\190190" .. tostring(_G.GlobalConfig.bUsePackTexture190))
end

function DebugTabTUI:PrintViewPortInfo()
  local ViewPortSize = UE4.UWidgetLayoutLibrary.GetViewportSize(UE4Helper.GetCurrentWorld())
  local ViewPortScale = UE4.UWidgetLayoutLibrary.GetViewportScale(UE4Helper.GetCurrentWorld())
  Log.Error("ViewPortSize", ViewPortSize)
  Log.Error("ViewPortScale", ViewPortScale)
end

function DebugTabTUI:SetViewPortInfo(name, panel, InputText)
  local viewPortSize
  if panel then
    viewPortSize = panel.InputBox:GetText()
  else
    viewPortSize = InputText
  end
  UE4.UNRCStatics.ExecConsoleCommand("r.SetRes " .. viewPortSize)
  local ViewPortSize = UE4.UWidgetLayoutLibrary.GetViewportSize(UE4Helper.GetCurrentWorld())
  local ViewPortScale = UE4.UWidgetLayoutLibrary.GetViewportScale(UE4Helper.GetCurrentWorld())
  Log.Error("ViewPortSize", ViewPortSize)
  Log.Error("ViewPortScale", ViewPortScale)
end

function DebugTabTUI:OpenSubUMGPanel(Name, Panel, InputNumber)
  local times
  if Panel then
    times = Panel:GetInputNumber()
  else
    times = tonumber(InputNumber)
  end
  for i = 1, times do
    _G.NRCModuleManager:DoCmd(_G.TUIModuleCmd.OpenSubUMGPanel, true)
  end
end

function DebugTabTUI:OpenNoSubUMGPanel(Name, Panel, InputNumber)
  local times
  if Panel then
    times = Panel:GetInputNumber()
  else
    times = tonumber(InputNumber)
  end
  for i = 1, times do
    _G.NRCModuleManager:DoCmd(_G.TUIModuleCmd.OpenNoSubUMGPanel, true)
  end
end

function DebugTabTUI:PrintSumTime()
  _G.NRCProfilerLog:DumpSumTimeLog()
end

function DebugTabTUI:OpenMediaTools()
  _G.NRCModeManager:DoCmd(TUIModuleCmd.OpenOrCloseTUIMediaPanel, false)
end

function DebugTabTUI:CloseMediaTools()
  _G.NRCModeManager:DoCmd(TUIModuleCmd.OpenOrCloseTUIMediaPanel, true)
end

function DebugTabTUI:ShowMapScale()
  _G.GlobalConfig.bShowMapScale = not _G.GlobalConfig.bShowMapScale
end

function DebugTabTUI:ResourceTrack()
  _G.NRCModuleManager:DoCmd(_G.ResTrackerModuleCmd.OpenTrackPanel)
end

function DebugTabTUI:Snapshot(name, panel)
  mcw:DumpCurrMemorySnapshotWithGC()
  _G.SnapshotNum = _G.SnapshotNum + 1
end

function DebugTabTUI:OpenPrintPanelName()
  UE4.UNRCUserWidget.SetIsPrintPanelName(true)
end

function DebugTabTUI:ClosePrintPanelName()
  UE4.UNRCUserWidget.SetIsPrintPanelName(false)
end

function DebugTabTUI:SetUiAlpha()
  _G.NRCModuleManager:GetModule("MainUIModule"):DispatchEvent(MainUIModuleEvent.SetUiAlpha)
  _G.NRCModuleManager:GetModule("UpdateUIModule"):DispatchEvent(UpdateUIModuleEvent.SetUiAlpha)
  _G.NRCModuleManager:GetModule("DebugModule"):DispatchEvent(DebugModuleEvent.SetUiAlpha)
end

function DebugTabTUI:OpenAllInstallerUI()
  local Context = DialogContext()
  Context:SetTitle("\230\181\139\232\175\149"):SetContent("\230\181\139\232\175\149"):SetMode(DialogContext.Mode.OK_CANCEL):SetCallback(self, function(this, result)
  end):SetButtonText(LuaText.YES, LuaText.NO):SetCloseOnCancel(true)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
  _G.NRCAudioManager:PlaySound2DAuto(41401005, "UMG_Update_UI_C:OnClickRepair")
  _G.NRCModuleManager:DoCmd(UpdateUIModuleCmd.OpenRepairToolsPanel)
  local PanelPath = "/Game/NewRoco/Modules/System/UpdateUIModule/Res/UMG_RestartGameMask.UMG_RestartGameMask_C"
  _G.NRCResourceManager:LoadResAsync(self, PanelPath, _G.PriorityEnum.UI_OpenPanel, 0)
end

function DebugTabTUI:TestHudTips()
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.AddTip, TipObject.CreateUnlockUIEnumTip(1))
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.AddTip, TipObject.CreateUnlockUIEnumTip(5))
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.AddTip, TipObject.CreateUnlockUIEnumTip(6))
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "HUD\230\181\139\232\175\149")
end

function DebugTabTUI:RemoveNPCById(Name, Panel, id)
  if Panel then
    local npcId = Panel:GetInputNumber()
    _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.RemoveNPC, npcId)
  elseif id then
    local npcId = id
    _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.RemoveNPC, npcId)
  end
end

function DebugTabTUI:GetStringHeightSize(Name, Panel)
  if Panel then
    Panel:GetStringListSize()
  end
end

function DebugTabTUI:OpenOrCloseCaptureDemoState()
  _G.GlobalConfig.IsDemoCapture = not _G.GlobalConfig.IsDemoCapture
  if _G.GlobalConfig.IsDemoCapture then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\230\136\170\229\177\143demo\229\188\128\229\144\175\239\188\129\239\188\129\239\188\129")
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\230\136\170\229\177\143demo\230\151\160\228\186\134")
  end
end

function DebugTabTUI:HideMainMapMask()
  _G.GlobalConfig.bHideMainMapMask = not _G.GlobalConfig.bHideMainMapMask
  _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.HideMainMapMask, _G.GlobalConfig.bHideMainMapMask)
end

function DebugTabTUI:OpenStateWatchPanel()
  _G.NRCModuleManager:DoCmd(_G.ResTrackerModuleCmd.OpenStateWatchPanel)
end

function DebugTabTUI:OpenShop()
  _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.OpenMainPanel)
end

function DebugTabTUI:OpenSecondPanel(name, panel, InputText)
  local ModuleData = _G.NRCModuleManager:GetModule("DebugModule"):GetData("DebugModuleData"):GetSecondUIType()
  local TabName
  if panel then
    TabName = panel.InputBox:GetText()
  else
    TabName = InputText
  end
  local TabNum = tonumber(TabName:match("%d+"))
  GlobalConfig.OpenMainPanelFromDebugBtn = 1
  if nil ~= TabNum then
    if panel then
      TabName = string.match(panel.InputBox:GetText(), "(.+)%d+")
    else
      TabName = string.match(InputText, "(.+)%d+")
    end
  end
  local TempData = self:GetTempData(TabName)
  for i, Type in ipairs(ModuleData) do
    if TabName == Type.Typename then
      if nil ~= Type.Cmd and nil ~= Type.Index then
        for i = 1, #Type.Index do
          if 2 == i and i == TabNum then
            GlobalConfig.OpenMainPanelFromDebugBtn = 2
          elseif 3 == i and i == TabNum then
            GlobalConfig.OpenMainPanelFromDebugBtn = 3
          elseif 4 == i and i == TabNum then
            GlobalConfig.OpenMainPanelFromDebugBtn = 4
          elseif 5 == i and i == TabNum then
            GlobalConfig.OpenMainPanelFromDebugBtn = 5
          elseif 6 == i and i == TabNum then
            GlobalConfig.OpenMainPanelFromDebugBtn = 6
          elseif 7 == i and i == TabNum then
            GlobalConfig.OpenMainPanelFromDebugBtn = 7
          elseif 8 == i and i == TabNum then
            GlobalConfig.OpenMainPanelFromDebugBtn = 8
          end
        end
      end
      if "Appearance" == TabName or "Beauty" == TabName then
        local AppearanceLocalUtils = require("NewRoco.Modules.System.Appearance.AppearanceLocalUtils")
        if "Appearance" == TabName then
        else
          AppearanceLocalUtils.OpenSalon()
        end
      else
        _G.NRCModeManager:DoCmd(Type.Cmd, TempData)
      end
      if 2 == TabNum then
        if "Map" == TabName then
          local bigMapModule = _G.NRCModuleManager:GetModule("BigMapModule")
          local WorldMapConfigs = bigMapModule.data:GetWorldMapDatas()
          local worldMapCfg = WorldMapConfigs[TempData.world_map_cfg_id]
          _G.NRCModeManager:DoCmd(_G.BigMapModuleCmd.OpenMapRightPanel, 0, TempData, worldMapCfg)
        elseif "BattlePass" == TabName then
          _G.NRCModeManager:DoCmd(_G.BattlePassModuleCmd.OpenPassSelectPanel)
        elseif "HandBook" == TabName then
          local selPetBookInfo = {
            HandbookId = 34,
            PetBaseConf = {name = "\229\178\154\233\184\159"},
            State = 3,
            HandbookNumber = "\231\188\150\229\143\183 034",
            FinshTaskNum = 8
          }
          _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.OpenHandbookSubjectPanel, selPetBookInfo, 3037)
        elseif "StudentCard" == TabName then
          _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.OpenChangeCardLabel)
        end
      end
    end
  end
end

function DebugTabTUI:GetTempData(_name)
  local Data
  if "NPCShop" == _name then
    Data = {
      Config = {action_param1 = "2001"}
    }
  elseif "PetReport" == _name then
    Data = {
      action = nil,
      data = {
        pet_submit_params = {},
        ret_info = {
          goods_change_info = {
            changes = {}
          }
        }
      },
      oldCoinNum = 0
    }
  elseif "PetPanel" == _name then
    Data = {
      subPanelIndex = 4,
      callback = self.OnUMGLoadFinished
    }
  elseif "Map" == _name then
    Data = {
      entry_id = 1125899906842802,
      world_map_cfg_id = 70003,
      npc_refresh_id = 130310
    }
  elseif "AppearancePanel" == _name then
    Data = {
      Config = {action_param1 = "101"}
    }
  elseif "HandBookCover" == _name then
    Data = {isPlayCompass = true}
  end
  return Data
end

function DebugTabTUI:ShowTouchHotArea()
  _G.NRCModuleManager:DoCmd(_G.TUIModuleCmd.ShowTouchHotArea)
end

function DebugTabTUI:EnableFullScreenPanelCollapsed()
  _G.GlobalConfig.EnableFullScreenPanelCollapsed = not _G.GlobalConfig.EnableFullScreenPanelCollapsed
  Log.Error("EnableFullScreenPanelCollapsed", _G.GlobalConfig.EnableFullScreenPanelCollapsed)
end

function DebugTabTUI:OpenDisplayCutoutTool()
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.OpenDisplayCutoutAdjustPanel)
end

function DebugTabTUI:DebugActivityData()
  local activityModule = NRCModuleManager:GetModule("ActivityModule")
  local activityModuleData = activityModule and activityModule.data
  if not activityModuleData then
    return
  end
  self:Inspect(activityModuleData:DumpActivityDetail(), "ActivityData")
  self:ClosePanel()
end

function DebugTabTUI:DebugEnhancedInputData()
  local enhancedInputModule = NRCModuleManager:GetModule("EnhancedInputModule")
  if not enhancedInputModule then
    return
  end
  self:Inspect(enhancedInputModule:DumpEnhancedInputDetail(), "EnhancedInputData")
  self:ClosePanel()
end

function DebugTabTUI:DebugEditorAsPcInTeachManual()
  _G.GlobalConfig.bEditorAsPcInTeachManual = not _G.GlobalConfig.bEditorAsPcInTeachManual
  if _G.GlobalConfig.bEditorAsPcInTeachManual then
    Log.Error("\229\189\147\229\137\141\228\189\156\228\184\186PC\231\171\175")
  else
    Log.Error("\229\189\147\229\137\141\228\189\156\228\184\186\230\137\139\230\156\186\231\171\175")
  end
end

function DebugTabTUI:DebugSvrRedPointData()
  local redPointModule = NRCModuleManager:GetModule("RedPointModule")
  if not redPointModule then
    return
  end
  self:Inspect(redPointModule:DumpSvrRedPointData(), "RedPointData")
  self:ClosePanel()
end

function DebugTabTUI:DebugRolePlayData()
  local debugData = {}
  local panelStatus = {}
  debugData["\231\149\140\233\157\162\231\138\182\230\128\129"] = panelStatus
  local storyFlagEnable = false
  local PlayerStoryFlags = _G.DataModelMgr.PlayerDataModel:GetStoryFlags()
  if PlayerStoryFlags then
    for i, Flag in ipairs(PlayerStoryFlags) do
      if Flag == _G.Enum.PlayerStoryFlagEnum.PSF_FUNC_FASHION_BIGWORLD then
        storyFlagEnable = true
      end
    end
  end
  if not storyFlagEnable then
    panelStatus[string.format("StoryFlag[%d]", _G.Enum.PlayerStoryFlagEnum.PSF_FUNC_FASHION_BIGWORLD)] = storyFlagEnable
  end
  local bBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.GetFunctionState, _G.Enum.PlayerFunctionBanType.PFBT_ROLE_PLAY)
  if bBan then
    panelStatus[string.format("FunctionBanType[%d]", _G.Enum.PlayerFunctionBanType.PFBT_ROLE_PLAY)] = bBan
  end
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player.statusComponent and player.statusComponent:HasAnyStatusExclude(_G.ProtoEnum.WorldPlayerStatusType.WPST_LANDED) then
    panelStatus["\233\153\164WPST_LANDED\229\164\150\229\133\182\229\174\131\231\138\182\230\128\129"] = true
  end
  local relaxData = {}
  debugData["\228\186\146\229\138\168\230\140\137\233\146\174"] = relaxData
  local suitDebugData = {}
  relaxData["\229\189\147\229\137\141\229\165\151\232\163\133"] = suitDebugData
  local suitIdTable = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.CheckSuitEffect)
  if suitIdTable and #suitIdTable > 0 then
    local suitID = tonumber(suitIdTable and suitIdTable[1])
    local suitConf = _G.DataConfigManager:GetFashionSuitsConf(suitID)
    local PerFormConf = _G.DataConfigManager:GetFashionPerformConf(suitConf.perform_id)
    local suitRolePlayId = PerFormConf and PerFormConf.suiteffect3_rest_skill or 0
    suitDebugData.id = suitID
    suitDebugData.name = suitConf and suitConf.name or "\230\156\170\233\133\141\231\189\174"
    suitDebugData.rolePlayId = suitRolePlayId
    suitDebugData.petBaseId = PerFormConf and PerFormConf.petbase3_id or 0
  end
  local curPets = {}
  relaxData["\229\135\186\230\136\152\231\178\190\231\129\181"] = curPets
  local battlePetDatas = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  if battlePetDatas then
    for _, petData in ipairs(battlePetDatas) do
      local petDebugInfo
      local rpId = 0
      local BondInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerBondInfo()
      local BondItem = BondInfo.fashion_bond_item
      local Find_fashion_bond_conf
      for i, v in ipairs(BondItem) do
        local fashion_bond_conf = _G.DataConfigManager:GetFashionBondConf(v.id)
        if fashion_bond_conf and fashion_bond_conf.perform_id then
          local fashion_perform_conf = _G.DataConfigManager:GetFashionPerformConf(fashion_bond_conf.perform_id)
          if fashion_perform_conf and fashion_perform_conf.petbase3_id then
            local petBaseIdList = fashion_perform_conf.petbase3_id
            for _, baseId in ipairs(petBaseIdList) do
              if baseId == petData.base_conf_id then
                Find_fashion_bond_conf = fashion_bond_conf
                break
              end
            end
          end
        end
        if Find_fashion_bond_conf then
          break
        end
      end
      if Find_fashion_bond_conf and Find_fashion_bond_conf.pet_interact_id and 0 ~= Find_fashion_bond_conf.pet_interact_id then
        rpId = Find_fashion_bond_conf.pet_interact_id
      end
      petDebugInfo = string.format("%d@%s", petData.base_conf_id, petData.name)
      if 0 ~= rpId then
        petDebugInfo = string.format("%s[medal=%d]", petDebugInfo, rpId)
      end
      table.insert(curPets, petDebugInfo)
    end
  end
  self:Inspect(debugData, "RolePlay\230\149\176\230\141\174")
end

function DebugTabTUI:DebugWindowsData()
  local debugData = {}
  local positionInScreen = UE4.UNRCTUIStatics.GetPositionInScreen()
  debugData.positionInScreen = string.format("(%s,%s)", tostring(positionInScreen.X), tostring(positionInScreen.Y))
  local sizeInScreen = UE4.UNRCTUIStatics.GetSizeInScreen()
  debugData.sizeInScreen = string.format("(%s,%s)", tostring(sizeInScreen.X), tostring(sizeInScreen.Y))
  self:Inspect(debugData, "\231\170\151\229\143\163\230\149\176\230\141\174")
end

function DebugTabTUI:DebugUISummaryData()
  local summaryData = {}
  local layerCenter = _G.NRCPanelManager.layerCenter
  if layerCenter then
    summaryData["UI\229\177\130\231\186\167\228\191\161\230\129\175"] = layerCenter:GetDebugData()
  end
  summaryData["\229\164\167\228\184\150\231\149\140\230\184\178\230\159\147\231\138\182\230\128\129"] = _G.UE4Helper.GetWorldRenderingDebugData()
  summaryData["\232\181\132\230\186\144\229\138\160\232\189\189\230\168\161\229\188\143"] = _G.UE4Helper.GetDesiredResLoadModeDebugData()
  self:Inspect(summaryData, "UI\230\177\135\230\128\187\228\191\161\230\129\175")
end

function DebugTabTUI:MapCreateItemNumPerSecond(name, panel)
  local num = panel:GetInputNumber()
  _G.GlobalConfig.mapCreateItemNumPerSecond = num
end

function DebugTabTUI:DebugOpenWeeklyChallengeBattle()
  _G.NRCModuleManager:DoCmd(_G.WeeklyChallengeBattleModuleCmd.OpenStarlightPhoto, nil, 0)
end

function DebugTabTUI:DebugSwitchSleepUtility()
  _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.SwitchSleepModeOnEditor)
end

function DebugTabTUI:DebugSwitchSleepUtilityOnPack()
  _G.GlobalConfig.DebugEnableSleepMode = not _G.GlobalConfig.DebugEnableSleepMode
  Log.Warning(string.format("\229\189\147\229\137\141\229\190\133\230\156\186\231\138\182\230\128\129\239\188\154%s", _G.GlobalConfig.DebugEnableSleepMode))
  if _G.SystemSettingModuleCmd then
    _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.SwitchSleepMode)
  end
end

function DebugTabTUI:DebugStartSleepMode()
  _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.EnterSleepModeOnDebug)
end

function DebugTabTUI:DebugOpenRelationTreeShiningMedalPopUp()
  _G.NRCModuleManager:DoCmd(_G.RelationTreeCmd.OpenRelationTreeMedalPopUp, 305005)
end

function DebugTabTUI:DebugHideShop8070Tab()
  local shopPanel = _G.NRCPanelManager:GetPanel("ShopModule", "Shop")
  if not shopPanel then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\229\149\134\229\186\151\231\149\140\233\157\162\230\156\170\230\137\147\229\188\128\239\188\140\232\175\183\229\133\136\230\137\147\229\188\128\229\149\134\229\186\151\231\149\140\233\157\162")
    return
  end
  local found = false
  if shopPanel.ShopList then
    for i = 1, #shopPanel.ShopList do
      if shopPanel.ShopList[i].shopConf[1].shop_id == 8070 then
        found = true
        break
      end
    end
  end
  if not found then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "8070\229\149\134\229\186\151Tab\229\183\178\231\187\143\228\184\141\229\173\152\229\156\168\239\188\140\230\151\160\233\156\128\233\154\144\232\151\143")
    return
  end
  shopPanel:_HandleFashionExchangeTabEmpty()
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\229\183\178\233\154\144\232\151\1438070\229\149\134\229\186\151Tab")
end

function DebugTabTUI:DebugShowShop8070Tab()
  local shopPanel = _G.NRCPanelManager:GetPanel("ShopModule", "Shop")
  if not shopPanel then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\229\149\134\229\186\151\231\149\140\233\157\162\230\156\170\230\137\147\229\188\128\239\188\140\232\175\183\229\133\136\230\137\147\229\188\128\229\149\134\229\186\151\231\149\140\233\157\162")
    return
  end
  if shopPanel.ShopList then
    for i = 1, #shopPanel.ShopList do
      if shopPanel.ShopList[i].shopConf[1].shop_id == 8070 then
        _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "8070\229\149\134\229\186\151Tab\229\183\178\231\187\143\229\173\152\229\156\168\239\188\140\230\151\160\233\156\128\230\152\190\231\164\186")
        return
      end
    end
  end
  shopPanel:_HandleFashionExchangeTabReappear()
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\229\183\178\230\152\190\231\164\1868070\229\149\134\229\186\151Tab")
end

return DebugTabTUI
