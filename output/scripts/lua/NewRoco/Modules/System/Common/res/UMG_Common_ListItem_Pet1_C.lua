local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local PetUtils = require("NewRoco.Utils.PetUtils")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local PetUIModuleEnum = require("NewRoco.Modules.System.PetUI.PetUIModuleEnum")
local UMG_Common_ListItem_Pet1_C = Base:Extend("UMG_Common_ListItem_Pet1_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ItemState = {
  Normal = 0,
  CanExchange = 1,
  CanAddIn = 2,
  LockNormal = 3,
  Lock = 4
}

function UMG_Common_ListItem_Pet1_C:OnConstruct()
end

function UMG_Common_ListItem_Pet1_C:OnDestruct()
  if self.Module then
    self.Module:UnRegisterEvent(self, PetUIModuleEvent.PetTeamWarehouseItemSelected, self.OnPetTeamWarehouseItemSelected)
    self.Module:UnRegisterEvent(self, PetUIModuleEvent.PetTeamWarehouseItemExChanging, self.OnPetTeamWarehouseItemExChanging)
    self.Module:UnRegisterEvent(self, PetUIModuleEvent.PetTeamFastFormationChanged, self.OnPetTeamFastFormationChanged)
    self.Module:UnRegisterEvent(self, PetUIModuleEvent.PetTeamWarehouseItemLocked, self.OnPetTeamWarehouseItemLocked)
    self.Module:UnRegisterEvent(self, PetUIModuleEvent.PetTeamFastFormationRefreshed, self.OnPetTeamFastFormationRefreshed)
  end
end

function UMG_Common_ListItem_Pet1_C:RefreshItem()
  self:OnItemUpdate(self.uiData, nil, nil, true)
end

function UMG_Common_ListItem_Pet1_C:OnItemUpdate(_data, datalist, index, IsRefreshItem)
  self.curIndex = index
  self.Module = _G.NRCModuleManager:GetModule("PetUIModule")
  self.Module:UnRegisterEvent(self, PetUIModuleEvent.PetTeamWarehouseItemSelected, self.OnPetTeamWarehouseItemSelected)
  self.Module:UnRegisterEvent(self, PetUIModuleEvent.PetTeamWarehouseItemLocked, self.OnPetTeamWarehouseItemLocked)
  self.Module:UnRegisterEvent(self, PetUIModuleEvent.PetTeamWarehouseItemExChanging, self.OnPetTeamWarehouseItemExChanging)
  self.Module:UnRegisterEvent(self, PetUIModuleEvent.PetTeamFastFormationChanged, self.OnPetTeamFastFormationChanged)
  self.Module:UnRegisterEvent(self, PetUIModuleEvent.PetTeamFastFormationRefreshed, self.OnPetTeamFastFormationRefreshed)
  self.uiData = _data
  self.data = _data
  local iconNum = _data.itemNum
  local NRCSwitcherTopLeftVisibility = UE4.ESlateVisibility.Collapsed
  local NRCSwitcherTopLeftActiveIndex = 0
  local NRCSwitcherPetVisibility = UE4.ESlateVisibility.Collapsed
  local NRCSwitcherPetActiveIndex = 0
  local imageIconPath = ""
  local textQuantityText = ""
  if _data.isHasPet then
    if iconNum then
      self.Text_Quantity:SetText(iconNum)
    end
    NRCSwitcherPetVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
    if self.Switcher then
      self.Switcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if _data.PetData.gid then
      local petInfo = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(_data.PetData.gid, true)
      if petInfo and petInfo.base_conf_id then
        self.pet:SetIconPathAndMaterial(petInfo.base_conf_id, petInfo.mutation_type, petInfo.glass_info)
      end
      if petInfo and petInfo.partner_mark and petInfo.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE then
        self.Star:SetPath(PetUtils.GetPetCollectTagIcon(petInfo.partner_mark))
        self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    else
      if _data.PetData.PetBaseInfo.partner_mark and _data.PetData.PetBaseInfo.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE then
        self.Star:SetPath(PetUtils.GetPetCollectTagIcon(_data.PetData.PetBaseInfo.partner_mark))
        self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      self.pet:SetIconPathAndMaterial(_data.PetData.base_conf_id)
    end
    local isRandomPet = _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.CmdIsRandomPet, _data.PetData.gid)
    textQuantityText = tostring(_data.PetData.level)
    if _data.PetData.is_trial_pet then
      NRCSwitcherTopLeftActiveIndex = 0
      NRCSwitcherTopLeftVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
    elseif isRandomPet then
      local randomPetData = _data.PetData
      local typeInfo = randomPetData and randomPetData.type
      local typeInfoParam = typeInfo and typeInfo.param
      local skillDamType = typeInfoParam
      NRCSwitcherPetActiveIndex = 1
      if 0 == skillDamType then
        NRCSwitcherTopLeftActiveIndex = 2
      else
        NRCSwitcherTopLeftActiveIndex = 1
        local damType = skillDamType
        local typeDictionaryConf = _G.DataConfigManager:GetTypeDictionary(damType)
        local icon = typeDictionaryConf and typeDictionaryConf.type_icon
        if icon then
          imageIconPath = icon
        end
      end
      textQuantityText = "??"
      NRCSwitcherTopLeftVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
    else
      NRCSwitcherTopLeftVisibility = UE4.ESlateVisibility.Collapsed
    end
  else
    if self.Switcher then
      if _data.isLockUp then
        self.Switcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.Switcher:SetActiveWidgetIndex(2)
      else
        self.Switcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
    self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Text_Quantity:SetText("--")
    self.TryOut:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.Switcher_bg then
    if _data.isPetListItem then
      self.Switcher_bg:SetActiveWidgetIndex(0)
    else
      self.Switcher_bg:SetActiveWidgetIndex(1)
    end
  end
  if self.NRCSwitcher_TopLeft then
    self.NRCSwitcher_TopLeft:SetVisibility(NRCSwitcherTopLeftVisibility)
    self.NRCSwitcher_TopLeft:SetActiveWidgetIndex(NRCSwitcherTopLeftActiveIndex)
  end
  if self.NRCSwitcher_Pet then
    self.NRCSwitcher_Pet:SetVisibility(NRCSwitcherPetVisibility)
    self.NRCSwitcher_Pet:SetActiveWidgetIndex(NRCSwitcherPetActiveIndex)
  end
  self.Text_Quantity:SetText(textQuantityText)
  self.Image_Icon:SetPath(imageIconPath)
  self.Module:RegisterEvent(self, PetUIModuleEvent.PetTeamWarehouseItemSelected, self.OnPetTeamWarehouseItemSelected)
  self.Module:RegisterEvent(self, PetUIModuleEvent.PetTeamWarehouseItemLocked, self.OnPetTeamWarehouseItemLocked)
  self.Module:RegisterEvent(self, PetUIModuleEvent.PetTeamWarehouseItemExChanging, self.OnPetTeamWarehouseItemExChanging)
  self.Module:RegisterEvent(self, PetUIModuleEvent.PetTeamFastFormationChanged, self.OnPetTeamFastFormationChanged)
  self.Module:RegisterEvent(self, PetUIModuleEvent.PetTeamFastFormationRefreshed, self.OnPetTeamFastFormationRefreshed)
  local curMode = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.PetTeamReplaceGetCurMode)
  if curMode == PetUIModuleEnum.ModifyPetMode.SingleEdit then
    self.number:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif curMode == PetUIModuleEnum.ModifyPetMode.QuickEdit then
    self.number:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if _data.isHasPet then
      if self.rightShowNumber and _data.canInTeamNum and self.rightShowNumber <= _data.canInTeamNum then
        self.number:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      elseif not _data.canInTeamNum then
        Log.Error("UMG_Common_ListItem_Pet1_C canInTeamNum data is nil, check pet data")
      end
    end
  end
end

function UMG_Common_ListItem_Pet1_C:OnPetTeamWarehouseItemChanged(_PetData)
end

function UMG_Common_ListItem_Pet1_C:SetObturationPet()
  if self.data.isHasPet then
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(self.data.PetData.base_conf_id, true)
    if petBaseConf then
      local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
      self.Obturation_Pet:SetPath(modelConf.icon)
      self.Obturation_Pet:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Obturation_Pet:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    self.Obturation_Pet:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Common_ListItem_Pet1_C:ChangeItemState(Sate)
  if Sate == ItemState.Normal then
    self.Switcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Obturation:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Obturation_Pet:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif Sate == ItemState.CanExchange then
    self.Switcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Switcher:SetActiveWidgetIndex(0)
    self.Obturation:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:SetObturationPet()
  elseif Sate == ItemState.CanAddIn then
    self.Switcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Switcher:SetActiveWidgetIndex(1)
    self.Obturation:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:SetObturationPet()
  elseif Sate == ItemState.LockNormal then
    self.Switcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Switcher:SetActiveWidgetIndex(2)
    self.Obturation:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Obturation_Pet:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif Sate == ItemState.Lock then
    self.Switcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Switcher:SetActiveWidgetIndex(2)
    self.Obturation:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Obturation_Pet:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Common_ListItem_Pet1_C:OnPetTeamWarehouseItemExChanging(isInTeam, PetData)
  if self.Switcher then
    self:ChangeItemState(ItemState.Normal)
    if self.data.isPetListItem then
      local state = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.PetTeamReplaceGetCurExChangeState)
      if not state then
        if self.curIndex > self.data.canInTeamNum then
          self:ChangeItemState(ItemState.Lock)
          return
        end
        if self.data.isHasPet then
          if isInTeam then
            if PetData and self.data.PetData.gid ~= PetData.gid then
              self:ChangeItemState(ItemState.CanExchange)
            end
          else
            local hasCommon = _G.NRCModeManager:DoCmd(PetUIModuleCmd.PetTeamHasCommonEvolution, PetData.gid)
            if hasCommon then
              if PetUtils.IsCommonEvolution(PetData.gid, self.data.PetData.gid) then
                self:ChangeItemState(ItemState.CanExchange)
              else
                self:ChangeItemState(ItemState.Normal)
              end
            else
              self:ChangeItemState(ItemState.CanExchange)
            end
          end
        elseif not isInTeam then
          local hasCommon = _G.NRCModeManager:DoCmd(PetUIModuleCmd.PetTeamHasCommonEvolution, PetData.gid)
          if hasCommon then
            self:ChangeItemState(ItemState.Normal)
          else
            self:ChangeItemState(ItemState.CanAddIn)
          end
        end
      else
        if self.curIndex > self.data.canInTeamNum then
          self:ChangeItemState(ItemState.LockNormal)
          return
        end
        self:ChangeItemState(ItemState.Normal)
      end
    end
  end
end

function UMG_Common_ListItem_Pet1_C:OnPetTeamWarehouseItemLocked(_PetData, teamPetList)
  do return end
  if not self.data.isHasPet then
    return
  end
  self.IsLock = false
  if not self.data.isPetListItem then
    for _, petData in ipairs(teamPetList) do
      if (not _PetData or petData.gid ~= _PetData.gid) and PetUtils.IsCommonEvolution(self.data.PetData.gid, petData.gid) then
        self.IsLock = true
        break
      end
    end
  end
  if self.IsLock then
    self.Obturation:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Obturation_Pet:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Obturation:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Obturation_Pet:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Common_ListItem_Pet1_C:OnSpawn()
  self:OnSpawn1()
  self:OnSpawn2()
end

function UMG_Common_ListItem_Pet1_C:OnSpawn1()
  local curMode = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.PetTeamReplaceGetCurMode)
  if curMode == PetUIModuleEnum.ModifyPetMode.QuickEdit then
    self:StopAllAnimationsAndRecord()
    local data = self.data
    if data and data.PetData then
      self:OnPetTeamFastFormationRefreshed(self.teamInfoDic)
    end
  else
    local data = self.data
    if data and data.PetData then
      local curSelectGid = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.PetTeamReplaceGetCurSelPetDataGid)
      local isInTeam = self:GetIsSelect()
      if data.PetData.gid == curSelectGid then
        if not isInTeam then
          self:PlayAnimationAndRecord(PetUIModuleEnum.CommonListItemPet1Anim.In)
        end
      elseif isInTeam then
        self:PlayAnimationAndRecord(PetUIModuleEnum.CommonListItemPet1Anim.Out)
      end
    end
  end
end

function UMG_Common_ListItem_Pet1_C:GetIsSelect()
  local Opacity = self.Selected_bg:GetRenderOpacity()
  return Opacity > 0 or self:IsPlayingAnimationByRecord(PetUIModuleEnum.CommonListItemPet1Anim.In)
end

function UMG_Common_ListItem_Pet1_C:OnPetTeamWarehouseItemSelected(_PetData)
  local state = true
  if not self.uiData.bFromShiningWeekend then
    state = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.PetTeamReplaceGetCurExChangeState)
  end
  if not state then
    return
  end
  local isInTeam = self:GetIsSelect()
  if self.data and self.data.PetData then
    if _PetData and self.data.PetData.gid == _PetData.gid then
      if not isInTeam then
        self:PlayAnimationAndRecord(PetUIModuleEnum.CommonListItemPet1Anim.In)
      end
    elseif isInTeam then
      self:PlayAnimationAndRecord(PetUIModuleEnum.CommonListItemPet1Anim.Out)
    end
  elseif isInTeam then
    self:PlayAnimationAndRecord(PetUIModuleEnum.CommonListItemPet1Anim.Out)
  end
end

function UMG_Common_ListItem_Pet1_C:UpdateCollectCanvas()
end

function UMG_Common_ListItem_Pet1_C:OnPetTeamFastFormationRefreshed(newTeamInfoDic)
  local data = self.data
  self.number:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.teamInfoDic = newTeamInfoDic
  if data and data.PetData then
    self:StopAllAnimationsAndRecord()
    if newTeamInfoDic and newTeamInfoDic[data.PetData.gid] then
      self.rightShowNumber = newTeamInfoDic[data.PetData.gid]
      if self.rightShowNumber and data.canInTeamNum and self.rightShowNumber <= data.canInTeamNum then
        self.number:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      self.Text_number:SetText(self.rightShowNumber)
      self:PlayAnimationAndRecord(PetUIModuleEnum.CommonListItemPet1Anim.In)
      if self.data.PetData.PetBaseInfo.partner_mark and self.data.PetData.PetBaseInfo.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE then
        self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    else
      if not self:IsPlayingAnimationByRecord() then
        self:PlayAnimationAndRecord(PetUIModuleEnum.CommonListItemPet1Anim.Normal)
      end
      if self.data.PetData.PetBaseInfo.partner_mark and self.data.PetData.PetBaseInfo.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE then
        self.CollectCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    end
  elseif not self:IsPlayingAnimationByRecord() then
    self:PlayAnimationAndRecord(PetUIModuleEnum.CommonListItemPet1Anim.Normal)
  end
end

function UMG_Common_ListItem_Pet1_C:ResetUI()
  local isInTeam = self:GetIsSelect()
  if isInTeam then
    self:PlayAnimationAndRecord(PetUIModuleEnum.CommonListItemPet1Anim.Out)
  end
end

function UMG_Common_ListItem_Pet1_C:OnPetTeamFastFormationChanged(newTeamInfoDic)
  local data = self.data
  self.teamInfoDic = newTeamInfoDic
  local isInTeam = self:GetIsSelect()
  if data and data.PetData then
    if newTeamInfoDic and newTeamInfoDic[data.PetData.gid] then
      self.rightShowNumber = newTeamInfoDic[data.PetData.gid]
      self.Text_number:SetText(self.rightShowNumber)
      if self.rightShowNumber > data.canInTeamNum then
        self.number:SetVisibility(UE4.ESlateVisibility.Collapsed)
      else
        self.number:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        if not self.data.PetData.PetBaseInfo.partner_mark or self.data.PetData.PetBaseInfo.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE then
        end
      end
      if not isInTeam then
        self:PlayAnimationAndRecord(PetUIModuleEnum.CommonListItemPet1Anim.In)
      end
    else
      self.rightShowNumber = nil
      if isInTeam then
        self:PlayAnimationAndRecord(PetUIModuleEnum.CommonListItemPet1Anim.Out)
      end
      if not self.data.PetData.PetBaseInfo.partner_mark or self.data.PetData.PetBaseInfo.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE then
      end
    end
  else
    self:PlayAnimationAndRecord(PetUIModuleEnum.CommonListItemPet1Anim.Normal)
  end
end

function UMG_Common_ListItem_Pet1_C:SetQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

function UMG_Common_ListItem_Pet1_C:OnItemSelected(_bSelected, _bScrollSelected)
  if _bScrollSelected then
    return
  end
  if self.uiData.isLockUp then
    return
  end
  if self.uiData and self.uiData.PetData and self.uiData.PetData.is_trial_pet and self.uiData.PetData.refreshTime then
    local servetTime = ActivityUtils.GetSvrTimestamp()
    if servetTime > self.uiData.PetData.refreshTime then
      local tips = _G.DataConfigManager:GetBattleGlobalConfig("pvp_rank_trial_pet_character4").str
      _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, tips)
      _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.SendZonePvpInfoQueryReq)
      _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.AnimClosePetTeamReplacePanel)
      return
    end
  end
  if _bSelected then
    if not _bScrollSelected and self.IsLock then
      local nameLessCfg = _G.DataConfigManager:GetBattleGlobalConfig("pvp_team_same_pet")
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, nameLessCfg.str)
      return
    end
    local curMode = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.PetTeamReplaceGetCurMode)
    if curMode == PetUIModuleEnum.ModifyPetMode.SingleEdit then
      local state = true
      if not self.uiData.bFromShiningWeekend then
        state = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.PetTeamReplaceGetCurExChangeState)
      end
      local canSelect = false
      if state then
        canSelect = true
      else
        local isInTeam = _G.NRCModuleManager:DoCmd(PetUIModuleCmd.PetTeamReplaceGetCurSelectIsInTeam)
        if isInTeam then
          if self.uiData.PetData then
            canSelect = true
          end
        elseif self.uiData.PetData then
          canSelect = true
        elseif self.uiData.isPetListItem then
          canSelect = true
        end
      end
      if canSelect then
        self.Module:DispatchEvent(PetUIModuleEvent.PetTeamWarehouseItemSelected, self.uiData.PetData)
      end
    elseif curMode == PetUIModuleEnum.ModifyPetMode.QuickEdit then
      self.Module:DispatchEvent(PetUIModuleEvent.PetTeamFastFormationSelected, self.uiData.PetData)
    end
  end
end

function UMG_Common_ListItem_Pet1_C:OnDeactive()
  self.uiData = nil
  self.data = nil
end

function UMG_Common_ListItem_Pet1_C:OnSpawn2()
  local data = self.data
  local callbackOwner = data and data.CallbackOwner
  local onSpawnCallback = data and data.OnSpawnCallback
  if onSpawnCallback then
    tcall(callbackOwner, onSpawnCallback, data)
  end
end

function UMG_Common_ListItem_Pet1_C:PlayAnimationAndRecord(Animation)
  if not Animation or self.curAnimation == Animation then
    return
  end
  if self.curAnimation and self.curAnimation ~= Animation then
    self:StopAllAnimationsAndRecord()
  end
  if Animation == PetUIModuleEnum.CommonListItemPet1Anim.In then
    self:PlayAnimation(self.In)
  elseif Animation == PetUIModuleEnum.CommonListItemPet1Anim.Out then
    self:PlayAnimation(self.Out)
  elseif Animation == PetUIModuleEnum.CommonListItemPet1Anim.Normal then
    self:PlayAnimation(self.Normal)
  end
  self.curAnimation = Animation
end

function UMG_Common_ListItem_Pet1_C:StopAllAnimationsAndRecord()
  if self.curAnimation then
    self:StopAllAnimations()
  end
  self.curAnimation = nil
end

function UMG_Common_ListItem_Pet1_C:OnAnimationFinished(Animation)
  self.curAnimation = nil
end

function UMG_Common_ListItem_Pet1_C:IsPlayingAnimationByRecord(Animation)
  if not Animation then
    return self.curAnimation ~= nil
  else
    return self.curAnimation == Animation
  end
end

return UMG_Common_ListItem_Pet1_C
