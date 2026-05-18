local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local UMG_Activity_PikaFashionSurvey_ToPhoto_Item_C = Base:Extend("UMG_Activity_PikaFashionSurvey_ToPhoto_Item_C")

function UMG_Activity_PikaFashionSurvey_ToPhoto_Item_C:OnConstruct()
  self:AddButtonListener(self.TrackBtn.btnLevelUp, self.OnClickTrack)
end

function UMG_Activity_PikaFashionSurvey_ToPhoto_Item_C:OnDestruct()
end

function UMG_Activity_PikaFashionSurvey_ToPhoto_Item_C:OnItemUpdate(_data, datalist, index)
end

function UMG_Activity_PikaFashionSurvey_ToPhoto_Item_C:OnItemSelected(_bSelected)
end

function UMG_Activity_PikaFashionSurvey_ToPhoto_Item_C:OnDeactive()
end

function UMG_Activity_PikaFashionSurvey_ToPhoto_Item_C:RefreshItem(Data)
  self.Data = Data
  local bUnlocked = Data and Data.bUnlocked
  local petBaseId = Data and Data.petBaseIds and Data.petBaseIds[1]
  local PetBaseConf = DataConfigManager:GetPetbaseConf(petBaseId or 0, true)
  self.Text_Name:SetText(PetBaseConf and PetBaseConf.name or "")
  if not bUnlocked then
    self.Photo:SetPath(self.Data.photoLockRes or "")
  else
    self.Photo:SetPath(self.Data.photoRes or "")
  end
end

function UMG_Activity_PikaFashionSurvey_ToPhoto_Item_C:OnClickTrack()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_Activity_PikaFashionSurvey_ToPhoto_Item_C:OnClickTrack")
  if self.Data and self.Data.petBaseIds then
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
    
    for i, petBaseId in ipairs(self.Data.petBaseIds) do
      AddPetBaseId(petBaseId)
    end
    ActivityUtils.RequestTracePet(petBaseIdList, self.Data.activityInst)
  end
end

return UMG_Activity_PikaFashionSurvey_ToPhoto_Item_C
