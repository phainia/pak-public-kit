local TakePhotosModuleEvent = require("NewRoco/Modules/System/TakePhotos/TakePhotosModuleEvent")
local TakePhotosModuleData = _G.NRCData:Extend("TakePhotosModuleData")
local SaveName = "TakePhotosSaveGame"
local SaveGameClassPath = "/Game/NewRoco/Modules/System/TakePhotos/Res/BP_TakePhotosSaveGame.BP_TakePhotosSaveGame_C"

function TakePhotosModuleData:Ctor()
  NRCData.Ctor(self)
  self.TheRT = nil
  self.TheRTRef = nil
  self.PhotoExternFileName = ".png"
  self.PhotoRTFormat = UE.ETextureRenderTargetFormat.RTF_RGBA8
  self.RefCount = 0
  self.ThePhotoBigTexture = nil
  self.ThePhotoBigTextureRef = nil
  self.CurPhotoMode = 0
  self:InitPetHandBookIndices()
end

function TakePhotosModuleData:InitSaveData()
  if UE.UAsyncSaveGameHandle then
    self.SaveDataProxy = NewObject(UE.UAsyncSaveGameHandle, UE4.UNRCPlatformGameInstance.GetInstance(), SaveName)
    self.SaveDataProxyRef = UnLua.Ref(self.SaveDataProxy)
    self.SaveDataProxy.Completed:Add(self.SaveDataProxy, function(_)
      self.SaveDataProxy.Completed:Clear()
      self.module.Controller.PhotoManager:InitLocalBriefList()
    end)
    self.SaveDataProxy:AsyncLoadByRawClassPath(SaveGameClassPath, SaveName)
  end
end

function TakePhotosModuleData:GetSaveData()
  if not self.SaveData then
    self.SaveData = self.SaveDataProxy and self.SaveDataProxy.SaveGameObject
  end
  return self.SaveData
end

function TakePhotosModuleData:IsSaveGameDataReady()
  return self:GetSaveData()
end

function TakePhotosModuleData:AsyncSaveGameData()
  if self.DelaySaveGameTimer then
    Log.Debug("[TakePhoto] pending save data")
    return
  end
  self.DelaySaveGameTimer = DelayManager:DelayFrames(1, function()
    self.DelaySaveGameTimer = nil
    Log.Debug("[TakePhoto] start save data")
    self.SaveDataProxy.Completed:Add(self.SaveDataProxy, function()
      self.SaveDataProxy.Completed:Clear()
      Log.Debug("[TakePhoto] save data completed")
    end)
    self.SaveDataProxy:AsyncSaveGameToSlot()
  end)
end

function TakePhotosModuleData:IfNeedNotifyDelete()
  local timestamp = self:GetSaveData().disable_notify_timestamp
  if not timestamp then
    return true
  end
  local Now = _G.ZoneServer:GetServerTime() // 1000
  local date1 = os.date("*t", timestamp)
  local date2 = os.date("*t", Now)
  Log.Info("[TakePhoto] IfNeedNotifyDelete", timestamp, " <> ", Now)
  return date1.year ~= date2.year or date1.month ~= date2.month or date1.day ~= date2.day
end

function TakePhotosModuleData:OnDeleteNotifyConfirm(bNeedDisableNotify)
  if bNeedDisableNotify then
    self:GetSaveData().disable_notify_timestamp = _G.ZoneServer:GetServerTime() // 1000
    self:AsyncSaveGameData()
  end
end

function TakePhotosModuleData:GetLocalPhotoStats(PhotoFilePath)
  if not self:GetSaveData() then
    return
  end
  local Uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  local Map = self:GetSaveData().local_photo_files
  local Val = Map:Find(PhotoFilePath .. Uin)
  return Val
end

function TakePhotosModuleData:RecordLocalPhotoStats(PhotoFilePath, Md5)
  if not self:GetSaveData() then
    return
  end
  local Uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  local Map = self:GetSaveData().local_photo_files
  Map:Add(PhotoFilePath .. Uin, Md5)
  self:GetSaveData().local_photo_files = Map
  self:AsyncSaveGameData()
end

function TakePhotosModuleData:RemoveLocalPhotoStats(PhotoFilePath)
  if not self:GetSaveData() then
    return
  end
  local Uin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  local Map = self:GetSaveData().local_photo_files
  Map:Remove(PhotoFilePath .. Uin)
  self:GetSaveData().local_photo_files = Map
  self:AsyncSaveGameData()
end

function TakePhotosModuleData:GetScreenSize()
  local Size = UE.FIntPoint(0, 0)
  local viewportSize = UE.UWidgetLayoutLibrary.GetViewportSize(UE4Helper.GetCurrentWorld())
  local borderWidth = UE4.USlateBlueprintLibrary.GetNRCBorderWidth()
  local borderHeight = UE4.USlateBlueprintLibrary.GetNRCBorderHeight()
  viewportSize.X = viewportSize.X - borderWidth * 2
  viewportSize.Y = viewportSize.Y - borderHeight * 2
  Size.X = math.floor(viewportSize.X)
  Size.Y = math.floor(viewportSize.Y)
  return Size
end

function TakePhotosModuleData:CreateRT(Size)
  if not TEST_PHOTO_RT or not _G.RocoEnv.IS_EDITOR then
    local TestRT = UE.UKismetRenderingLibrary.CreateRenderTarget2D(UE4.UNRCPlatformGameInstance.GetInstance(), Size.X, Size.Y, self.PhotoRTFormat)
    local TestRTRef = UnLua.Ref(TestRT)
    return TestRT, TestRTRef
  else
    local TestRT = UE.UObject.Load("/Game/NewRoco/Modules/System/TakePhotos/TestCapture.TestCapture")
    local TestRTRef = UnLua.Ref(TestRT)
    UE.UNRCStatics.ChangeTextureToMatchScene(TestRT)
    return TestRT, TestRTRef
  end
end

function TakePhotosModuleData:Preload()
  if self.TheRT and not UE.UObject.IsValid(self.TheRT) then
    self.TheRT = nil
    Log.Error("Preload Invalid RenderTarget, need create, ref count", self.RefCount)
  end
  if not self.TheRT then
    local Size = self:GetScreenSize()
    self.TheRT, self.TheRTRef = self:CreateRT(Size)
    if self.TheRT then
      Log.Debug("TakePhoto RT Size=", self.TheRT.SizeX, self.TheRT.SizeY)
    end
  end
end

function TakePhotosModuleData:RequestRT()
  if self.TheRT and not UE.UObject.IsValid(self.TheRT) then
    self.TheRT = nil
    Log.Error("RequestRT Invalid RenderTarget, need create, ref count", self.RefCount)
  end
  if not self.TheRT then
    local Size = self:GetScreenSize()
    self.TheRT, self.TheRTRef = self:CreateRT(Size)
    if self.TheRT then
      Log.Debug("TakePhoto RT Size=", self.TheRT.SizeX, self.TheRT.SizeY)
    end
  end
  return self.TheRT
end

function TakePhotosModuleData:ReleaseRT()
  if self.TheRTRef and UE.UObject.IsValid(self.TheRTRef) then
    UnLua.Unref(self.TheRTRef)
  end
  self.TheRTRef = nil
  self.TheRT = nil
end

function TakePhotosModuleData:AddRef()
  self.RefCount = self.RefCount + 1
end

function TakePhotosModuleData:RemoveRef()
  self.RefCount = self.RefCount - 1
  if 0 == self.RefCount then
    self:Clear()
  end
end

function TakePhotosModuleData:Clear()
  Log.Debug("[TakePhoto] Clear Resources")
  self.RefCount = 0
  self.ThePhotoBigTexture = nil
  if self.ThePhotoBigTextureRef and UE.UObject.IsValid(self.ThePhotoBigTextureRef) then
    UnLua.Unref(self.ThePhotoBigTextureRef)
  end
  self.ThePhotoBigTextureRef = nil
  self:ReleaseRT()
end

function TakePhotosModuleData:InitPetHandBookIndices()
  local AllData = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.PET_HANDBOOK):GetAllDatas()
  local PetBaseIdSet = {}
  for k, v in pairs(AllData) do
    if v.include_petbase_id then
      for i, idsWrap in ipairs(v.include_petbase_id) do
        local ids = idsWrap.petbase_id
        for _, id in ipairs(ids) do
          PetBaseIdSet[id] = true
        end
      end
    end
  end
  self.PetBaseIdSet = PetBaseIdSet
end

function TakePhotosModuleData:IsPetInHandbook(PetBaseId)
  return self.PetBaseIdSet and self.PetBaseIdSet[PetBaseId]
end

return TakePhotosModuleData
