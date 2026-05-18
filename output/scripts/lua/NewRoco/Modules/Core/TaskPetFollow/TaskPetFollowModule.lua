local PetFollowRunner = require("NewRoco.Modules.Core.TaskPetFollow.PetFollowRunner")
local TaskPetFollowModule = _G.NRCModuleBase:Extend("TaskPetFollowModule")

function TaskPetFollowModule:OnConstruct()
  self.PetFollowContexts = {}
end

function TaskPetFollowModule:OnActive()
end

function TaskPetFollowModule:OnRelogin()
end

function TaskPetFollowModule:OnDeactive()
  self:RecycleFollowedPets()
end

function TaskPetFollowModule:OnDestruct()
end

function TaskPetFollowModule:OnPetTogetherTaskNotify(Notify)
  _G.DataModelMgr.PlayerDataModel:UpdatePetStatusFlag(Notify.gid, Notify.pet_status_flags)
  if -1 == Notify.pet_status_flags then
    self:CachePet(Notify.gid, Notify.task_id)
  elseif 0 ~= Notify.pet_status_flags & ProtoEnum.PetStatusFlag.TASK_TOGETHER_IN_PROGRESS then
    self:TrySummonPet(Notify.gid, Notify.task_id)
  elseif 0 ~= Notify.pet_status_flags & ProtoEnum.PetStatusFlag.TASK_TOGETHER_MARKING then
    self:MarkPet(Notify.gid, Notify.task_id)
  else
    self:TryRecyclePet(Notify.gid)
  end
end

function TaskPetFollowModule:TrySummonPet(Gid, TaskID)
  if not self.PetFollowContexts[Gid] then
    self.PetFollowContexts[Gid] = PetFollowRunner(self, Gid, TaskID)
  else
    Log.Warning("[PetFollowModule] \229\183\178\231\187\143\229\173\152\229\156\168\229\175\185\229\186\148\231\154\132PetFollowContext")
    self.PetFollowContexts[Gid]:AddBindTask(TaskID)
  end
  self.PetFollowContexts[Gid]:TrySummonPet()
end

function TaskPetFollowModule:MarkPet(Gid, TaskID)
  if not self.PetFollowContexts[Gid] then
    self.PetFollowContexts[Gid] = PetFollowRunner(self, Gid, TaskID)
  else
    self.PetFollowContexts[Gid]:RecyclePet(false, false)
    self.PetFollowContexts[Gid]:AddBindTask(TaskID)
  end
end

function TaskPetFollowModule:CachePet(Gid, TaskID)
  if not self.PetFollowContexts[Gid] then
    self.PetFollowContexts[Gid] = PetFollowRunner(self, Gid, TaskID)
  else
    self.PetFollowContexts[Gid]:AddBindTask(TaskID)
  end
end

function TaskPetFollowModule:TrySummonPetFollow(PetConfID, TaskID)
  if not self:CheckTaskValidByID(TaskID) then
    return
  end
  if not _G.DataModelMgr.PlayerDataModel then
    return
  end
  local AllPetData = _G.DataModelMgr.PlayerDataModel:GetPetData()
  if not AllPetData then
    return
  end
  local TargetPetData
  local LatestTime = math.mininteger
  for _, PetData in ipairs(AllPetData) do
    if PetData.conf_id == PetConfID and LatestTime < PetData.add_time then
      TargetPetData = PetData
      LatestTime = PetData.add_time
    end
  end
  if not TargetPetData then
    Log.Error("[PetFollowModule] \230\137\190\228\184\141\229\136\176\229\175\185\229\186\148\231\154\132\231\178\190\231\129\18123333\239\188\140\230\163\128\230\159\165\228\184\128\228\184\139")
    return
  end
  if not self.PetFollowContexts[TargetPetData.gid] then
    self.PetFollowContexts[TargetPetData.gid] = PetFollowRunner(self, TargetPetData.gid, TaskID)
  else
    Log.Warning("[PetFollowModule] \229\183\178\231\187\143\229\173\152\229\156\168\229\175\185\229\186\148\231\154\132PetFollowContext")
    self.PetFollowContexts[TargetPetData.gid]:AddBindTask(TaskID)
  end
  self.PetFollowContexts[TargetPetData.gid]:TrySummonPet()
end

local CheckFlag = {
  None = 0,
  ThrowCheck = 1,
  RideCheck = 2,
  FreeCheck = 3,
  BagLock = 4
}
TaskPetFollowModule.CheckFlag = CheckFlag

function TaskPetFollowModule:CheckPetInTaskFollow(Gid, Flag)
  local PetFollowContext = self.PetFollowContexts[Gid]
  if not PetFollowContext then
    return false
  end
  local Message
  local TaskName = self:GetTaskNameByID(PetFollowContext.FirstTaskID)
  if Flag == CheckFlag.ThrowCheck then
    Message = string.format(_G.DataConfigManager:GetLocalizationConf("follower_pet_cantcallback").msg, TaskName)
    return PetFollowContext and PetFollowContext.Session, Message
  elseif Flag == CheckFlag.RideCheck then
    Message = string.format(_G.DataConfigManager:GetLocalizationConf("follower_pet_cantride").msg, TaskName)
    return PetFollowContext and PetFollowContext.Session, Message
  elseif Flag == CheckFlag.FreeCheck then
    Message = string.format(_G.DataConfigManager:GetLocalizationConf("follower_pet_cantrelease").msg, TaskName)
    return true, Message
  elseif Flag == CheckFlag.BagLock then
    return true
  end
  return false
end

function TaskPetFollowModule:GetTaskNameByID(TaskID)
  local TaskObject = _G.NRCModuleManager:DoCmd(_G.TaskModuleCmd.GetTaskObjectByTaskId, TaskID)
  return TaskObject and TaskObject.Config.name or "Unknown Task"
end

function TaskPetFollowModule:CheckTaskValidByID(TaskID)
  return true
end

function TaskPetFollowModule:TryRecyclePet(Gid)
  local PetFollowContext = self.PetFollowContexts[Gid]
  if not PetFollowContext then
    return
  end
  PetFollowContext:RecyclePet()
  self.PetFollowContexts[Gid] = nil
end

function TaskPetFollowModule:RecycleFollowedPets()
  for _, PetFollowContext in pairs(self.PetFollowContexts) do
    PetFollowContext:RecyclePet()
  end
  table.clear(self.PetFollowContexts)
end

return TaskPetFollowModule
