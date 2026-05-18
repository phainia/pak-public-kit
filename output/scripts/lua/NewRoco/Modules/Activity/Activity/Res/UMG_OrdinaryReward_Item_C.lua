local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_OrdinaryReward_Item_C = Base:Extend("UMG_OrdinaryReward_Item_C")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")

function UMG_OrdinaryReward_Item_C:OnConstruct()
  self:AddButtonListener(self.Btn3.btnLevelUp, self.GetReward)
  self:AddButtonListener(self.TraceBtn.btnLevelUp, self.TraceSeed)
end

function UMG_OrdinaryReward_Item_C:OnDestruct()
  self:RemoveButtonListener(self.Btn3.btnLevelUp)
  self:RemoveButtonListener(self.TraceBtn.btnLevelUp)
end

function UMG_OrdinaryReward_Item_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  local rewardItems = _G.DataConfigManager:GetRewardConf(_data.reward_id).RewardItem
  local initData = {}
  for _, rewardItem in ipairs(rewardItems) do
    local data = _G.NRCCommonItemIconData()
    data.itemType = rewardItem.Type
    data.itemId = rewardItem.Id
    data.itemNum = rewardItem.Count
    data.bShowNum = true
    table.insert(initData, data)
  end
  self.IconList:InitGridView(initData)
  if _data.reward_state == _G.ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_OPEN then
    self.Switcher:SetActiveWidgetIndex(1)
  elseif _data.reward_state == _G.ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_WAIT then
    self.Switcher:SetActiveWidgetIndex(0)
  elseif _data.reward_state == _G.ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_DONE then
    self.Switcher:SetActiveWidgetIndex(2)
  elseif _data.reward_state == _G.ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_CLOSE then
    self.Switcher:SetActiveWidgetIndex(3)
  end
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(_data.pet_base_id)
  self.Array:SetText(string.format(_G.DataConfigManager:GetTaskConf(_data.task_id).task_des, petBaseConf.name))
  self.Btn3:SetRedDotExtraKey(215, {
    _data.activity_id,
    _data.part_id
  })
end

function UMG_OrdinaryReward_Item_C:GetReward()
  local req = _G.ProtoMessage:newZoneReceivePlayerActivityPartRewardReq()
  req.activity_id = self.uiData.activity_id
  req.activity_part_id = self.uiData.activity_part_id
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_RECEIVE_PLAYER_ACTIVITY_PART_REWARD_REQ, req, self, self.OnRewardGet)
end

function UMG_OrdinaryReward_Item_C:OnRewardGet(rsp)
  if 0 == rsp.ret_info.ret_code then
    self.uiData.reward_state = _G.ProtoEnum.PlayerActivityInfo.ActivityPartState.APS_DONE
    self.Switcher:SetActiveWidgetIndex(2)
    self.uiData.callback(self.uiData.caller, self.uiData.seed_index)
    local rewardData = _G.DataConfigManager:GetRewardConf(self.uiData.reward_id).RewardItem
    local popupInitData = {}
    for i = 1, #rewardData do
      local popupData = _G.ProtoMessage:newGoodsItem()
      popupData.id = rewardData[i].Id
      popupData.num = rewardData[i].Count
      popupData.type = rewardData[i].Type
      table.insert(popupInitData, popupData)
    end
    _G.NRCModuleManager:DoCmd(_G.CommonPopUpModuleCmd.OpenNPCShopItemRewardsPanel, popupInitData)
  end
end

function UMG_OrdinaryReward_Item_C:TraceSeed()
  ActivityUtils.DoActivityOptionCmd(self.uiData.activity_option_id)
end

return UMG_OrdinaryReward_Item_C
