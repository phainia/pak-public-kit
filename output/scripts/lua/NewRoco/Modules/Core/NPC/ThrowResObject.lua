local ThrowSessionStatusEnum = require("NewRoco.Modules.Core.NPC.ThrowSessionStatusEnum")
local ThrowSessionEvent = require("NewRoco.Modules.Core.NPC.ThrowSessionEvent")
local ResObjectBase = require("NewRoco.Utils.ResObjectBase")
local Base = ResObjectBase
local ThrowResObject = Base:Extend("ThrowResObject")

function ThrowResObject:Ctor(Session)
  Base.Ctor(self)
  self.Session = Session
end

function ThrowResObject:DoLoad()
  if self.Session.beginThrowFinished then
    self:FireCallback(not self.Session.bThrowFailed)
  else
    self.Session:AddEventListener(self, ThrowSessionEvent.OnStatusChanged, self.OnSessionStatusChanged)
    self.Session:AddEventListener(self, ThrowSessionEvent.OnBeginThrowFinished, self.OnBeginThrowFinished)
  end
end

function ThrowResObject:OnSessionStatusChanged(Session, Status)
  if Status == ThrowSessionStatusEnum.Destroyed or Status == ThrowSessionStatusEnum.Recycling then
    self.Session:RemoveEventListener(self, ThrowSessionEvent.OnBeginThrowFinished, self.OnBeginThrowFinished)
    self.Session:RemoveEventListener(self, ThrowSessionEvent.OnStatusChanged, self.OnSessionStatusChanged)
    self:FireCallback(false)
  end
end

function ThrowResObject:OnBeginThrowFinished(Success)
  self.Session:RemoveEventListener(self, ThrowSessionEvent.OnBeginThrowFinished, self.OnBeginThrowFinished)
  self.Session:RemoveEventListener(self, ThrowSessionEvent.OnStatusChanged, self.OnSessionStatusChanged)
  self:FireCallback(Success)
end

function ThrowResObject:DoRelease()
  if self.Session then
    self.Session:RemoveEventListener(self, ThrowSessionEvent.OnBeginThrowFinished, self.OnBeginThrowFinished)
    self.Session:RemoveEventListener(self, ThrowSessionEvent.OnStatusChanged, self.OnSessionStatusChanged)
  end
  self.Session = nil
end

function ThrowResObject:DoGet()
  return self.Session
end

return ThrowResObject
