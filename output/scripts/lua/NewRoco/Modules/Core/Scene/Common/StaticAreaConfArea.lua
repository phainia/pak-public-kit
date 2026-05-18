local StaticAreaBase = require("NewRoco.Modules.Core.Scene.Common.StaticAreaBase")
local Base = StaticAreaBase
local StaticAreaConfArea = Base:Extend("StaticAreaConfArea")

function StaticAreaConfArea.MakeWithAreaConf(Name, AreaID, Option)
  local Conf = _G.DataConfigManager:GetAreaConf(AreaID)
  if not Conf then
    return nil
  end
  local Region = NewObject(UE.URegion, _G.UE4Helper.GetCurrentWorld())
  local RegionRef = UnLua.Ref(Region)
  local MinZ, MaxZ, Success = Region:BuildAreaConf(AreaID)
  if not Success then
    return nil
  end
  local Inst = StaticAreaConfArea()
  Inst.AreaID = AreaID
  Inst.UniqueName = Name
  Inst.SceneID = Conf.scene_id
  Inst.Region = Region
  Inst.RegionRef = RegionRef
  Inst.MinZ = MinZ
  Inst.MaxZ = MinZ + Conf.area_height
  Inst.Option = Option
  return Inst
end

function StaticAreaConfArea:Ctor()
  Base.Ctor(self)
  self.MinZ = 0
  self.MaxZ = 0
end

function StaticAreaConfArea:BroadCheck(X, Y, Z, PlayerRadius, PlayerHalfHeight)
  if self.MinZ == self.MaxZ then
    return true
  end
  if Z + PlayerHalfHeight < self.MinZ or Z - PlayerHalfHeight > self.MaxZ then
    return false
  end
  return true
end

function StaticAreaConfArea:FineCheck(X, Y, Z, PlayerRadius, PlayerHalfHeight)
  if not UE4.UObject.IsValid(self.Region) then
    return false
  end
  return self.Region:ContainPointXY(X, Y)
end

function StaticAreaConfArea:Destroy()
  self.RegionRef = nil
  self.Region = nil
  if self.Option and self.Option.inActionArea then
    self.Option:OnOptionLeave()
  end
  Base.Destroy(self)
end

function StaticAreaConfArea:OnPlayerEnter(X, Y, Z, PlayerRadius, PlayerHalfHeight)
  if self.Option then
    self.bPreviouslyInArea = self.Option:OnOptionEnter()
  else
    Base.OnPlayerEnter(self, X, Y, Z, PlayerRadius, PlayerHalfHeight)
  end
end

function StaticAreaConfArea:OnPlayerLeave(X, Y, Z, PlayerRadius, PlayerHalfHeight)
  if self.Option then
    self.bPreviouslyInArea = self.Option:OnOptionLeave()
  else
    Base.OnPlayerLeave(self, X, Y, Z, PlayerRadius, PlayerHalfHeight)
  end
end

function StaticAreaConfArea:ResetPlayerInArea()
  self.bPreviouslyInArea = false
end

return StaticAreaConfArea
