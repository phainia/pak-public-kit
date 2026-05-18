local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local PetUtils = require("NewRoco.Utils.PetUtils")
local MainUIModuleEvent = reload("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local UMG_PetFormIntoColumns_C = _G.NRCViewBase:Extend("UMG_PetFormIntoColumns_C")
local PetFormIntoColumnsUiData

function UMG_PetFormIntoColumns_C:Initialize(Initializer)
end

function UMG_PetFormIntoColumns_C:OnConstruct()
  self.uiData = {}
  self.PetFormIndex = 0
  self.ChildSize_Y = 0
  self.icon = {}
  self.icon[1] = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/PetUI/Frames/img_cangxing1_png.img_cangxing1_png'"
  self.icon[2] = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/PetUI/Frames/img_cangxing2_png.img_cangxing2_png'"
  self.icon[3] = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/PetUI/Frames/img_hun1_png.img_hun1_png'"
  self.icon[4] = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/PetUI/Frames/img_hun2_png.img_hun2_png'"
  self.icon[5] = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/PetUI/Frames/img_shi1_png.img_shi1_png'"
  self.icon[6] = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/PetUI/Frames/img_shi2_png.img_shi2_png'"
  self.icon[7] = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/PetUI/Frames/img_yang1_png.img_yang1_png'"
  self.icon[8] = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/PetUI/Frames/img_yang2_png.img_yang2_png'"
  self.icon[9] = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/PetUI/Frames/img_yao1_png.img_yao1_png'"
  self.icon[10] = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/PetUI/Frames/img_yao2_png.img_yao2_png'"
  self.icon[11] = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/PetUI/Frames/img_yue1_png.img_yue1_png'"
  self.icon[12] = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/PetUI/Frames/img_yue2_png.img_yue2_png'"
  self:OnAddEventListener()
end

function UMG_PetFormIntoColumns_C:OnScrollCallback(Offset)
end

function UMG_PetFormIntoColumns_C:OnDestruct()
end

function UMG_PetFormIntoColumns_C:OnActive()
end

function UMG_PetFormIntoColumns_C:UpdatePetFormInfo(_petTeamInfo, _IsTeamPet)
  self.uiData.PetTeamInfo = _petTeamInfo
  self:SetIconList()
  if true == _IsTeamPet then
    self.IconList:SelectItemByIndex(self.PetFormIndex - 1)
  else
    self.PetFormIndex = self.uiData.PetTeamInfo.main_team_idx
    self.IconList:SelectItemByIndex(self.PetFormIndex)
    self:SetScrollOffsetInfo()
  end
end

function UMG_PetFormIntoColumns_C:SetIconList()
  local IsCanExchangePet = _G.NRCModeManager:DoCmd(PetUIModuleCmd.GetIsCanExchangePet)
  local PetTeams = self.uiData.PetTeamInfo.teams
  local mainTeamIndex = self.uiData.PetTeamInfo.main_team_idx + 1
  for i, v in ipairs(PetTeams) do
    if mainTeamIndex == i then
      v.main_team_idx = mainTeamIndex
    else
      v.main_team_idx = nil
    end
    v.icon = self.icon[2 * i - 1]
    v.icon1 = self.icon[2 * i]
    v.IsCanExchangePet = IsCanExchangePet
    v.PetFormIndex = self.PetFormIndex
    if i == self.PetFormIndex then
      v.IsOnClick = true
    else
      v.IsOnClick = false
    end
  end
  self.IconList:InitList(PetTeams)
end

function UMG_PetFormIntoColumns_C:OnAddEventListener()
  self:AddButtonListener(self.FightBtn, self.OnCloseButtonClicked)
  self:RegisterEvent(self, PetUIModuleEvent.ChangePetMainIndex, self.OnChangePetMainIndex)
  self:RegisterEvent(self, PetUIModuleEvent.ChangePetTeams, self.OnChangePetTeams)
  self:RegisterEvent(self, PetUIModuleEvent.OnClickSetMainTeam, self.OnClickMainImage)
  self.IconList:BindLuaCallback({
    self,
    self.OnScrollCallback
  })
end

function UMG_PetFormIntoColumns_C:SetScrollOffsetInfo()
  local mainTeamIndex = self.uiData.PetTeamInfo.main_team_idx + 1
  local size_Y = self.IconList.Slot:GetSize().Y
  local margin = size_Y % self.ChildSize_Y
  local sizeoffset = mainTeamIndex * self.ChildSize_Y
  if size_Y < sizeoffset then
    local offset = sizeoffset - size_Y + margin
    Log.Debug(offset, "UMG_PetFormIntoColumns_C:SetScrollOffset")
    self.IconList:SetScrollOffset(offset)
  end
end

function UMG_PetFormIntoColumns_C:OnCloseButtonClicked()
  if self.petInfoMainCtrl then
    self.petInfoMainCtrl:CloseTeamPanle()
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1007, "UMG_PetLeftPanel_C:OnBtnCloseSubPanelClick")
  end
end

function UMG_PetFormIntoColumns_C:OnChangePetMainIndex(index, size_Y)
  self.PetFormIndex = index
  self.ChildSize_Y = size_Y
  self:SetIconList()
  self.petInfoMainCtrl:SetPetInfoList()
end

function UMG_PetFormIntoColumns_C:GetPetFormIndex()
  return self.PetFormIndex
end

function UMG_PetFormIntoColumns_C:OnChangePetTeams(index)
  local PetTeamIndex = index
  local GidList = {}
  local petTeamInfo = self.uiData.PetTeamInfo
  for i, team in ipairs(petTeamInfo.teams) do
    if self.PetFormIndex == i and team.pet_infos and team.pet_infos[index] then
      for j, v in ipairs(team.pet_infos) do
        if i - 1 == petTeamInfo.main_team_idx and #team.pet_infos <= 1 then
          _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.umg_petformintocolumns_1)
          return
        end
        if j == PetTeamIndex then
          table.insert(GidList, team.pet_infos[j].pet_gid)
          table.remove(team.pet_infos, j)
        end
      end
    end
  end
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ChangePetTeamsInfo, petTeamInfo.teams, self.PetFormIndex - 1)
  self.IconList:InitList(petTeamInfo.teams)
  self.module:DispatchEvent(PetUIModuleEvent.PET_TEAM_CHANGE, GidList)
  self.petInfoMainCtrl:UpdatePetWarehouse(petTeamInfo)
end

function UMG_PetFormIntoColumns_C:OnPanelStateChange(_isShow)
  if _isShow then
  end
  if _isShow then
    self:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_PetFormIntoColumns_C:OnClickMainImage(_index)
  local petTeamInfo = self.uiData.PetTeamInfo
  local GidList = PetUtils.PetTeamGetPetGidList(petTeamInfo.teams[petTeamInfo.main_team_idx + 1])
  petTeamInfo.main_team_idx = _index - 1
  self.PetFormIndex = _index
  self:SetIconList()
  self.IconList:SelectItemByIndex(self.PetFormIndex - 1)
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ChangePetMainTeams, self.PetFormIndex - 1)
  _G.NRCModuleManager:GetModule("MainUIModule"):DispatchEvent(PetUIModuleEvent.PET_TEAM_CHANGE, GidList)
  self.petInfoMainCtrl:UpdatePetWarehouse(petTeamInfo)
end

function UMG_PetFormIntoColumns_C:setPetInfoMainCtrl(_petInfoMainCtrl)
  self.petInfoMainCtrl = _petInfoMainCtrl
end

function UMG_PetFormIntoColumns_C:OnDeactive()
end

return UMG_PetFormIntoColumns_C
