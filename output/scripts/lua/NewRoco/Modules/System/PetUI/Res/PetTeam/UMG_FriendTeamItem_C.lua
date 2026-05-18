local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UIUtils = require("NewRoco.Utils.UIUtils")
local UMG_FriendTeamItem_C = Base:Extend("UMG_FriendTeamItem_C")

function UMG_FriendTeamItem_C:OnConstruct()
  self.module = _G.NRCModuleManager:GetModule("PetUIModule")
  self.moduleData = self.module:GetData("PetUIModuleData")
  self.Btn_View.btnLevelUp.OnClicked:Add(self, self.OnViewBtnClicked)
end

function UMG_FriendTeamItem_C:OnDestruct()
end

function UMG_FriendTeamItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self.datalist = datalist
  self:UpdateUIInfo()
  self:CheckPageRequest(index, #datalist)
end

function UMG_FriendTeamItem_C:CheckPageRequest(curIndex, totalCount)
  local friendPetTeamResultInfo = self.moduleData:GetFriendPetTeamResultInfo()
  local curReqPageIndex = friendPetTeamResultInfo.ReqPageIndex
  local totalPageCount = friendPetTeamResultInfo.TotalPageCount
  local expectedPageIndex = self.moduleData:GetExpectedFriendTeamReqIndex()
  if curReqPageIndex < totalPageCount - 1 and curReqPageIndex >= expectedPageIndex and totalCount - curIndex <= self.moduleData:GetThresholdCountForPageReq() then
    local newPageIndex = curReqPageIndex + 1
    self.moduleData:SetExpectedFriendTeamReqIndex(newPageIndex)
    Log.DebugFormat("UMG_FriendTeamItem_C:CheckPageRequest - Requesting next page: %d, teamType: %s, filter: %s", newPageIndex, tostring(friendPetTeamResultInfo.TeamType), friendPetTeamResultInfo.Filter)
    self.module:OnZonePetTeamFriendGetListReq(friendPetTeamResultInfo.TeamType, newPageIndex, friendPetTeamResultInfo.Filter)
  end
end

function UMG_FriendTeamItem_C:UpdateUIInfo()
  local petItemDataList = self:GetPetItemDataList()
  self.PetGridView:InitGridView(petItemDataList)
  self:UpdateRoleMagicInfo()
  self:UpdateFriendInfo()
  self:UpdateTeamName()
end

function UMG_FriendTeamItem_C:UpdateTeamName()
  local teamData = self.data.petTeam
  local teamNameStr
  if not teamData.team_name or teamData.team_name == "" then
    local teamNameCfg = _G.DataConfigManager:GetBattleGlobalConfig("pvp_team_name")
    teamNameStr = string.format(teamNameCfg.str, teamData.team_idx + 1)
  else
    teamNameStr = teamData.team_name
  end
  UIUtils.SafeSetText(self.TeamName, teamNameStr)
end

function UMG_FriendTeamItem_C:GetPetItemDataList()
  local petItemDataList = {}
  self.HasTrialPet = false
  for _, petInfo in ipairs(self.data.petTeam.pet_infos) do
    local petData = self.moduleData:GetPetDataByFriendUinAndPetGid(self.data.friendUin, petInfo.pet_gid)
    if not table.isNotEmpty(petData) then
    else
      if petData.is_trial_pet then
        self.HasTrialPet = true
      end
      local petItemData = {}
      petItemData.isTrailPet = petData.is_trial_pet or false
      petItemData.PetData = petData
      table.insert(petItemDataList, petItemData)
    end
  end
  return petItemDataList
end

function UMG_FriendTeamItem_C:UpdateFriendInfo()
  UIUtils.SafeSetText(self.PlayerNameText, self.data.friendName)
  if self.data.friend_is_mirror_unlocked then
    self.PlayerNameText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("dc9827ff"))
  else
    self.PlayerNameText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("F4EEE1FF"))
  end
  UIUtils.SafeSetText(self.GradeText, self.data.friendLevel)
  UIUtils.SetPlayerHeadIcon(self.HeadPortrait, self.data.cardIconSelected)
end

function UMG_FriendTeamItem_C:UpdateRoleMagicInfo()
  local hasMagic = false
  local petData = self.data.petTeam
  if petData.mirror_magic_id and 0 ~= petData.mirror_magic_id then
    local PlayerMagicConf = _G.DataConfigManager:GetBagItemConf(petData.mirror_magic_id)
    if PlayerMagicConf then
      hasMagic = true
      self.MagicIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.MagicIcon:SetPath(PlayerMagicConf.icon)
    end
  end
  if not hasMagic then
    self.MagicIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_FriendTeamItem_C:OnViewBtnClicked()
  _G.NRCAudioManager:PlaySound2DAuto(40008005, "UMG_FriendTeamPanel_C:OnDoubtBtnClicked")
  local friendTeamDetailsParam = {}
  friendTeamDetailsParam.PetTeam = self.data.petTeam
  friendTeamDetailsParam.FriendUin = self.data.friendUin
  friendTeamDetailsParam.TeamType = self.data.TeamType
  friendTeamDetailsParam.HasTrialPet = self.HasTrialPet
  friendTeamDetailsParam.IsUnlockTeamShare = self.data.friend_is_mirror_unlocked
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenFriendPetTeamDetailPanel, friendTeamDetailsParam)
end

function UMG_FriendTeamItem_C:OnItemSelected(_bSelected)
end

return UMG_FriendTeamItem_C
