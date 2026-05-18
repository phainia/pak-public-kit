local AppearanceLoginModuleData = _G.NRCData:Extend("AppearanceLoginModuleData")

function AppearanceLoginModuleData:Ctor()
  NRCData.Ctor(self)
  self.curBeautyChooseType = _G.Enum.SalonLabelType.SLT_BEGIN
  self.curMaleBeautyData = {}
  self.curFemaleBeautyData = {}
  self.UIColorIndexToColorIdMap = {}
  self.AvatarSalonIdToSalonIds = {}
  self.curAvatarSuitId = 0
  self.InitialOptionalSuitIdMap = {}
  self.InitialSelectedSuitIdMap = {}
end

function AppearanceLoginModuleData:BuildUIColorIndexToColorMap()
  local colorTable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.CHANGE_COLOUR_CONF)
  local colorData = colorTable:GetAllDatas()
  self.UIColorIndexToColorIdMap = {}
  for _, conf in pairs(colorData) do
    self.UIColorIndexToColorIdMap[conf.ui_value] = conf
  end
end

function AppearanceLoginModuleData:BuildAvatarSalonIdToSalonIds()
  local salonItemData = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.SALON_ITEM_CONF):GetAllDatas()
  for k, conf in pairs(salonItemData) do
    if self.AvatarSalonIdToSalonIds[conf.avatar_id] == nil then
      self.AvatarSalonIdToSalonIds[conf.avatar_id] = {}
    end
    if conf.is_free_item then
      table.insert(self.AvatarSalonIdToSalonIds[conf.avatar_id], k)
    end
  end
end

function AppearanceLoginModuleData:BuildAvatarInitialSuitMap()
  self.InitialOptionalSuitIdMap = {}
  local maleSuitConf = _G.DataConfigManager:GetRoleGlobalConfig("fashion_male_choose_suits")
  local femaleSuitConf = _G.DataConfigManager:GetRoleGlobalConfig("fashion_female_choose_suits")
  if nil == maleSuitConf or nil == femaleSuitConf then
    Log.Error("AppearanceLoginModuleData:BuildAvatarInitialSuitMap", "maleSuitConf or femaleSuitConf is nil")
    return
  end
  self.InitialOptionalSuitIdMap[ProtoEnum.ESexValue.SEX_MALE] = maleSuitConf.numList or {}
  self.InitialOptionalSuitIdMap[ProtoEnum.ESexValue.SEX_FEMALE] = femaleSuitConf.numList or {}
  self.InitialSelectedSuitIdMap = {
    [ProtoEnum.ESexValue.SEX_MALE] = self.InitialOptionalSuitIdMap[ProtoEnum.ESexValue.SEX_MALE][1],
    [ProtoEnum.ESexValue.SEX_FEMALE] = self.InitialOptionalSuitIdMap[ProtoEnum.ESexValue.SEX_FEMALE][1]
  }
end

function AppearanceLoginModuleData:GetInitialOptionalSuitIds(gender)
  return self.InitialOptionalSuitIdMap[gender]
end

function AppearanceLoginModuleData:GetInitialSelectedSuitId(gender)
  return self.InitialSelectedSuitIdMap[gender]
end

function AppearanceLoginModuleData:SetInitialSelectedSuitId(gender, fashionId)
  self.InitialSelectedSuitIdMap[gender] = fashionId
end

function AppearanceLoginModuleData:GenerateBeautyItemList()
  local beautyItemList = {}
  return self.AvatarSalonIdToSalonIds
end

function AppearanceLoginModuleData:SaveCurBeautyData(gender, salonData)
  if gender == ProtoEnum.ESexValue.SEX_MALE then
    self.curMaleBeautyData = salonData
  elseif gender == ProtoEnum.ESexValue.SEX_FEMALE then
    self.curFemaleBeautyData = salonData
  end
end

function AppearanceLoginModuleData:GetCurBeautyData(gender)
  if gender == ProtoEnum.ESexValue.SEX_MALE then
    return self.curMaleBeautyData
  elseif gender == ProtoEnum.ESexValue.SEX_FEMALE then
    return self.curFemaleBeautyData
  end
  return nil
end

return AppearanceLoginModuleData
