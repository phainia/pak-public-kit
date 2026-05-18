local UMG_TowerReward_C = _G.NRCPanelBase:Extend("UMG_TowerReward_C")

function UMG_TowerReward_C:OnConstruct()
end

function UMG_TowerReward_C:OnDestruct()
end

function UMG_TowerReward_C:OnActive(_data)
  self.uiData = _data
  self:LoadAnimation(0)
  self:SetRewardInfo()
  self:OnAddEventListener()
end

function UMG_TowerReward_C:OnAddEventListener()
  self:AddButtonListener(self.btnCloseRenamePanel, self.OnClickbtnCloseRenamePanel)
end

function UMG_TowerReward_C:SetRewardInfo()
  local uiData = self.uiData
  local RewardInfo = {}
  for i, v in ipairs(uiData) do
    local itemCfg = v.Id > 1 and _G.DataConfigManager:GetBagItemConf(v.Id) or nil
    table.insert(RewardInfo, {
      id = v.Id,
      type = v.Type,
      itemCfg = itemCfg,
      RewardData = v,
      num = v.Count
    })
  end
  self.awardList:InitList(RewardInfo)
end

function UMG_TowerReward_C:OnClickbtnCloseRenamePanel()
  self.btnCloseRenamePanel:SetIsEnabled(false)
  self:DoClose()
  self.btnCloseRenamePanel:SetIsEnabled(true)
end

function UMG_TowerReward_C:OnAnimationFinished(Animation)
  if Animation == self:GetAnimByIndex(2) then
  end
end

function UMG_TowerReward_C:OnDeactive()
end

return UMG_TowerReward_C
