local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local UMG_Activity_AbuBadge_C = Base:Extend("UMG_Activity_AbuBadge_C")
local PetUtils = require("NewRoco.Utils.PetUtils")

function UMG_Activity_AbuBadge_C:BindUIElements()
  local uiElements = {}
  uiElements.desireActivityType = Enum.ActivityType.ATP_TRACK_CONDITION
  uiElements.title = self.Text_Title
  uiElements.promptText = self.Text_Describe
  uiElements.particularsBtn = self.ParticularsBtn
  uiElements.openAnimName = "In"
  uiElements.changeAnimName = "In"
  uiElements.loopAnimName = "Loop"
  return uiElements
end

function UMG_Activity_AbuBadge_C:OnAddEventListener()
  self:AddButtonListener(self.Btn_Claimable.btnLevelUp, self.OnTraceBtnClick)
  self:AddButtonListener(self.ExamineBtn, self.OpenPetPanel)
end

function UMG_Activity_AbuBadge_C:OnConstruct()
  Base.OnConstruct(self)
  self:OnAddEventListener()
  self.Btn_Claimable:SetBtnText(self.activityInst:GetBtnText())
  self:RegisterEvent(self, ActivityModuleEvent.TrackConditionRewardItemProgressChange, self.OnTrackConditionRewardItemProgressChange)
end

function UMG_Activity_AbuBadge_C:OnEnable(firstLoad)
  Base.OnEnable(self, firstLoad)
  if self.activityInst then
    self.IsLotteryOpen = self.activityInst:IsLotteryTimeOpen()
    self:RefreshView()
  end
end

function UMG_Activity_AbuBadge_C:RefreshView()
  local activityInst = self.activityInst
  local petBaseId = activityInst:GetPetBaseId()
  if petBaseId and 0 ~= petBaseId then
    local petBaseData = _G.DataConfigManager:GetPetbaseConf(petBaseId)
    self.Name:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TextName:SetText(petBaseData and petBaseData.name or "")
    self.Attr:InitGridView(ActivityUtils.CreatePetCommonAttrListData(petBaseData and petBaseData.unit_type, nil, nil, PetUtils.CreateFakePetData(petBaseId)))
    local objMap = activityInst:GetItemObjectMap()
    local datas = {}
    for _key, _value in pairs(objMap) do
      table.insert(datas, _value)
    end
    table.sort(datas, function(a, b)
      return a:GetRewardItemId() < b:GetRewardItemId()
    end)
    self.List:InitGridView(ActivityUtils.CreateActivityItemBaseDataForList(self, datas))
  else
    self.Name:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.Text_DrawDate:SetText(activityInst:GetLotteryCloseText())
  if self.IsLotteryOpen then
    self.CanvasPanel_Btn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Text_DrawDate:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.CanvasPanel_Btn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Text_DrawDate:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  local lotteryState = activityInst:GetLotteryState()
  if 10001 == lotteryState then
    self.NRCSwitcher_47:SetActiveWidgetIndex(2)
  elseif 10002 == lotteryState then
    self.NRCSwitcher_47:SetActiveWidgetIndex(1)
  else
    self.NRCSwitcher_47:SetActiveWidgetIndex(0)
  end
  self.Btn_Claimable.RedDot:SetupKey(420, {
    activityInst:GetActivityId()
  })
end

function UMG_Activity_AbuBadge_C:OnDestruct()
  Base.OnDestruct(self)
  self:RemoveAllButtonListener()
  self:UnRegisterEvent(self, ActivityModuleEvent.TrackConditionRewardItemProgressChange)
end

function UMG_Activity_AbuBadge_C:OnTrackConditionRewardItemProgressChange(_activityInst, _rewardItemObj)
  if _activityInst and _activityInst == self.activityInst then
    local itemIndex = self:GetRewardItemIndexByObj(_rewardItemObj)
    self.List:OpItemByIndex(itemIndex, 0, _rewardItemObj)
  end
end

function UMG_Activity_AbuBadge_C:OpenPetPanel()
  local petBaseId = self.activityInst:GetPetBaseId()
  if petBaseId and 0 ~= petBaseId then
    _G.NRCAudioManager:PlaySound2DAuto(40002013, "UMG_Activity_AbuBadge_C:OpenPetPanel")
    _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.OpenPetDetailPanel, petBaseId, true)
  end
end

function UMG_Activity_AbuBadge_C:OnTraceBtnClick()
  local activityInst = self.activityInst
  if self.IsLotteryOpen then
    if activityInst:GetTrackType() == Enum.ActivityTrackType.ATKT_WORLD_MAP then
      local trackParams = activityInst:GetTrackParam()
      local worldMapConf = _G.DataConfigManager:GetWorldMapConf(trackParams)
      if worldMapConf then
        local refreshIds = worldMapConf.npc_refresh_ids
        if refreshIds and #refreshIds > 0 then
          _G.NRCModuleManager:DoCmd(BigMapModuleCmd.OpenWorldMap, {
            centerNPCRefreshId = refreshIds[1]
          })
        end
      end
      if self.Btn_Claimable.RedDot:IsRed() then
        NRCModuleManager:DoCmd(RedPointModuleCmd.EraseRedPoint, 420, {
          tostring(activityInst:GetActivityId())
        })
      end
      _G.NRCAudioManager:PlaySound2DAuto(40008005, "UMG_Activity_AbuBadge_C:OnTraceBtnClick")
    end
  else
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.activity_abu_lotterynpc_unopen_tips)
  end
end

function UMG_Activity_AbuBadge_C:GetRewardItemIndexByObj(_rewardItemObj)
  local itemIndex = self.List:GetIndexByData(_rewardItemObj, function(_data, _valueInList)
    return _valueInList and _valueInList.customData == _data
  end)
  return itemIndex
end

return UMG_Activity_AbuBadge_C
