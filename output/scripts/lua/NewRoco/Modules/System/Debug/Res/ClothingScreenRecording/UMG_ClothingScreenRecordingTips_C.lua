local RolePlayModuleDef = require("NewRoco.Modules.System.RolePlay.RolePlayModuleDef")
local DebugTabPlayerCamera = require("NewRoco.Modules.System.Debug.Tabs.DebugTabPlayerCamera")
local DebugTabBattle = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBattle")
local DebugBattlePVPShowResultUI = require("NewRoco.Modules.System.Debug.Res.ClothingScreenRecording.DebugBattlePVPShowResultUI")
local DebugModuleEvent = require("NewRoco.Modules.System.Debug.DebugModuleEvent")
local UMG_ClothingScreenRecordingTips_C = _G.NRCPanelBase:Extend("UMG_ClothingScreenRecordingTips_C")
UMG_ClothingScreenRecordingTips_C.FunctionType = {
  EquipCostumesAndPet = 1,
  LeisurelyMovement = 2,
  BattleSettlement = 3,
  BattleChangePet = 4
}

function UMG_ClothingScreenRecordingTips_C:OnConstruct()
  self:SetChildViews(self.UMG_BattlePoint)
  self.DebugData = {
    {
      Type = self.FunctionType.EquipCostumesAndPet,
      Text = "\232\163\133\229\164\135\230\140\135\229\174\154\230\151\182\232\163\133\229\143\138\230\151\182\232\163\133\231\178\190\231\129\181",
      Call = self
    },
    {
      Type = self.FunctionType.LeisurelyMovement,
      Text = "\232\167\166\229\143\145\230\151\182\232\163\133\229\164\167\228\184\150\231\149\140\228\188\145\233\151\178\229\138\168\228\189\156",
      Call = self
    },
    {
      Type = self.FunctionType.BattleSettlement,
      Text = "\232\167\166\229\143\145\230\173\163\229\184\184\230\136\152\230\150\151\232\131\156\229\136\169\231\187\147\231\174\151",
      Call = self
    },
    {
      Type = self.FunctionType.BattleChangePet,
      Text = "\232\167\166\229\143\145\230\151\182\232\163\133\230\136\152\230\150\151\228\184\173\229\143\172\229\148\164",
      Call = self
    }
  }
  self.BattlePointList = {}
  self.SelectTypeIndex = self.FunctionType.EquipCostumesAndPet
  self.PetConfId = nil
  local BattleGlobalConf = _G.DataConfigManager:GetBattleGlobalConfig("battle_mappoint_1")
  local BattleGlobalConf_1 = _G.DataConfigManager:GetBattleGlobalConfig("battle_mappoint_2")
  if BattleGlobalConf.numList and #BattleGlobalConf.numList > 0 then
    table.insert(self.BattlePointList, {
      id = BattleGlobalConf.id,
      Pos = UE4.FVector(math.floor(BattleGlobalConf.numList[2]) or 0, math.floor(BattleGlobalConf.numList[3]) or 0, math.floor(BattleGlobalConf.numList[4]) or 0),
      Call = self,
      handler = self.OnSetBattlePoint
    })
  end
  if BattleGlobalConf_1.numList and #BattleGlobalConf_1.numList > 0 then
    table.insert(self.BattlePointList, {
      id = BattleGlobalConf_1.id,
      Pos = UE4.FVector(math.floor(BattleGlobalConf_1.numList[2]) or 0, math.floor(BattleGlobalConf_1.numList[3]) or 0, math.floor(BattleGlobalConf_1.numList[4]) or 0),
      Call = self,
      handler = self.OnSetBattlePoint
    })
  end
  self:OnAddEventListener()
end

function UMG_ClothingScreenRecordingTips_C:OnDestruct()
end

function UMG_ClothingScreenRecordingTips_C:OnActive()
  self:SetPanelInfo()
end

function UMG_ClothingScreenRecordingTips_C:OnDeactive()
end

function UMG_ClothingScreenRecordingTips_C:OnAddEventListener()
  self:AddButtonListener(self.Confirm.btnLevelUp, self.OnConfirm)
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnCloseBtn)
  self:RegisterEvent(self, DebugModuleEvent.SetFashionInfo, self.SetFashionInfo)
  self:RegisterEvent(self, DebugModuleEvent.PetTeamFriendGetMirrorPetData, self.OnPetTeamFriendGetMirrorPetData)
  self.OrderOne.OnCheckStateChanged:Add(self, self.OnOrderOne)
  self.OrderTwo.OnCheckStateChanged:Add(self, self.OnOrderTwo)
  self.OrderThree.OnCheckStateChanged:Add(self, self.OnOrderThree)
  self.Leader.OnCheckStateChanged:Add(self, self.OnLeader)
end

function UMG_ClothingScreenRecordingTips_C:SetPanelInfo()
  self.List:InitGridView(self.DebugData)
  self.List:SelectItemByIndex(self.SelectTypeIndex - 1)
  self.UMG_BattlePoint:UpdateInfo(self.BattlePointList)
end

function UMG_ClothingScreenRecordingTips_C:OnSetBattlePoint(_Param)
  self.SelectPos = _Param.Pos
  self.UMG_BattlePoint:SetText(_Param.id)
  self.UMG_BattlePoint:SetScrollVisible(false)
end

function UMG_ClothingScreenRecordingTips_C:SelectInfo(Type)
  if Type == self.FunctionType.EquipCostumesAndPet then
    self.NRCSwitcher_50:SetActiveWidgetIndex(0)
  else
    self.NRCSwitcher_50:SetActiveWidgetIndex(1)
    if Type == self.FunctionType.LeisurelyMovement then
      self.PlayRelaxation:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.UMG_BattlePoint:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.PlayRelaxation:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.UMG_BattlePoint:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  self.SelectTypeIndex = Type
end

function UMG_ClothingScreenRecordingTips_C:OnConfirm()
  if self.SelectTypeIndex == self.FunctionType.EquipCostumesAndPet then
    self:EquipCostumesAndPetInfo()
  elseif self.SelectTypeIndex == self.FunctionType.LeisurelyMovement then
    if self:AddPetInfo() then
      self:PlayInteractive()
    end
  elseif self.SelectTypeIndex == self.FunctionType.BattleSettlement then
    if self:AddPetInfo() then
      self:OnBattleChangePet(self.SelectTypeIndex)
    end
  elseif self.SelectTypeIndex == self.FunctionType.BattleChangePet and self:AddPetInfo() then
    self:OnBattleChangePet(self.SelectTypeIndex)
  end
end

function UMG_ClothingScreenRecordingTips_C:PlayInteractive()
  if self:SetFashionRelaxData() then
    local IsMeetCasePet, rolePlayItem = self:GetRolePlayItem(self.PetConfId)
    if IsMeetCasePet then
      self:PlayInteractiveStar(rolePlayItem)
    end
  end
end

function UMG_ClothingScreenRecordingTips_C:PlayInteractiveStar(rolePlayItem)
  if not string.IsNilOrEmpty(self.InputBox_3:GetText()) then
    _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.SetLoop, true, self.InteractiveConfItem, self, rolePlayItem)
  end
  self:SetCameraInfo()
  self:InteractiveConfItem(rolePlayItem)
  _G.NRCModeManager:DoCmd(_G.DebugModuleCmd.OpenOrClosePanel, false)
  self:DoClose()
end

function UMG_ClothingScreenRecordingTips_C:EquipCostumesAndPetInfo()
  local fashionSuitsId = tonumber(self.InputBox:GetText()) or 0
  local sgSuitId = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.CheckSGSuitId, fashionSuitsId)
  if not sgSuitId then
    _G.NRCModuleManager:DoCmd(DebugModuleCmd.OpenDebugTips, "\232\190\147\229\133\165\231\154\132\228\184\141\230\152\175\229\141\142\228\184\189\233\173\148\230\179\149\229\165\151\232\163\133,\232\175\183\233\135\141\230\150\176\232\190\147\229\133\165")
    return
  end
  _G.NRCModuleManager:DoCmd(DebugModuleCmd.GmSetFashionSuit, fashionSuitsId)
end

function UMG_ClothingScreenRecordingTips_C:SetFashionInfo(fashionSuitsId, salonIds, item_id)
  local itemIdList = {}
  local bHasWand = false
  for k, v in ipairs(item_id) do
    local itemConf = _G.DataConfigManager:GetFashionItemConf(v)
    if itemConf and itemConf.type == _G.Enum.FashionLabelType.FLT_WAND then
      bHasWand = true
    end
    table.insert(itemIdList, v)
  end
  if not bHasWand then
    table.insert(itemIdList, 32500101)
  end
  _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetDefaultSuit, itemIdList, self:SetSalonIds(salonIds), nil, false)
  _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.OnCmdSetFashionDataReq, 1, itemIdList, nil, nil, nil, nil, nil, salonIds)
  _G.NRCModeManager:DoCmd(_G.DebugModuleCmd.OpenOrClosePanel, false)
  self:DoClose()
end

function UMG_ClothingScreenRecordingTips_C:SetSalonIds(_salonIds)
  local salonIds = {}
  if _salonIds and #_salonIds > 0 then
    for k, v in ipairs(_salonIds) do
      table.insert(salonIds, {item_wear_id = v})
    end
  end
  return salonIds
end

function UMG_ClothingScreenRecordingTips_C:AddPetInfo()
  local OrderOne = self.OrderOne:IsChecked()
  local OrderTwo = self.OrderTwo:IsChecked()
  local OrderThree = self.OrderThree:IsChecked()
  local Leader = self.Leader:IsChecked()
  local suitIdTable = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.CheckSuitEffect)
  if suitIdTable and #suitIdTable > 0 then
    local suitID = tonumber(suitIdTable and suitIdTable[1])
    local suitConf = _G.DataConfigManager:GetFashionSuitsConf(suitID)
    if suitConf and 0 ~= suitConf.perform_id then
      local PerFormConf = _G.DataConfigManager:GetFashionPerformConf(suitConf.perform_id)
      local PetBaseId = 0
      if OrderOne then
        PetBaseId = PerFormConf.petbase1_id and PerFormConf.petbase1_id[1]
      elseif OrderTwo then
        PetBaseId = PerFormConf.petbase2_id and PerFormConf.petbase2_id[1]
      elseif OrderThree then
        PetBaseId = PerFormConf.petbase3_id and PerFormConf.petbase3_id[1]
      elseif Leader then
        PetBaseId = PerFormConf.petbase4_id and PerFormConf.petbase4_id[1]
      end
      local PetConf = self:GetPetConfByBaseId(PetBaseId)
      self.PetConfId = PetConf.id
      if self:IsHasPetByMagicalCostume(suitConf, PetConf.base_id) then
        if not self:IsHasPetByPlayerPetBattlePet(self.PetConfId) then
          if not self:IsHasPetByPlayerBackpackPetInfo(self.PetConfId) then
            _G.NRCModuleManager:DoCmd(DebugModuleCmd.AddRewardInfo, "ADD", "PET", self.PetConfId, 1, self.ChangePetTeamsInfo, self, self.PetConfId)
          else
            self:ChangePetTeamsInfo(self.PetConfId)
          end
          return false
        else
          return true
        end
      else
        _G.NRCModuleManager:DoCmd(DebugModuleCmd.OpenDebugTips, "\229\189\147\229\137\141\229\141\142\228\184\189\233\173\148\230\179\149\230\156\141\232\163\133\230\178\161\230\156\137\231\187\145\229\174\154\232\175\165\229\174\160\231\137\169,\232\175\183\233\135\141\230\150\176\232\190\147\229\133\165\229\174\160\231\137\169PetConfId")
        return false
      end
    else
      _G.NRCModuleManager:DoCmd(DebugModuleCmd.OpenDebugTips, "\232\175\165\230\156\141\232\163\133\230\178\161\230\156\137\229\175\185\229\186\148\229\141\142\228\184\189\233\173\148\230\179\149\232\161\168\230\188\148id,\232\175\183\233\135\141\230\150\176\233\128\137\230\139\169\230\156\141\232\163\133")
      return false
    end
    return true
  end
end

function UMG_ClothingScreenRecordingTips_C:OnPetTeamFriendGetMirrorPetData()
  if self.SelectTypeIndex == self.FunctionType.LeisurelyMovement then
    self:PlayInteractive()
  elseif self.SelectTypeIndex == self.FunctionType.BattleSettlement then
    self:OnBattleChangePet(self.SelectTypeIndex)
  elseif self.SelectTypeIndex == self.FunctionType.BattleChangePet then
    self:OnBattleChangePet(self.SelectTypeIndex)
  end
end

function UMG_ClothingScreenRecordingTips_C:OnBattleChangePet(SelectTypeIndex)
  local IsSucceed = false
  if self:IsHasMotion(SelectTypeIndex) then
    local IsMeetCasePet, PetData = self:GetSettlementAndChangePet(self.PetConfId)
    if IsMeetCasePet then
      if SelectTypeIndex == self.FunctionType.BattleSettlement then
        _G.EnableFakePVPRecord = true
        _G.NRCModuleManager:DoCmd(MainUIModuleCmd.SelectPetByGid, PetData.gid)
        _G.BattleManager.debugEnv.BattleSettlement = true
        _G.BattleManager.debugEnv.Pos = self.SelectPos
      elseif SelectTypeIndex == self.FunctionType.BattleChangePet then
        _G.EnableFakePVPRecord = true
        _G.NRCModuleManager:DoCmd(MainUIModuleCmd.SelectPetByGid, self:SelectCommonPet(PetData.gid))
        _G.BattleManager.debugEnv.GmChangeMagicPet = true
        _G.BattleManager.debugEnv.GmChangeMagicPetData = PetData
        _G.BattleManager.debugEnv.Pos = self.SelectPos
      end
      DebugTabBattle:EnterBattle()
      IsSucceed = true
      NRCModuleManager:DoCmd(UpdateUIModuleCmd.ShowUid, false)
    end
  end
  if IsSucceed then
    _G.NRCModeManager:DoCmd(_G.DebugModuleCmd.OpenOrClosePanel, false)
    self:DoClose()
  end
end

function UMG_ClothingScreenRecordingTips_C:GetPetConfByBaseId(PetBaseId)
  local PetConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.PET_CONF):GetAllDatas()
  for i, Pet in pairs(PetConf) do
    if PetBaseId == Pet.base_id and 0 == Pet.pet_info_id then
      return Pet
    end
  end
  _G.NRCModuleManager:DoCmd(DebugModuleCmd.OpenDebugTips, "\230\178\161\230\156\137\229\156\168PetConf\228\184\173\230\137\190\229\136\176\229\175\185\229\186\148PetBaseId")
end

function UMG_ClothingScreenRecordingTips_C:IsHasPetByMagicalCostume(FashionSuitConf, PetBaseId)
  if FashionSuitConf.petbase_id and #FashionSuitConf.petbase_id > 0 then
    for i, Id in ipairs(FashionSuitConf.petbase_id) do
      if PetBaseId == Id then
        return true
      end
    end
  end
  return false
end

function UMG_ClothingScreenRecordingTips_C:IsHasPetByPlayerPetBattlePet(PetConfId)
  local battlePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  if battlePetList and #battlePetList > 0 then
    for i, Pet in ipairs(battlePetList) do
      if Pet.conf_id == PetConfId then
        return true
      end
    end
  end
  return false
end

function UMG_ClothingScreenRecordingTips_C:SelectCommonPet(_gid)
  local battlePetDatas = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  local rolePlayItems = _G.NRCModuleManager:DoCmd(_G.RolePlayModuleCmd.GetRolePlayData, RolePlayModuleDef.RolePlayType.Interactive, self.fashionRelaxData)
  for i, Pet in ipairs(battlePetDatas) do
    local gid = Pet.gid
    if gid == _gid then
      gid = nil
    end
    if gid then
      return gid
    end
  end
  return battlePetDatas[1].gid
end

function UMG_ClothingScreenRecordingTips_C:IsHasPetByPlayerBackpackPetInfo(PetConfId)
  local backpackPetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBackpackPetInfo()
  if backpackPetList and #backpackPetList > 0 then
    for i, Pet in ipairs(backpackPetList) do
      if Pet.conf_id == PetConfId then
        return true, Pet
      end
    end
  end
  return false, nil
end

function UMG_ClothingScreenRecordingTips_C:ChangePetTeamsInfo(PetConfId)
  local IsHasPet, Pet = self:IsHasPetByPlayerBackpackPetInfo(PetConfId)
  if IsHasPet then
    local new_team_pet_gid = {}
    local battlePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
    for i, pet_data in ipairs(battlePetList) do
      if 1 ~= i then
        table.insert(new_team_pet_gid, pet_data.gid)
      else
        table.insert(new_team_pet_gid, Pet.gid)
      end
    end
    local teams = {}
    for i = 1, #new_team_pet_gid do
      local teamPetInfo = _G.ProtoMessage:newPetTeam_PetInfo()
      teamPetInfo.pet_gid = new_team_pet_gid[i]
      table.insert(teams, teamPetInfo)
    end
    local teamList = {}
    local teamIndexList = {}
    local addTeamIndex = _G.DataModelMgr.PlayerDataModel:GetBattleTeamIndex()
    table.insert(teamIndexList, addTeamIndex)
    table.insert(teamList, teams)
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.ChangePetTeamsInfo, teamList, teamIndexList, Enum.PlayerTeamType.PTT_BIG_WORLD)
  end
end

function UMG_ClothingScreenRecordingTips_C:SetFashionRelaxData()
  self.fashionRelaxData = {}
  local battlePetDatas = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  if not battlePetDatas then
    _G.NRCModuleManager:DoCmd(DebugModuleCmd.OpenDebugTips, "\231\188\150\233\152\159\230\178\161\230\156\137\229\174\160\231\137\169,\232\175\183\229\138\160\229\133\165\229\174\160\231\137\169")
    return false
  end
  local suitIdTable = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.CheckSuitEffect)
  if suitIdTable and #suitIdTable > 0 then
    local suitID = tonumber(suitIdTable and suitIdTable[1])
    local suitConf = _G.DataConfigManager:GetFashionSuitsConf(suitID)
    if suitConf and 0 ~= suitConf.perform_id then
      local PerFormConf = _G.DataConfigManager:GetFashionPerformConf(suitConf.perform_id)
      local suitRolePlayId = PerFormConf and PerFormConf.suiteffect3_rest_skill or 0
      if suitRolePlayId and 0 ~= suitRolePlayId then
        local suitRelatedPetBaseIds = {}
        local petBaseIds = PerFormConf and PerFormConf.petbase3_id
        if petBaseIds then
          for _, petBaseId in ipairs(petBaseIds) do
            suitRelatedPetBaseIds[petBaseId] = true
          end
        end
        for _, petData in ipairs(battlePetDatas) do
          local petBaseId = petData.base_conf_id
          if suitRelatedPetBaseIds[petBaseId] then
            self.fashionRelaxData[petData.gid] = suitRolePlayId
          end
        end
      end
    else
      _G.NRCModuleManager:DoCmd(DebugModuleCmd.OpenDebugTips, "\232\175\165\230\156\141\232\163\133\230\178\161\230\156\137\229\175\185\229\186\148\229\141\142\228\184\189\233\173\148\230\179\149\232\161\168\230\188\148id,\232\175\183\233\135\141\230\150\176\233\128\137\230\139\169\230\156\141\232\163\133")
      return false
    end
  end
  local BondInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerBondInfo()
  local BondItem = BondInfo.fashion_bond_item
  if BondItem then
    for _, petData in ipairs(battlePetDatas) do
      local Find_fashion_bond_conf
      for i, v in ipairs(BondItem) do
        local fashion_bond_conf = _G.DataConfigManager:GetFashionBondConf(v.id)
        if fashion_bond_conf and fashion_bond_conf.perform_id then
          local fashion_perform_conf = _G.DataConfigManager:GetFashionPerformConf(fashion_bond_conf.perform_id)
          if fashion_perform_conf and fashion_perform_conf.petbase3_id then
            local petBaseIdList = fashion_perform_conf.petbase3_id
            for _, baseId in ipairs(petBaseIdList) do
              if baseId == petData.base_conf_id then
                Find_fashion_bond_conf = fashion_bond_conf
                break
              end
            end
          end
        end
        if Find_fashion_bond_conf then
          break
        end
      end
      if Find_fashion_bond_conf and Find_fashion_bond_conf.pet_interact_id and 0 ~= Find_fashion_bond_conf.pet_interact_id then
        self.fashionRelaxData[petData.gid] = Find_fashion_bond_conf.pet_interact_id
      end
    end
  end
  if self:IsHasInfo() then
    return true
  else
    _G.NRCModuleManager:DoCmd(DebugModuleCmd.OpenDebugTips, "\232\175\165\230\156\141\232\163\133\230\178\161\230\156\137\229\175\185\229\186\148\229\174\160\231\137\169\228\188\145\233\151\178\229\138\168\228\189\156")
    return false
  end
end

function UMG_ClothingScreenRecordingTips_C:IsHasMotion(SelectTypeIndex)
  local battlePetDatas = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  if not battlePetDatas then
    _G.NRCModuleManager:DoCmd(DebugModuleCmd.OpenDebugTips, "\231\188\150\233\152\159\230\178\161\230\156\137\229\174\160\231\137\169,\232\175\183\229\138\160\229\133\165\229\174\160\231\137\169")
    return false
  end
  local suitRolePlayId
  local suitIdTable = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.CheckSuitEffect)
  if suitIdTable and #suitIdTable > 0 then
    local suitID = tonumber(suitIdTable and suitIdTable[1])
    local suitConf = _G.DataConfigManager:GetFashionSuitsConf(suitID)
    if suitConf and 0 ~= suitConf.perform_id then
      local PerFormConf = _G.DataConfigManager:GetFashionPerformConf(suitConf.perform_id)
      if SelectTypeIndex == self.FunctionType.BattleSettlement then
        suitRolePlayId = PerFormConf and PerFormConf.suiteffect3_win_skill or 0
        if 0 == suitRolePlayId then
          _G.NRCModuleManager:DoCmd(DebugModuleCmd.OpenDebugTips, "\232\175\165\230\156\141\232\163\133\230\178\161\230\156\137\229\175\185\229\186\148\229\174\160\231\137\169\231\187\147\231\174\151\229\138\168\228\189\156")
          return false
        end
      elseif SelectTypeIndex == self.FunctionType.BattleChangePet then
        suitRolePlayId = PerFormConf and PerFormConf.suiteffect3_callout_skill or 0
        if 0 == suitRolePlayId then
          _G.NRCModuleManager:DoCmd(DebugModuleCmd.OpenDebugTips, "\232\175\165\230\156\141\232\163\133\230\178\161\230\156\137\229\175\185\229\186\148\229\174\160\231\137\169\230\141\162\229\174\160\229\138\168\228\189\156")
          return false
        end
      end
    end
    return true
  end
end

function UMG_ClothingScreenRecordingTips_C:CheckPetAndAction()
  local battlePetDatas = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  if not battlePetDatas then
    _G.NRCModuleManager:DoCmd(DebugModuleCmd.OpenDebugTips, "\231\188\150\233\152\159\230\178\161\230\156\137\229\174\160\231\137\169,\232\175\183\229\138\160\229\133\165\229\174\160\231\137\169")
    return false
  end
  if not self:IsHasInfo() then
    _G.NRCModuleManager:DoCmd(DebugModuleCmd.OpenDebugTips, "\232\175\165\230\156\141\232\163\133\230\178\161\230\156\137\229\175\185\229\186\148\229\174\160\231\137\169\228\188\145\233\151\178\229\138\168\228\189\156")
    return false
  end
  return true
end

function UMG_ClothingScreenRecordingTips_C:GetMeetCasePet()
  if self:CheckPetAndAction() then
    local battlePetDatas = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
    local rolePlayItems = _G.NRCModuleManager:DoCmd(_G.RolePlayModuleCmd.GetRolePlayData, RolePlayModuleDef.RolePlayType.Interactive, self.fashionRelaxData)
    for i, Pet in ipairs(battlePetDatas) do
      for j, rolePlayItem in pairs(rolePlayItems) do
        if type(rolePlayItem) == "table" then
          local base_conf_id = rolePlayItem.customData and rolePlayItem.customData.base_conf_id or 0
          if Pet.base_conf_id == base_conf_id then
            return true, rolePlayItem
          end
        end
      end
    end
    _G.NRCModuleManager:DoCmd(DebugModuleCmd.OpenDebugTips, "\230\178\161\230\156\137\229\156\168\231\188\150\233\152\159\230\137\190\229\136\176\229\175\185\229\186\148\229\174\160\231\137\169\233\128\130\229\144\136\232\175\165\230\156\141\232\163\133")
    return false
  end
end

function UMG_ClothingScreenRecordingTips_C:GetSettlementAndChangePet(PetConfId)
  local battlePetDatas = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  if PetConfId then
    for i, Pet in ipairs(battlePetDatas) do
      if Pet.conf_id == PetConfId then
        return true, Pet
      end
    end
  end
  _G.NRCModuleManager:DoCmd(DebugModuleCmd.OpenDebugTips, "\230\178\161\230\156\137\229\156\168\231\188\150\233\152\159\230\137\190\229\136\176\229\175\185\229\186\148\229\174\160\231\137\169\233\128\130\229\144\136\232\175\165\230\156\141\232\163\133")
  return false
end

function UMG_ClothingScreenRecordingTips_C:GetRolePlayItem(PetConfId)
  if self:CheckPetAndAction() then
    local battlePetDatas = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
    local rolePlayItems = {}
    if self.fashionRelaxData then
      for petGid, relaxRolePlayId in pairs(self.fashionRelaxData) do
        local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(petGid)
        local _itemConf = {}
        _itemConf.type = RolePlayModuleDef.RolePlayType.Interactive
        _itemConf.value = relaxRolePlayId
        _itemConf.customData = petData
        if _itemConf then
          table.insert(rolePlayItems, _itemConf)
        end
      end
    end
    local BattleHasPet = false
    local rolePlayPet = false
    for i, Pet in ipairs(battlePetDatas) do
      if Pet.conf_id == PetConfId then
        BattleHasPet = true
        for j, rolePlayItem in pairs(rolePlayItems) do
          if type(rolePlayItem) == "table" then
            local conf_id = rolePlayItem.customData and rolePlayItem.customData.conf_id or 0
            if PetConfId == conf_id then
              rolePlayPet = true
              return true, rolePlayItem
            end
          end
        end
      end
    end
    if not BattleHasPet then
      _G.NRCModuleManager:DoCmd(DebugModuleCmd.OpenDebugTips, "\233\128\137\228\184\173\231\154\132\228\184\137\233\152\182\229\174\160\231\137\169\228\184\141\229\156\168\231\188\150\233\152\159\228\184\173,\232\175\183\230\159\165\231\156\139\229\142\159\229\155\160")
      return false
    end
    if not rolePlayPet then
      _G.NRCModuleManager:DoCmd(DebugModuleCmd.OpenDebugTips, "\232\175\165\230\156\141\232\163\133\229\175\185\229\186\148\231\154\132\229\174\160\231\137\169\230\178\161\230\156\137\228\188\145\233\151\178\229\138\168\228\189\156,\232\175\183\233\135\141\230\150\176\232\190\147\229\133\165")
      return false
    end
  end
end

function UMG_ClothingScreenRecordingTips_C:InteractiveConfItem(data)
  local itemConf = data
  if not itemConf or not itemConf.value then
    return
  end
  local petData = itemConf.customData
  if not petData or not petData.base_conf_id then
    return
  end
  local executeParam = {}
  executeParam.type = itemConf.type
  executeParam.skill_interact_id = itemConf.value
  executeParam.statusParams = {}
  executeParam.statusParams.role_play_param = {}
  executeParam.statusParams.role_play_param.role_play_id = executeParam.id
  executeParam.statusParams.role_play_param.pet_id = petData.base_conf_id
  executeParam.statusParams.role_play_param.mutation_type = petData.mutation_type
  executeParam.statusParams.role_play_param.nature = petData.nature
  executeParam.statusParams.role_play_param.glass_info = petData.glass_info
  executeParam.statusParams.role_play_param.skill_type = ProtoEnum.RolePlaySkillType.RPST_PET_TREE_CLOSE
  executeParam.statusParams.role_play_param.skill_interact_id = itemConf.value
  _G.NRCModuleManager:DoCmd(_G.RolePlayModuleCmd.ExecuteRolePlay, executeParam)
end

function UMG_ClothingScreenRecordingTips_C:IsHasInfo()
  for i, fashionRelax in pairs(self.fashionRelaxData) do
    return true
  end
  return false
end

function UMG_ClothingScreenRecordingTips_C:SetCameraInfo()
  local GM_CameraOffset_X = tonumber(self.InputBox_4:GetText())
  if GM_CameraOffset_X then
    local Params = DebugTabPlayerCamera:GetCurCameraParams()
    Params.GM_CameraOffset_X = GM_CameraOffset_X
    local Camera = DebugTabPlayerCamera:GetCamera()
    for key, value in pairs(Params) do
      Camera[key] = value
    end
    Camera.GM_Camera = not Camera.GM_Camera
  end
  local localPlayer = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer then
    local rotator = localPlayer.viewObj:K2_GetActorRotation()
    rotator.Yaw = rotator.Yaw - 180
    local Controller = localPlayer:GetUEController()
    Controller:SetControlRotation(rotator)
  end
end

function UMG_ClothingScreenRecordingTips_C:OnCloseBtn()
  self:DoClose()
end

function UMG_ClothingScreenRecordingTips_C:OnPlay()
  DebugBattlePVPShowResultUI:PlaySkillInfo()
  _G.NRCModeManager:DoCmd(_G.DebugModuleCmd.OpenOrClosePanel, false)
  self:DoClose()
end

function UMG_ClothingScreenRecordingTips_C:OnOrderOne()
  if self.OrderOne:IsChecked() then
    self.OrderTwo:SetIsChecked(false)
    self.OrderThree:SetIsChecked(false)
    self.Leader:SetIsChecked(false)
  end
end

function UMG_ClothingScreenRecordingTips_C:OnOrderTwo()
  if self.OrderTwo:IsChecked() then
    self.OrderOne:SetIsChecked(false)
    self.OrderThree:SetIsChecked(false)
    self.Leader:SetIsChecked(false)
  end
end

function UMG_ClothingScreenRecordingTips_C:OnOrderThree()
  if self.OrderThree:IsChecked() then
    self.OrderOne:SetIsChecked(false)
    self.OrderTwo:SetIsChecked(false)
    self.Leader:SetIsChecked(false)
  end
end

function UMG_ClothingScreenRecordingTips_C:OnLeader()
  if self.Leader:IsChecked() then
    self.OrderOne:SetIsChecked(false)
    self.OrderTwo:SetIsChecked(false)
    self.OrderThree:SetIsChecked(false)
  end
end

return UMG_ClothingScreenRecordingTips_C
