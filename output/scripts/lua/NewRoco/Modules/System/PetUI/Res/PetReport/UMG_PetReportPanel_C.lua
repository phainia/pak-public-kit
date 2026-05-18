local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local UMG_PetReportPanel_C = _G.NRCPanelBase:Extend("UMG_PetReportPanel_C")

function UMG_PetReportPanel_C:OnActive()
end

function UMG_PetReportPanel_C:OnDeactive()
end

function UMG_PetReportPanel_C:OnAddEventListener()
end

function UMG_PetReportPanel_C:InitWithPetBaseId(PetBaseIdList)
  local petbaseList = {}
  table.deepCopy(PetBaseIdList, petbaseList, false)
  local activities = _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.GetActivityInstByType, _G.Enum.ActivityType.ATP_PET_CATCH)
  local isHaveActive = activities and #activities > 0
  if isHaveActive then
    local isOpen = activities[1]:IsInProgress()
    if isOpen then
      local totalScore = 0
      for key, Petdata in pairs(petbaseList) do
        local score = math.floor(self:GetPetDataScore(Petdata))
        Petdata.score = score
        totalScore = totalScore + score
      end
      self.HorizontalBox_35:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Text_quantity:SetText(totalScore)
    else
      self.HorizontalBox_35:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self.HorizontalBox_35:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.List.bShowAll = true
  self.List:InitList(petbaseList)
  self.Number:SetText(string.format("%d", #petbaseList))
end

function UMG_PetReportPanel_C:GetMutationTypes(mutationType)
  local results = {}
  for key, bit in pairs(_G.Enum.MutationDiffType) do
    if 0 ~= bit and 0 ~= mutationType & bit then
      table.insert(results, _G.Enum.MutationDiffType[key])
    end
  end
  return results
end

function UMG_PetReportPanel_C:GetPetDataScore(data)
  local baseId = data.base_conf_id
  local petbaseConf = _G.DataConfigManager:GetPetbaseConf(baseId)
  local petTalentRank = data.talent_rank
  local mutationTypes = self:GetMutationTypes(data.mutation_type)
  local bloodMultiple = 1
  local totalScore = 0
  if petbaseConf then
    local petfreeSort = petbaseConf.petfree_sort
    if petfreeSort > 0 then
      local scoreConf = _G.DataConfigManager:GetPetReportScoreConf(petfreeSort)
      local basicScore = scoreConf.point
      local talentDic = {}
      talentDic[_G.Enum.PetTalentRate.PTR_NONE] = scoreConf.normal_ratio / 10000
      talentDic[_G.Enum.PetTalentRate.PTR_NORMAL] = scoreConf.normal_ratio / 10000
      talentDic[_G.Enum.PetTalentRate.PTR_GOOD] = scoreConf.good_ratio / 10000
      talentDic[_G.Enum.PetTalentRate.PTR_AMAZING] = scoreConf.amazing_ratio / 10000
      talentDic[_G.Enum.PetTalentRate.PTR_PERFECT] = scoreConf.perfect_ratio / 10000
      local talent = talentDic[petTalentRank] or 1
      local mutationDic = {}
      mutationDic[Enum.MutationDiffType.MDT_NONE] = 1
      mutationDic[Enum.MutationDiffType.MDT_SHINING] = scoreConf.shining_ratio / 10000
      mutationDic[Enum.MutationDiffType.MDT_GLASS] = scoreConf.glass_ratio / 10000
      mutationDic[Enum.MutationDiffType.MDT_CHAOS_TWO] = scoreConf.chaos_two_ratio / 10000
      local mutation = 1
      if mutationTypes and #mutationTypes > 0 then
        for i = 1, #mutationTypes do
          local mutationType = mutationTypes[i]
          if mutationDic[mutationType] then
            mutation = mutation * mutationDic[mutationType]
          end
        end
      end
      local bloodConf = _G.DataConfigManager:GetPetBloodConf(data.blood_id)
      if bloodConf then
        if bloodConf.blood == Enum.PetBloodType.PBT_BOSS then
          bloodMultiple = scoreConf.bossblood_ratio / 10000
        else
          local isUnit = false
          if petbaseConf.unit_type and #petbaseConf.unit_type > 0 then
            for i = 1, #petbaseConf.unit_type do
              if petbaseConf.unit_type[i] == bloodConf.blood_type then
                isUnit = true
              end
            end
          end
          if false == isUnit then
            bloodMultiple = scoreConf.differentblood_ratio / 10000
          end
        end
      end
      totalScore = basicScore * talent * mutation * bloodMultiple
    end
  end
  return totalScore
end

return UMG_PetReportPanel_C
