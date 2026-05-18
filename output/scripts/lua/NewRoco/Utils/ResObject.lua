local ResObjectBase = require("NewRoco.Utils.ResObjectBase")
local ResObjectState = require("NewRoco.Utils.ResObjectState")
local Base = ResObjectBase
local ResObject = Base:Extend("ResObject")

function ResObject.MakeUClass(Path, Priority)
  if string.IsNilOrEmpty(Path) then
    return nil
  end
  Path = _G.NRCUtils.FormatBlueprintAssetPath(Path)
  local Inst = ResObject(Path, Priority or -1)
  return Inst
end

function ResObject.MakeUObject(Path, Priority)
  if string.IsNilOrEmpty(Path) then
    return nil
  end
  local Inst = ResObject(Path, Priority or -1)
  return Inst
end

function ResObject:Ctor(Path, Priority)
  Base.Ctor(self)
  self.Path = Path
  self.KeepRequest = false
  self.Priority = Priority or 0
  self.CallbackOwner = nil
  self.Callback = nil
end

function ResObject:DoLoad()
  self.Request = _G.NRCResourceManager:LoadResAsync(self, self.Path, self.Priority, 0, self.OnSuccess, self.OnFailed)
end

function ResObject:DoRelease()
  if self.Request then
    _G.NRCResourceManager:UnLoadRes(self.Request)
    self.Request = nil
  end
  self.LoadedAsset = nil
  self.LoadedAssetRef = nil
end

function ResObject:DoGet()
  return self.LoadedAsset
end

function ResObject:OnSuccess(Request, Object)
  self.LoadedAsset = Object
  self.LoadedAssetRef = UnLua.Ref(Object)
  if not self.KeepRequest then
    _G.NRCResourceManager:UnLoadRes(self.Request)
    self.Request = nil
  end
  self:FireCallback(true, self.LoadedAsset)
end

function ResObject:OnFailed(Request, Message)
  Log.Error("ResObject\232\181\132\230\186\144\229\138\160\232\189\189\229\164\177\232\180\165", Request.assetPath, Message)
  self.LoadedAsset = nil
  self.LoadedAssetRef = nil
  if not self.KeepRequest then
    _G.NRCResourceManager:UnLoadRes(self.Request)
    self.Request = nil
  end
  self:FireCallback(false)
end

return ResObject
