local UMG_SleepingOwl_GoodAndBadi_Tips_C = _G.NRCPanelBase:Extend("UMG_SleepingOwl_GoodAndBadi_Tips_C")

function UMG_SleepingOwl_GoodAndBadi_Tips_C:OnActive(AdvantageType, DisadvantageType)
  _G.NRCAudioManager:PlaySound2DAuto(1060, "CampingModule:OpenNourishRightFruit")
  self:PlayAnimation(self.TweenIn)
  self:AddButtonListener(self.HotArea, self.OnClose)
  self.AdvantageList:InitGridView(AdvantageType)
  local IsAdvantage = true
  local TypeText = ""
  if AdvantageType then
    for i = 1, #AdvantageType do
      local typeDic = _G.DataConfigManager:GetTypeDictionary(AdvantageType[i])
      if i == #AdvantageType then
        TypeText = TypeText .. typeDic.short_name
      else
        TypeText = TypeText .. typeDic.short_name .. "\227\128\129"
      end
    end
  else
    Log.Error("UMG_SleepingOwl_GoodAndBadi_Tips_C:OnActive   AdvantageType is nil")
  end
  local TypeText1
  if IsAdvantage then
    self.Text_GoodAndBad:SetText(LuaText.umg_nourish_goodandbadi_tipsitem_1)
    TypeText1 = _G.DataConfigManager:GetLocalizationConf("advantage_type_tips").msg
    self.textBuffDesc:SetText(string.format(TypeText1, TypeText))
  else
    self.Text_GoodAndBad:SetText(LuaText.umg_nourish_goodandbadi_tipsitem_2)
    TypeText1 = _G.DataConfigManager:GetLocalizationConf("disadvantage_type_tips").msg
    self.textBuffDesc:SetText(string.format(TypeText1, TypeText))
  end
end

function UMG_SleepingOwl_GoodAndBadi_Tips_C:OnDeactive()
  self:RemoveButtonListener(self.HotArea)
end

function UMG_SleepingOwl_GoodAndBadi_Tips_C:OnAddEventListener()
end

function UMG_SleepingOwl_GoodAndBadi_Tips_C:OnClose()
  _G.NRCAudioManager:PlaySound2DAuto(1060, "CampingModule:OpenNourishRightFruit")
  self:PlayAnimation(self.TweenOut)
end

function UMG_SleepingOwl_GoodAndBadi_Tips_C:OnAnimationFinished(anim)
  if anim == self.TweenOut then
    self:DoClose()
  end
end

return UMG_SleepingOwl_GoodAndBadi_Tips_C
