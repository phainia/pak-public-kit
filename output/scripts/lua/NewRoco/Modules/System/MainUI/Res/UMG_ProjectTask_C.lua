local TipsDisplayExecutor = require("NewRoco.Modules.System.TipsModule.TipsDisplayExecutor")
local TipEnum = require("NewRoco.Modules.System.TipsModule.Utils.TipEnum")
local UMG_ProjectTask_C = _G.NRCViewBase:Extend("UMG_ProjectTask_C")

local function GetTipsListDataSortIndexDic(tipList)
  local sortDic = {}
  for i = 1, #tipList do
    if not sortDic[tipList[i].customData.handbook_id] then
      sortDic[tipList[i].customData.handbook_id] = i + 1
    end
  end
  return sortDic
end

function UMG_ProjectTask_C:OnConstruct()
  self.schedules = {
    self.Schedule_5,
    self.Schedule_4,
    self.Schedule_3,
    self.Schedule_2,
    self.Schedule_1,
    self.Schedule
  }
  for _, _schedule in ipairs(self.schedules) do
    if _schedule then
      _schedule:SetShowHide(false)
    end
  end
  self.tipDisplayExecutor = TipsDisplayExecutor():Attach(self, self.OnPlayTips, nil, self.OnAllTipsFinished, self.OnTipDisplayStatusChangeHandler)
  if self.tipDisplayExecutor then
    self.tipDisplayExecutor:StartTipDispatchStateListener()
  end
  self.TaskItems = {}
  self:AddButtonListener(self.Btn_SkipGuide, self.OnBtnClickJump)
end

function UMG_ProjectTask_C:OnDestruct()
  if self.tipDisplayExecutor then
    self.tipDisplayExecutor:Free()
  end
end

function UMG_ProjectTask_C:OnActive()
  if self.tipDisplayExecutor then
    self.tipDisplayExecutor:Resume()
  end
end

function UMG_ProjectTask_C:OnDeactive()
  if self.tipDisplayExecutor then
    self.tipDisplayExecutor:Pause()
  end
end

function UMG_ProjectTask_C:AddNew(_data)
  if self.tipDisplayExecutor then
    self.tipDisplayExecutor:AddDisplayTip(_data)
    local tipList = self.tipDisplayExecutor.tipList
    if #tipList > 1 then
      local sortDic = GetTipsListDataSortIndexDic(tipList)
      table.sort(tipList, function(a, b)
        return sortDic[a.customData.handbook_id] < sortDic[b.customData.handbook_id]
      end)
    end
  end
end

function UMG_ProjectTask_C:OnBtnClickJump()
  local isBan = _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.CheckUIFunctionBan, _G.Enum.FunctionEntrance.FE_HANDBOOK, false)
  if isBan then
    return
  end
  local isSelectBtn = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetIsSelectBtn, "MainUIModule", "LobbyMain")
  if isSelectBtn then
    return
  end
  local displayingTip = self.tipDisplayExecutor and self.tipDisplayExecutor:GetDisplayingTip()
  local handbookTopicTipData = displayingTip and displayingTip.customData
  if handbookTopicTipData then
    local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, "LobbyMain").PROJECTTASK
    _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.LockIsSelectBtn, "MainUIModule", "LobbyMain", touchReasonType)
    local petBookInfo = _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.GetPetHandBookData, handbookTopicTipData.handbook_id)
    _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.OnOpenContentView, handbookTopicTipData.handbook_id, handbookTopicTipData.petbase_id)
    _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.OpenHandbookSubjectPanel, petBookInfo, handbookTopicTipData.petbase_id)
  end
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_ProjectTask_C:OnPlayTips(tip)
  self:CancelDelayByFunc(self.OnFadeOutFinished)
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:StopAllAnimations()
  self:PlayAnimation(self.In)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(40008022, "UMG_ProjectTask_C:OnPlayTips")
  local handbookTopicTipData = tip.customData
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(handbookTopicTipData.petbase_id)
  local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
  self.Pet:SetPath(modelConf.icon)
  do
    local displayTopicList = {}
    local desc = handbookTopicTipData.topicConf and handbookTopicTipData.topicConf.topic_desc or ""
    table.insert(displayTopicList, {desc = desc, topic = handbookTopicTipData})
    self.DescribeList:InitGridView(displayTopicList)
  end
end

function UMG_ProjectTask_C:OnAllTipsFinished()
  if not self or not UE4.UObject.IsValid(self) then
    return false
  end
  self:StopAllAnimations()
  self:PlayAnimation(self.Out)
  self:DelaySeconds(0.2, self.OnFadeOutFinished, self)
  return true
end

function UMG_ProjectTask_C:OnTipDisplayStatusChangeHandler(pause)
  if pause then
    local tip = self.tipDisplayExecutor:GetDisplayingTip()
    if tip and tip.tipType == TipEnum.TipObjectType.HandbookTopic then
      self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_ProjectTask_C:OnFadeOutFinished()
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.tipDisplayExecutor then
    self.tipDisplayExecutor:UserAgreeFinish()
  end
end

function UMG_ProjectTask_C:OnAnimationFinished(anim)
  if anim == self.In then
    for i = 1, self.DescribeList:GetItemCount() do
      local taskItem = self.TaskItems[i]
      if not taskItem then
        self.TaskItems[i] = self.DescribeList:GetItemByIndex(i - 1)
        taskItem = self.TaskItems[i]
      end
      if taskItem then
        taskItem:RefreshTaskFinishCntWithAnimation()
      end
    end
  end
end

return UMG_ProjectTask_C
