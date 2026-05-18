local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local TakePhotosModuleEvent = require("NewRoco.Modules.System.TakePhotos.TakePhotosModuleEvent")
local TakePhotosModeBasic = Class()

function TakePhotosModeBasic:Ctor(Mgr, Name)
  self.Mgr = Mgr
  self:OnConstruct()
  self.Name = Name
  self:OnInitFov()
end

function TakePhotosModeBasic:OnInitFov()
  self.MinFovScale = TakePhotosEnum.TPGlobalNum("takephoto_camera_zoom_out", 10000) / 10000
  self.MaxFovScale = TakePhotosEnum.TPGlobalNum("takephoto_camera_zoom_in", 10000) / 10000
  self.SavedFov = self:GetBaseFov()
  self.MinFov = self.SavedFov * self.MinFovScale
  self.MaxFov = self.SavedFov * self.MaxFovScale
end

function TakePhotosModeBasic:GetMiniFov()
  return self.MinFov
end

function TakePhotosModeBasic:GetMaxiFov()
  return self.MaxFov
end

function TakePhotosModeBasic:GetFov()
  return self.SavedFov
end

function TakePhotosModeBasic:SetFov(Fov)
  self.SavedFov = Fov
end

function TakePhotosModeBasic:GetRenderTarget2D()
end

function TakePhotosModeBasic:HasCameraEntered()
  return true
end

function TakePhotosModeBasic:GetModule()
  return self.Mgr:GetModule()
end

function TakePhotosModeBasic:OnConstruct()
end

function TakePhotosModeBasic:ResetCameraView()
end

function TakePhotosModeBasic:IsEnablePlayerLookLensFeature()
  return false
end

function TakePhotosModeBasic:PreCheck()
  return true
end

function TakePhotosModeBasic:OnEnter()
  local PctType = self:GetPlayerConditionType()
  if PctType then
    _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.AddCondition, PctType)
    _G.NRCEventCenter:RegisterEvent(self.Name, self, NPCModuleEvent.NpcActionExecute, self.OnNpcActionExecute)
  end
  self:OnShowEnterTips()
end

function TakePhotosModeBasic:OnShowEnterTips()
end

function TakePhotosModeBasic:OnExit()
  local PctType = self:GetPlayerConditionType()
  if PctType then
    _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.RemoveCondition, PctType)
    _G.NRCEventCenter:UnRegisterEvent(self, NPCModuleEvent.NpcActionExecute, self.OnNpcActionExecute)
  end
  self:GetModule():DispatchEvent(TakePhotosModuleEvent.OnExitMode)
end

function TakePhotosModeBasic:GetPlayerConditionType()
end

function TakePhotosModeBasic:OnNpcActionExecute(Action)
  local PctType = self:GetPlayerConditionType()
  if PctType then
    local ActionType = Action.Config.action_type
    local InterruptActionTypeNames = string.split(TakePhotosEnum.TPGlobalStr("takephoto_ACTION_break", ""), ";")
    for i, InterruptTypeName in ipairs(InterruptActionTypeNames) do
      local InterruptActionType = Enum.ActionType[InterruptTypeName]
      if ActionType == InterruptActionType then
        Log.Warning("[TakePhoto] Interrupt by action type", InterruptTypeName, ActionType)
        NRCModuleManager:DoCmd(TakePhotosModuleCmd.ExitTakePhotos)
        break
      end
    end
  end
end

function TakePhotosModeBasic:GetBaseFov()
  return self.Mgr.TakePhotosModeTripod:GetBaseFov()
end

function TakePhotosModeBasic:OnTick(Dt)
end

function TakePhotosModeBasic:ConsumeHandActionChangeRequest()
end

return TakePhotosModeBasic
