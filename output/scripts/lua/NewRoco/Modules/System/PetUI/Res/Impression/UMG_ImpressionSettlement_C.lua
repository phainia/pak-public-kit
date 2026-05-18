local UMG_ImpressionSettlement_C = _G.NRCPanelBase:Extend("UMG_BuildingSettlement_C")

function UMG_ImpressionSettlement_C:OnConstruct()
end

function UMG_ImpressionSettlement_C:OnActive(group_id, level)
  self:OnAddEventListener()
  self:PlayAnimation(self.open)
  _G.NRCAudioManager:PlaySound2DAuto(1220002001, "UMG_BuildingSettlement_C:OnActive")
  self.Conf = self:GetConf(group_id, level)
  self:ShowPanel(self.Conf)
  self:SetUpgradeTime()
end

function UMG_ImpressionSettlement_C:GetConf(group_id, level)
  local habits = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.PET_HABIT_CONF):GetAllDatas()
  local Conf
  for i, conf in pairs(habits) do
    if conf.group_id == group_id and conf.group_number == level then
      Conf = conf
      break
    end
  end
  return Conf
end

function UMG_ImpressionSettlement_C:ShowPanel(conf)
  self.NumText:SetText(conf.name)
  self.Icon_3:SetPath(conf.habit_icon_path)
  self.Icon:SetPath(conf.habit_locked_icon_path)
  self.NumText_1:SetText(conf.desc)
  self.Image_detail:SetPath(conf.attribute_icon)
  self.Icon_3:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("652800FF"))
  self.IconBg_fangyu:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("652800FF"))
  self.Icon:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("C4C2B6FF"))
  self.IconBg_fangyu_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("C4C2B6FF"))
  self:SetIconScale(UE4.FVector2D(1, 1))
  if self.Conf.habit_buff_type == _G.Enum.HabitBuffType.HBT_NONE then
    self.IconBg_fangyu:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.IconBg_Jiantou:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.IconBg_fangyu_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.IconBg_Jiantou_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif self.Conf.habit_buff_type == _G.Enum.HabitBuffType.HBT_POSITIVE then
    self.IconBg_fangyu:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.IconBg_Jiantou:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.IconBg_fangyu_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.IconBg_Jiantou_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif self.Conf.habit_buff_type == _G.Enum.HabitBuffType.HBT_NEGATIVE then
    self.IconBg_fangyu:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.IconBg_Jiantou:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.IconBg_fangyu_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.IconBg_Jiantou_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:SetIconScale(UE4.FVector2D(0.65, 0.65))
    self.Icon_3:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("FBC664FF"))
    self.IconBg_fangyu:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("652800FF"))
    self.IconBg_fangyu_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("C4C2B6FF"))
    self.Icon:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("FAC563FF"))
  end
end

function UMG_ImpressionSettlement_C:OnDeactive()
end

function UMG_ImpressionSettlement_C:OnAddEventListener()
  self:AddButtonListener(self.btnCloseRewardPanel, self.OnClickbtnCloseRewardPanel)
end

function UMG_ImpressionSettlement_C:OnAnimationFinished(anim)
  if anim == self.close then
    self:DoClose()
  elseif anim == self.open then
    self:PlayAnimation(self.loop, 0)
  end
end

function UMG_ImpressionSettlement_C:OnClickbtnCloseRewardPanel()
  self:PlayAnimation(self.close)
end

function UMG_ImpressionSettlement_C:SetUpgradeTime()
  local nowTimePoke = math.floor(_G.ZoneServer:GetServerTime() / 1000)
  local ban_time = os.date("%Y.%m.%d", nowTimePoke)
  self.NRCText_96:SetText(ban_time)
end

return UMG_ImpressionSettlement_C
