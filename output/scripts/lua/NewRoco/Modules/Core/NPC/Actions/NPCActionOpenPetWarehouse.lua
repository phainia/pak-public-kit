local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local NPCShopUIModuleEvent = reload("NewRoco.Modules.System.NPCShopUI.NPCShopUIModuleEvent")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = NPCActionBase
local NPCActionOpenPetWarehouse = Base:Extend("NPCActionOpenPetWarehouse")

function NPCActionOpenPetWarehouse:ExecuteWithModel()
  local CampFire = self:GetOwnerNPCView()
  local skillPath = "/Game/ArtRes/Effects/G6Skill/Luying/Camping_Pet_Storeroon_Start.Camping_Pet_Storeroon_Start"
  local skillProxy = RocoSkillProxy.Create(skillPath, CampFire.RocoSkill, PriorityEnum.Active_Player_Action)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  localPlayer.viewObj:K2_GetRootComponent():SetVisibility(false, true)
  _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.SetNpcModelVisible, false)
  _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.PlayCampingSkill, CampFire, skillProxy, self, self.OnCameraStartEnd)
end

function NPCActionOpenPetWarehouse:OnCameraStartEnd(Event, Skill)
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SetCanSelectWareHouseItem, true)
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetwarehousePanel, self)
end

function NPCActionOpenPetWarehouse:EndAction()
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  localPlayer.viewObj:K2_GetRootComponent():SetVisibility(true, true)
  _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.SetNpcModelVisible, true)
  local CampFire = self:GetOwnerNPCView()
  if not CampFire then
    self:OnCameraEndEnd()
    return
  end
  local skillPath = "/Game/ArtRes/Effects/G6Skill/Luying/Camping_Pet_Storeroon_End.Camping_Pet_Storeroon_End"
  local skillProxy = RocoSkillProxy.Create(skillPath, CampFire.RocoSkill, PriorityEnum.Active_Player_Action)
  _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.PlayCampingSkill, CampFire, skillProxy, self, self.OnCameraEndEnd)
end

function NPCActionOpenPetWarehouse:OnCameraEndEnd(Event, Skill)
  self:Finish()
end

return NPCActionOpenPetWarehouse
