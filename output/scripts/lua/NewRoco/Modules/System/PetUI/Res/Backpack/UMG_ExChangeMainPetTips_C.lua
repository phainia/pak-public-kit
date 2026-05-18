local UMG_ExChangeMainPetTips_C = _G.NRCPanelBase:Extend("UMG_ExChangeMainPetTips_C")

function UMG_ExChangeMainPetTips_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
end

function UMG_ExChangeMainPetTips_C:OnDestruct()
end

function UMG_ExChangeMainPetTips_C:OnActive(ChangePetGid)
  self:LoadAnimation(0)
  self:SetCommonPopUpInfo(self.PopUp3)
  local battlePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  self.ChangePetGid = ChangePetGid
  self.ChangeIndex = -1
  local PetList = {}
  self.TeamInfo = {}
  self.IsBattleListChangeItem = false
  self.OldIndex = -1
  for i = 1, #battlePetList do
    local IsChangeItem = false
    if battlePetList[i].gid == ChangePetGid then
      self.IsBattleListChangeItem = true
      IsChangeItem = true
      self.OldIndex = i
    end
    table.insert(PetList, {
      data = battlePetList[i],
      IsChangeItem = IsChangeItem,
      panel = self
    })
    table.insert(self.TeamInfo, battlePetList[i].gid)
  end
  self.ItemList:InitList(PetList)
  self:OnAddEventListener()
end

function UMG_ExChangeMainPetTips_C:OnDeactive()
end

function UMG_ExChangeMainPetTips_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.ClosePanel
  CommonPopUpData.Btn_RightHandler = self.ApplyChange
  CommonPopUpData.ClosePanelHandler = self.WhiteClosePanel
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_ExChangeMainPetTips_C:OnSelectChangeMainPetItem(index)
  _G.NRCAudioManager:PlaySound2DAuto(40002006, "UMG_PetWarehouseMain_C:OnCloseBtnClicked")
  self.ChangeIndex = index
end

function UMG_ExChangeMainPetTips_C:OnAddEventListener()
end

function UMG_ExChangeMainPetTips_C:ClosePanel()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_PetWarehouseMain_C:OnCloseBtnClicked")
  self:LoadAnimation(2)
end

function UMG_ExChangeMainPetTips_C:WhiteClosePanel()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_PetWarehouseMain_C:OnCloseBtnClicked")
  self:LoadAnimation(2)
end

function UMG_ExChangeMainPetTips_C:ApplyChange()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_PetWarehouseMain_C:OnCloseBtnClicked")
  if -1 == self.ChangeIndex then
    local text = _G.DataConfigManager:GetLocalizationConf("UMG_ExChangeMainPetTips").msg
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, text)
  else
    self.IsApply = true
    self:LoadAnimation(2)
  end
end

function UMG_ExChangeMainPetTips_C:OnAnimationFinished(anima)
  if anima == self:GetAnimByIndex(2) then
    if self.IsApply then
      local teamIndex = _G.DataModelMgr.PlayerDataModel:GetBattleTeamIndex()
      local teaminfo = _G.DataModelMgr.PlayerDataModel:GetPlayerPetTeamInfo().teams
      local team = teaminfo[teamIndex + 1]
      if self.IsBattleListChangeItem then
        local OldGid = team.pet_infos[self.ChangeIndex].pet_gid
        team.pet_infos[self.ChangeIndex].pet_gid = self.ChangePetGid
        team.pet_infos[self.OldIndex].pet_gid = OldGid
      else
        team.pet_infos[self.ChangeIndex].pet_gid = self.ChangePetGid
      end
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ChangePetTeamsInfo, teaminfo, teamIndex)
      self.IsApply = false
    end
    self:DoClose()
  end
end

function UMG_ExChangeMainPetTips_C:SetPetItemClickAble(clickable)
  if clickable then
    local count = self.ItemList:GetItemCount()
    for i = 1, count do
      local item = self.ItemList:GetItemByIndex(i - 1)
      if not item.IsChangeItem then
        item.clickable = true
      end
    end
  else
    self.ItemList:SetItemClickAble(clickable)
  end
end

return UMG_ExChangeMainPetTips_C
