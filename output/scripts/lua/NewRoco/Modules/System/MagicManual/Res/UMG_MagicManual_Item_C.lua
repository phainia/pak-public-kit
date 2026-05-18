local MagicManualUtils = require("NewRoco/Modules/System/MagicManual/MagicManualUtils")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local MagicManualModuleEvent = require("NewRoco.Modules.System.MagicManual.MagicManualModuleEvent")
local UMG_MagicManual_Item_C = Base:Extend("UMG_MagicManual_Item_C")
local BaseBgColor = "DED6BDFF"

function UMG_MagicManual_Item_C:OnConstruct()
  self.Describe.OnRichTextClick:Add(self, self.ShowDescRightPanel)
  self.Btn.btnLevelUp.OnClicked:Add(self, self.OnBtnPressed)
  self.Btn_1.btnLevelUp.OnClicked:Add(self, self.OnBtnTracePressed)
end

function UMG_MagicManual_Item_C:OnDestruct()
  self:CancelAllDelay()
end

function UMG_MagicManual_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self.parent = _data.parent
  if _data.RedPointKey then
    self.Dot:SetupKey(_data.RedPointKey, {
      _data.PlayerTaskInfo.id
    })
  else
    self.Dot:SetupKey(161, {
      _data.PlayerTaskInfo.id
    })
  end
  if self.Image_bg then
    if _data.ThemeColor and _data.ThemeColor ~= "" then
      self.Image_bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(_data.ThemeColor))
    else
      self.Image_bg:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(BaseBgColor))
    end
  end
  self:SetInfo()
end

function UMG_MagicManual_Item_C:OnAnimationStarted(anim)
  if anim == self.In then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_MagicManual_Item_C:ShowDescRightPanel(id)
  _G.NRCModuleManager:DoCmd(MagicManualModuleCmd.ShowMagicManualDescTips, id)
end

function UMG_MagicManual_Item_C:SetBtnCanClick()
  if self.Btn_1 and self.Btn_1.btnLevelUp then
    self.Btn_1.btnLevelUp:SetIsEnabled(true)
  end
end

function UMG_MagicManual_Item_C:SetInfo()
  local data = self.data
  self.taskConf = _G.DataConfigManager:GetTaskConf(self.data.PlayerTaskInfo.id)
  if self.data.IsHide then
    self.Describe_1:SetText(string.format("?/?"))
  elseif self.data.PlayerTaskInfo.state == ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
    if self.data.PlayerTaskInfo.task_target_list then
      local condition = self.taskConf.task_condition[1]
      local num = condition.count
      self.Describe_1:SetText(string.format("%s/%s", num, num))
    end
  elseif self.data.PlayerTaskInfo.task_target_list then
    local condition = self.taskConf.task_condition[1]
    local num = condition.count
    self.Describe_1:SetText(string.format("%s/%s", self.data.PlayerTaskInfo.task_target_list[1], num))
  end
  self:SetSortText()
  local TypeText = ""
  if data.TaskConf.task_class == Enum.TaskClassType.TCT_ADVENTURE_CORE then
    TypeText = LuaText.magic_manual_task_type1
  elseif data.TaskConf.task_class == Enum.TaskClassType.TCT_ADVENTURE_ELECTIVE then
    TypeText = LuaText.magic_manual_task_type2
  elseif data.TaskConf.task_class == Enum.TaskClassType.TCT_ADVENTURE_CHALLENGE then
    TypeText = LuaText.magic_manual_task_type3
  elseif data.TaskConf.task_class == Enum.TaskClassType.TCT_SADV_CHALLENGE then
    TypeText = LuaText.season_manual_task_type2
  elseif data.TaskConf.task_class == Enum.TaskClassType.TCT_SADV_NORMAL then
    TypeText = LuaText.season_manual_task_type1
  end
  self.BG_xingxing:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.BG_xingxing_get:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ParticleSystemWidget:SetActivate(false)
  self.ParticleSystemWidget:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.data.IsHide then
    self.Describe:SetText(string.format("%s%s", TypeText, "???"))
  else
    self.Describe:SetText(string.format("%s%s", TypeText, data.TaskConf.name))
  end
  if self.data.IsHide then
    self.Switcher:SetActiveWidgetIndex(5)
    self.NRCSwitcher_0:SetActiveWidgetIndex(1)
    self.Btn2:SetShowLockIcon(true)
    self.Btn2.HideAnim = true
    self.Btn2:SetBtnText(LuaText.challenge_text_42)
    if data.TaskConf.task_class == Enum.TaskClassType.TCT_ADVENTURE_CORE then
      self.LockDescribe:SetText(string.format(LuaText.magic_manual_hide_task, self.data.DoneTaskNum, self.data.NeedUnlockNum))
    elseif data.TaskConf.task_class == Enum.TaskClassType.TCT_ADVENTURE_ELECTIVE then
      self.LockDescribe:SetText(string.format(LuaText.magic_manual_hide_task02, self.data.DoneTaskNum, self.data.NeedUnlockNum))
    elseif data.TaskConf.task_class == Enum.TaskClassType.TCT_SADV_NORMAL then
      local tempStr = string.format("%d/%d", self.data.DoneTaskNum, self.data.NeedUnlockNum)
      self.LockDescribe:SetText(string.format(LuaText.magic_manual_season_chapter_unlock_tips, tempStr))
    end
  else
    self:SetRewardList()
    self.NRCSwitcher_0:SetActiveWidgetIndex(0)
    if data.PlayerTaskInfo and data.PlayerTaskInfo.state == ProtoEnum.EMTaskState.EM_TASK_STATE_OPEN then
      self.go_guide = nil
      for i, v in pairs(self.taskConf.go_guide) do
        if v.type and v.type == Enum.TaskGoActionType.TGAT_UI and v.text then
          self.go_guide = v
        end
      end
      if self.go_guide and self.go_guide.type and self.go_guide.type == Enum.TaskGoActionType.TGAT_UI and self.go_guide.text then
        self.Switcher:SetActiveWidgetIndex(4)
      else
        self.Switcher:SetActiveWidgetIndex(1)
      end
    elseif data.PlayerTaskInfo and data.PlayerTaskInfo.state == ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
      self.Switcher:SetActiveWidgetIndex(0)
    elseif data.PlayerTaskInfo and data.PlayerTaskInfo.state == ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
      self.Switcher:SetActiveWidgetIndex(2)
    else
      self.Switcher:SetActiveWidgetIndex(0)
    end
  end
end

function UMG_MagicManual_Item_C:SetSortText()
end

function UMG_MagicManual_Item_C:OnBgMouseButtonDown(MyGeometry, InTouchEvent)
  _G.NRCModuleManager:DoCmd(MagicManualModuleCmd.ShowMagicManualDescTips)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_MagicManual_Item_C:SetRewardList()
  local RewardId = self.data.TaskConf.Reward
  if not RewardId or 0 == RewardId then
    self.List_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  else
    self.List_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  local RewardList = {}
  local RewardConf = _G.DataConfigManager:GetRewardConf(RewardId)
  local RewardItem = RewardConf.RewardItem
  for i, _RewardConf in ipairs(RewardItem) do
    if (_RewardConf.Type ~= _G.Enum.GoodsType.GT_CARD_ICON or _RewardConf.Type ~= _G.Enum.Enum.GoodsType.GT_CARD_SKIN or _RewardConf.Type ~= _G.Enum.Enum.GoodsType.GT_CARD_LABEL) and _RewardConf.Type ~= _G.Enum.GoodsType.GT_REWARD then
      table.insert(RewardList, {
        RewardConf = _RewardConf,
        state = self.data.PlayerTaskInfo.state
      })
    end
  end
  local rewardsTable = {}
  for k, v in ipairs(RewardList) do
    local rewards = _G.NRCCommonItemIconData()
    rewards.itemType = v.RewardConf.Type
    rewards.itemId = v.RewardConf.Id
    rewards.itemNum = v.RewardConf.Count
    rewards.bShowNum = true
    rewards.bShowTip = true
    if v.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
      rewards.bShowGetTag = true
    else
      rewards.bShowGetTag = false
    end
    table.insert(rewardsTable, rewards)
  end
  self.List_1:InitGridView(rewardsTable)
end

function UMG_MagicManual_Item_C:OnBtnPressed()
  self.Switcher:SetActiveWidgetIndex(2)
  self:PlayAnimation(self.Anim_get)
  local id = {}
  if self.data ~= nil then
    table.insert(id, self.data.PlayerTaskInfo.id)
  end
  _G.NRCModuleManager:DoCmd(_G.MagicManualModuleCmd.OnZoneTaskRewardReq, id, self.index)
end

function UMG_MagicManual_Item_C:OnBtnTracePressed()
  self.Btn_1.btnLevelUp:SetIsEnabled(false)
  self:CancelAllDelay()
  self.Handler = _G.DelayManager:DelaySeconds(0.1, function()
    self.Btn_1.btnLevelUp:SetIsEnabled(true)
  end)
  _G.NRCModuleManager:DoCmd(_G.MagicManualModuleCmd.SetMagicManualCanNotClick)
  _G.NRCAudioManager:PlaySound2DAuto(1220002025, "UMG_MagicManual_Item_C:OnBtnPressed")
  MagicManualUtils.TaskTraceByGoGuide(self.go_guide)
end

function UMG_MagicManual_Item_C:CancelAllDelay()
  if self.Handler then
    _G.DelayManager:CancelDelayById(self.Handler)
    self.Handler = nil
  end
end

function UMG_MagicManual_Item_C:SetCompleteIcon(_BgPath)
  if nil == _BgPath then
    return
  else
    local BgPath = _BgPath
    self.NRCImage_GotIcon:SetPath(BgPath)
  end
end

function UMG_MagicManual_Item_C:OnAnimationFinished(anim)
  if anim == self.Get_press then
    self:PlayAnimation(self.Get_up)
  end
  if anim == self.Get_up then
  end
  if anim == self.In and self.Dot and UE.UObject.IsValid(self.Dot) and self.Dot:IsRed() then
    local red = self.Dot.RedPointNode:GetChildAt(0)
    if red and red.PlayAnimation then
      red:PlayAnimation(red.Loop)
    end
  end
end

function UMG_MagicManual_Item_C:PlayGetRewardAnim()
end

function UMG_MagicManual_Item_C:OnDeactive()
end

return UMG_MagicManual_Item_C
