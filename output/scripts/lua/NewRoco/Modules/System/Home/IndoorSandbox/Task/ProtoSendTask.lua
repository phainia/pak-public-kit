local Super = require("NewRoco/Modules/System/Home/IndoorSandbox/HomeTask")
local ProtoSendTask = Super:Extend("ProtoSendTask")

function ProtoSendTask:Ctor(ProtoFuncName, ...)
  Super.Ctor(self)
  local Server = HomeIndoorSandbox.Server
  self.ProtoFuncName = ProtoFuncName
  self.ProtoFunc = Server[ProtoFuncName]
  HomeIndoorSandbox:Ensure(self.ProtoFunc, "invalid proto function", ProtoFuncName)
  self.SendDelegate = FPartial(self.ProtoFunc, Server, FPartial(self.NotifyFinish, self), ...)
  _G.NRCEventCenter:RegisterEvent("HomeModule.ProtoSendTask", self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisConnect)
  _G.NRCEventCenter:RegisterEvent("HomeModule.ProtoSendTask", self, _G.SceneEvent.OnEnterSceneFinishNtyAck, self.OnEnterSceneFinishNtyAck)
end

function ProtoSendTask:OnStart()
  self.bNeedTry = not self.SendDelegate()
end

function ProtoSendTask:OnClean()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisConnect)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.SceneEvent.OnEnterSceneFinishNtyAck, self.OnEnterSceneFinishNtyAck)
end

function ProtoSendTask:OnEnterSceneFinishNtyAck()
  HomeIndoorSandbox:LogWarn("OnEnterSceneFinishNtyAck")
  self.bEnableTry = true
end

function ProtoSendTask:OnUpdate()
  if self.bEnableTry and self.bNeedTry then
    self.bEnableTry = false
    self.bNeedTry = not self.SendDelegate()
    HomeIndoorSandbox:Ensure(not self.bNeedTry, "cannot send proto", self.ProtoFuncName)
  end
end

function ProtoSendTask:OnDisConnect()
  HomeIndoorSandbox:LogWarn("OnDisConnect")
  self.bNeedTry = true
end

return ProtoSendTask
