local ResObjectBase = require("NewRoco.Utils.ResObjectBase")
local Base = ResObjectBase
local ModelResObject = Base:Extend("ModelResObject")

function ModelResObject.MakeModel(ConfID, Position, Dir, Priority)
  if not ConfID or 0 == ConfID then
    return nil
  end
  local Res = ModelResObject(ConfID, Position, Dir, Priority)
  return Res
end

function ModelResObject:Ctor(ConfID, Position, Dir, Priority)
  Base.Ctor(self)
  self.Model = nil
  self.ConfID = ConfID
  self.Position = Position
  self.Dir = Dir
  self.ID = 0
  self.Priority = Priority or -1
  self.DisableFixCoord = true
end

function ModelResObject:DoLoad()
  local modelConf = _G.DataConfigManager:GetModelConf(self.ConfID)
  if not modelConf then
    self:FireCallback(false)
    return
  end
  self.Path = modelConf.path
  self.Request = _G.NRCResourceManager:LoadResAsync(self, self.Path, self.Priority, 0, self.OnSuccess, self.OnFailed)
end

function ModelResObject:OnSuccess(Request, Object)
  self.LoadedAsset = Object
  self.LoadedAssetRef = UnLua.Ref(Object)
  if not self.KeepRequest then
    _G.NRCResourceManager:UnLoadRes(self.Request)
    self.Request = nil
  end
  if self.LoadedAsset then
    local World = _G.UE4Helper.GetCurrentWorld()
    local quat = UE4.FQuat.FromAxisAndAngle(_G.UE4Helper.UpVector, 0)
    local fTransfom = UE4.FTransform(quat, UE4.FVector(-10000, -10000, -10000))
    self.Model = World:Abs_SpawnActor(self.LoadedAsset, fTransfom, UE4.ESpawnActorCollisionHandlingMethod.AdjustIfPossibleButAlwaysSpawn, nil, nil, nil, {})
    if self.Model.InitOutSceneAsync then
      self.Model:InitOutSceneAsync(self, self.OnActorResLoaded)
    else
      self:FireCallback(true, self.Model)
    end
    self.Model.IsFakeNpc = true
  end
end

function ModelResObject:OnFailed()
  self.LoadedAsset = nil
  self.LoadedAssetRef = nil
  if not self.KeepRequest then
    _G.NRCResourceManager:UnLoadRes(self.Request)
    self.Request = nil
  end
  self:FireCallback(false)
end

function ModelResObject:OnActorResLoaded()
  if self.Model then
    self:FireCallback(true, self.Model)
  else
    self:FireCallback(false)
  end
end

function ModelResObject:DoGet()
  if self.Model then
    return self.Model
  end
  return nil
end

function ModelResObject:DoRelease()
  if self.Model then
    self.Model:K2_DestroyActor()
  end
  if self.Request then
    _G.NRCResourceManager:UnLoadRes(self.Request)
  end
  self.ID = 0
  self.Model = nil
  self.LoadedAsset = nil
  self.LoadedAssetRef = nil
end

return ModelResObject
