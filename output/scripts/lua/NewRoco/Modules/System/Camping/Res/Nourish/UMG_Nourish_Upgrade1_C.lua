local UMG_Nourish_Upgrade1_C = _G.NRCPanelBase:Extend("UMG_Nourish_Upgrade1_C")

function UMG_Nourish_Upgrade1_C:OnActive(CampingId, CampingLv, caller, rspHandler)
  self.CampingId = CampingId
  self.CampingLv = CampingLv
  self.caller = caller
  self.rspHandler = rspHandler
  local CampingLvNum = 0
  self:OnAddEventListener()
  self.NRCTitle_1:SetText(_G.DataConfigManager:GetLocalizationConf("camp_levelup_title").msg)
  self.NRCTitle:SetText(_G.DataConfigManager:GetLocalizationConf("camp_levelup_title").msg)
  self.insufficientText = _G.DataConfigManager:GetLocalizationConf("Camp_Exchange_cailiaobuzu").msg
  local campingLvTable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.CAMP_LEVELUP_CONF)
  local campLvCfgs = campingLvTable:GetAllDatas()
  for k, v in ipairs(campLvCfgs) do
    if v.content_id == self.CampingId and v.level == self.CampingLv + 1 then
      self.CampingLvUpConf = v
    end
    if v.content_id == self.CampingId and v.level == self.CampingLv then
      CampingLvNum = v.pet_fruit_num
    end
  end
  local BracketAddNum = self.CampingLvUpConf.pet_fruit_num - CampingLvNum
  self.textBuffDesc:SetText(string.format(_G.DataConfigManager:GetLocalizationConf("camp_levelup_desc").msg, self.CampingLvUpConf.level))
  self.NRCTextBracket:SetText(_G.DataConfigManager:GetLocalizationConf("add_petfruit_num_icon").msg .. BracketAddNum)
  local RewardItemConf = _G.DataConfigManager:GetRewardConf(self.CampingLvUpConf.levelup_reward)
  self.List_Icon:InitGridView(RewardItemConf.RewardItem)
  self:UpdateCostItemNum()
  self.Text:SetText("/" .. self.CampingLvUpConf.levelup_cost_item_num)
  self.Icon1:AsRewardItem()
  self:PlayAnimation(self.In)
end

function UMG_Nourish_Upgrade1_C:OnDeactive()
  self:RemoveButtonListener(self.Btn1.btnLevelUp, self.OnUpgrade)
  self:RemoveButtonListener(self.Btn2.btnLevelUp, self.OnCanCel)
end

function UMG_Nourish_Upgrade1_C:OnAddEventListener()
  self:AddButtonListener(self.Btn1.btnLevelUp, self.OnUpgrade)
  self:AddButtonListener(self.Btn2.btnLevelUp, self.OnCanCel)
end

function UMG_Nourish_Upgrade1_C:OnUpgrade()
  if self.ItemEnough then
    self.module:SetNourishPanelBtnClick(false)
    self.IsUpGrade = true
    self:PlayAnimation(self.Out)
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, self.insufficientText)
  end
end

function UMG_Nourish_Upgrade1_C:UpdateCostItemNum()
  local HasUpItemNum = 0
  if self.CampingLvUpConf.levelup_cost_item_type == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(self.CampingLvUpConf.levelup_cost_item_id)
    if bagItemConf then
      self.icon:SetPath(NRCUtils:FormatConfIconPath(bagItemConf.icon, _G.UIIconPath.BagItemPath))
      local itemData = _G.NRCModeManager:DoCmd(BagModuleCmd.GetBagItemByID, self.CampingLvUpConf.levelup_cost_item_id)
      if itemData then
        HasUpItemNum = itemData.num or 0
      end
    end
  elseif self.CampingLvUpConf.levelup_cost_item_type == _G.Enum.GoodsType.GT_VITEM then
    local vItemConf = _G.DataConfigManager:GetVisualItemConf(self.CampingLvUpConf.levelup_cost_item_id)
    if nil ~= vItemConf then
      self.icon:SetPath(NRCUtils:FormatConfIconPath(vItemConf.bigIcon, _G.UIIconPath.BagItemPath))
    end
    HasUpItemNum = _G.DataModelMgr.PlayerDataModel:GetVItemCount(self.CampingLvUpConf.levelup_cost_item_id)
  end
  if HasUpItemNum < self.CampingLvUpConf.levelup_cost_item_num then
    self.CountText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#FF0F00FF"))
    self.ItemEnough = false
  else
    self.CountText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#ffffffff"))
    self.ItemEnough = true
  end
  self.CountText:SetText(HasUpItemNum)
end

function UMG_Nourish_Upgrade1_C:OnCanCel()
  self.IsUpGrade = false
  self:PlayAnimation(self.Out)
end

function UMG_Nourish_Upgrade1_C:OnAnimationFinished(anim)
  if anim == self.Out then
    if self.IsUpGrade then
    end
    self:DoClose()
  end
end

return UMG_Nourish_Upgrade1_C
