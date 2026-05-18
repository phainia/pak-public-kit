TakePhotoEditorTools = Class("TakePhotoEditorTools")
local TakePhotosUtils = require("NewRoco.Modules.System.TakePhotos.TakePhotosUtils")
local TakePhotoEditorToolsInst

function TakePhotoEditorTools.Get()
  if not TakePhotoEditorToolsInst then
    TakePhotoEditorToolsInst = TakePhotoEditorTools()
  end
  return TakePhotoEditorToolsInst
end

function TakePhotoEditorTools:Ctor()
  self.StorageRideAllConfMap = {}
  self.HandledDataModel = {}
  self.HandledDataModel2p = {}
  self.SelfieDataModel = {}
  self.RideConf = nil
end

function TakePhotoEditorTools:ExportAll()
  if not self.RideConf then
    return
  end
  local folderName = self.RideConf.animation_name or ""
  local data = self.StorageRideAllConfMap[self.RideConf.id] or {}
  if 1 == self.Mode then
    data.eyes_view_point_offset_x = self.HandledDataModel.eyes_view_point_offset_x or 0
    data.eyes_view_point_offset_y = self.HandledDataModel.eyes_view_point_offset_y or 0
    data.eyes_view_point_offset_z = self.HandledDataModel.eyes_view_point_offset_z or 0
    local Command = string.format("/update_all_ride_scale.py setHandledTakePhoto1pOffset %s %d %d %d", folderName, data.eyes_view_point_offset_x, data.eyes_view_point_offset_y, data.eyes_view_point_offset_z)
    local Ret = UE.UPythonScriptLibrary.ExecutePythonCommandEx(Command, nil, nil, UE.EPythonCommandExecutionMode.ExecuteFile, UE.EPythonFileExecutionScope.Private)
    Log.Debug("ExportAll 1P:", folderName, data.eyes_view_point_offset_x, data.eyes_view_point_offset_y, data.eyes_view_point_offset_z, "Ret:", Ret, "Cmd:", Command)
    self.StorageRideAllConfMap[self.RideConf.id] = data
  elseif 2 == self.Mode then
    data.eyes_view_point_offset_2p_x = self.HandledDataModel2p.eyes_view_point_offset_2p_x or 0
    data.eyes_view_point_offset_2p_y = self.HandledDataModel2p.eyes_view_point_offset_2p_y or 0
    data.eyes_view_point_offset_2p_z = self.HandledDataModel2p.eyes_view_point_offset_2p_z or 0
    local Command = string.format("/update_all_ride_scale.py setHandledTakePhoto2pOffset %s %d %d %d", folderName, data.eyes_view_point_offset_2p_x, data.eyes_view_point_offset_2p_y, data.eyes_view_point_offset_2p_z)
    local Ret = UE.UPythonScriptLibrary.ExecutePythonCommandEx(Command, nil, nil, UE.EPythonCommandExecutionMode.ExecuteFile, UE.EPythonFileExecutionScope.Private)
    Log.Debug("ExportAll 2P:", folderName, data.eyes_view_point_offset_2p_x, data.eyes_view_point_offset_2p_y, data.eyes_view_point_offset_2p_z, "Ret:", Ret, "Cmd:", Command)
    self.StorageRideAllConfMap[self.RideConf.id] = data
  elseif 4 == self.Mode then
    local nums = {
      self.SelfieDataModel.selfie2p_view_offset_x or 0,
      self.SelfieDataModel.selfie2p_view_pitch or 0,
      self.SelfieDataModel.selfie2p_view_yaw or 0
    }
    local selfie2p_takephoto_params = table.concat(nums, ";")
    data.selfie2p_takephoto_params = selfie2p_takephoto_params
    local Command = string.format("/update_all_ride_scale.py setSelfie2PTakePhotoOffset %s %s", folderName, selfie2p_takephoto_params)
    local Ret = UE.UPythonScriptLibrary.ExecutePythonCommandEx(Command, nil, nil, UE.EPythonCommandExecutionMode.ExecuteFile, UE.EPythonFileExecutionScope.Private)
    Log.Debug("ExportAll Selfie2p:", folderName, selfie2p_takephoto_params, "Ret:", Ret, "Cmd:", Command)
    self.StorageRideAllConfMap[self.RideConf.id] = data
  elseif 3 == self.Mode then
    local nums = {
      self.SelfieDataModel.view_offset_h or 0,
      self.SelfieDataModel.view_offset_v or 0,
      self.SelfieDataModel.cam_offset_h or 0,
      self.SelfieDataModel.cam_offset_d or 0,
      self.SelfieDataModel.cam_offset_l or 0,
      self.SelfieDataModel.cam_min_l or 0,
      self.SelfieDataModel.cam_max_l or 0
    }
    local selfie_takephoto_params = table.concat(nums, ";")
    data.selfie_takephoto_params = selfie_takephoto_params
    local Command = string.format("/update_all_ride_scale.py setSelfieTakePhotoOffset %s %s", folderName, selfie_takephoto_params)
    local Ret = UE.UPythonScriptLibrary.ExecutePythonCommandEx(Command, nil, nil, UE.EPythonCommandExecutionMode.ExecuteFile, UE.EPythonFileExecutionScope.Private)
    Log.Debug("ExportAll Selfie:", folderName, selfie_takephoto_params, "Ret:", Ret, "Cmd:", Command)
    self.StorageRideAllConfMap[self.RideConf.id] = data
  end
end

function TakePhotoEditorTools:ResetAll()
  if not self.RideConf then
    return
  end
  local Storage = self.StorageRideAllConfMap[self.RideConf.id] or self.RideConf
  if 1 == self.Mode then
    local eyes_view_point_offset_x = Storage.eyes_view_point_offset_x or 0
    local eyes_view_point_offset_y = Storage.eyes_view_point_offset_y or 0
    local eyes_view_point_offset_z = Storage.eyes_view_point_offset_z or 0
    self:SetHandledData("eyes_view_point_offset_x", eyes_view_point_offset_x)
    self:SetHandledData("eyes_view_point_offset_y", eyes_view_point_offset_y)
    self:SetHandledData("eyes_view_point_offset_z", eyes_view_point_offset_z)
  elseif 2 == self.Mode then
    local eyes_view_point_offset_2p_x = Storage.eyes_view_point_offset_2p_x or 0
    local eyes_view_point_offset_2p_y = Storage.eyes_view_point_offset_2p_y or 0
    local eyes_view_point_offset_2p_z = Storage.eyes_view_point_offset_2p_z or 0
    self:SetHandled2pData("eyes_view_point_offset_2p_x", eyes_view_point_offset_2p_x)
    self:SetHandled2pData("eyes_view_point_offset_2p_y", eyes_view_point_offset_2p_y)
    self:SetHandled2pData("eyes_view_point_offset_2p_z", eyes_view_point_offset_2p_z)
  elseif 4 == self.Mode then
    local selfie2p_takephoto_params = Storage.selfie2p_takephoto_params or ""
    local nums = string.split(selfie2p_takephoto_params, ";")
    for i, num in ipairs(nums) do
      nums[i] = tonumber(num) or 0
    end
    local DefaultPitch = -18
    local DefaultYaw = 180
    local DefaultOffset = 45
    local selfie2p_view_offset_x = nums[1] or DefaultOffset
    local selfie2p_view_pitch = nums[2] or DefaultPitch
    local selfie2p_view_yaw = nums[3] or DefaultYaw
    self:SetSelfieData("selfie2p_view_offset_x", selfie2p_view_offset_x)
    self:SetSelfieData("selfie2p_view_pitch", selfie2p_view_pitch)
    self:SetSelfieData("selfie2p_view_yaw", selfie2p_view_yaw)
  else
    local selfie_takephoto_params = Storage.selfie_takephoto_params or ""
    local nums = string.split(selfie_takephoto_params, ";")
    for i, num in ipairs(nums) do
      nums[i] = tonumber(num) or 0
    end
    local view_offset_h = nums[1] or 0
    local view_offset_v = nums[2] or 0
    local cam_offset_h = nums[3] or 0
    local cam_offset_d = nums[4] or 200
    local cam_offset_l = nums[5] or 0
    local cam_min_l = nums[6] or 0
    local cam_max_l = nums[7] or 150
    self:SetSelfieData("view_offset_h", view_offset_h)
    self:SetSelfieData("view_offset_v", view_offset_v)
    self:SetSelfieData("cam_offset_h", cam_offset_h)
    self:SetSelfieData("cam_offset_d", cam_offset_d)
    self:SetSelfieData("cam_offset_l", cam_offset_l)
    self:SetSelfieData("cam_min_l", cam_min_l)
    self:SetSelfieData("cam_max_l", cam_max_l)
  end
end

function TakePhotoEditorTools:UpdateMode(Mode)
  self.Mode = Mode
end

function TakePhotoEditorTools:IsDirty()
  if self.RideConf then
    local data = self.StorageRideAllConfMap[self.RideConf.id]
    if not data then
      return true
    else
      if 1 == self.Mode then
        return (self.HandledDataModel.eyes_view_point_offset_x or 0) ~= data.eyes_view_point_offset_x or (self.HandledDataModel.eyes_view_point_offset_y or 0) ~= data.eyes_view_point_offset_y or (self.HandledDataModel.eyes_view_point_offset_z or 0) ~= data.eyes_view_point_offset_z
      elseif 2 == self.Mode then
        return (self.HandledDataModel2p.eyes_view_point_offset_2p_x or 0) ~= data.eyes_view_point_offset_2p_x or (self.HandledDataModel2p.eyes_view_point_offset_2p_y or 0) ~= data.eyes_view_point_offset_2p_y or (self.HandledDataModel2p.eyes_view_point_offset_2p_z or 0) ~= data.eyes_view_point_offset_2p_z
      elseif 4 == self.Mode then
        local nums = {
          self.SelfieDataModel.selfie2p_view_offset_x or 0,
          self.SelfieDataModel.selfie2p_view_pitch or 0,
          self.SelfieDataModel.selfie2p_view_yaw or 0
        }
        local temp_selfie2p_takephoto_params = table.concat(nums, ";")
        if temp_selfie2p_takephoto_params ~= data.selfie2p_takephoto_params then
          return true
        else
          return false
        end
      end
      local nums = {
        self.SelfieDataModel.view_offset_h or 0,
        self.SelfieDataModel.view_offset_v or 0,
        self.SelfieDataModel.cam_offset_h or 0,
        self.SelfieDataModel.cam_offset_d or 0,
        self.SelfieDataModel.cam_offset_l or 0,
        self.SelfieDataModel.cam_min_l or 0,
        self.SelfieDataModel.cam_max_l or 0
      }
      local temp_selfie_takephoto_params = table.concat(nums, ";")
      if temp_selfie_takephoto_params ~= data.selfie_takephoto_params then
        return true
      end
    end
  end
end

function TakePhotoEditorTools:SetRideId(Id)
  local RideConf = DataConfigManager:GetAllRidePet(Id, true)
  if RideConf ~= self.RideConf then
    self.RideConf = RideConf
    self:ResetAll()
  end
end

function TakePhotoEditorTools:SetHandledData(Key, Val)
  self.HandledDataModel[Key] = Val
  TakePhotosUtils.SetRideFirstPersonViewOffset(self:GetHandledData("eyes_view_point_offset_x"), self:GetHandledData("eyes_view_point_offset_y"), self:GetHandledData("eyes_view_point_offset_z"))
end

function TakePhotoEditorTools:SetHandled2pData(Key, Val)
  self.HandledDataModel2p[Key] = Val
  TakePhotosUtils.SetRideFirstPersonViewOffset(self:GetHandledData("eyes_view_point_offset_2p_x"), self:GetHandledData("eyes_view_point_offset_2p_y"), self:GetHandledData("eyes_view_point_offset_2p_z"))
end

function TakePhotoEditorTools:GetSelfieTakePhotoParams(PetBaseId)
  local Storage = self.StorageRideAllConfMap[PetBaseId]
  return Storage and Storage.selfie_takephoto_params
end

function TakePhotoEditorTools:Apply1PCameraOffset()
  local Player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local ScenePet = Player:GetRidePetLua()
  if ScenePet then
    local SelfScenePet = Player.viewObj.BP_RideComponent and Player.viewObj.BP_RideComponent.ScenePet
    if SelfScenePet == ScenePet then
      local Storage = self.StorageRideAllConfMap[ScenePet.config.id]
      TakePhotosUtils.SetRideFirstPersonViewOffset(Storage and Storage.eyes_view_point_offset_x or 0, Storage and Storage.eyes_view_point_offset_y or 0, Storage and Storage.eyes_view_point_offset_z or 0)
    else
      local Storage = self.StorageRideAllConfMap[ScenePet.config.id]
      TakePhotosUtils.SetRideFirstPersonViewOffset(Storage and Storage.eyes_view_point_offset_2p_x or 0, Storage and Storage.eyes_view_point_offset_2p_y or 0, Storage and Storage.eyes_view_point_offset_2p_z or 0)
    end
  else
    TakePhotosUtils.SetRideFirstPersonViewOffset(0, 0, 0)
  end
end

function TakePhotoEditorTools:SetSelfieData(Key, Val)
  self.SelfieDataModel[Key] = Val
  local Module = NRCModuleManager:GetModule("TakePhotosModule")
  if Module.ModeMgr:IsSelfieMode() then
    Module.ModeMgr.TakePhotosModeSelfie:OnSelfieConfigChangedEd()
  end
end

function TakePhotoEditorTools:GetHandledData(Key)
  return self.HandledDataModel[Key] or 0
end

function TakePhotoEditorTools:GetHandled2pData(Key)
  return self.HandledDataModel2p[Key] or 0
end

function TakePhotoEditorTools:GetSelfieData(Key)
  return self.SelfieDataModel[Key] or 0
end
