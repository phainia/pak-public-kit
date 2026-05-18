local MagicManualUtils = require("NewRoco/Modules/System/MagicManual/MagicManualUtils")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local BattlePassModuleEvent = require("NewRoco.Modules.System.BattlePass.BattlePassModuleEvent")
local UMG_Pass_AwardItem_C = Base:Extend("UMG_Pass_AwardItem_C")

function UMG_Pass_AwardItem_C:OnConstruct()
  self.VisualItems = {}
  local VisualItem = {}
  VisualItem.icon = self.Icon
  VisualItem.text = self.Number
  VisualItem.btn = self.Button_60
  VisualItem.Parent = self.SizeBox_74
  local VisualItem1 = {}
  VisualItem1.icon = self.Icon_1
  VisualItem1.text = self.Number_1
  VisualItem1.btn = self.Button
  VisualItem1.Parent = self.SizeBox_137
  table.insert(self.VisualItems, VisualItem)
  table.insert(self.VisualItems, VisualItem1)
  _G.UpdateManager:UnRegister(self)
  _G.UpdateManager:Register(self)
  _G.NRCEventCenter:RegisterEvent("UMG_Pass_AwardItem_C", self, BattlePassModuleEvent.UpdateBattlePassInfo, self.OnUpdateBattlePassInfo)
  if self.BtnText then
    self.BtnText:SetText(LuaText.bp_task_go_ahead)
  end
end

function UMG_Pass_AwardItem_C:OnUpdateBattlePassInfo()
  if self:IsVisible() then
    self:OnItemUpdate(self.data, self.datalist, self.index)
  end
end

function UMG_Pass_AwardItem_C:OnDestruct()
  _G.UpdateManager:UnRegister(self)
  _G.NRCEventCenter:UnRegisterEvent(self, BattlePassModuleEvent.UpdateBattlePassInfo, self.OnUpdateBattlePassInfo)
end

function UMG_Pass_AwardItem_C:OnBtnPressed()
  Log.Info("UMG_Pass_AwardItem_C:OnBtnPressed", self:GetName())
  _G.NRCAudioManager:PlaySound2DAuto(41400001, "UMG_Pass_AwardItem_C:OnClickCloseBtn")
  if self:IsAnimationPlaying(self.Stamp_Out) then
    Log.Info("UMG_Pass_AwardItem_C on btn pressed animation  return ")
    return
  end
  local IsItemRewardsPanelOpen = _G.NRCModuleManager:DoCmd(_G.CommonPopUpModuleCmd.IsItemRewardsPanelOpen)
  if IsItemRewardsPanelOpen then
    Log.Info("UMG_Pass_AwardItem_C:OnBtnPressed IsItemRewardsPanelOpen return ")
    return
  end
  local id = {}
  if self.data ~= nil then
    table.insert(id, self.data.id)
  end
  _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.OnZoneTaskRewardReq, id)
end

function UMG_Pass_AwardItem_C:OnBtnTracePressed()
  _G.NRCAudioManager:PlaySound2DAuto(1078, "UMG_Pass_AwardItem_C:OnBtnTracePressed")
  if self.go_guide and self.go_guide.type and self.go_guide.type == Enum.TaskGoActionType.TGAT_UI and self.go_guide.text then
    MagicManualUtils.TaskTraceByGoGuide(self.go_guide)
  end
end

function UMG_Pass_AwardItem_C:PlayInAnimation()
  Log.Info("UMG_Pass_AwardItem_C play in animation ", self:GetName())
  self:StopAllAnimations()
  self:PlayAnimation(self.In)
end

function UMG_Pass_AwardItem_C:PlayNormalAnimation()
  Log.Info("UMG_Pass_AwardItem_C play normal animation ", self:GetName())
  if self:IsAnimationPlaying(self.Stamp_Out) then
    Log.Info("UMG_Pass_AwardItem_C play out animation  return PlayNormalAnimation")
    return
  end
  self:StopAnimation(self.Normal)
  self:PlayAnimation(self.Normal)
end

function UMG_Pass_AwardItem_C:PlayOutAnimation()
  Log.Info("UMG_Pass_AwardItem_C play out animation ", self:GetName())
  if self:IsAnimationPlaying(self.Stamp_Out) then
    Log.Info("UMG_Pass_AwardItem_C play out animation  return ")
    return
  end
  if self.FullText_2 then
    self.FullText_2:SetText("")
  end
  self:StopAllAnimations()
  self:PlayAnimation(self.Stamp_Out)
  self.Btn_Get:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_Pass_AwardItem_C:PlayStampAnimation()
  Log.Info("UMG_Pass_AwardItem_C play stamp  animation ", self:GetName())
  if self:IsAnimationPlaying(self.Stamp_Out) then
    Log.Info("UMG_Pass_AwardItem_C play stamp animation  return,is playing stamp out animation ")
    return
  end
  self:PlayAnimation(self.Stamp)
end

function UMG_Pass_AwardItem_C:PlaySelectLoopAnimation()
end

function UMG_Pass_AwardItem_C:SetThemeRes()
  _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.ChangeThemeColor, "UMG_Pass_AwardItem", self)
end

function UMG_Pass_AwardItem_C:OnItemUpdate(_data, datalist, index)
  self.SizeBox_137:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if nil == _data then
    return
  end
  if _data.conf.task_class == _G.Enum.TaskClassType.TCT_BP_REPEAT then
    self.Time:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.Time:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.SizeBox_148:SetRenderOpacity(1)
  self.Btn_Get.OnPressed:Add(self, self.OnBtnPressed)
  self.Btn_Trace.OnPressed:Add(self, self.OnBtnTracePressed)
  self.Button_60.OnPressed:Add(self, self.ShowTips1)
  self.Button.OnPressed:Add(self, self.ShowTips2)
  self.BattlePassInfo = _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.GetCurrentBattlePassInfo)
  self.data = _data
  self.index = index
  self.taskConf = self.data.conf
  local taskType = self.data.conf.task_class
  if taskType == _G.Enum.TaskClassType.TCT_BP then
    self.Dot:SetupKey(141, self.data.id)
  elseif taskType == _G.Enum.TaskClassType.TCT_BP_REPEAT or taskType == _G.Enum.TaskClassType.TCT_BP_ROUTINE then
    self.Dot:SetupKey(144, self.data.id)
  else
    self.Dot:SetupKey(141, self.data.id)
  end
  local glbCfg = _G.DataConfigManager:GetPaymentGlobalConfig("max_bp_exp_per_week")
  local maxWeekExp = 0
  if glbCfg then
    maxWeekExp = glbCfg.num
  end
  local isMaxWeekExp = maxWeekExp <= self.BattlePassInfo.exp_info.last_week_exp
  local passConf = _G.DataConfigManager:GetBattlePassConf(self.BattlePassInfo.battle_pass_id)
  local isMaxLevel = passConf and self.BattlePassInfo.exp_info.level >= passConf.top_level
  self:SetThemeRes()
  self.Btn_Get:SetIsEnabled(true)
  self.Switcher_1:SetActiveWidgetIndex(0)
  self.Mask2:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.data.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_OPEN then
    self.go_guide = nil
    for i, v in pairs(self.taskConf.go_guide) do
      if v.type and v.type == Enum.TaskGoActionType.TGAT_UI and v.text then
        self.go_guide = v
      end
    end
    if self.go_guide and self.go_guide.type and self.go_guide.type == Enum.TaskGoActionType.TGAT_UI and self.go_guide.text then
      self.Switcher_1:SetActiveWidgetIndex(2)
    else
      self.Switcher_1:SetActiveWidgetIndex(0)
    end
  elseif self.data.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
    self.Switcher_1:SetActiveWidgetIndex(1)
  elseif self.data.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
    self.Btn_Get:SetIsEnabled(false)
    self.Done_1:SetVisibility(UE4.ESlateVisibility.Visible)
    local reason = _G.Enum.RedPointReason.RPR_BATTLE_PASS_NEW_TASK
    _G.NRCModuleManager:DoCmd(_G.RedPointModuleCmd.EraseRedPointWithReason, reason, tostring(self.data.id))
    self.Mask2:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.Switcher_1:SetActiveWidgetIndex(0)
  end
  local condition = self.taskConf.task_condition[1]
  local conten_str = condition.text
  local num = condition.count
  local rewardConf
  if 0 ~= self.taskConf.Reward then
    rewardConf = _G.DataConfigManager:GetRewardConf(self.taskConf.Reward)
  end
  self.goods = {}
  self.Schedule_Number:SetText(string.format("%s/%s", self.data.task_target_list[1], num))
  self.Title:SetText(self.taskConf.name)
  self.ContentText:SetText(conten_str)
  if rewardConf then
    self.goods = rewardConf.RewardItem
    for i = 1, #self.VisualItems do
      local item = self.VisualItems[i]
      if i > #self.goods then
        item.Parent:SetVisibility(UE4.ESlateVisibility.Collapsed)
      else
        local data = self.goods[i]
        item.Parent:SetVisibility(UE4.ESlateVisibility.Visible)
        local iconPath = self:GetItemIconPath(data)
        item.icon:SetPath(iconPath)
        item.text:SetText(data.Count)
        if data.type == _G.Enum.GoodsType.GT_VITEM and data.id == _G.Enum.VisualItem.VI_BP_PK_POINTS then
          item.text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("46433BFF"))
        elseif (isMaxWeekExp or isMaxLevel) and data.type == _G.Enum.GoodsType.GT_VITEM and data.id == _G.Enum.VisualItem.VI_BP_EXP then
          item.text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("46433BFF"))
        else
          item.text:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("f4eee1"))
        end
      end
    end
  end
end

function UMG_Pass_AwardItem_C:FormatCountdown(seconds)
  if seconds >= 86400 then
    local days = math.floor(seconds / 86400)
    local hours = math.floor(seconds % 86400 / 3600)
    return string.format(LuaText.activity_RTS1, days, hours)
  elseif seconds >= 3600 then
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor(seconds % 3600 / 60)
    return string.format(LuaText.activity_RTS2, hours, minutes)
  elseif seconds >= 60 then
    local minutes = math.floor(seconds / 60)
    return string.format(LuaText.activity_RTS2, 0, minutes)
  else
    return LuaText.activity_RTS3
  end
end

function UMG_Pass_AwardItem_C:OnTick(InDeltaTime)
  if not self.CountdownTime or self.CountdownTime <= 0 then
    _G.UpdateManager:UnRegister(self)
  else
    self.CountdownTime = self.CountdownTime - InDeltaTime
    local timeStr = self:FormatCountdown(self.CountdownTime)
    self.TextTime:SetText(timeStr)
  end
end

function UMG_Pass_AwardItem_C:ShowTips(item)
  local pos = UE4.FVector2D(0, 0)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1004, "UMG_CampingTemplate_C:OnItemSelected")
  if item.Type == _G.Enum.GoodsType.GT_BAGITEM then
    local Itemdata = _G.DataConfigManager:GetBagItemConf(item.Id)
    if Itemdata.lable_type == _G.Enum.ItemLableType.ILT_SKILL_MACHINE then
      local skillMachineid = Itemdata.item_behavior[1].ratio[1]
      _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetSKillTips, skillMachineid, true, Itemdata.id)
    else
      _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, item.Id, item.Type, false, 0, 0, true, pos)
    end
  elseif self.data.Type == _G.Enum.GoodsType.GT_PET then
    local pet_id = item.Id
    local pet_conf = _G.DataConfigManager:GetPetConf(pet_id)
    local param = {
      petbaseId = pet_conf.base_id,
      needBlur = false,
      notAcquired = false,
      isSketch = true
    }
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.Tips_OpenMagicDetailTips, param)
  else
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, item.Id, item.Type, false, 0, 0, false, pos)
  end
end

function UMG_Pass_AwardItem_C:ShowTips1()
  if 0 == #self.goods then
    return
  end
  local item = self.goods[1]
  self:ShowTips(item)
end

function UMG_Pass_AwardItem_C:ShowTips2()
  if 0 == #self.goods then
    return
  end
  local item = self.goods[2]
  self:ShowTips(item)
end

function UMG_Pass_AwardItem_C:OnItemSelected(_bSelected)
end

function UMG_Pass_AwardItem_C:OnDeactive()
  _G.UpdateManager:UnRegister(self)
end

function UMG_Pass_AwardItem_C:GetItemIconPath(reward)
  local itemId = reward.Id
  local iconPath = ""
  if reward.Type == _G.Enum.GoodsType.GT_VITEM then
    local vItemConf = _G.DataConfigManager:GetVisualItemConf(itemId)
    if nil ~= vItemConf then
      iconPath = vItemConf.bigIcon
    end
  elseif reward.Type == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(itemId)
    if nil ~= bagItemConf then
      iconPath = bagItemConf.icon
    end
  elseif reward.Type == _G.Enum.GoodsType.GT_PET then
    local petInfo = _G.DataConfigManager:GetPetConf(itemId)
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petInfo.base_id)
    if nil ~= petBaseConf then
      local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
      iconPath = modelConf.icon
    end
  end
  return iconPath
end

function UMG_Pass_AwardItem_C:OnAnimationFinished(anim)
  if anim == self.Stamp_Out then
    _G.UpdateManager:UnRegister(self)
    if self.data and self.data.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
      self:PlayStampAnimation()
    end
  elseif not (anim == self.In and self.data) or self.data.state == _G.ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
  end
end

function UMG_Pass_AwardItem_C:OnSwitcherSwitcher_1(SwitcherIndex)
  self.Switcher_1:SetActiveWidgetIndex(SwitcherIndex)
end

function UMG_Pass_AwardItem_C:OnSwitcherSwitcher(SwitcherIndex)
  self.Switcher:SetActiveWidgetIndex(SwitcherIndex)
end

return UMG_Pass_AwardItem_C
