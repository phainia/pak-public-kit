local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local MainUIModuleCmd = require("NewRoco.Modules.System.MainUI.MainUIModuleCmd")
local Base = DebugTabBase
local DebugTabLua = Base:Extend("DebugTabLua")

function DebugTabLua:Ctor()
  Base.Ctor(self)
  self.npcInsId = 0
end

function DebugTabLua:SetupTabs()
end

function DebugTabLua:BlockLog()
  Log.SetLogLevel(Log.LOG_LEVEL.ELogFatal)
  UE4.UNRCStatics.SetLogLevel(0)
end

function DebugTabLua:OpenTestUmg()
  NRCModuleManager:DoCmd(NPCShopUIModuleCmd.OpenNPCShopTempPanel)
end

function DebugTabLua:BindClient()
end

function DebugTabLua:ShowObjectRefs()
  UE4.UNRCStatics.ShowRefObject(false)
end

function DebugTabLua:ShowRefObjectByType()
  UE4.UNRCStatics.ShowRefObjectByType()
end

function DebugTabLua:DumpClass()
  Log.Dump(_G.ClassesTable, 3)
end

function DebugTabLua:DumpRegister()
  Log.Debug("show registry len:", #debug.getregistry(), debug.getregistry()[1])
end

function DebugTabLua:DumpLoadedModule()
  for k, v in pairs(package.loaded) do
    Log.Debug("show me registry:", k, v)
  end
end

function DebugTabLua:OnShowLuaMem()
  Log.Error(collectgarbage("count"))
end

function DebugTabLua:GC()
  collectgarbage("collect")
end

function DebugTabLua:GCUE()
  UE4.UNRCStatics.ForceGarbageCollection(true)
end

function DebugTabLua:GCOnTick(name, panel, InputText)
  local v
  if panel then
    v = panel.InputBox:GetText()
  else
    v = InputText
  end
  if "" == v then
    v = 1
  end
  _G.StartAutoGCByTick = tonumber(v)
end

function DebugTabLua:GCOnTickTwice(...)
  _G.StartAutoGCByTickTwice = true
end

function DebugTabLua:DumpPanelManager()
  Log.Dump(NRCPanelManager)
end

function DebugTabLua:DumpModule()
  Log.Dump(NRCModuleManager)
end

function DebugTabLua:DumpLoginModule()
  local loginModule = NRCModuleManager:GetModule("LoginModule")
  if not loginModule then
    Log.Debug("gooooood")
  end
end

function DebugTabLua:DeactiveLoginModule()
  NRCModuleManager:DeactiveModule("LoginModule")
end

function DebugTabLua:ForceClearPanelManager()
  for k, v in pairs(NRCPanelManager) do
    NRCPanelManager[k] = nil
  end
end

function DebugTabLua:OnOpenTestLoginPanel()
  NRCModuleManager:DoCmd(LoginModuleCmd.OpenTestLoginPanel)
end

function DebugTabLua:OnCloseTestLoginPanel()
  NRCModuleManager:DoCmd(LoginModuleCmd.CloseTestLoginPanel)
end

function DebugTabLua:OnOpenTestLoginPanelC()
  UE4.UNRCStatics.TestOpenPanel()
end

function DebugTabLua:OnCloseTestLoginPanelC()
  UE4.UNRCStatics.TestClosePanel()
end

function DebugTabLua:OpenPanelLobbyMain(...)
  NRCModeManager:DoCmd(MainUIModuleCmd.OpenPanelLobbyMain)
end

function DebugTabLua:ClosePanelLobbyMain(...)
  NRCModeManager:DoCmd(MainUIModuleCmd.ClosePanelLobbyMain)
end

function DebugTabLua:ShowMiniWidget()
  Log.Debug("UE4.UNRCPlatformGameInstance.GetInstance().MinimapWidget:", UE4.UNRCPlatformGameInstance.GetInstance().MinimapWidget:GetName())
end

function DebugTabLua:OnPrintObjList()
  UE4.UNRCStatics.ShowRefObject()
end

function DebugTabLua:OnPrintObjListNone()
  UE4.UNRCStatics.ShowRefObject(true)
end

function DebugTabLua:OnPrintFunctionList()
  UE4.UNRCStatics.ShowRefFunction()
end

function DebugTabLua:OnPrintObjMap()
  if debug.getregistry().ObjectMap then
    for k, v in pairs(debug.getregistry().ObjectMap) do
      Log.Debug("OnPrintObjMap:", k, v, v:GetName(), type(v))
    end
  end
end

function DebugTabLua:OnStopCheckSkillRes()
  _G.StopCheckBattleSkillResIsExist = true
end

function DebugTabLua:OnStartCheckSkillRes()
  _G.StopCheckBattleSkillResIsExist = false
end

function DebugTabLua:OnForceReleaseSkill(name, panel, InputText)
  local inputText
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  if "" == inputText then
    UE4.USkillRecordLibrary.ReleaseSkill("/Game/ArtRes/Effects/G6Skill/Jineng/708002")
  else
    UE4.USkillRecordLibrary.ReleaseSkill("/Game/ArtRes/Effects/G6Skill/Jineng/" .. inputText)
  end
end

function DebugTabLua:OnLogInstance()
  LogInstance()
end

function DebugTabLua:OnCloseNotNecessaryModule()
  _G.CloseNotNecessaryModule = true
end

function DebugTabLua:RemovePendingKillObject()
  UE4.UNRCStatics.RemovePendingKillObject()
end

function DebugTabLua:OnUnLua_UnRegisterClass()
  local skillPath = "/Game/ArtRes/Effects/G6Skill/Jineng/G6_Ice_BDGX_709003"
  local g6SkillClass = _G.NRCResourceManager:LoadForDebugOnly(skillPath)
  UnLua_UnRegisterClass("UG6_Ice_BDGX_709003_C")
end

function DebugTabLua:PrintGetProperty()
  _G.PrintGetProperty = true
end

function DebugTabLua:OpenLuaProfiler(Name, Panel)
  UE4.FToolKitModule:EnableToolKitFunc()
end

function DebugTabLua:DonntUnloadUmgAsset(Name, Panel)
  _G.DonntUnloadUmgAsset = true
end

function DebugTabLua:ForceRefUClass(Name, Panel)
  _G.ForceRefUClass = true
end

function DebugTabLua:OnDisableWorldRender()
  UE4Helper.SetEnableWorldRendering(false)
end

function DebugTabLua:OnEnableWorldRender()
  UE4Helper.SetEnableWorldRendering(true)
end

function DebugTabLua:OnEnableUIOnly()
  UE4.UNRCTUIStatics.SetEnableUIOnlyRendering(true)
end

function DebugTabLua:OnDisableUIOnly()
  UE4.UNRCTUIStatics.SetEnableUIOnlyRendering(false)
end

function DebugTabLua:OnUseNPCShopTemp()
  _G.bUseNPCShopTemp = true
end

function DebugTabLua:OnForceNPCShopCache()
  _G.bForceNPCShopCache = true
end

function DebugTabLua:OnForceNPCShopNotCache()
  _G.bForceNPCShopCache = false
end

function DebugTabLua:OnForceImageLoadSync()
  _G.bForceImageLoadAsync = false
end

function DebugTabLua:OnForceImageLoadAsync()
  _G.bForceImageLoadAsync = true
end

function DebugTabLua:OpenNPCShop()
  _G.NRCModuleManager:DoCmd(_G.NPCShopUIModuleCmd.OpenNPCShopTempPanel)
end

function DebugTabLua:ClearDelayManager()
  _G.DelayManager:ClearAll()
end

function DebugTabLua:DumpDelayManager()
  self:Inspect(_G.DelayManager, "DelayManager")
end

function DebugTabLua:MonitorDelayManager()
  _G.DelayManager.bMonitoring = not _G.DelayManager.bMonitoring
end

function DebugTabLua:EnableLuaProfile(Name, Panel)
  UE.UNRCStatics.EnableLuaProfile(true)
end

function DebugTabLua:DisableLuaProfile(Name, Panel)
  UE.UNRCStatics.EnableLuaProfile(false)
end

function DebugTabLua:EnableLuaDebugger(Name, Panel)
  UE.UNRCStatics.EnableLuaDebugger(self:GetInputNumber(5067))
end

function DebugTabLua:DisableLuaDebugger(Name, Panel)
  UE.UNRCStatics.EnableLuaDebugger(0)
end

function DebugTabLua:ExecLua()
  UE4.UNRCPlatformGameInstance.GetInstance():ExecDoString(self:GetInputString())
end

function DebugTabLua:EnableLuaCPPProfile(Name, Panel)
  UE.UNRCStatics.EnableLuaCPPProfile(true)
end

function DebugTabLua:DisableLuaCPPProfile(Name, Panel)
  UE.UNRCStatics.EnableLuaCPPProfile(false)
end

function DebugTabLua:EnableLoadingProfiler()
  LoadingProfiler:SetEnable(true)
end

function DebugTabLua:DisableLoadingProfiler()
  LoadingProfiler:SetEnable(false)
end

function DebugTabLua:StopLoadingProfiler()
  LoadingProfiler:Stop()
end

function DebugTabLua:EnableLoadPriority()
  _G.EnableLoadPriority = true
end

function DebugTabLua:DisableLoadPriority()
  _G.EnableLoadPriority = false
end

return DebugTabLua
