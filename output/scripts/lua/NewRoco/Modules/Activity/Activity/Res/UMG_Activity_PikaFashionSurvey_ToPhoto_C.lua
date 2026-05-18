local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local UMG_Activity_PikaFashionSurvey_ToPhoto_C = _G.NRCPanelBase:Extend("UMG_Activity_PikaFashionSurvey_ToPhoto_C")

function UMG_Activity_PikaFashionSurvey_ToPhoto_C:OnConstruct()
  self.PhotoItemsList4 = {
    self.PhotoItem1,
    self.PhotoItem2,
    self.PhotoItem3,
    self.PhotoItem4
  }
  self.PhotoItemsList3 = {
    self.PhotoItem3_1,
    self.PhotoItem3_2,
    self.PhotoItem3_3
  }
  self:OnAddEventListener()
end

function UMG_Activity_PikaFashionSurvey_ToPhoto_C:OnActive(Parent)
  _G.NRCAudioManager:PlaySound2DAuto(40006007, "UMG_Activity_PikaFashionSurvey_ToPhoto_C:OnActive")
  self.ParentPanel = Parent
  self:InitPhotoList()
  self:InitDesc()
end

function UMG_Activity_PikaFashionSurvey_ToPhoto_C:OnDeactive()
end

function UMG_Activity_PikaFashionSurvey_ToPhoto_C:OnAddEventListener()
  self:AddButtonListener(self.FullScreen_Close, self.OnReqClose)
  self:AddButtonListener(self.btnClose.btnClose, self.OnReqClose)
  self:RegisterEvent(self, ActivityModuleEvent.TakePhotoPetIdentifyActivityExpired, self.DoClose)
end

function UMG_Activity_PikaFashionSurvey_ToPhoto_C:OnReqClose()
  _G.NRCAudioManager:PlaySound2DAuto(41400008, "UMG_Activity_PikaFashionSurvey_ToPhoto_C:OnReqClose")
  if self.bPendingClose then
    return
  end
  self.bPendingClose = true
  self:PlayAnimation(self.Out)
end

function UMG_Activity_PikaFashionSurvey_ToPhoto_C:OnAnimationFinished(Anim)
  if Anim == self.Out then
    self:DoClose()
  end
end

function UMG_Activity_PikaFashionSurvey_ToPhoto_C:IsPetUnLocked(Pets, petBaseIds)
  local petBaseIdList = {}
  local petBaseIdMap = {}
  
  local function AddPetBaseId(petBaseId)
    local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(petBaseId, true)
    if PetBaseConf then
      local EvolutionConf = _G.DataConfigManager:GetPetEvolutionConf(PetBaseConf.pet_evolution_id[1], true)
      if EvolutionConf then
        local evolution_chain = EvolutionConf.evolution_chain
        if evolution_chain then
          for _, chain in ipairs(evolution_chain) do
            if not petBaseIdMap[chain.petbase_id] then
              petBaseIdMap[chain.petbase_id] = true
              table.insert(petBaseIdList, chain.petbase_id)
            end
          end
        end
      end
    end
  end
  
  for i, petBaseId in ipairs(petBaseIds) do
    AddPetBaseId(petBaseId)
  end
  for i, pet in ipairs(Pets) do
    if petBaseIdMap[pet] then
      return true
    end
  end
  return false
end

function UMG_Activity_PikaFashionSurvey_ToPhoto_C:InitPhotoList()
  local ActObj = self.ParentPanel:GetActivityObject()
  local Data = ActObj:GetActivityData()
  local pets = Data.already_taken_pets
  local Config = self.ParentPanel.PetPhotoConf
  local Num = #Config.condition_group
  local ShowList = self.PhotoItemsList4
  if 3 == Num then
    ShowList = self.PhotoItemsList3
    self.NumberSwitcher:SetActiveWidgetIndex(0)
  else
    self.NumberSwitcher:SetActiveWidgetIndex(1)
  end
  for i, PhotoItem in ipairs(ShowList) do
    local PhotoConfig = Config.condition_group[i]
    if not PhotoConfig then
      PhotoItem:SetVisibility(UE.ESlateVisibility.Collapsed)
    else
      local PhotoData = {
        bUnlocked = pets and self:IsPetUnLocked(pets, PhotoConfig.base_ids),
        photoRes = PhotoConfig.condition_photo,
        photoLockRes = PhotoConfig.unfinish_photo,
        petBaseIds = PhotoConfig.base_ids,
        activityInst = ActObj
      }
      PhotoItem:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      PhotoItem:RefreshItem(PhotoData)
    end
  end
end

function UMG_Activity_PikaFashionSurvey_ToPhoto_C:InitDesc()
  local Config = self.ParentPanel.PetPhotoConf
  local activityObject = self.ParentPanel:GetActivityObject()
  local ActivityData = activityObject:GetActivityData()
  local Conf = _G.DataConfigManager:GetActivityPetPhoto(activityObject:GetActivityId(), true)
  local v1 = ActivityData.already_taken_pets and #ActivityData.already_taken_pets or 0
  local v2 = #Conf.condition_group
  self.SPartName:SetText(string.format(Config.scpart_name, v1, v2))
end

return UMG_Activity_PikaFashionSurvey_ToPhoto_C
