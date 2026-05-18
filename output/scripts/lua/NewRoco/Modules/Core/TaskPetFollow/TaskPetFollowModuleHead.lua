local TaskPetFollowModuleHead = NRCModuleHeadBase:Extend("TaskPetFollowModuleHead")

function TaskPetFollowModuleHead:OnConstruct()
  _G.TaskPetFollowModuleCmd = reload("NewRoco.Modules.Core.TaskPetFollow.TaskPetFollowModuleCmd")
  self:BindCmd(_G.TaskPetFollowModuleCmd.TrySummonPetFollow, "TrySummonPetFollow")
  self:BindCmd(_G.TaskPetFollowModuleCmd.RecycleFollowedPets, "RecycleFollowedPets")
  self:BindCmd(_G.TaskPetFollowModuleCmd.CheckPetInTaskFollow, "CheckPetInTaskFollow")
  self:BindCmd(_G.TaskPetFollowModuleCmd.TrySummonPet, "TrySummonPet")
  self:BindCmd(_G.TaskPetFollowModuleCmd.OnPetTogetherTaskNotify, "OnPetTogetherTaskNotify")
end

return TaskPetFollowModuleHead
