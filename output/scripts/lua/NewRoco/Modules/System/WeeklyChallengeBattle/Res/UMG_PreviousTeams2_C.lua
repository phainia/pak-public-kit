local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local WeeklyChallengeBattleModuleEvent = require("NewRoco.Modules.System.WeeklyChallengeBattle.WeeklyChallengeBattleModuleEvent")
local UMG_PreviousTeams2_C = Base:Extend("UMG_PreviousTeams2_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")

function UMG_PreviousTeams2_C:OnConstruct()
end

function UMG_PreviousTeams2_C:OnDestruct()
end

function UMG_PreviousTeams2_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.timestamp = _data.photo.timestamp
  local dateDetail = ActivityUtils.ToTimeDetailData(self.timestamp)
  self.Text_name:SetText(dateDetail.year .. "/" .. dateDetail.month .. "/" .. dateDetail.day)
  self.petTeamData = _data
  self.total_cheer_point = _data.total_cheer_point
  self.photo_template_id = _data.photo.photo_template_id
  self.animFrame = _data.photo.anime_percent
  self.petIDData = _data.pet_conf_id
  self.petGIDData = _data.pet_gid
  local petFullIDData = {}
  if self.petIDData then
    for i, petID in ipairs(self.petIDData) do
      petFullIDData[i] = {}
      petFullIDData[i].petID = petID
      if self.petGIDData[i] then
        petFullIDData[i].petGID = self.petGIDData[i]
      end
    end
  else
    Log.Error("UMG_PreviousTeams2_C self.petIDData is nil")
  end
  self.petFullIDData = petFullIDData
  self:UpdateUI()
end

function UMG_PreviousTeams2_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:PlayAnimation(self.Select_In)
    NRCEventCenter:DispatchEvent(WeeklyChallengeBattleModuleEvent.ChangeHistoryTeamUsePhotoData, self.petTeamData, self.index)
  else
    self:PlayAnimation(self.Cancel)
  end
end

function UMG_PreviousTeams2_C:OnDeactive()
end

function UMG_PreviousTeams2_C:UpdateUI()
  self.PetList:InitGridView(self.petFullIDData)
  self.Headline_1:SetText("x" .. self.total_cheer_point)
end

return UMG_PreviousTeams2_C
