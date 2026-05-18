local MagicManualUtils = require("NewRoco/Modules/System/MagicManual/MagicManualUtils")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local UMG_Activity_PetSurveyItem_C = Base:Extend("UMG_Activity_PetSurveyItem_C")

function UMG_Activity_PetSurveyItem_C:OnConstruct()
  self:AddButtonListener(self.Btn6.btnLevelUp, self.BtnClick)
  self:AddButtonListener(self.TraceBtn.btnLevelUp, self.TraceBtnClick)
end

function UMG_Activity_PetSurveyItem_C:OnDestruct()
end

function UMG_Activity_PetSurveyItem_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self:SetInfo()
end

function UMG_Activity_PetSurveyItem_C:SetInfo()
  local rewardsTable = {}
  local taskConf = _G.DataConfigManager:GetTaskConf(self.uiData.task_id)
  self.taskConf = taskConf
  local RewardId = taskConf.Reward
  local rewardsGroup = _G.DataConfigManager:GetRewardConf(RewardId).RewardItem
  if rewardsGroup then
    for _, _reward in ipairs(rewardsGroup) do
      local itemData = {}
      itemData.itemType = _reward.Type
      itemData.itemId = _reward.Id
      itemData.itemNum = _reward.Count
      itemData.bShowNum = true
      itemData.bShowTip = true
      itemData.bShowGetTag = self.uiData.task_state == ProtoEnum.EMTaskState.EM_TASK_STATE_DONE
      table.insert(rewardsTable, itemData)
    end
  end
  self.Text_Describe:SetText(taskConf.name)
  self.AwardList:InitGridView(rewardsTable)
  local targetNum = taskConf.task_condition[1].count
  self.Text_quantity:SetText(self.uiData.task_target .. "/" .. targetNum)
  if not self.uiData.task_state or self.uiData.task_state < ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
    self.go_guide = nil
    for i, v in pairs(taskConf.go_guide) do
      if v.type and v.type == Enum.TaskGoActionType.TGAT_UI and v.text then
        self.go_guide = v
      end
    end
    if self.go_guide and self.go_guide.type and self.go_guide.type == Enum.TaskGoActionType.TGAT_UI and self.go_guide.text then
      self.BtnSwitcher:SetActiveWidgetIndex(2)
    else
      self.BtnSwitcher:SetActiveWidgetIndex(3)
    end
  elseif self.uiData.task_state == ProtoEnum.EMTaskState.EM_TASK_STATE_DONE then
    self.BtnSwitcher:SetActiveWidgetIndex(1)
    for i = 1, self.AwardList:GetItemCount() do
      local item = self.AwardList:GetItemByIndex(i - 1)
      item:SetAlreadyReceived(true)
    end
  elseif self.uiData.task_state == ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
    self.Btn6:SetRedDotKey(265)
    self.BtnSwitcher:SetActiveWidgetIndex(0)
  end
end

function UMG_Activity_PetSurveyItem_C:OnItemSelected(_bSelected)
end

function UMG_Activity_PetSurveyItem_C:OnDeactive()
end

function UMG_Activity_PetSurveyItem_C:BtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_Activity_PetSurveyItem_C:BtnClick")
  if self.uiData.task_state == ProtoEnum.EMTaskState.EM_TASK_STATE_WAIT then
    if self.uiData.IsActivityExpired then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.Error_Code_2235)
      return
    end
    self:ZoneTaskRewardReq({
      self.uiData.task_id
    })
  end
end

function UMG_Activity_PetSurveyItem_C:TraceBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(40002006, "UMG_Activity_PetSurveyItem_C:TraceBtnClick")
  MagicManualUtils.TaskTraceByGoGuide(self.go_guide)
end

function UMG_Activity_PetSurveyItem_C:ZoneTaskRewardReq(task_id_list)
  local req = _G.ProtoMessage:newZoneTaskRewardReq()
  req.task_list = task_id_list
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_TASK_REWARD_REQ, req, self, self.ZoneTaskRewardRsp, false, true)
end

function UMG_Activity_PetSurveyItem_C:ZoneTaskRewardRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    local CurRewardConf = rsp.ret_info.goods_reward
    if #CurRewardConf.rewards > 0 then
      local newRewards = self:MergeRewards(CurRewardConf.rewards)
      _G.NRCModuleManager:DoCmd(_G.NPCShopUIModuleCmd.OpenNPCShopItemRewardsPanel, newRewards, "")
      self.uiData.task_state = ProtoEnum.EMTaskState.EM_TASK_STATE_DONE
      self.BtnSwitcher:SetActiveWidgetIndex(1)
      for i = 1, self.AwardList:GetItemCount() do
        local item = self.AwardList:GetItemByIndex(i - 1)
        item:SetAlreadyReceived(true)
      end
      _G.NRCModuleManager:GetModule("ActivityModule"):DispatchEvent(ActivityModuleEvent.RefreshLimitedFlowerHandbook, self.uiData.task_id)
    end
  else
    local key = string.format("Error_Code_%d", rsp.ret_info.ret_code)
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText[key])
  end
end

function UMG_Activity_PetSurveyItem_C:MergeRewards(_rspRewards)
  local newRewards = {}
  for _, goodsItem in ipairs(_rspRewards) do
    if goodsItem.reward_reason ~= _G.ProtoEnum.FlowReason.FLOW_REASON_LEVEL_REWARD then
      table.insert(newRewards, goodsItem)
    end
  end
  return newRewards
end

return UMG_Activity_PetSurveyItem_C
