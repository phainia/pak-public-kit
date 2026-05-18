local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local PetTeamUtils = require("NewRoco.Modules.System.PetUI.Res.PetTeam.PetTeamUtils")
local UMG_Pet_TeamManagement_List_C = Base:Extend("UMG_Pet_TeamManagement_List_C")

function UMG_Pet_TeamManagement_List_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_Pet_TeamManagement_List_C:OnDestruct()
  self:OnRemoveEventListener()
end

function UMG_Pet_TeamManagement_List_C:GetTeamName()
  local petData = self.uiData.team
  if petData.is_mirror then
    self.FriendsLineupText:SetVisibility(UE4.ESlateVisibility.Visible)
    self.FriendsLineupText:SetText(string.format(LuaText.share_pet_owner_inf_1, petData.mirror_friend_name))
    self.Btn_rename:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.NRCImage_64:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCImage_3:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Btn_rename:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRCImage_64:SetVisibility(UE4.ESlateVisibility.Visible)
    self.NRCImage_3:SetVisibility(UE4.ESlateVisibility.Visible)
    self.FriendsLineupText:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if not petData.team_name or petData.team_name == "" then
    local teamNameCfg = _G.DataConfigManager:GetBattleGlobalConfig("pvp_team_name")
    return string.format(teamNameCfg.str, self.index)
  else
    return petData.team_name
  end
end

function UMG_Pet_TeamManagement_List_C:OnItemNameUpdate(_data)
  self.uiData = _data
  self.Text_name:SetText(self:GetTeamName())
  self:UpdateRoleMagicInfo()
end

function UMG_Pet_TeamManagement_List_C:UpdateRoleMagicInfo()
  local hasMagic = false
  local petData = self.uiData.team
  if petData.is_mirror then
    self.BloodBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Exchange:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Exchange_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.BloodBtn:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Exchange:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Exchange_1:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  if petData.is_mirror then
    if petData.mirror_magic_id and 0 ~= petData.mirror_magic_id then
      local BagItemConf = _G.DataConfigManager:GetBagItemConf(petData.mirror_magic_id)
      if BagItemConf then
        hasMagic = true
        self.Switcher:SetActiveWidgetIndex(0)
        self.Icon:SetPath(BagItemConf.icon)
      end
    end
  elseif petData.role_magic_gid and 0 ~= petData.role_magic_gid then
    local itemInfo = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemByGid, petData.role_magic_gid)
    if itemInfo then
      local PlayerMagicConf = _G.DataConfigManager:GetBagItemConf(itemInfo.id)
      if PlayerMagicConf then
        hasMagic = true
        self.Switcher:SetActiveWidgetIndex(0)
        self.Icon:SetPath(PlayerMagicConf.icon)
      end
    end
  end
  if not hasMagic then
    self.Switcher:SetActiveWidgetIndex(1)
  end
end

function UMG_Pet_TeamManagement_List_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.uiData = _data
  self:SetupList()
  self.Text_name:SetText(self:GetTeamName())
  self:UpdateRoleMagicInfo()
end

function UMG_Pet_TeamManagement_List_C:OnItemSelected(_bSelected)
  if _bSelected then
    if not self.curSelect and self.uiData then
      self:PlayAnimation(self.Select_In)
      self.AtPresent:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.uiData.parentView:OnItemSelected(self.uiData.idx)
    end
  else
    self.AtPresent:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if self.curSelect then
      self:PlayAnimation(self.Cancel)
    end
  end
  self.curSelect = _bSelected
end

function UMG_Pet_TeamManagement_List_C:OnAddEventListener()
  self.Btn_rename.OnClicked:Add(self, self.OnBtnRenameClick)
  self.Exchange_1.btnLevelUp.OnClicked:Add(self, self.OnBtnOpenMagicBag)
  self.BloodBtn.OnClicked:Add(self, self.OnBtnOpenMagicBag)
  self.Exchange.btnLevelUp.OnClicked:Add(self, self.OnBtnOpenMagicBag)
  self.Exchange.btnLevelUp.OnPressed:Add(self, self.Exchange.OnClickbtnPressed)
  self.Exchange.btnLevelUp.OnReleased:Add(self, self.Exchange.OnClickbtnLevelReleased)
end

function UMG_Pet_TeamManagement_List_C:OnRemoveEventListener()
  self.Btn_rename.OnClicked:Remove(self, self.OnBtnRenameClick)
  self.Exchange_1.btnLevelUp.OnClicked:Remove(self, self.OnBtnOpenMagicBag)
  self.BloodBtn.OnClicked:Remove(self, self.OnBtnOpenMagicBag)
  self.Exchange.btnLevelUp.OnClicked:Remove(self, self.OnBtnOpenMagicBag)
  self.Exchange.btnLevelUp.OnPressed:Remove(self, self.Exchange.OnClickbtnPressed)
  self.Exchange.btnLevelUp.OnReleased:Remove(self, self.Exchange.OnClickbtnLevelReleased)
end

function UMG_Pet_TeamManagement_List_C:OnPetTeamEquipPetMagic(MagicData)
end

function UMG_Pet_TeamManagement_List_C:OnBtnOpenMagicBag()
  local BagItemS = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemArrayByType, Enum.BagItemType.BI_PLAYERSKILL)
  if not self.uiData then
    Log.Error("\230\128\142\228\185\136\228\188\154\229\135\186\231\142\176self.uiData\230\149\176\230\141\174\228\184\186\231\169\186\229\145\162\239\188\140\230\156\137\233\151\174\233\162\152 self.index=", self.index)
    return
  end
  if BagItemS and #BagItemS > 0 then
    _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenBloodLineMagic, self.uiData.teamType, self.uiData.idx)
  else
    local Conf = _G.DataConfigManager:GetBattleGlobalConfig("pvp_tips1")
    _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, Conf.str)
  end
end

function UMG_Pet_TeamManagement_List_C:OnBtnRenameClick()
  local param = {
    teamType = self.uiData.teamType,
    TeamIdx = self.uiData.idx,
    teamName = self:GetTeamName()
  }
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenRechristenPanel, param, nil, 2)
end

function UMG_Pet_TeamManagement_List_C:OnDeactive()
end

function UMG_Pet_TeamManagement_List_C:SetupList()
  local petData = self.uiData.team
  local petList = {}
  self.canInTeamNum = PetTeamUtils.GetCanInPetNum(self.uiData.teamType)
  for i = 1, self.canInTeamNum do
    if petData and petData.pet_infos and petData.pet_infos[i] then
      local petinfo = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(petData.pet_infos[i].pet_gid, petData.is_mirror)
      if petinfo then
        local FriendTeamAvatarpData = {}
        FriendTeamAvatarpData.PetData = petinfo
        FriendTeamAvatarpData.isTrailPet = _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.CmdIsTrailPet, petinfo.gid)
        table.insert(petList, FriendTeamAvatarpData)
      else
        table.insert(petList, "nil")
      end
    else
      table.insert(petList, "nil")
    end
  end
  if self.canInTeamNum < 6 then
    for i = self.canInTeamNum + 1, 6 do
      table.insert(petList, "nil")
    end
  end
  self.PetList_1:InitGridView(petList)
end

function UMG_Pet_TeamManagement_List_C:SetItemBG(isActive)
  local count = self.PetList:GetItemCount()
  for i = 1, count do
    local item = self.PetList:GetItemByIndex(i - 1)
  end
end

return UMG_Pet_TeamManagement_List_C
