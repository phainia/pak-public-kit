local Class = _G.MakeSimpleClass
local HiddenPluginFx = Class("HiddenPluginFx")
local AsyncCacheTime = 10
HiddenPluginFx:SetMemberCount(13)

function HiddenPluginFx:Ctor(fxPath, async, preload, priority)
  self.owner = nil
  self.path = fxPath
  self.showing = false
  self.use_async = async or false
  self.preload = async and preload or false
  self.load_priority = priority or _G.PriorityEnum.Passive_World_NPC_Hidden_Other
  self.loading_res = false
  self.res_req = nil
  self.preres_req = nil
  self.instanceId = -1
  self.socket = "locator_body"
  self.is_solo = true
  self.attach_to_socket = true
end

function HiddenPluginFx:Init(owner)
  self.owner = owner
  if self.preload and not self.preres_req then
    self.preres_req = _G.NRCResourceManager:LoadResAsync(self, self.path, self.load_priority, AsyncCacheTime, self.PreloadSucc, self.PreloadFail)
  end
end

function HiddenPluginFx:PreloadSucc(req, asset)
  Log.Debug("[HiddenPluginFx] Preload asset", self.path)
end

function HiddenPluginFx:PreloadFail(req, msg)
end

function HiddenPluginFx:Release()
  self:UnShow(true)
  if self.preload and self.preres_req then
    _G.NRCResourceManager:UnLoadRes(self.preres_req)
    self.preres_req = nil
  end
  self.owner = nil
end

function HiddenPluginFx:Show()
  if not self.owner then
    return
  end
  if self.loading_res then
    return
  end
  local RocoFx
  if self.showing and self.is_solo then
    RocoFx = self:GetFxComp() or false
    if RocoFx and RocoFx:DoesInstancePlaying(self.instanceId) then
      return
    end
  end
  if self.use_async then
    self.loading_res = true
    local previous_req = self.res_req
    self.res_req = _G.NRCResourceManager:LoadResAsync(self, self.path, self.load_priority, AsyncCacheTime, self.LoadSucc, self.LoadFail)
    if previous_req then
      _G.NRCResourceManager:UnLoadRes(previous_req)
    end
  else
    if nil == RocoFx then
      RocoFx = self:GetFxComp()
    end
    if RocoFx then
      self.instanceId = RocoFx:PlayFxByPath_Name(self.path, self.socket, self.attach_to_socket, true, -1, true)
      self.showing = true
    end
  end
end

function HiddenPluginFx:UnShow(imme)
  if self.loading_res then
    self:ReleaseRes()
    return
  end
  if not self.showing then
    return
  end
  self.showing = false
  local RocoFx = self:GetFxComp()
  if RocoFx then
    if imme then
      RocoFx:StopFx(self.instanceId)
    else
      RocoFx:PauseFxByID(self.instanceId, true)
    end
  end
  self.instanceId = -1
  self:ReleaseRes()
end

function HiddenPluginFx:GetFxComp()
  local Model = self.owner and self.owner.viewObj
  if Model and UE.UObject.IsValid(Model) then
    return Model.RocoFX or Model:GetComponentByClass(UE.URocoFXComponent)
  end
  return nil
end

function HiddenPluginFx:LoadSucc(req, psTemplate)
  self.loading_res = false
  local RocoFx = self:GetFxComp()
  if RocoFx then
    self.instanceId = RocoFx:PlayFx_Name(psTemplate, self.socket, self.attach_to_socket, true, -1, true)
    self.showing = true
  else
    self:ReleaseRes()
  end
end

function HiddenPluginFx:LoadFail(req, errMsg)
  Log.Error(errMsg)
  self.loading_res = false
end

function HiddenPluginFx:ReleaseRes()
  if self.use_async and self.res_req then
    local req = self.res_req
    self.res_req = nil
    _G.NRCResourceManager:UnLoadRes(req)
  end
  self.loading_res = false
end

function HiddenPluginFx:GetParticleSystemComp()
  local fxComp = self:GetFxComp()
  return fxComp and fxComp:GetFxSystemComponentById(self.instanceId)
end

return HiddenPluginFx
