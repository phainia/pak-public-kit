local TakePhotosModeBasic = require("NewRoco/Modules/System/TakePhotos/Mode/TakePhotosModeBasic")
local TakePhotosModeWorld = TakePhotosModeBasic:Extend("TakePhotosMode1P")
local TakePhotosUtils = require("NewRoco/Modules/System/TakePhotos/TakePhotosUtils")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")

function TakePhotosModeWorld:PreCheck()
  return true
end

function TakePhotosModeWorld:DoEnter()
end

function TakePhotosModeWorld:TakePhotos()
  return false
end

function TakePhotosModeWorld:GetPlayerConditionType()
  return Enum.PlayerConditionType.PCT_TAKE_PHOTO_TRIPOD_WORLD
end

function TakePhotosModeWorld:OnShowEnterTips()
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.takephoto_tripod_world_tips, nil, nil, self.Mgr.ToggleTipsSeconds)
end

function TakePhotosModeWorld:OnEnter()
  TakePhotosModeBasic.OnEnter(self)
  local MainUIModule = NRCModuleManager:GetModule("MainUIModule")
  if MainUIModule then
    MainUIModule:DispatchEvent(MainUIModuleEvent.RefreshTaskDungeon)
  end
end

function TakePhotosModeWorld:OnExit(bExitTakingPhoto, Context)
  TakePhotosModeBasic.OnExit(self)
  local MainUIModule = NRCModuleManager:GetModule("MainUIModule")
  if MainUIModule then
    MainUIModule:DispatchEvent(MainUIModuleEvent.RefreshTaskDungeon)
  end
  if bExitTakingPhoto or Context and Context.ToMode ~= self.Mgr.TakePhotosModeTripod then
    self.Mgr.TakePhotosModeTripod:OnClean()
  end
end

function TakePhotosModeWorld:IsDelayTakePhotosEnabled()
  return true
end

function TakePhotosModeWorld:TickFov(Dt, Scale)
end

function TakePhotosModeBasic:StopTickFov()
end

function TakePhotosModeBasic:GetRenderTarget2D()
  return self.Mgr.TakePhotosModeTripod:GetRenderTarget2D()
end

return TakePhotosModeWorld
