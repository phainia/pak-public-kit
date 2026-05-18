local Singleton = _G.Singleton
local CurveStatics = Singleton:Extend("CurveStatics")

function CurveStatics:LoadOrGetCurveAsync(path)
  if not path then
    return nil
  end
  if not self.loaded_res then
    self.loaded_res = {}
  end
  if self.loaded_res[path] then
    return self.loaded_res[path]
  end
  local req = _G.NRCResourceManager:LoadResAsync(self, path, 5, 120, self.LoadSuccess, self.LoadFailed)
  self.loaded_res[path] = req
  return req
end

function CurveStatics:LoadSuccess(req, res)
  req.asset = res
  req.assetRef = res and UnLua.Ref(res)
end

function CurveStatics:LoadFailed(req, msg)
end

function CurveStatics:Clean()
  for _, req in pairs(self.loaded_res) do
    req.asset = nil
    _G.NRCResourceManager:UnLoadRes(req)
  end
  self.loaded_res = {}
end

return CurveStatics
