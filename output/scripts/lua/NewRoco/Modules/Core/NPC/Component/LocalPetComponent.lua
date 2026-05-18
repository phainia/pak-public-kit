local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local ThrowSessionStatusEnum = require("NewRoco.Modules.Core.NPC.ThrowSessionStatusEnum")
local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local Base = ActorComponent

local function GetSquaredGlobalConf(key, default)
  local confID = _G.DataConfigManager.ConfigTableId.NPC_GLOBAL_CONFIG
  local conf = _G.DataConfigManager:GetGlobalConfigByKeyType(key, confID)
  if not conf then
    return default or 100
  end
  local num = conf.num
  return num * num
end

local UpdateManager = _G.UpdateManager
local PhaseCount = 5
local PhaseIndex = 1
local RecycleDistSquared2D = GetSquaredGlobalConf("petrelease_distance", 4000000)
local RecycleTimeout = 10
local LocalPetComponent = Base:Extend("LocalPetComponent")

function LocalPetComponent:Attach(owner)
  Base.Attach(self, owner)
  self:SetEnable(false)
  self.RecycleStartTime = -1
  SceneUtils.RegisterNPCVisibilityNotify(self, true)
end

function LocalPetComponent:OnVisible()
  self:SetEnable(true)
end

function LocalPetComponent:OnInvisible()
end

function LocalPetComponent:Destroy()
  self:SetEnable(false)
end

function LocalPetComponent:OnEnable()
  self.FrameCount = 0
  UpdateManager:Register(self)
end

function LocalPetComponent:OnDisable()
  UpdateManager:UnRegister(self)
  self.FrameCount = 0
end

function LocalPetComponent:SetStatus(Status)
  self.owner.ThrowSession:SetStatus(Status)
end

function LocalPetComponent:GetStatus()
  return self.owner.ThrowSession.Status
end

function LocalPetComponent:OnTick(DeltaTime)
  if not self.enabled then
    return
  end
  if not UE4.UObject.IsValid(self.owner.viewObj) then
    self.owner:Disappear(true)
    self:SetStatus(ThrowSessionStatusEnum.Destroyed)
    return
  end
  self.FrameCount = self.FrameCount + 1
  if self.FrameCount % PhaseCount ~= PhaseIndex then
    return
  end
  local Status = self:GetStatus()
  if Status == ThrowSessionStatusEnum.PostInteract then
    local PetPos = self.owner:GetActorLocation()
    if not PetPos then
      return
    end
    local Player = SceneUtils.GetPlayer()
    if not Player then
      return
    end
    local PlayerPos = Player:GetActorLocation()
    if not PlayerPos then
      return
    end
    local DistanceSquared = UE4.FVector.DistSquared2D(PetPos, PlayerPos)
    if DistanceSquared < RecycleDistSquared2D then
      return
    end
    local PetView = self.owner.viewObj
    if not PetView then
      self.owner:Disappear(true)
      self:SetStatus(ThrowSessionStatusEnum.Destroyed)
      return
    end
    self.RecycleStartTime = UpdateManager.Timestamp
    self.owner.ThrowSession:Recycle()
  elseif Status == ThrowSessionStatusEnum.Recycling then
    if -1 == self.RecycleStartTime then
      self.RecycleStartTime = UpdateManager.Timestamp
      return
    end
    local Now = UpdateManager.Timestamp
    if Now - self.RecycleStartTime < RecycleTimeout then
      return
    end
    self.owner:Disappear(true)
    self:SetStatus(ThrowSessionStatusEnum.Destroyed)
    self:SetEnable(false)
  end
end

return LocalPetComponent
