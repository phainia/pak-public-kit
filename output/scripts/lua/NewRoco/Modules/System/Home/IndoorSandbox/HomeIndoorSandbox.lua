local HomeResMgr = require("NewRoco/Modules/System/Home/IndoorSandbox/HomeResMgr")
local HomeTaskMgr = require("NewRoco/Modules/System/Home/IndoorSandbox/HomeTaskMgr")
local HomeWorld = require("NewRoco/Modules/System/Home/IndoorSandbox/Scene/HomeWorld")
local HomeServer = require("NewRoco/Modules/System/Home/IndoorSandbox/HomeServer")
local HomeUtils = require("NewRoco/Modules/System/Home/IndoorSandbox/HomeUtils")
local HomeDefine = require("NewRoco/Modules/System/Home/IndoorSandbox/HomeDefine")
local HomeModuleEvent = require("NewRoco.Modules.System.Home.HomeModuleEvent")
local HomeDecoService = require("NewRoco/Modules/System/Home/IndoorSandbox/Service/HomeDecoService")
local HomePropsService = require("NewRoco/Modules/System/Home/IndoorSandbox/Service/HomePropsService")
local HomeEnterMap = require("NewRoco/Modules/System/Home/IndoorSandbox/Service/HomeEnterMap")
local HomeUpgrade = require("NewRoco/Modules/System/Home/IndoorSandbox/Service/HomeUpgrade")
local HomeEditService = require("NewRoco/Modules/System/Home/IndoorSandbox/Service/HomeEditService")
local HomeTipsService = require("NewRoco/Modules/System/Home/IndoorSandbox/Service/HomeTipsService")
local HomeCreationService = require("NewRoco/Modules/System/Home/IndoorSandbox/Service/HomeCreationService")
local HomeAIService = require("NewRoco/Modules/System/Home/IndoorSandbox/Service/HomeAIService")
local HomeLightService = require("NewRoco/Modules/System/Home/IndoorSandbox/Service/HomeLightService")
local HomeEnum = require("NewRoco/Modules/System/Home/HomeEnum")
local HomeIndoorSandbox = Singleton:Extend("HomeIndoorSandbox")

function HomeIndoorSandbox:Ctor(name)
  Singleton.Ctor(self, name)
  self:OnConstruct()
end

function HomeIndoorSandbox:OnConstruct()
  self.Module = NRCModuleManager:GetModule("HomeModule")
  self.ResMgr = HomeResMgr()
  self.TaskMgr = HomeTaskMgr()
  self.EnterMapServ = HomeEnterMap()
  self.UpgradeServ = HomeUpgrade()
  self.HomeDecoServ = HomeDecoService()
  self.HomePropsServ = HomePropsService()
  self.HomeEditServ = HomeEditService()
  self.HomeTipsServ = HomeTipsService()
  self.HomeCreationServ = HomeCreationService()
  self.HomeAIServ = HomeAIService()
  self.HomeLightServ = HomeLightService()
  self.Services = {
    self.EnterMapServ,
    self.UpgradeServ,
    self.HomeDecoServ,
    self.HomePropsServ,
    self.HomeEditServ,
    self.HomeTipsServ,
    self.HomeCreationServ,
    self.HomeAIServ,
    self.HomeLightServ
  }
  self.World = HomeWorld()
  self.Server = HomeServer()
  self.Utils = HomeUtils
  self.Define = HomeDefine
  self.Event = HomeModuleEvent
  self.Enum = HomeEnum
  
  function self.DummyFunction()
  end
end

function HomeIndoorSandbox:LogDebug(...)
  return Log.Debug("[Home]", ...)
end

function HomeIndoorSandbox:LogInfo(...)
  return Log.Info("[Home]", ...)
end

function HomeIndoorSandbox:LogWarn(...)
  return Log.Warning("[Home]", ...)
end

function HomeIndoorSandbox:Ensure(Expr, ...)
  if not Expr then
    return Log.Error("[Home]", ...)
  end
  return Expr
end

function HomeIndoorSandbox:DebugTips(Fmt, ...)
end

function HomeIndoorSandbox:RegisterEvent(EventName, Caller, Delegate)
  local Home = NRCModuleManager:GetModule("HomeModule")
  return Home:RegisterEvent(Caller, EventName, Delegate)
end

function HomeIndoorSandbox:UnRegisterEvent(EventName, Caller)
  local Home = NRCModuleManager:GetModule("HomeModule")
  return Home:UnRegisterEvent(Caller, EventName)
end

function HomeIndoorSandbox:DispatchEvent(EventName, ...)
  local Home = NRCModuleManager:GetModule("HomeModule")
  return Home:DispatchEvent(EventName, ...)
end

function HomeIndoorSandbox:ReqEnterHomeScene(HomeInfo)
  self:LogInfo("ReqEnterHomeScene", HomeInfo)
  self.EnterMapServ:ReqEnterHome(HomeInfo)
end

function HomeIndoorSandbox:ReqExitHome(isPassive)
  self.EnterMapServ:ReqExitHome(isPassive)
end

function HomeIndoorSandbox:OnExitMap()
  for _, Service in ipairs(self.Services) do
    Service:OnExitHome()
  end
  self.ResMgr:OnExitHome()
end

function HomeIndoorSandbox:InHomeIndoor()
  return self.EnterMapServ.bInHomeIndoor or false
end

function HomeIndoorSandbox:InOtherHomeIndoor()
  return self.EnterMapServ.bInHomeIndoor and not self.Server:IsLocalMaster()
end

function HomeIndoorSandbox:InLocalMasterIndoor()
  return self:InHomeIndoor() and self.Server:IsLocalMaster()
end

return HomeIndoorSandbox
