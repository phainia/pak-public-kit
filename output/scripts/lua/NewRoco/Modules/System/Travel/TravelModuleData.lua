local TravelModuleData = _G.NRCData:Extend("TravelModuleData")
local TravelModuleEvent = reload("NewRoco.Modules.System.Travel.TravelModuleEvent")

function TravelModuleData:Ctor()
  NRCData.Ctor(self)
  self.CampLevelupDatas = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.CAMP_LEVELUP_CONF):GetAllDatas()
  self.selectTimeTabIndex = 0
  self.selectPetDic = {}
  self:ClearSelectTravelPet()
end

function TravelModuleData:GetCampLevelConf(contentId, travelLv)
  for i, data in pairs(self.CampLevelupDatas) do
    if data.content_id == contentId and data.level == travelLv then
      return data
    end
  end
  return nil
end

function TravelModuleData:GetCampLevelConfs(contentId)
  local List
  for i, data in pairs(self.CampLevelupDatas) do
    if data.content_id == contentId then
      if nil == List then
        List = {}
      end
      table.insert(List, data)
    end
  end
  return List
end

function TravelModuleData:SelectTravelPet(key, gid, baseId, level)
  if nil == gid or nil == baseId then
    gid = -1
    baseId = -1
  end
  self.selectPetDic[key] = {
    gid = gid,
    baseId = baseId,
    level = level
  }
end

function TravelModuleData:GetSelectTravelPet()
  return self.selectPetDic
end

function TravelModuleData:GetSelectTravelPetIndex()
  for key, value in pairs(self.selectPetDic) do
    if -1 == value.gid then
      return key
    end
  end
  return 0
end

function TravelModuleData:ClearSelectTravelPet()
  self.selectPetDic[1] = {gid = -1, baseId = -1}
  self.selectPetDic[2] = {gid = -1, baseId = -1}
end

function TravelModuleData:GetTravelInfos()
  if _G.DataModelMgr.PlayerDataModel.playerInfo.pet_info == nil then
    _G.DataModelMgr.PlayerDataModel.playerInfo.pet_info = {}
  end
  if nil == _G.DataModelMgr.PlayerDataModel.playerInfo.pet_info.travel_info then
    _G.DataModelMgr.PlayerDataModel.playerInfo.pet_info.travel_info = {}
  end
  return _G.DataModelMgr.PlayerDataModel.playerInfo.pet_info.travel_info
end

function TravelModuleData:SetTravelInfo(travel_info)
  if nil == travel_info then
    travel_info = {}
  end
  _G.DataModelMgr.PlayerDataModel.playerInfo.pet_info.travel_info = travel_info
end

function TravelModuleData:GetSelectTimeTabIndex()
  return self.selectTimeTabIndex
end

function TravelModuleData:SetSelectTimeTabIndex(index)
  self.selectTimeTabIndex = index
end

return TravelModuleData
