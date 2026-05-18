local PhotoFileData = Class("PhotoFileData")
local Delegate = require("Utils.Delegate")
local TakePhotosModuleEvent = require("NewRoco/Modules/System/TakePhotos/TakePhotosModuleEvent")

function PhotoFileData:Ctor()
  self.SerializeId = 0
  self.bWaterMaskEnabled = true
  self.PetIdentifyInfo = nil
  self.TaskIdentifyInfo = nil
  self.OnRenderTextureSerialized = Delegate()
  self.OnDeleteDelegate = Delegate()
  self.OnDeletedDelegate = Delegate()
  self.OnUploadDelegate = Delegate()
  self.OnShareDelegate = Delegate()
  self.OnUploadCardDelegate = Delegate()
  self.OnCloseDelegate = Delegate()
  self.OnTextureReadyDelegate = Delegate()
end

function PhotoFileData:GetPetIdentifyInfo()
  return self.PetIdentifyInfo
end

function PhotoFileData:SetPetIdentifyInfo(Info)
  self.PetIdentifyInfo = Info
end

function PhotoFileData:GetTaskIdentifyInfo()
  return self.TaskIdentifyInfo
end

function PhotoFileData:SetTaskIdentifyInfo(Info)
  self.TaskIdentifyInfo = Info
end

function PhotoFileData:SetBriefInfo(BriefInfo)
  self.Brief = BriefInfo
  if self.PhotoManager then
    self.PhotoManager:TryAllocateResourceByPhotoData(self)
  end
end

function PhotoFileData:SetTextureEvents(bEnable)
  if bEnable then
    if self.PhotoManager and self.Brief then
      self.PhotoManager.ThumbnailScrollPool:AddTextureReadyDelegate(self.Brief, self, self.OnTextureReady)
    end
  elseif self.PhotoManager and self.Brief then
    self.PhotoManager.ThumbnailScrollPool:RemoveTextureReadyDelegate(self.Brief, self, self.OnTextureReady)
  end
end

function PhotoFileData:GetBriefInfo()
  return self.Brief
end

function PhotoFileData:IsValid()
  return not self.bDestroyed
end

function PhotoFileData:OnDestroy()
  self:SetTextureEvents(false)
  self.bDestroyed = true
  self:Detach()
  self:DetachSection()
  self.OnDeletedDelegate:Invoke()
end

function PhotoFileData:OnTextureReady()
  if self.PhotoManager then
    self.PhotoManager.ThumbnailScrollPool:RemoveTextureReadyDelegate(self.Brief, self, self.OnTextureReady)
  end
  self.OnTextureReadyDelegate:Invoke(self)
end

function PhotoFileData:GetThumbnailTexture(LuaIndex)
  if self.PhotoManager and self:IsReady() then
    return self.PhotoManager.ThumbnailScrollPool:GetThumbnailTexture(self.Brief, LuaIndex)
  end
end

function PhotoFileData:AddTextureReadyDelegate(Caller, Func)
  if not self.OnTextureReadyDelegate.List or not self.OnTextureReadyDelegate:Has(Caller, Func) then
    self.OnTextureReadyDelegate:Add(Caller, Func)
  end
end

function PhotoFileData:RemoveTextureReadyDelegate(Caller, Func)
  self.OnTextureReadyDelegate:Remove(Caller, Func)
end

function PhotoFileData:GetPhotoPath()
  return self.Brief and self.Brief.FilePath
end

function PhotoFileData:IsReady()
  return self.Brief ~= nil and self:IsValid()
end

function PhotoFileData:GetDesiredMd5()
  return self.Brief and self.Brief.DesiredMd5
end

function PhotoFileData:UnpackPhotoName()
  if self.Brief and not self.Name then
    local Names = string.Split(self.Brief.FilePath, "/")
    local Name = Names[#Names]
    self.Name = Name
  end
  return self.Name
end

function PhotoFileData:Attach(List, Manager)
  self.PhotoManager = Manager
  self.PhotoList = List
  table.insert(List, self)
  self.SerializeId = #List
end

function PhotoFileData:AttachSection(List)
  self.SectionList = List
  table.insert(self.SectionList, self)
  self.SectionIdx = #List
end

function PhotoFileData:DetachSection()
  if self.SectionList then
    local Data = table.remove(self.SectionList, self.SectionIdx)
    assert(Data == self)
    for i = self.SectionIdx, #self.SectionList do
      self.SectionList[i].SectionIdx = i
    end
    self.SectionList = nil
    self.SectionIdx = nil
  end
end

function PhotoFileData:Detach()
  if self.PhotoList then
    local Data = table.remove(self.PhotoList, self.SerializeId)
    assert(Data == self)
    for i = self.SerializeId, #self.PhotoList do
      self.PhotoList[i].SerializeId = i
    end
    self.PhotoList = nil
    self.SerializeId = 0
  end
  self:DetachSection()
end

function PhotoFileData:GetPhotoTexture2D()
  if self:GetPhotoPath() then
    return NRCModuleManager:GetModule("TakePhotosModule"):UpdatePhotoBigTexture(self:GetPhotoPath())
  end
  return nil
end

function PhotoFileData:GetNext()
  if self.SectionList then
    local Idx = self.SectionIdx
    return self.SectionList[Idx + 1]
  end
  if self.PhotoList then
    local Idx = self.SerializeId
    return self.PhotoList[Idx + 1]
  end
end

function PhotoFileData:GetPrevious()
  if self.SectionList then
    local Idx = self.SectionIdx
    return self.SectionList[Idx - 1]
  end
  if self.PhotoList then
    local Idx = self.SerializeId
    return self.PhotoList[Idx - 1]
  end
end

function PhotoFileData:OnReqDelete()
  self.OnDeleteDelegate:Invoke(self)
end

function PhotoFileData:OnReqUpload()
  self.OnUploadDelegate:Invoke(self)
end

function PhotoFileData:OnReqUploadCard()
  self.OnUploadCardDelegate:Invoke(self)
end

function PhotoFileData:OnReqShare()
  self.OnShareDelegate:Invoke(self)
end

function PhotoFileData:SetWaterMaskEnabled(bEnable)
  self.bWaterMaskEnabled = bEnable
end

local PhotoFileDefine = Class("PhotoFileDefine")

function PhotoFileDefine.MakePhotoData()
  local Data = PhotoFileData()
  return Data
end

return PhotoFileDefine
