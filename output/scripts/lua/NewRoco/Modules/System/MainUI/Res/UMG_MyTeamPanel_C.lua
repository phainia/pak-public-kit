local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_MyTeamPanel_C = _G.NRCPanelBase:Extend("UMG_MyTeamPanel_C")

function UMG_MyTeamPanel_C:OnActive()
  UE4Helper.SetDesiredShowCursor(true, "UMG_MyTeamPanel_C")
  self:OnAddEventListener()
  local petInfoList = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo()
  local teamInfo = PetUtils.PlayerPetInfoGetTeamInfo(petInfoList, Enum.PlayerTeamType.PTT_BIG_WORLD)
  self.curTeamInfo = teamInfo
  local MainIndex = teamInfo.main_team_idx
  self.TeamIndex = MainIndex + 1
  local petTeamList = {}
  self.TeamNum = #teamInfo.teams
  for i, v in ipairs(teamInfo.teams) do
    local IsMainTeam = MainIndex + 1 == i
    local petList = {}
    for j = 1, 6 do
      table.insert(petList, "nil")
    end
    if v.pet_infos then
      for index, PetTeamInfo in ipairs(v.pet_infos) do
        local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(PetTeamInfo.pet_gid)
        petList[index] = petData
      end
    end
    local petTeam = {
      petList = petList,
      IsMainTeam = IsMainTeam,
      team = v,
      Panel = self
    }
    table.insert(petTeamList, petTeam)
  end
  self:DelayFrames(1, function()
    self.teamList:InitList(petTeamList)
    self.teamList:SelectItemByIndex(MainIndex)
  end)
  local pos = UE4.FVector2D()
  if UE.UGameplayStatics.GetGameInstance(self):IsPCMode() then
    pos.X = -40.0
    pos.Y = 25.0
  else
    pos.X = 0
    pos.Y = 0
  end
  _G.NRCAudioManager:PlaySound2DAuto(40002009, "UMG_MyTeamPanel_C:OnActive")
  self.CanvasPanel1.Slot:SetPosition(pos)
  self:PlayAnimation(self.open)
  self:BindInputAction()
end

function UMG_MyTeamPanel_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_MainTeamChangePanel")
  if mappingContext then
    mappingContext:BindAction("IA_CloseMainTeamChangeUI", self, "OnPcClose")
    for i = 1, self.TeamNum do
      mappingContext:BindAction("IA_SelectMainPetList_" .. i, self, "OnSelectMainPetListIndex" .. i, UE.ETriggerEvent.Triggered)
    end
  end
end

function UMG_MyTeamPanel_C:OnDeactive()
  UE4Helper.ReleaseDesiredShowCursor("UMG_MyTeamPanel_C")
  self:DispatchEvent(MainUIModuleEvent.TryShowOrCloseMainPetUi, true)
  local mappingContext = self:GetInputMappingContext("IMC_MainTeamChangePanel")
  if mappingContext then
    mappingContext:UnBindAction("IA_CloseMainTeamChangeUI")
    for i = 1, self.TeamNum do
      mappingContext:UnBindAction("IA_SelectMainPetList_" .. i)
    end
  end
end

function UMG_MyTeamPanel_C:OnSelectMainPetListIndex1()
  if self:IsAnimationPlaying(self.open) then
    return
  end
  self.teamList:SelectItemByIndex(0)
end

function UMG_MyTeamPanel_C:OnSelectMainPetListIndex2()
  if self:IsAnimationPlaying(self.open) then
    return
  end
  self.teamList:SelectItemByIndex(1)
end

function UMG_MyTeamPanel_C:OnSelectMainPetListIndex3()
  if self:IsAnimationPlaying(self.open) then
    return
  end
  self.teamList:SelectItemByIndex(2)
end

function UMG_MyTeamPanel_C:OnSelectMainPetListIndex4()
  if self:IsAnimationPlaying(self.open) then
    return
  end
  self.teamList:SelectItemByIndex(3)
end

function UMG_MyTeamPanel_C:OnSelectMainPetListIndex5()
  if self:IsAnimationPlaying(self.open) then
    return
  end
  self.teamList:SelectItemByIndex(4)
end

function UMG_MyTeamPanel_C:OnPcClose()
  self:ClosePanel()
end

function UMG_MyTeamPanel_C:SetCurTeamIndex(TeamIndex)
  if self.TeamIndex ~= TeamIndex and not self:IsAnimationPlaying(self.open) then
    self.TeamIndex = TeamIndex
    self.canClose = true
    self:PlayAnimationReverse(self.open)
  end
end

function UMG_MyTeamPanel_C:ClosePanel()
  _G.NRCAudioManager:PlaySound2DAuto(40002010, "UMG_MyTeamPanel_C:OnActive")
  self.canClose = true
  self:PlayAnimationReverse(self.open, 1.5)
end

function UMG_MyTeamPanel_C:OnAnimationFinished(anim)
  if anim == self.open and self.canClose then
    if self.TeamIndex - 1 ~= self.curTeamInfo.main_team_idx then
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ChangePetMainTeams, self.TeamIndex - 1, _G.ProtoEnum.PlayerTeamType.PTT_BIG_WORLD)
    end
    self:DoClose()
  end
end

function UMG_MyTeamPanel_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn, self.ClosePanel)
end

return UMG_MyTeamPanel_C
