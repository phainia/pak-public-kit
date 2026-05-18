local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_PetBloodlineMagic_C = _G.NRCPanelBase:Extend("UMG_PetBloodlineMagic_C")

function UMG_PetBloodlineMagic_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
  self.SelectIndex = 0
  self.MaxIndex = 0
  self.IsEquipment = false
  self.SelectBagItem = nil
  self.BagItemS = nil
  self.roleMagicGid = 0
  self.data = self.module:GetData("PetUIModuleData")
  self:OnAddEventListener()
end

function UMG_PetBloodlineMagic_C:OnDestruct()
  self.module.WaitForEquipRsp = false
  self:OnRemoveEventListener()
end

function UMG_PetBloodlineMagic_C:OnActive(TeamType, TeamIndex, CustomizeGidList)
  self.teamType = TeamType
  self.teamIndex = TeamIndex
  self.SkipAudio = true
  self:LoadAnimation(0)
  local petTeam = _G.DataModelMgr.PlayerDataModel:GetPlayerPetTeamInfoByTeamType(TeamType)
  if petTeam then
    self.petTeams = petTeam.teams[TeamIndex + 1]
  else
    self.petTeams = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  end
  if self.petTeams then
    self.roleMagicGid = self.petTeams.role_magic_gid
  else
    self.roleMagicGid = 0
  end
  self.petIdList = {}
  local PetUtils = require("NewRoco.Utils.PetUtils")
  local gidList = PetUtils.PetTeamGetPetGidList(self.petTeams)
  if CustomizeGidList then
    gidList = CustomizeGidList
  end
  if gidList then
    for i, v in ipairs(gidList) do
      local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(v)
      table.insert(self.petIdList, petData)
    end
  end
  self:SetCommonPopUpInfo()
  self:SetPanelInfo(true)
end

function UMG_PetBloodlineMagic_C:OnAddEventListener()
  self:AddButtonListener(self.Btn_left, self.OnBtnLeft)
  self:AddButtonListener(self.Btn_right, self.OnBtnRight)
  self:AddButtonListener(self.ViewLeaderItemBtn, self.OnViewLeaderItemBtn)
  self:RegisterEvent(self, PetUIModuleEvent.SelectBloodItemEvent, self.UpdateSelectInfo)
  self:RegisterEvent(self, PetUIModuleEvent.EquipmentOrRemoveBloodEvent, self.OnEquipmentOrRemoveBloodEvent)
  _G.NRCEventCenter:RegisterEvent("UMG_PetBloodlineMagic_C", self, PetUIModuleEvent.PetTeamEquipPetMagicRsp, self.OnPetTeamEquipPetMagic)
end

function UMG_PetBloodlineMagic_C:OnRemoveEventListener()
  self:UnRegisterEvent(self, PetUIModuleEvent.SelectBloodItemEvent, self.UpdateSelectInfo)
  self:UnRegisterEvent(self, PetUIModuleEvent.EquipmentOrRemoveBloodEvent, self.OnEquipmentOrRemoveBloodEvent)
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.PetTeamEquipPetMagicRsp, self.OnPetTeamEquipPetMagic)
end

function UMG_PetBloodlineMagic_C:SetPanelInfo(_IsSort)
  local petInfoList = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo()
  local teamInfo = PetUtils.PlayerPetInfoGetTeamInfo(petInfoList, Enum.PlayerTeamType.PTT_BIG_WORLD)
  local BagItemS = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemArrayByType, Enum.BagItemType.BI_PLAYERSKILL)
  if BagItemS and #BagItemS > 0 then
    if _IsSort then
      local function SortBagItem(a, b)
        local SortA = _G.DataConfigManager:GetBagItemConf(a.id).sort_id
        
        local SortB = _G.DataConfigManager:GetBagItemConf(b.id).sort_id
        if teamInfo and teamInfo.teams and teamInfo.teams[self.teamIndex + 1] and a.gid == teamInfo.teams[self.teamIndex + 1].role_magic_gid then
          SortA = -999999
        end
        if teamInfo and teamInfo.teams and teamInfo.teams[self.teamIndex + 1] and b.gid == teamInfo.teams[self.teamIndex + 1].role_magic_gid then
          SortB = -999999
        end
        return SortA < SortB
      end
      
      table.sort(BagItemS, SortBagItem)
    end
    if BagItemS and #BagItemS > 1 then
      self.Btn_left:SetVisibility(UE4.ESlateVisibility.Visible)
      self.Btn_right:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.Btn_left:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Btn_right:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    local BagItemList = {}
    for index, BagItem in pairs(BagItemS) do
      if self.roleMagicGid == BagItem.gid then
        self.SelectIndex = index - 1
      end
      table.insert(BagItemList, {
        BagItem = BagItem,
        roleMagicGid = self.roleMagicGid,
        TeamType = self.teamType
      })
    end
    self.MaxIndex = #BagItemList
    self.BagItemS = BagItemS
    self.List:InitGridView(BagItemList)
    self.List:SelectItemByIndex(self.SelectIndex)
  end
  local LeaderItemInfo = self.data:GetLeaderItemList()
  local BagItemArray = _G.NRCModeManager:DoCmd(BagModuleCmd.GetBagItemArrayByType, Enum.BagItemType.BI_BOSS_EVO)
  if LeaderItemInfo and BagItemArray then
    self.LeaderItemNum:SetText(string.format("%d/%d", #BagItemArray, #LeaderItemInfo))
  end
  self:UpdateCanvasPanel103Visibility()
end

function UMG_PetBloodlineMagic_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.Call = self
  CommonPopUpData.Desc = ""
  CommonPopUpData.TitleText = LuaText.umg_magic_title
  CommonPopUpData.Btn_LeftHandler = self.OnCanCel
  CommonPopUpData.Btn_RightHandler = self.OnConfirm
  CommonPopUpData.ClosePanelHandler = self.OnBtnClose
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp3:SetPanelInfo(CommonPopUpData)
end

function UMG_PetBloodlineMagic_C:UpdateSelectInfo(BagItem, Index, _bSelected)
  if self.SkipAudio then
    self.SkipAudio = false
  else
    _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_PetLeftPanel_C:UpdateSelectInfo")
  end
  if not _bSelected then
    if self.SelectBagItem then
      self:SetOnNewStateRemove()
    end
    return
  elseif self.SelectBagItem and self.SelectBagItem.id == BagItem.id then
    self:SetOnNewStateRemove()
  end
  self.SelectIndex = Index
  self.SelectBagItem = BagItem
  local BagItemConf = _G.DataConfigManager:GetBagItemConf(BagItem.id)
  if BagItemConf then
    self.Icon:SetPath(BagItemConf.big_icon)
    self.Text_Name:SetText(BagItemConf.name)
    self.Text_Details:SetText(BagItemConf.description)
    if BagItem.remain_use_cnt >= 99 then
      self.RemainingUses:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      local Content
      if 0 == BagItem.remain_use_cnt then
        Content = string.format("<red>0</>/%d", BagItemConf.initial_use_times)
      else
        Content = string.format("%d/%d", BagItem.remain_use_cnt, BagItemConf.initial_use_times)
      end
      self.RemainingUses:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.itemCount:SetText(Content)
    end
  end
  local showEquipped = false
  if self.roleMagicGid == BagItem.gid then
    showEquipped = true
  end
  self.Equipped:SetVisibility(showEquipped and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  self:SetUsePet(BagItem)
  self:SetBtnInfo(BagItem)
  self:PlayAnimation(self.Change)
  self.SelectBagItem = BagItem
  self:UpdateCanvasPanel103Visibility()
end

function UMG_PetBloodlineMagic_C:SetOnNewStateRemove()
end

function UMG_PetBloodlineMagic_C:SetUsePet(BagItem)
  self.Switcher:SetActiveWidgetIndex(0)
  local BagItemConf = _G.DataConfigManager:GetBagItemConf(BagItem.id)
  if BagItemConf then
    local PlayerMagicConf = _G.DataConfigManager:GetPlayerMagicConf(BagItemConf.player_skill_id)
    if PlayerMagicConf then
      local SkillConf = _G.DataConfigManager:GetSkillConf(PlayerMagicConf.skill_id)
      if SkillConf then
        local PetDataList = {}
        for i, PetData in ipairs(self.petIdList) do
          for j, Blood in ipairs(SkillConf.target_blood_limit) do
            local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(PetData.base_conf_id, true)
            if PetData.blood_id == Blood then
              if PetData.blood_id == Enum.PetBloodType.PBT_BOSS then
                if PetBaseConf and PetBaseConf.evolution_pet_id and PetBaseConf.evolution_pet_id[1] then
                  table.insert(PetDataList, PetData)
                  break
                end
                if PetBaseConf and PetBaseConf.bosspetbase_rule == BattleEnum.BloodItemRule.BossPet and PetBaseConf.bosspetbase_rule_param and #PetBaseConf.bosspetbase_rule_param > 0 then
                  local BagItem = _G.NRCModeManager:DoCmd(BagModuleCmd.GetBagItemByID, PetBaseConf.bosspetbase_rule_param[1])
                  if BagItem and BagItem.type == Enum.BagItemType.BI_BOSS_EVO then
                    table.insert(PetDataList, PetData)
                  end
                end
                break
              end
              table.insert(PetDataList, PetData)
              break
            end
          end
        end
        if PetDataList and #PetDataList > 0 then
          self.Switcher:SetActiveWidgetIndex(1)
          self.PetList:InitGridView(PetDataList)
        end
      end
    end
  end
end

function UMG_PetBloodlineMagic_C:DepartmentMatching(PetData, blood_id)
  for i, type in ipairs(PetData.skill_dam_type) do
    local PetBloodConf = _G.DataConfigManager:GetPetBloodConf(blood_id)
    if PetBloodConf and type == PetBloodConf.blood_type then
      return true
    end
  end
  return false
end

function UMG_PetBloodlineMagic_C:OnPetTeamEquipPetMagic()
  if not self.teamType then
    return
  end
  local petTeams = _G.DataModelMgr.PlayerDataModel:GetPlayerPetTeamInfoByTeamType(self.teamType)
  self.roleMagicGid = petTeams.teams[self.teamIndex + 1].role_magic_gid
  self:SetPanelInfo(false)
end

function UMG_PetBloodlineMagic_C:OnEquipmentOrRemoveBloodEvent()
  self:SetPanelInfo(false)
end

function UMG_PetBloodlineMagic_C:OnBtnClose()
  self:SetItemOnNewStateRemove()
  _G.NRCAudioManager:PlaySound2DAuto(41401014, "UMG_PetLeftPanel_C:OnBtnClose")
  self:LoadAnimation(2)
end

function UMG_PetBloodlineMagic_C:OnBtnLeft()
  _G.NRCAudioManager:PlaySound2DAuto(41401007, "UMG_PetLeftPanel_C:OnBtnLeft")
  if self.SelectIndex - 1 >= 0 then
    self.SkipAudio = true
    self.List:SelectItemByIndex(self.SelectIndex - 1)
  end
end

function UMG_PetBloodlineMagic_C:OnBtnRight()
  _G.NRCAudioManager:PlaySound2DAuto(41401007, "UMG_PetLeftPanel_C:OnBtnRight")
  if self.SelectIndex + 1 < self.MaxIndex then
    self.SkipAudio = true
    self.List:SelectItemByIndex(self.SelectIndex + 1)
  end
end

function UMG_PetBloodlineMagic_C:OnCanCel()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_PetLeftPanel_C:OnCanCel")
  self:SetItemOnNewStateRemove()
  self:LoadAnimation(2)
end

function UMG_PetBloodlineMagic_C:OnPcClose()
  self:OnCanCel()
end

function UMG_PetBloodlineMagic_C:SetItemOnNewStateRemove()
end

function UMG_PetBloodlineMagic_C:OnConfirm()
  self.SkipAudio = true
  if self.teamType == _G.Enum.PlayerTeamType.PTT_BIG_WORLD then
    if self.IsEquipment then
      _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_PetLeftPanel_C:OnConfirm")
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ChangePetTeamRoleMagicGid, self.teamIndex, self.teamType, self.SelectBagItem.gid)
      self:SetItemOnNewStateRemove()
    else
      _G.NRCAudioManager:PlaySound2DAuto(41401005, "UMG_PetLeftPanel_C:OnConfirm")
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ChangePetTeamRoleMagicGid, self.teamIndex, self.teamType, 0)
    end
  elseif self.IsEquipment then
    _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_PetLeftPanel_C:OnConfirm")
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ChangePetTeamRoleMagicGid, self.teamIndex, self.teamType, self.SelectBagItem.gid)
    self:SetItemOnNewStateRemove()
  else
    _G.NRCAudioManager:PlaySound2DAuto(41401005, "UMG_PetLeftPanel_C:OnConfirm")
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ChangePetTeamRoleMagicGid, self.teamIndex, self.teamType, 0)
  end
end

function UMG_PetBloodlineMagic_C:SetBtnInfo(BagItem)
  if self.roleMagicGid == BagItem.gid then
    self.IsEquipment = false
    self.PopUp3:SetBtnRightText(LuaText.umg_bag_12)
  else
    self.IsEquipment = true
    self.PopUp3:SetBtnRightText(LuaText.umg_bag_9)
  end
  if self.SelectIndex <= 1 then
    self.Btn_left:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Btn_right:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  local BagItemS = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemArrayByType, Enum.BagItemType.BI_PLAYERSKILL)
  if #BagItemS > 1 then
    if 0 == self.SelectIndex then
      self.Btn_left:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.Btn_right:SetVisibility(UE4.ESlateVisibility.Visible)
    elseif self.SelectIndex == #BagItemS - 1 then
      self.Btn_left:SetVisibility(UE4.ESlateVisibility.Visible)
      self.Btn_right:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Btn_left:SetVisibility(UE4.ESlateVisibility.Visible)
      self.Btn_right:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  else
    self.Btn_left:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Btn_right:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PetBloodlineMagic_C:OnAnimationFinished(Anim)
  if Anim == self:GetAnimByIndex(2) then
    self:DoClose()
  elseif Anim == self.Press then
    self:PlayAnimation(self.Up)
  elseif Anim == self.Up and self.module then
    self.module:OnCmdOpenLeaderItemPanel()
  end
end

function UMG_PetBloodlineMagic_C:OnViewLeaderItemBtn()
  _G.NRCAudioManager:PlaySound2DAuto(41401004, "UMG_PetBloodlineMagic_C:OnViewLeaderItemBtn")
  self:PlayAnimation(self.Press)
end

function UMG_PetBloodlineMagic_C:UpdateCanvasPanel103Visibility()
  if not self.CanvasPanel_103 then
    return
  end
  if self:IsEvolutionMagicSelected() then
    self.CanvasPanel_103:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.CanvasPanel_103:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PetBloodlineMagic_C:IsEvolutionMagicSelected()
  if not self.SelectBagItem or not self.SelectBagItem.id then
    return false
  end
  local bagItemConf = _G.DataConfigManager:GetBagItemConf(self.SelectBagItem.id)
  if not bagItemConf or not bagItemConf.player_skill_id then
    return false
  end
  local playerMagicConf = _G.DataConfigManager:GetPlayerMagicConf(bagItemConf.player_skill_id)
  if not playerMagicConf then
    return false
  end
  return 1 == playerMagicConf.tag
end

return UMG_PetBloodlineMagic_C
