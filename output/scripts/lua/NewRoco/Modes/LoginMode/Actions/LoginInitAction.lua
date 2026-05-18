local NRCModeAction = require("Core.NRCMode.NRCModeAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local LoginModuleEvent = reload("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local LoginUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")
local CreatePlayerModuleCmd = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerModuleCmd")
local Base = NRCModeAction
local LoginInitAction = Base:Extend("LoginInitAction")

function LoginInitAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function LoginInitAction:OnEnter()
  Log.Debug("LoginInitAction:OnEnter")
  local PropertyHolder = LoginUtils.GetPropertyHolder() or NRCModuleManager:DoCmd(CreatePlayerModuleCmd.GetCreatePlayerFsm)
  PropertyHolder.bPendingEnd = false
  PropertyHolder.bIsMale = nil
  local curLevelName = LevelHelper:GetLevelName()
  Log.Debug("EnterLoginLevelAction CurLevelName ", curLevelName)
  if "Login" == curLevelName or "Plot_A1_LearnMagic_New_Release" == curLevelName then
    self:StartLogin()
  else
    NRCEventCenter:RegisterEvent("OnMapLoaded", self, NRCGlobalEvent.PostLoadMapWithWorld, self.OnMapLoaded)
    LevelHelper:OpenLevel("/Game/Levels/Login")
  end
end

function LoginInitAction:OnFinish()
  Log.Debug("LoginInitAction finish")
end

function LoginInitAction:OnMapLoaded()
  Log.Debug("EnterLoginLevelAction:OnMapLoaded")
  _G.DelayManager:DelayFrames(1, function()
    NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.PostLoadMapWithWorld, self.OnMapLoaded)
    self:StartLogin()
  end)
end

function LoginInitAction:StartLogin()
  LoginUtils.DestroyActors()
  LoginUtils.InitActors(self, self.OnInitActorFinished)
end

function LoginInitAction:OnInitActorFinished()
  self.fsm.UseTimerFlag = true
  local controller = LoginUtils.GetLoginController()
  local ActorHolder = LoginUtils.GetUObjectHolder()
  controller:SetPlayerMesh(ActorHolder.Player1, ActorHolder.Player2)
  controller:CreatePlayerCenter()
  ActorHolder.PlayerCenter = controller.playerCenter
  self:Finish()
end

return LoginInitAction
