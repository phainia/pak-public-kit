local BigMapUtils = require("NewRoco/Modules/System/BigMap/BigMapUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local CompassUIData = require("NewRoco.Modules.System.MainUI.Res.compass.CompassUIData")
local Base = CompassUIData
local VisitCompassUIData = Base:Extend("VisitCompassUIData")

function VisitCompassUIData:InitData(Info, ViewField, index)
  Base.ResetData(self)
  local _SceneResId, iconSceneResId, posX, posY, posZ = BigMapUtils.GetVisitorIconSceneResIdAndPos(Info)
  local Position = UE4.FVector(posX, posY, posZ)
  if SceneUtils.GetSceneResId() ~= 10003 and SceneUtils.GetSceneResId() ~= 10018 then
    Position = UE4.FVector(Info.pos.pos.x, Info.pos.pos.y, Info.pos.pos.z)
  end
  self:SetPos(Position)
  self.TaskAngleLimit = ViewField
  self.HasArrived = Info.HasArrived or false
  self.UIN = Info.uin
  self.CurState = CompassUIData.MapAreaState.Visit
  self:SetIsBig(true)
  self.index = index
  self:SetZOrder(self.index)
end

function VisitCompassUIData:UpdateData(Info, index)
  local _SceneResId, iconSceneResId, posX, posY, posZ = BigMapUtils.GetVisitorIconSceneResIdAndPos(Info)
  local Position = UE4.FVector(posX, posY, posZ)
  if SceneUtils.GetSceneResId() ~= 10003 and SceneUtils.GetSceneResId() ~= 10018 then
    Position = UE4.FVector(Info.pos.pos.x, Info.pos.pos.y, Info.pos.pos.z)
  end
  self:SetPos(Position)
  self.HasArrived = Info.HasArrived or false
  self.UIN = Info.uin
  if self.index ~= index then
    self:SetZOrder(self.index)
  end
  self.index = index
  if self.CompWidget then
    self.CompWidget:SetIndex(self.index)
  end
end

function VisitCompassUIData:SetIndex()
  if self.CompWidget then
    self.CompWidget:SetIndex(self.index)
  end
end

function VisitCompassUIData:SetIsBig(isBig, isForce)
  Base.SetIsBig(self, isBig, isForce)
  if self.CompWidget then
    local Font = self.CompWidget.SerialNumber.Font
    if isBig then
      Font.Size = 25
      self.CompWidget.SerialNumber:SetFont(Font)
    else
      Font.Size = 20
      self.CompWidget.SerialNumber:SetFont(Font)
    end
  end
end

function VisitCompassUIData:OnDestruct()
  Base.OnDestruct(self)
end

return VisitCompassUIData
