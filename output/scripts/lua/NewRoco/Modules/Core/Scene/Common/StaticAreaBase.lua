local Class = _G.MakeSimpleClass
local StaticAreaBase = Class("StaticAreaBase")

function StaticAreaBase:Ctor()
  self.bPreviouslyInArea = false
  self.SceneID = 0
  self.UniqueName = ""
  self.bRevokeOnDisconnect = false
end

function StaticAreaBase:StartDetect()
  _G.NRCEventCenter:DispatchEvent(_G.SceneEvent.AddStaticArea, self)
end

function StaticAreaBase:StopDetect()
  _G.NRCEventCenter:DispatchEvent(_G.SceneEvent.RemoveStaticArea, self)
end

function StaticAreaBase:GetSceneID()
  return self.SceneID
end

function StaticAreaBase:GetUniqueName()
  return self.UniqueName
end

function StaticAreaBase:BroadCheck(X, Y, Z, PlayerRadius, PlayerHalfHeight)
  return false
end

function StaticAreaBase:FineCheck(X, Y, Z, PlayerRadius, PlayerHalfHeight)
  return false
end

function StaticAreaBase:OnPlayerEnter(X, Y, Z, PlayerRadius, PlayerHalfHeight)
  self.bPreviouslyInArea = true
end

function StaticAreaBase:OnPlayerLeave(X, Y, Z, PlayerRadius, PlayerHalfHeight)
  self.bPreviouslyInArea = false
end

function StaticAreaBase:InArea()
  return self.bPreviouslyInArea
end

function StaticAreaBase:Destroy()
end

return StaticAreaBase
