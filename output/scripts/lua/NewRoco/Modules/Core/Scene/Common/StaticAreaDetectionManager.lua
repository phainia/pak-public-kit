local Class = _G.MakeSimpleClass
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local MaxCheckPerFrame = 5
local StaticAreaDetectionManager = Class("StaticAreaDetectionManager")

function StaticAreaDetectionManager:Ctor()
  _G.UpdateManager:Register(self)
  self.Areas = {}
  self.CurrentIndex = nil
  self.LastSceneID = 0
  self.bPauseTick = false
  _G.NRCEventCenter:RegisterEvent(self.name, self, SceneEvent.AddStaticArea, self.AddArea)
  _G.NRCEventCenter:RegisterEvent(self.name, self, SceneEvent.RemoveStaticArea, self.RemoveArea)
  _G.NRCEventCenter:RegisterEvent(self.name, self, SceneEvent.LoadMapStart, self.LoadMapStart)
  _G.NRCEventCenter:RegisterEvent(self.name, self, SceneEvent.OnEnterSceneFinishNtyAckEnd, self.LoadMapFinish)
end

function StaticAreaDetectionManager:AddArea(Area)
  if not Area then
    return
  end
  local SceneID = Area:GetSceneID()
  local Name = Area:GetUniqueName()
  local Areas = self:GetSceneArea(SceneID, true)
  Areas[Name] = Area
end

function StaticAreaDetectionManager:RemoveArea(Area)
  if not Area then
    return
  end
  local SceneID = Area:GetSceneID()
  local Name = Area:GetUniqueName()
  local Areas = self:GetSceneArea(SceneID, false)
  if not Areas then
    return
  end
  Areas[Name] = nil
end

function StaticAreaDetectionManager:LoadMapStart(SameSceneRes, bReconnecting, SceneID, SceneResID)
  self.bPauseTick = true
  local SceneChanged = self.LastSceneID ~= SceneID
  if SceneChanged then
    self:Stop()
  end
  local Areas = self:GetSceneArea(self.LastSceneID, false)
  if Areas then
    for _, Area in pairs(Areas) do
      if Area and Area:InArea() and (Area.bRevokeOnDisconnect or SceneChanged) then
        Area:OnPlayerLeave(0, 0, 0, 0, 0)
      end
    end
  end
end

function StaticAreaDetectionManager:LoadMapFinish(bReconnecting)
  self.bPauseTick = false
end

function StaticAreaDetectionManager:Stop()
  self.CurrentIndex = nil
end

function StaticAreaDetectionManager:GetSceneArea(SceneID, Create)
  local Areas = self.Areas[SceneID]
  if not Areas and Create then
    Areas = {}
    self.Areas[SceneID] = Areas
  end
  return Areas
end

function StaticAreaDetectionManager:OnTick(DeltaTime)
  if self.bPauseTick then
    self:Stop()
    return
  end
  local State = _G.SceneModuleCmd and _G.NRCModuleManager:DoCmd(_G.SceneModuleCmd.CheckSceneFullyEntered) or false
  if not State then
    self:Stop()
    return
  end
  local CurrentSceneID = SceneUtils.GetSceneID()
  local Areas = self:GetSceneArea(CurrentSceneID, false)
  if not Areas or type(Areas) ~= "table" then
    self:Stop()
    return
  end
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not Player then
    self:Stop()
    return
  end
  local PlayerView = Player.viewObj
  if not PlayerView or not UE.UObject.IsValid(PlayerView) then
    self:Stop()
    return
  end
  if PlayerView.BP_RideComponent and PlayerView.BP_RideComponent.RidePet then
    PlayerView = PlayerView.BP_RideComponent.RidePet
  end
  local PlayerHalfHeight, PlayerRadius = Player:GetControlPawnCapsuleSize()
  local X, Y, Z = PlayerView:Abs_K2_GetActorLocation_XYZ()
  for _ = 1, MaxCheckPerFrame do
    if self.CurrentIndex ~= nil and Areas[self.CurrentIndex] == nil then
      self.CurrentIndex = nil
    end
    local Name, Area = next(Areas, self.CurrentIndex)
    if not Name then
      self:Stop()
      break
    end
    self:CheckPlayerInArea(Area, X, Y, Z, PlayerRadius, PlayerHalfHeight)
    self.CurrentIndex = Name
  end
  self.LastSceneID = CurrentSceneID
end

function StaticAreaDetectionManager:CheckPlayerInArea(Area, X, Y, Z, PlayerRadius, PlayerHalfHeight)
  local WasInArea = Area:InArea()
  local IsInArea = Area:BroadCheck(X, Y, Z, PlayerRadius, PlayerHalfHeight) and Area:FineCheck(X, Y, Z, PlayerRadius, PlayerHalfHeight)
  if not WasInArea and IsInArea then
    Area:OnPlayerEnter(X, Y, Z, PlayerRadius, PlayerHalfHeight)
  elseif WasInArea and not IsInArea then
    Area:OnPlayerLeave(X, Y, Z, PlayerRadius, PlayerHalfHeight)
  end
end

function StaticAreaDetectionManager:Destroy()
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.AddStaticArea, self.AddArea)
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.RemoveStaticArea, self.RemoveArea)
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.LoadMapStart, self.LoadMapStart)
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.LoadMapFinish, self.LoadMapFinish)
  _G.UpdateManager:UnRegister(self)
  for _, AreaList in pairs(self.Areas) do
    for _, Area in pairs(AreaList) do
      if Area then
        Area:Destroy()
      end
    end
  end
  table.clear(self.Areas)
end

return StaticAreaDetectionManager
