local ModeSwitchContext = Class("ModeSwitchContext")
local EnmStatus = {
  None = 0,
  Cleaning = 2,
  PreTransit = 3,
  Transiting = 4
}

function ModeSwitchContext:Ctor(Module, Controller)
  self.Controller = Controller
  self.FromMode = nil
  self.ToMode = nil
  self.Status = EnmStatus.None
  self.Module = Module
  self.bTickEnabled = false
end

function ModeSwitchContext:BeginTransit(From, To)
  if self.Status ~= EnmStatus.None then
    return false
  end
  Log.Debug("[TakePhoto] transit mode", From.Name, To.Name)
  if From == To then
    return false
  end
  if To == self.Module.ModeMgr.TakePhotosModeWorld and From ~= self.Module.ModeMgr.TakePhotosModeTripod then
    return false
  end
  self.FromMode = From
  self.ToMode = To
  self.Status = EnmStatus.None
  self:InternalTransit()
  return true
end

function ModeSwitchContext:BeginDestroy()
  self.ToMode = nil
  self.FromMode = nil
  self.Status = EnmStatus.None
  self.Module:ClosePanel("UMG_PhotoFrame")
end

function ModeSwitchContext:IsReady()
  return self.Status == EnmStatus.None
end

function ModeSwitchContext:InternalTransit()
  if self.Status == EnmStatus.None then
    if self.FromMode then
      if self.ToMode then
        self.Status = EnmStatus.PreTransit
      else
        self.Status = EnmStatus.Cleaning
      end
    elseif self.ToMode then
      self.Status = EnmStatus.PreTransit
    end
  end
  if self.Status == EnmStatus.Cleaning then
    self.FromMode:OnExit(false, self)
    self.Status = EnmStatus.None
    self.FromMode = nil
    if self.ToMode then
      self.Status = EnmStatus.PreTransit
    end
  end
  if self.Status == EnmStatus.PreTransit then
    self.Status = EnmStatus.Transiting
    Log.Debug("[TakePhoto] switching mode")
    self.Module:InternalOpenPhotoFrame("Switch", function()
      if self.Status ~= EnmStatus.Transiting then
        Log.Warning("[TakePhoto] transited, but status changed, status=", self.Status)
        return
      end
      local FromMode = self.FromMode
      local ToMode = self.ToMode
      if FromMode then
        FromMode:OnExit(false, self)
      end
      self.FromMode = nil
      self.ToMode = nil
      self.Status = EnmStatus.None
      self.Module.ModeMgr:OnEnterMode(ToMode, FromMode)
      Log.Debug("[TakePhoto] switching mode end")
    end, function()
      local Mode = self.Module.ModeMgr.CurrMode
      return not Mode or Mode:HasCameraEntered()
    end)
  end
end

function ModeSwitchContext:IsTransiting()
  return self.Status == EnmStatus.Transiting
end

return ModeSwitchContext
