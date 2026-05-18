local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectBase")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local LevelSelectionModuleCmd = require("NewRoco.Modules.System.LevelSelection.LevelSelectionModuleCmd")
local PetInheritanceActivityObject = Base:Extend("PetInheritanceActivityObject")

local function CalLoginDays(accLoginDays, maxLoginDays)
  local loginDays = _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.GetLoginDays)
  return math.min(loginDays + accLoginDays, maxLoginDays)
end

function PetInheritanceActivityObject:OnConstruct(_conf)
  self.accLoginDays = 0
  local partIds = self:GetPartIds()
  self.itemsData = table.new(0, #partIds)
  for _, partId in ipairs(partIds) do
    local inheritanceConf = _G.DataConfigManager:GetActivityInheritanceConf(partId)
    local maxProgress = inheritanceConf and inheritanceConf.day_num or 0
    self.itemsData[partId] = {
      partId = partId,
      curProgress = CalLoginDays(0, maxProgress),
      maxProgress = maxProgress,
      selectedPetData = nil
    }
  end
end

function PetInheritanceActivityObject:UpdatePartItemProgress(partId)
  local itemData = self:GetPartItemData(partId)
  if itemData and itemData.curProgress < itemData.maxProgress then
    local loginDays = CalLoginDays(self.accLoginDays, itemData.maxProgress)
    if loginDays ~= itemData.curProgress then
      itemData.curProgress = loginDays
      self:SendEvent(ActivityModuleEvent.RefreshPetInheritancePartItemData, self, itemData)
    end
  end
end

function PetInheritanceActivityObject:UpdatePartItemInheritPetData(petData, partId)
  local itemData = self:GetPartItemData(partId)
  if itemData then
    local curGid = itemData.selectedPetData and itemData.selectedPetData.gid or 0
    local newGid = petData and petData.gid or 0
    if curGid ~= newGid then
      itemData.selectedPetData = petData
      self:SendEvent(ActivityModuleEvent.RefreshPetInheritancePartItemData, self, itemData)
    end
  end
end

function PetInheritanceActivityObject:GetPartItemData(partId)
  return self.itemsData[partId or self:GetSinglePartId()]
end

function PetInheritanceActivityObject:IsPetInherited(petGid)
  for _, itemData in pairs(self.itemsData) do
    if itemData.selectedPetData and itemData.selectedPetData.gid == petGid then
      return true
    end
  end
  return false
end

function PetInheritanceActivityObject:SendZoneChooseInheritPetReq(partId, petGid)
  local itemData = self:GetPartItemData(partId)
  local curSelectGid = itemData and itemData.selectedPetData and itemData.selectedPetData.gid
  local req = _G.ProtoMessage:newZoneChooseInheritPetReq()
  req.activity_id = self:GetActivityId()
  req.pet_gid = petGid
  req.take_back = curSelectGid == petGid
  ActivityUtils.SendMsgToSvr(_G.ProtoCMD.ZoneSvrCmd.ZONE_CHOOSE_INHERIT_PET_REQ, req, self, self.OnZoneChooseInheritPetRsp, partId)
end

function PetInheritanceActivityObject:OnZoneChooseInheritPetRsp(rsp, req, partId)
  if not rsp or 0 ~= rsp.ret_info.ret_code then
    return
  end
  if req.take_back then
    self:UpdatePartItemInheritPetData(nil, partId)
  else
    local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(req.pet_gid)
    if petData then
      self:UpdatePartItemInheritPetData(petData, partId)
    else
      Log.Error("OnZoneChooseInheritPetRsp: petData not found.", req.pet_gid)
      self:ReqGetPlayerActivityData()
    end
  end
end

function PetInheritanceActivityObject:GetPetTeamData(teamType)
  local teamGids = {}
  local teamInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerPetTeamInfoByTeamType(teamType)
  local teams = teamInfo and teamInfo.teams
  if teams then
    for idx, team in ipairs(teams) do
      if team.pet_infos then
        for pos, petInfo in ipairs(team.pet_infos) do
          teamGids[petInfo.pet_gid] = {idx, pos}
        end
      end
    end
  end
  return teamGids
end

function PetInheritanceActivityObject:GetInheritancePetList(partId)
  local petList = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo().pet_data or {}
  local bagPetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBackpackPetInfo()
  local battlePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  local curInheritancePetGid
  local inheritanceData = self:GetPartItemData(partId)
  if inheritanceData and inheritanceData.selectedPetData then
    curInheritancePetGid = inheritanceData.selectedPetData.gid
  end
  local inheritanceConf = _G.DataConfigManager:GetActivityInheritanceConf(partId)
  local petWhitelist = inheritanceConf and inheritanceConf.pet_whitelist or {}
  local showAllPet = inheritanceConf and 0 == inheritanceConf.appearance or false
  local allowColorTypeMask = 0
  if inheritanceConf and inheritanceConf.color_type then
    for _, v in ipairs(inheritanceConf.color_type) do
      allowColorTypeMask = allowColorTypeMask | v
    end
  end
  local petWhitelistDic = table.new(0, #petWhitelist)
  for _, v in ipairs(petWhitelist) do
    petWhitelistDic[v] = true
  end
  local maxPetNum = #petList + #bagPetList + #battlePetList
  local petDataList = table.new(maxPetNum, 0)
  local petDataDic = table.new(0, maxPetNum)
  local teamGids = self:GetPetTeamData(Enum.PlayerTeamType.PTT_BIG_WORLD)
  
  local function GetPetSortNum(petInfo)
    local sortNum = 0
    if petInfo.isSelected then
      sortNum = -1
    elseif petInfo.isTeam then
      sortNum = petInfo.teamIdx * 10 + petInfo.teamPos
    else
      sortNum = 1000
    end
    return sortNum
  end
  
  local function CreateReplacePetData(petData)
    local teamData = teamGids[petData.gid]
    local ret = {}
    ret.PetData = petData
    ret.gid = petData.gid
    ret.addTime = petData.add_time
    ret.level = petData.level
    ret.teamIdx = teamData and teamData[1] or 0
    ret.teamPos = teamData and teamData[2] or 0
    ret.isTeam = nil ~= teamData or _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.IsHasLevelSelectionTeams, petData.gid) and true or false
    ret.isBattleTeam = table.contains(battleTeamGids, petData.gid)
    ret.isInTemporarilyStoreBackpack = _G.DataModelMgr.PlayerDataModel:IsInBackpack(petData.gid)
    ret.isTravel = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetPetIsTravel, petData.gid)
    ret.isInHome = _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.GetPetIsInHome, petData.gid)
    ret.isInGuard = _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.GetHomePlantGuardPetGid) == petData.gid
    ret.isSelected = curInheritancePetGid == petData.gid
    ret.sortNum = GetPetSortNum(ret)
    return ret
  end
  
  local function MergePetData(src, dst)
    for _, v in ipairs(src) do
      local shouldFilter = petDataDic[v.gid] or not petWhitelistDic[v.base_conf_id]
      if not shouldFilter and not showAllPet then
        if v.mutation_type == Enum.MutationDiffType.MDT_NONE and (not v.glass_info or v.glass_info.glass_type == ProtoEnum.GlassType.GT_NULL) then
          shouldFilter = true
        elseif 0 ~= v.mutation_type & ~allowColorTypeMask then
          shouldFilter = true
        end
      end
      shouldFilter = shouldFilter or v.pet_status_flags and v.pet_status_flags & _G.ProtoEnum.PetStatusFlag.MIRACLE_CHANGING > 0
      if not shouldFilter then
        table.insert(dst, CreateReplacePetData(v))
      end
      petDataDic[v.gid] = true
    end
  end
  
  MergePetData(petList, petDataList)
  MergePetData(bagPetList, petDataList)
  MergePetData(battlePetList, petDataList)
  return petDataList
end

function PetInheritanceActivityObject:SyncActivityDataOnAvailable()
  self:ReqGetPlayerActivityData()
end

function PetInheritanceActivityObject:OnSvrUpdateActivityData(_cmdId, _updateData, _initUpdate)
  if _cmdId == _G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_ACTIVITY_DATA_RSP then
    local inheritPetData = _updateData and _updateData.inherit_pet_data
    self.accLoginDays = inheritPetData and inheritPetData.reserved1 or 0
    self:UpdatePartItemInheritPetData(inheritPetData and inheritPetData.inherit_pet_info)
    self:UpdatePartItemProgress()
  end
end

return PetInheritanceActivityObject
