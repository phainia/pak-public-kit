local PetUtils = require("NewRoco.Utils.PetUtils")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_PetExchange_C = _G.NRCPanelBase:Extend("UMG_PetExchange_C")

function UMG_PetExchange_C:OnActive(changePetGid)
  self:OnAddEventListener()
  self.AddPetGid = changePetGid
  self.IsChangeMainTeamPet = _G.DataModelMgr.PlayerDataModel:GetIsMainTeamPetByGid(self.AddPetGid)
  self:SetTeamInfo(changePetGid)
  self:SetPetBagCurTeamNameAndBloodLineMagic(self.TeamIndex)
  self:SetPetBagInfo(changePetGid)
end

function UMG_PetExchange_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
  self.PopUp3.Btn_Right.BG:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_btn1_grey_png.img_btn1_grey_png'")
  self.PopUp3.Btn_Right.HideAnim = true
  self.ScrollPageController.LongPressTime = 0.3
  self.ScrollPageController.pageScrollTime = 0.25
end

function UMG_PetExchange_C:SetPetItemClickAble(clickable)
  if clickable then
    local count = self.TeamList:GetTotalItemNumber()
    for i = 1, count do
      local item = self.TeamList:GetItemByIndex(i - 1)
      if item and not item.IsChangeItem then
        item.clickable = true
      end
    end
    count = self.BagList:GetTotalItemNumber()
    for i = 1, count do
      local item = self.BagList:GetItemByIndex(i - 1)
      if item and not item.IsChangeItem then
        item.clickable = true
      end
    end
  else
    self.TeamList:SetItemClickAble(clickable)
    self.BagList:SetItemClickAble(clickable)
  end
end

function UMG_PetExchange_C:SetTeamInfo(ChangePetGid)
  local petInfoList = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo()
  local teamInfo = PetUtils.PlayerPetInfoGetTeamInfo(petInfoList, Enum.PlayerTeamType.PTT_BIG_WORLD)
  self.curTeamInfo = teamInfo
  self.TeamIndex = self.TeamIndex or teamInfo.main_team_idx and teamInfo.main_team_idx + 1 or 1
  local TotalNum = #teamInfo.teams * 6
  self.Dot_List:InitGridView(teamInfo.teams)
  self.ScrollPageController:SetValidItemTotalNum(TotalNum)
  self.battlePetInfos = {}
  for index = 1, #self.curTeamInfo.teams do
    for i = 1, 6 do
      table.insert(self.battlePetInfos, {
        data = nil,
        IsChangeItem = false,
        panel = self,
        isTeamItem = true
      })
    end
    local battlePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo(index - 1)
    for i, pet_data in ipairs(battlePetList) do
      local IsChangeItem = false
      if battlePetList[i].gid == ChangePetGid then
        IsChangeItem = true
        self.TeamIndex = index
      end
      local realIndex = i + (index - 1) * 6
      self.battlePetInfos[realIndex].data = battlePetList[i]
      self.battlePetInfos[realIndex].IsChangeItem = IsChangeItem
    end
  end
  self.TeamList:InitList(self.battlePetInfos)
  self.ScrollPageController:ScrollToPage(self.TeamIndex - 1, 0.01, false)
end

function UMG_PetExchange_C:OnDeactive()
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.SetPanelCanScroll, self.OpenPetTips)
end

function UMG_PetExchange_C:OnSelectChangeMainPetItem(index, gid, isTeamItem)
  _G.NRCAudioManager:PlaySound2DAuto(40002006, "UMG_PetWarehouseMain_C:OnCloseBtnClicked")
  self.ChangeIndex = index
  self.changeGid = gid
  local selectInBackPack = not isTeamItem
  self.IsChangeInBackPack = selectInBackPack and not self.IsChangeMainTeamPet
  self.selectInBackPack = selectInBackPack
  if selectInBackPack then
    self.TeamList:ClearSelection()
  else
    self.BagList:ClearSelection()
  end
  self.PopUp3.Btn_Right.BG:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_btn1_white_png.img_btn1_white_png'")
  self.PopUp3.Btn_Right.HideAnim = false
end

function UMG_PetExchange_C:SetPetBagInfo(ChangePetGid)
  self.BackpackPets = {}
  local BackpackPetList = _G.DataModelMgr.PlayerDataModel:GetPlayerTemporarilyStoreBackpackPetInfo()
  local pet_bag_space_quantity = _G.DataModelMgr.PlayerDataModel.playerInfo.pet_info.backpack_info.pet_bag_space_quantity or 0
  for i = 1, pet_bag_space_quantity do
    table.insert(self.BackpackPets, {
      data = nil,
      IsChangeItem = nil,
      panel = self,
      isTeamItem = false
    })
  end
  for i, pet_data in ipairs(BackpackPetList) do
    local IsChangeItem = false
    if BackpackPetList[i].gid == ChangePetGid then
      IsChangeItem = true
    end
    self.BackpackPets[i].data = BackpackPetList[i]
    self.BackpackPets[i].IsChangeItem = IsChangeItem
  end
  self.BagList:InitList(self.BackpackPets)
end

function UMG_PetExchange_C:OpenPetTips(_, petData)
  if petData then
    _G.NRCModeManager:DoCmd(PetUIModuleCmd.ShowChangePetConfirm, petData)
  end
end

function UMG_PetExchange_C:OnAddEventListener()
  self:SetCommonPopUpInfo()
  _G.NRCEventCenter:RegisterEvent("UMG_PetExchange_C", self, PetUIModuleEvent.SetPanelCanScroll, self.OpenPetTips)
  self:AddButtonListener(self.NRCButton_68, self.OnLeftSlide)
  self:AddButtonListener(self.NRCButton, self.OnRightSlide)
  self.ScrollPageController:SetPageChangeHandler(self.OnPageChangeHandle, self)
end

function UMG_PetExchange_C:OnPageChangeHandle(_page)
  self.Dot_List:SelectItemByIndex(_page)
  if _page + 1 == self.TeamIndex then
    return
  end
  self.TeamIndex = _page + 1
  self:SetPetBagCurTeamNameAndBloodLineMagic(self.TeamIndex)
end

function UMG_PetExchange_C:SetPetBagCurTeamNameAndBloodLineMagic(TeamIndex)
  local default_name = _G.DataConfigManager:GetPetGlobalConfig("mainworld_team_default_name").str
  local CurPetTeam = self.curTeamInfo.teams[TeamIndex]
  if CurPetTeam.team_name then
    self.TeamName:SetText(CurPetTeam.team_name)
  else
    self.TeamName:SetText(string.format(default_name, self.TeamIndex))
  end
  local BagItemS = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemArrayByType, Enum.BagItemType.BI_PLAYERSKILL)
  local IsHasBlood = BagItemS and #BagItemS > 0 and true or false
  if IsHasBlood and CurPetTeam.role_magic_gid and CurPetTeam.role_magic_gid > 0 then
    for i, BagItem in ipairs(BagItemS) do
      if BagItem.gid == CurPetTeam.role_magic_gid then
        local BagItemConf = _G.DataConfigManager:GetBagItemConf(BagItem.id)
        if BagItemConf then
          self.TeamMagic:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          self.MagicBg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          self.TeamMagic:SetPath(BagItemConf.icon)
        end
      end
    end
  else
    self.MagicBg:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TeamMagic:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PetExchange_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.CancelClick
  CommonPopUpData.Btn_RightHandler = self.ApplyClick
  CommonPopUpData.ClosePanelHandler = self.ClosePanel
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp3:SetPanelInfo(CommonPopUpData)
end

function UMG_PetExchange_C:ClosePanel()
  self:DoClose()
end

function UMG_PetExchange_C:CancelClick()
  self:ClosePanel()
end

function UMG_PetExchange_C:ApplyClick()
  if self.selectInBackPack == nil then
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.UMG_ExChangeMainPetTips)
    return
  end
  if self.IsChangeInBackPack then
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ChangePetBackInfoInfo, self.changeGid, self.AddPetGid)
  else
    local ChangeInBackPack = false
    local ChangeSelectTeam = {}
    local CurAddTeam = {}
    local curSelectItemInTeamIndex = _G.DataModelMgr.PlayerDataModel:GetPlayerBattleTeamIndexByGid(self.changeGid)
    local curAddItemInTeamIndex = _G.DataModelMgr.PlayerDataModel:GetPlayerBattleTeamIndexByGid(self.AddPetGid)
    self.TeamIndex = curSelectItemInTeamIndex or self.TeamIndex
    if self.TeamIndex and curAddItemInTeamIndex and self.TeamIndex ~= curAddItemInTeamIndex and not self.selectInBackPack then
      local battlePetList1 = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo(self.TeamIndex - 1)
      local battlePetList2 = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo(curAddItemInTeamIndex - 1)
      if battlePetList1 and #battlePetList1 > 0 then
        for i, pet_data in ipairs(battlePetList1) do
          if self.changeGid ~= pet_data.gid then
            table.insert(ChangeSelectTeam, pet_data.gid)
          else
            table.insert(ChangeSelectTeam, self.AddPetGid)
          end
        end
        for i, pet_data in ipairs(battlePetList2) do
          if self.AddPetGid ~= pet_data.gid then
            table.insert(CurAddTeam, pet_data.gid)
          elseif self.changeGid then
            table.insert(CurAddTeam, self.changeGid)
          end
        end
        if not self.changeGid then
          table.insert(ChangeSelectTeam, self.AddPetGid)
        end
      else
        table.insert(ChangeSelectTeam, self.AddPetGid)
        for i, pet_data in ipairs(battlePetList2) do
          if self.AddPetGid ~= pet_data.gid then
            table.insert(CurAddTeam, pet_data.gid)
          end
        end
      end
    elseif self.TeamIndex and curAddItemInTeamIndex and self.TeamIndex == curAddItemInTeamIndex and not self.selectInBackPack then
      local battlePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo(self.TeamIndex - 1)
      for i, pet_data in ipairs(battlePetList) do
        if self.AddPetGid ~= pet_data.gid and self.changeGid ~= pet_data.gid then
          table.insert(CurAddTeam, pet_data.gid)
        elseif self.AddPetGid == pet_data.gid and self.changeGid then
          table.insert(CurAddTeam, self.changeGid)
        elseif self.changeGid == pet_data.gid then
          table.insert(CurAddTeam, self.AddPetGid)
        end
      end
      if not self.changeGid then
        table.insert(CurAddTeam, self.AddPetGid)
      end
    elseif curAddItemInTeamIndex then
      local battlePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo(curAddItemInTeamIndex - 1)
      for i, pet_data in ipairs(battlePetList) do
        if self.AddPetGid ~= pet_data.gid then
          table.insert(CurAddTeam, pet_data.gid)
        elseif self.changeGid then
          table.insert(CurAddTeam, self.changeGid)
        end
      end
      if not self.changeGid then
        ChangeInBackPack = true
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.team_pet_take_empty_bag_place)
        return
      end
    elseif self.TeamIndex then
      local battlePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo(self.TeamIndex - 1)
      for i, pet_data in ipairs(battlePetList) do
        if self.changeGid ~= pet_data.gid then
          table.insert(ChangeSelectTeam, pet_data.gid)
        else
          table.insert(ChangeSelectTeam, self.AddPetGid)
        end
      end
      if not self.changeGid then
        table.insert(ChangeSelectTeam, self.AddPetGid)
      end
    end
    local teams1 = {}
    local teamList = {}
    local teamIndexList = {}
    for i = 1, #ChangeSelectTeam do
      local teamPetInfo = _G.ProtoMessage:newPetTeam_PetInfo()
      teamPetInfo.pet_gid = ChangeSelectTeam[i]
      table.insert(teams1, teamPetInfo)
    end
    if #teams1 > 0 then
      table.insert(teamList, teams1)
      table.insert(teamIndexList, self.TeamIndex - 1)
    end
    local teams2 = {}
    for i = 1, #CurAddTeam do
      local teamPetInfo = _G.ProtoMessage:newPetTeam_PetInfo()
      teamPetInfo.pet_gid = CurAddTeam[i]
      table.insert(teams2, teamPetInfo)
    end
    if #teams2 > 0 then
      table.insert(teamList, teams2)
      table.insert(teamIndexList, curAddItemInTeamIndex - 1)
    end
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ChangePetTeamsInfo, teamList, teamIndexList, Enum.PlayerTeamType.PTT_BIG_WORLD, ChangeInBackPack)
  end
  self:ClosePanel()
end

function UMG_PetExchange_C:OnLeftSlide()
  if self.ScrollPageController.curPage > 0 then
    local Success = self.ScrollPageController:ScrollToPage(self.ScrollPageController.curPage - 1, 0.25, true)
  else
    local Success = self.ScrollPageController:ScrollToPage(self.ScrollPageController:GetTotalPageNum() - 1, 0.01, true)
  end
end

function UMG_PetExchange_C:OnRightSlide()
  if self.ScrollPageController.curPage < self.ScrollPageController:GetTotalPageNum() - 1 then
    local Success = self.ScrollPageController:ScrollToPage(self.ScrollPageController.curPage + 1, 0.25, true)
  else
    local Success = self.ScrollPageController:ScrollToPage(0, 0.01, true)
  end
end

return UMG_PetExchange_C
