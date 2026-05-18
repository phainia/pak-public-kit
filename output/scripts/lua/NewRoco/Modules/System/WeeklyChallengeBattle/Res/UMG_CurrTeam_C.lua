local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local WeeklyChallengeBattleModuleEvent = require("NewRoco.Modules.System.WeeklyChallengeBattle.WeeklyChallengeBattleModuleEvent")
local UMG_CurrTeam_C = Base:Extend("UMG_PreviousTeams2_C")

function UMG_CurrTeam_C:OnConstruct()
end

function UMG_CurrTeam_C:OnDestruct()
end

function UMG_CurrTeam_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  local petTeamData = _data
  self.petTeamData = petTeamData
  self.total_cheer_point = _data.total_cheer_point
  self.petIDData = petTeamData.pet_conf_id
  self.petGIDData = petTeamData.pet_gid
  local petFullIDData = {}
  for i, petID in ipairs(self.petIDData) do
    petFullIDData[i] = {}
    petFullIDData[i].petID = petID
    if self.petGIDData and self.petGIDData[i] then
      petFullIDData[i].petGID = self.petGIDData[i]
    end
  end
  self.petFullIDData = petFullIDData
  self:UpdateUI()
  if self.Switcher then
    self.Switcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_CurrTeam_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:PlayAnimation(self.Select_In)
    if self.petTeamData.photo then
      NRCEventCenter:DispatchEvent(WeeklyChallengeBattleModuleEvent.ChangeCurrTeamUsePhotoData, self.petTeamData, self.index)
    else
      NRCEventCenter:DispatchEvent(WeeklyChallengeBattleModuleEvent.ChangeCurrTeamUseTeamData, self.petTeamData, self.index)
    end
  else
    self:PlayAnimation(self.Cancel)
  end
end

function UMG_CurrTeam_C:OnDeactive()
end

function UMG_CurrTeam_C:UpdateUI()
  self.PetList:InitGridView(self.petFullIDData)
  self.Headline_1:SetText("x" .. self.total_cheer_point)
end

return UMG_CurrTeam_C
