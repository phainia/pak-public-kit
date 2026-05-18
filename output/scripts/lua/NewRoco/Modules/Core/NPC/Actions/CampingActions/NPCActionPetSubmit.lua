local NPCActionModelBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionModelBase
local NPCActionPetSubmit = Base:Extend("NPCActionPetSubmit")

function NPCActionPetSubmit:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionPetSubmit:ExecuteWithModel()
  self.shouldShowTip = false
  local backpackPets = _G.DataModelMgr.PlayerDataModel:GetPlayerBackpackPetInfo()
  local firstPet
  if #backpackPets > 0 then
    firstPet = backpackPets[#backpackPets]
  end
  local firstPetName = firstPet and firstPet.name or ""
  _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.RecordReportPetInfo, firstPetName)
  NRCModeManager:GetCurMode():DisablePanelByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  self:OnLuluPrepared()
end

function NPCActionPetSubmit:OnLuluPrepared()
  local CampFire = self:GetOwnerNPCView()
  if not CampFire then
    self:EndAction()
    return
  end
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OnSubmitPet, self)
end

function NPCActionPetSubmit:BeginEnd()
  local CampFire = self:GetOwnerNPCView()
  if not CampFire then
    return
  end
  CampFire:ClearPet()
end

function NPCActionPetSubmit:EndAction()
  _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.ShowReportPetInfo)
  self:Finish()
end

return NPCActionPetSubmit
