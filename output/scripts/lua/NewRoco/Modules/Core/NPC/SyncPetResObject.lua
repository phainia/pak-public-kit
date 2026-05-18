local ThrowSessionStatusEnum = require("NewRoco.Modules.Core.NPC.ThrowSessionStatusEnum")
local ThrowSessionEvent = require("NewRoco.Modules.Core.NPC.ThrowSessionEvent")
local ResObjectBase = require("NewRoco.Utils.ResObjectBase")
local Base = ResObjectBase
local SyncPetResObject = Base:Extend("SyncPetResObject")

function SyncPetResObject:Ctor(Pet)
  Base.Ctor(self)
  self.Pet = Pet
  self.Session = self.Pet.ThrowSession
end

function SyncPetResObject:DoLoad()
  if self.Session.petSyncFinished then
    self:FireCallback(not self.Session.bThrowFailed)
    return
  end
  if not self.Pet then
    self:FireCallback(false)
    return
  end
  self.Session:AddEventListener(self, ThrowSessionEvent.OnStatusChanged, self.OnSessionStatusChanged)
  self.Session:AddEventListener(self, ThrowSessionEvent.OnSyncPetCreateFinished, self.OnSyncPetFinished)
  _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.SyncPetCreate, self.Pet, _G.ProtoEnum.ClientCreatePetReason.CCPR_PERCEPTION)
end

function SyncPetResObject:OnSessionStatusChanged(Session, Status)
  if Status == ThrowSessionStatusEnum.Destroyed or Status == ThrowSessionStatusEnum.Recycling then
    self.Session:RemoveEventListener(self, ThrowSessionEvent.OnSyncPetCreateFinished, self.OnSyncPetFinished)
    self.Session:RemoveEventListener(self, ThrowSessionEvent.OnStatusChanged, self.OnSessionStatusChanged)
    self:FireCallback(false)
  end
end

function SyncPetResObject:OnSyncPetFinished()
  self.Session:RemoveEventListener(self, ThrowSessionEvent.OnSyncPetCreateFinished, self.OnSyncPetFinished)
  self.Session:RemoveEventListener(self, ThrowSessionEvent.OnStatusChanged, self.OnSessionStatusChanged)
  self:FireCallback(not self.Session.bThrowFailed)
end

function SyncPetResObject:DoRelease()
  if self.Session then
    self.Session:RemoveEventListener(self, ThrowSessionEvent.OnSyncPetCreateFinished, self.OnSyncPetFinished)
    self.Session:RemoveEventListener(self, ThrowSessionEvent.OnStatusChanged, self.OnSessionStatusChanged)
  end
  self.Session = nil
  self.Pet = nil
end

function SyncPetResObject:DoGet()
  return nil
end

return SyncPetResObject
