local TaskEnum = require("NewRoco.Modules.Core.Battle.Common.TaskEnum")
local TaskModuleEvent = require("NewRoco.Modules.Core.Task.TaskModuleEvent")
local UMG_MagicStampPanel_C = _G.NRCPanelBase:Extend("UMG_MagicStampPanel_C")

function UMG_MagicStampPanel_C:OnConstruct()
  self.DisBoard = false
  self.IsEquipment = false
  self.TokenUseType = nil
  self.TaskTokenInfo = {}
  self.TokenInfoList = {}
  self.MedalList = {}
  self.BaDgeList = nil
  self.TabList = {
    self.QiYinTab,
    self.StampTab
  }
  self:SetChildViews(self.QiYinTab, self.StampTab)
  self.data = self.module:GetData("TaskModuleData")
  self.data:SetSelectMagicStampIndex(-1)
  self:OnAddEventListener()
end

function UMG_MagicStampPanel_C:OnDestruct()
end

function UMG_MagicStampPanel_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn, self.OnClickCloseBtn)
  self:AddButtonListener(self.Btn1.btnLevelUp, self.OnConfirmBtn)
  self:AddButtonListener(self.Btn2.btnLevelUp, self.OnDisBoardToKen)
  self:RegisterEvent(self, TaskModuleEvent.ChangeMagicStamp, self.OnChangeTaskTab)
  self:RegisterEvent(self, TaskModuleEvent.SelectBaDgeInfoEvent, self.OnSelectBaDgeInfoEvent)
end

function UMG_MagicStampPanel_C:OnActive(_TaskTokenInfo, _OpenType, TabType)
  self.TaskTokenInfo = _TaskTokenInfo
  if not self.TaskTokenInfo then
    self.TaskTokenInfo = {}
  end
  self.TabType = TabType
  self.OpenType = _OpenType
  self:MergeSameToken()
  self:SetOperationInfo()
  _G.NRCAudioManager:PlaySound2DAuto(1220002046, "UMG_Task_Gather_C:OnActive")
end

function UMG_MagicStampPanel_C:SetOperationInfo()
  if self.OpenType == TaskEnum.OpenToKenType.operation then
    local itemList = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemArrayByType, Enum.BagItemType.BI_BADGE_MAGIC)
    self.MedalList = itemList or {}
    self:SortMedalList()
  end
  local num = #self.TaskTokenInfo
  if num <= 0 then
    self.TabList[1]:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TabList[2]:OnTouchEnded()
  else
    self.TabList[1]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.TabList[1]:OnTouchEnded()
  end
end

function UMG_MagicStampPanel_C:OnChangeTaskTab(TaskTab)
  local CurItemType = self.data:GetSelectMagicStampIndex()
  for i = 1, #self.TabList do
    self.TabList[i]:RemoveSelected(CurItemType)
  end
  self.data:SetSelectMagicStampIndex(TaskTab)
  self.TabType = TaskTab
  self:SetTypeInfo()
  self:SetPanelInfo()
end

function UMG_MagicStampPanel_C:OnSelectBaDgeInfoEvent(BaDge)
  if BaDge.BagItem and BaDge.BagItem.description then
    self.ParticleSystemWidget2_26:SetActivate(true)
    self.ParticleSystemWidget2:SetActivate(true)
    self.TextCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.NRCText_42:SetText(BaDge.BagItem.description)
  elseif BaDge.task_token_id then
    local TaskToKenConf = _G.DataConfigManager:GetTaskTokenConf(BaDge.task_token_id)
    if TaskToKenConf.token_des then
      self.NRCText_42:SetText(TaskToKenConf.token_des)
      if self.OpenType == TaskEnum.OpenToKenType.operation then
        self.ParticleSystemWidget2_26:SetActivate(false)
        self.ParticleSystemWidget2:SetActivate(false)
        self.TextCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
      else
        self.ParticleSystemWidget2_26:SetActivate(true)
        self.ParticleSystemWidget2:SetActivate(true)
        self.TextCanvas:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    else
      self.TextCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.ParticleSystemWidget2_26:SetActivate(false)
      self.ParticleSystemWidget2:SetActivate(false)
    end
  else
    self.TextCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ParticleSystemWidget2_26:SetActivate(false)
    self.ParticleSystemWidget2:SetActivate(false)
  end
end

function UMG_MagicStampPanel_C:SortMedalList()
  table.sort(self.MedalList, function(a, b)
    return a.id > b.id
  end)
end

local DebugData = {
  "\233\173\148\230\179\149\230\188\134\229\141\176",
  "\233\173\148\230\179\149\229\190\189\231\171\160"
}

function UMG_MagicStampPanel_C:SetTypeInfo()
  if self.OpenType == TaskEnum.OpenToKenType.operation then
    self.CanvasPanel_0:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Btn1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Btn2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    if self.TabType == TaskEnum.MagicStampTabType.Lacquer then
      self.Title:SetText(DebugData[1])
    else
      self.Title:SetText(DebugData[2])
    end
    self.Btn1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Btn2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.TextCanvas:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_MagicStampPanel_C:SetPanelInfo()
  if self.TabType == TaskEnum.MagicStampTabType.Lacquer then
    self:RemoveLocked()
    self:SortToKenInfo()
    local num = #self.TaskTokenInfo
    local InfoList = {}
    if num < 8 then
      for i = 1, 8 do
        if self.TaskTokenInfo[i] then
          table.insert(InfoList, self.TaskTokenInfo[i])
        else
          table.insert(InfoList, {IsEmpty = true})
        end
      end
    else
      InfoList = self.TaskTokenInfo
    end
    self.ItemList:InitGridView(InfoList)
    Log.Dump(self.TokenInfoList, 3, "UMG_MagicStampPanel_C:SetPanelInfo")
    local CurrentSelectParagraphToken = _G.NRCModeManager:DoCmd(TaskModuleCmd.GetCurrentSelectParagraphToken)
    for i, TaskToKen in ipairs(self.TokenInfoList) do
      local item = self.ItemList:GetItemByIndex(i - 1)
      item:SetOpenPanelType(self.OpenType)
      if CurrentSelectParagraphToken and CurrentSelectParagraphToken.task_token_info and CurrentSelectParagraphToken.task_token_info[1].task_token_id == TaskToKen.task_token_id and CurrentSelectParagraphToken.task_token_info[1].task_token_get_time == TaskToKen.task_token_get_time then
        self.ItemList:SelectItemByIndex(i - 1)
      end
    end
  else
    self:SetMedalInfo()
  end
end

function UMG_MagicStampPanel_C:SetMedalInfo()
  self.BaDgeList = self.data:GetBaDgeList()
  self.MedalList = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemArrayByType, Enum.BagItemType.BI_BADGE_MAGIC)
  for j, Medal in ipairs(self.MedalList) do
    for i, BaDeg in ipairs(self.BaDgeList) do
      if BaDeg.BagItem and Medal.id == BaDeg.BagItem.id then
        BaDeg.IsHas = true
      end
    end
  end
  local num = #self.BaDgeList
  local InfoList = {}
  if num < 8 then
    for i = 1, 8 do
      if self.BaDgeList[i] then
        table.insert(InfoList, self.BaDgeList[i])
      else
        table.insert(InfoList, {IsEmpty = true})
      end
    end
  else
    InfoList = self.BaDgeList
  end
  self.ItemList:InitGridView(InfoList)
end

function UMG_MagicStampPanel_C:RemoveLocked()
  if self.TaskTokenInfo then
    for i = #self.TaskTokenInfo, 1, -1 do
      if self.TaskTokenInfo[i].is_locked and 0 ~= self.TaskTokenInfo[i].is_locked then
        table.remove(self.TaskTokenInfo, i)
      end
    end
  end
end

function UMG_MagicStampPanel_C:MergeSameToken()
  local TokenInfo = {}
  for i, TaskToKen in ipairs(self.TaskTokenInfo) do
    if not TokenInfo[TaskToKen.task_token_id] then
      TokenInfo[TaskToKen.task_token_id] = TaskToKen
      TokenInfo[TaskToKen.task_token_id].num = 1
    else
      TokenInfo[TaskToKen.task_token_id].num = TokenInfo[TaskToKen.task_token_id].num + 1
    end
  end
  for i, TaskToken in pairs(TokenInfo) do
    table.insert(self.TokenInfoList, TaskToken)
  end
end

function UMG_MagicStampPanel_C:SortToKenInfo()
  table.sort(self.TokenInfoList, function(a, b)
    if a.task_token_id < b.task_token_id then
      return a.task_token_id < b.task_token_id
    elseif a.task_token_id == b.task_token_id and a.task_token_get_time > b.task_token_get_time then
      return a.task_token_get_time > b.task_token_get_time
    end
  end)
end

function UMG_MagicStampPanel_C:OnDeactive()
end

function UMG_MagicStampPanel_C:OnClickCloseBtn()
  self:DoClose()
end

function UMG_MagicStampPanel_C:OnConfirmBtn()
  local SelectTokenInfo = _G.NRCModeManager:DoCmd(TaskModuleCmd.GetSelectTokenInfo)
  local CurrentSelectParagraphToken = _G.NRCModeManager:DoCmd(TaskModuleCmd.GetCurrentSelectParagraphToken)
  if not SelectTokenInfo then
    local Text = _G.DataConfigManager:GetLocalizationConf("sub_task_token_must_select").msg
    _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, Text)
    return
  end
  if SelectTokenInfo.sub_task_id and 0 ~= SelectTokenInfo.sub_task_id then
    if CurrentSelectParagraphToken and CurrentSelectParagraphToken.task_token_info and CurrentSelectParagraphToken.task_token_info[1].task_token_id == SelectTokenInfo.task_token_id and CurrentSelectParagraphToken.task_token_info[1].task_token_get_time == SelectTokenInfo.task_token_get_time then
      self:OnEquipmentToKen(true)
    else
      local TaskConf = _G.DataConfigManager:GetTaskConf(SelectTokenInfo.sub_task_id)
      self:OnEquipmentHint(TaskConf.name, self.OnEquipmentToKen)
    end
  else
    self:SetType()
    self.IsEquipment = true
    self:Finished()
  end
end

function UMG_MagicStampPanel_C:SetType()
  local CurrentSelectParagraphToken = _G.NRCModeManager:DoCmd(TaskModuleCmd.GetCurrentSelectParagraphToken)
  if CurrentSelectParagraphToken and CurrentSelectParagraphToken.task_token_info then
    self.TokenUseType = TaskEnum.ToKenUseType.Replace
  else
    self.TokenUseType = TaskEnum.ToKenUseType.Equipment
  end
end

function UMG_MagicStampPanel_C:OnEquipmentToKen(_ok)
  if _ok then
    self:SetType()
    self.IsEquipment = true
    self:Finished()
  end
end

function UMG_MagicStampPanel_C:OnEquipmentHint(name, Callback)
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local dialogContext = DialogContext()
  local Text = _G.DataConfigManager:GetLocalizationConf("sub_task_token_occupied_confirm").msg
  local TipsContent = string.format(Text, name)
  dialogContext:SetContent(TipsContent):SetMode(DialogContext.Mode.OK_CANCEL):SetButtonText(LuaText.YES, LuaText.NO):SetCloseOnCancel(true):SetCallback(self, Callback)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, dialogContext)
end

function UMG_MagicStampPanel_C:OnDisBoardToKen()
  self.DisBoard = true
  self.TokenUseType = TaskEnum.ToKenUseType.DisCharge
  self:Finished()
end

function UMG_MagicStampPanel_C:OnAnimationFinished(Animation)
  if Animation == self.Out then
    if self.DisBoard then
      _G.NRCAudioManager:PlaySound2DAuto(1220002050, "UMG_Task_Gather_C:OnActive")
      _G.NRCModeManager:DoCmd(TaskModuleCmd.DisBoardToKenInfo, self.TokenUseType)
    elseif self.IsEquipment then
      _G.NRCAudioManager:PlaySound2DAuto(1220002049, "UMG_Task_Gather_C:OnActive")
      _G.NRCModeManager:DoCmd(TaskModuleCmd.EquipmentToKenInfo, self.TokenUseType)
    else
      _G.NRCAudioManager:PlaySound2DAuto(1220002047, "UMG_Task_Gather_C:OnActive")
      _G.NRCModeManager:DoCmd(TaskModuleCmd.SelectTokenInfo, nil)
    end
    self:DoClose()
  end
end

function UMG_MagicStampPanel_C:Finished()
  if self.DisBoard then
    _G.NRCAudioManager:PlaySound2DAuto(1220002050, "UMG_Task_Gather_C:OnActive")
    _G.NRCModeManager:DoCmd(TaskModuleCmd.DisBoardToKenInfo, self.TokenUseType)
  elseif self.IsEquipment then
    _G.NRCAudioManager:PlaySound2DAuto(1220002049, "UMG_Task_Gather_C:OnActive")
    _G.NRCModeManager:DoCmd(TaskModuleCmd.EquipmentToKenInfo, self.TokenUseType)
  else
    _G.NRCAudioManager:PlaySound2DAuto(1220002047, "UMG_Task_Gather_C:OnActive")
    _G.NRCModeManager:DoCmd(TaskModuleCmd.SelectTokenInfo, nil)
  end
  self:DoClose()
end

return UMG_MagicStampPanel_C
