local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PeerTask_Item_C = Base:Extend("UMG_PeerTask_Item_C")

function UMG_PeerTask_Item_C:OnConstruct()
  self:AddButtonListener(self.Btn6.btnLevelUp, self.OnGetRewardBtnClick)
end

function UMG_PeerTask_Item_C:OnDestruct()
end

function UMG_PeerTask_Item_C:OnItemUpdate(_data, datalist, index)
  if not _data then
    Log.Error("_data is nil")
    return
  end
  self.data = _data
  self.Text_quantity:SetText(string.format("%d/%d", _data.curProgress or 0, _data.totalProgress or 1))
  local conf = _G.DataConfigManager:GetActivityConditionRewardConf(_data.conditionId)
  if conf then
    self.Text_Describe:SetText(conf.part_name)
    self.Text_Describe_1:SetText(conf.part_desc)
    local rewards = {}
    if conf.reward_group then
      for i, v in ipairs(conf.reward_group) do
        table.insert(rewards, {
          itemId = v.goods_id,
          itemType = v.goods_type,
          itemNum = v.goods_count,
          isDone = _data.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE,
          bShowNum = true
        })
      end
    end
    self.AwardList:InitGridView(rewards)
    if _data.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_WAIT then
      self.BtnSwitcher:SetActiveWidgetIndex(1)
    elseif _data.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_DONE then
      self.BtnSwitcher:SetActiveWidgetIndex(2)
    else
      self.BtnSwitcher:SetActiveWidgetIndex(0)
    end
  end
end

function UMG_PeerTask_Item_C:OnGetRewardBtnClick()
  if self.data and self.data.state == ProtoEnum.PlayerActivityInfo.ActivityRewardState.ARS_WAIT then
    local parentCustomData = self:GetParentCustomData()
    if parentCustomData then
      local activityInst = parentCustomData.activityInst
      if activityInst then
        activityInst:GetReward(self.data.conditionId)
      end
    end
  end
end

function UMG_PeerTask_Item_C:OnItemSelected(_bSelected)
end

function UMG_PeerTask_Item_C:OnDeactive()
end

return UMG_PeerTask_Item_C
