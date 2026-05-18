local UMG_Nourish_Upgrade_C = _G.NRCPanelBase:Extend("UMG_Nourish_Upgrade_C")

function UMG_Nourish_Upgrade_C:OnActive(CampingId, CampingLv)
  self.CampingId = CampingId
  self.CampingLv = CampingLv
  local CampingLvNum = 0
  local campingLvTable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.CAMP_LEVELUP_CONF)
  local campLvCfgs = campingLvTable:GetAllDatas()
  for k, v in ipairs(campLvCfgs) do
    if v.content_id == self.CampingId and v.level == self.CampingLv then
      self.CampingLvUpConf = v
    end
    if v.content_id == self.CampingId and v.level == self.CampingLv - 1 then
      CampingLvNum = v.pet_fruit_num
    end
  end
  local BracketAddNum = self.CampingLvUpConf.pet_fruit_num - CampingLvNum
  self.NRCTextBracket:SetText(_G.DataConfigManager:GetLocalizationConf("add_petfruit_num_icon").msg .. BracketAddNum)
  self.Upgrade_Item.NRCText_21:SetText(self.CampingLvUpConf.level - 1)
  self.Upgrade_Item_1.NRCText_21:SetText(self.CampingLvUpConf.level)
  local RewardItemConf = _G.DataConfigManager:GetRewardConf(self.CampingLvUpConf.levelup_reward)
  self.List_Icon:InitGridView(RewardItemConf.RewardItem)
  self.Icon1:AsRewardItem()
  self.btnCloseRenamePanel:SetIsEnabled(false)
  self:AddButtonListener(self.btnCloseRenamePanel, self.OnClose)
  self:PlayAnimation(self.In)
end

function UMG_Nourish_Upgrade_C:OnDeactive()
end

function UMG_Nourish_Upgrade_C:OnClose()
  self:PlayAnimation(self.Out)
end

function UMG_Nourish_Upgrade_C:OnAnimationFinished(anim)
  if anim == self.Out then
    Log.Error("\233\173\148\229\138\155\228\185\139\230\186\144\230\187\139\229\133\187\229\183\178\231\187\143\229\186\159\229\188\131\229\149\166\239\188\129\239\188\129\239\188\129")
    self:DoClose()
  end
  if anim == self.In then
    self.btnCloseRenamePanel:SetIsEnabled(true)
  end
end

return UMG_Nourish_Upgrade_C
