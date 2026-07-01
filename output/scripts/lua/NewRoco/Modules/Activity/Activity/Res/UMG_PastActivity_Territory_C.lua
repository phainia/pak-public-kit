local UMG_PastActivity_Territory_C = _G.NRCPanelBase:Extend("UMG_PastActivity_Territory_C")
local PetUIModuleEnum = require("NewRoco.Modules.System.PetUI.PetUIModuleEnum")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")

function UMG_PastActivity_Territory_C:OnConstruct()
  local titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName(), true)
  if titleConf then
    self.Title1:Set_MainTitle(titleConf.title)
    self.Title1:SetBg(titleConf.head_icon)
    self.Title1:SetSubtitle(titleConf.subtitle[1].subtitle)
  end
end

function UMG_PastActivity_Territory_C:OnActive(pastData, cur_activity_id)
  self.cur_activity_id = cur_activity_id
  local initData = {}
  for _, v in ipairs(pastData) do
    local data = {}
    local base_id = v.base_id
    local territoryTrialConf = _G.DataConfigManager:GetTerritoryTrialConf(base_id)
    local challenge_id = territoryTrialConf.challenge_id[1]
    local boss_id = _G.DataConfigManager:GetTerritoryTrialChallengeConf(challenge_id).boss
    data.petBaseId = _G.DataConfigManager:GetMonsterConf(boss_id).base_id
    data.activityId = v.activity_conf_id
    data.baseId = base_id
    data.bCompleted = v.has_token
    table.insert(initData, data)
  end
  table.stableSort(initData, function(a, b)
    if a.bCompleted == b.bCompleted then
      return a.baseId < b.baseId
    else
      return b.bCompleted
    end
  end)
  self.initData = initData
  self.listData = initData
  self.List:InitList(initData)
  self.List:SetMsgHandler({
    OnItemSelected = _G.MakeWeakFunctor(self, self.OnItemSelected)
  })
  self.List:SelectItemByIndex(0)
  self.AlreadyObtained:SetShowLockIcon(false)
  self.AlreadyObtained:SetTitleTextAndIcon()
  self:OnAddEventListener()
end

function UMG_PastActivity_Territory_C:OnAddEventListener()
  self:AddButtonListener(self.btnClose.btnClose, self.ClosePanel)
  self:AddButtonListener(self.Exchange.btnLevelUp, self.TryGetToken)
  self:AddButtonListener(self.ParticularsBtn_1.btnLevelUp, self.OpenFilterPanel)
  _G.NRCEventCenter:RegisterEvent("UMG_PastActivity_Territory_C", self, PetUIModuleEvent.FilterPet, self.RefreshByChooseType)
end

function UMG_PastActivity_Territory_C:OnRemoveEventListener()
  self:RemoveButtonListener(self.btnClose.btnClose)
  self:RemoveButtonListener(self.Exchange.btnLevelUp)
  self:RemoveButtonListener(self.ParticularsBtn_1.btnLevelUp)
  _G.NRCEventCenter:UnRegisterEvent(self, PetUIModuleEvent.FilterPet, self.RefreshByChooseType)
end

function UMG_PastActivity_Territory_C:OnItemSelected(index)
  if not self:IsAnimationPlaying(self.In) then
    self:StopAllAnimations()
    self:PlayAnimation(self.switchover)
  end
  self.index = index
  local activityData = self.listData[index]
  self.curPet = activityData.petBaseId
  local territoryTrialConf = _G.DataConfigManager:GetTerritoryTrialConf(activityData.baseId)
  local token_id = territoryTrialConf.token
  local tokenConf = _G.DataConfigManager:GetBagItemConf(token_id)
  self.TextName:SetText(tokenConf.name)
  self.TextDescribe:SetText(tokenConf.description)
  self.icon:SetPath(tokenConf.big_icon)
  self.Attr:InitGridView(_G.DataConfigManager:GetPetbaseConf(activityData.petBaseId).unit_type)
  local bagItem = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetBagItemByID, territoryTrialConf.token_exchange_item)
  local moneyNum = bagItem and bagItem.num or 0
  local moneyIcon = _G.DataConfigManager:GetBagItemConf(territoryTrialConf.token_exchange_item).icon
  self.PetalMoney:SetInfo(territoryTrialConf.token_exchange_item, moneyNum)
  if activityData.bCompleted then
    self.Switcher_Btn:SetActiveWidgetIndex(1)
  else
    self.Switcher_Btn:SetActiveWidgetIndex(0)
    self.Exchange:SetTitleTextAndIcon(moneyIcon, territoryTrialConf.token_cost)
    if moneyNum < territoryTrialConf.token_cost then
      self.Exchange:SetQuantityTextColor("AF3D3EFF")
    end
  end
end

function UMG_PastActivity_Territory_C:TryGetToken()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_PastActivity_Territory_C:TryGetToken")
  local activityData = self.listData[self.index]
  local territoryTrialConf = _G.DataConfigManager:GetTerritoryTrialConf(activityData.baseId)
  local bagItem = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetBagItemByID, territoryTrialConf.token_exchange_item)
  local moneyNum = bagItem and bagItem.num or 0
  if moneyNum >= territoryTrialConf.token_cost then
    local initData = _G.NRCCommonPopUpData()
    initData.Call = self
    initData.Btn_LeftText = _G.LuaText.general_cancel
    initData.Btn_RightText = _G.LuaText.general_confirm
    initData.TitleText = _G.LuaText.general_title
    local token_id = territoryTrialConf.token
    local tokenConf = _G.DataConfigManager:GetBagItemConf(token_id)
    initData.ContentText = string.safeFormat(_G.LuaText.territory_trial_token_exchange_confirm, tokenConf.name)
    initData.Btn_RightHandler = self.ReqGetToken
    _G.NRCModuleManager:DoCmd(_G.CommonPopUpModuleCmd.OpenRemindPanel, initData)
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.territory_trial_token_exchange_missing)
  end
end

function UMG_PastActivity_Territory_C:ReqGetToken()
  if not self.req_activity_id then
    local req = _G.ProtoMessage:newZoneActivityCommonRewardsReq()
    local activityData = self.listData[self.index]
    req.activity_id = self.cur_activity_id
    self.req_activity_id = activityData.activityId
    req.activity_sub_id = _G.DataConfigManager:GetActivityConf(self.cur_activity_id).base_id[1]
    req.params = {
      activityData.baseId
    }
    self.ResetTimer = _G.DelayManager:DelaySeconds(3, function()
      self.req_activity_id = nil
      self.ResetTimer = nil
    end)
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_ACTIVITY_COMMON_REWARDS_REQ, req, self, self.OnGetToken)
  end
end

function UMG_PastActivity_Territory_C:OnGetToken(rsp)
  if 0 == rsp.ret_info.ret_code then
    local activityData
    for _, v in ipairs(self.listData) do
      if v.activityId == self.req_activity_id then
        activityData = v
        break
      end
    end
    if activityData then
      activityData.bCompleted = true
      local popupInitData = {
        {
          id = _G.DataConfigManager:GetTerritoryTrialConf(activityData.baseId).token,
          num = 1,
          type = _G.Enum.GoodsType.GT_BAGITEM
        }
      }
      _G.NRCModuleManager:DoCmd(_G.CommonPopUpModuleCmd.OpenNPCShopItemRewardsPanel, popupInitData)
    end
    table.stableSort(self.listData, function(a, b)
      if a.bCompleted == b.bCompleted then
        return a.baseId < b.baseId
      else
        return b.bCompleted
      end
    end)
    self.List:InitList(self.listData, true)
    self.List:SelectItemByIndex(0)
  end
  self.req_activity_id = nil
  if self.ResetTimer then
    _G.DelayManager:CancelDelay(self.ResetTimer)
    self.ResetTimer = nil
  end
end

function UMG_PastActivity_Territory_C:OpenFilterPanel()
  _G.NRCAudioManager:PlaySound2DAuto(40002003, "UMG_PastActivity_Territory_C:OpenFilterPanel")
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenFilterPanel, PetUIModuleEnum.OpenSortType.TerritoryTrial, {
    HiddenFilterEnum = {
      1,
      2,
      3,
      4,
      5,
      6,
      7
    }
  })
end

function UMG_PastActivity_Territory_C:RefreshByChooseType(TypeChooseList)
  local DepartmentFilter = {}
  if TypeChooseList.DepartmentFilter then
    for _, v in ipairs(TypeChooseList.DepartmentFilter) do
      if v.data.filter_enum_name and v.data.filter_enum_value and _G.Enum[v.data.filter_enum_name] and _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value] then
        local enum = _G.Enum[v.data.filter_enum_name][v.data.filter_enum_value]
        table.insert(DepartmentFilter, enum)
      end
    end
  end
  if #DepartmentFilter > 0 then
    self.ParticularsBtn_1:ChangeIconSelectState(2)
    self.listData = {}
    for _, v in ipairs(self.initData) do
      local unit_type = _G.DataConfigManager:GetPetbaseConf(v.petBaseId).unit_type
      for _, type in ipairs(unit_type) do
        for _, enum in ipairs(DepartmentFilter) do
          if type == enum then
            local bNew = true
            for _, data in ipairs(self.listData) do
              if data.baseId == v.baseId then
                bNew = false
                break
              end
            end
            if bNew then
              table.insert(self.listData, v)
            end
          end
        end
      end
    end
  else
    self.ParticularsBtn_1:ChangeIconSelectState(1)
    self.listData = self.initData
  end
  table.stableSort(self.listData, function(a, b)
    if a.bCompleted == b.bCompleted then
      return a.baseId < b.baseId
    else
      return b.bCompleted
    end
  end)
  self.List:InitList(self.listData)
  if #self.listData > 0 then
    local selectIndex = 0
    for i, v in ipairs(self.listData) do
      if v.petBaseId == self.curPet then
        selectIndex = i - 1
        break
      end
    end
    self.List:SelectItemByIndex(selectIndex)
    self.RewardInformation:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRCSwitcher_96:SetActiveWidgetIndex(0)
  else
    self.RewardInformation:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.NRCSwitcher_96:SetActiveWidgetIndex(1)
  end
end

function UMG_PastActivity_Territory_C:ClosePanel()
  _G.NRCAudioManager:PlaySound2DAuto(41401014, "UMG_PastActivity_Territory_C:ClosePanel")
  self:StopAllAnimations()
  self:OnClose()
end

function UMG_PastActivity_Territory_C:OnDeactive()
  if self.ResetTimer then
    _G.DelayManager:CancelDelay(self.ResetTimer)
    self.ResetTimer = nil
  end
  self:OnRemoveEventListener()
  local PetUIModuleData = _G.NRCModuleManager:GetModule("PetUIModule"):GetData()
  PetUIModuleData.chooseTypeListTerritoryTrial = {
    DepartmentFilter = {},
    TalentFilter = {},
    NaturePositiveEffectFilter = {},
    AttributeFilter = {},
    PartnerMarkerFilter = {},
    SpecialityFilter = {}
  }
end

return UMG_PastActivity_Territory_C
