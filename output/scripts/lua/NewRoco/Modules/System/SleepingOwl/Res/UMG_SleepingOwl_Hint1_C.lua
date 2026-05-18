local UMG_SleepingOwl_Hint1_C = _G.NRCPanelBase:Extend("UMG_SleepingOwl_Hint1_C")

function UMG_SleepingOwl_Hint1_C:OnConstruct()
  self:SetChildViews(self.PopUp1)
  self:OnAddEventListener()
end

function UMG_SleepingOwl_Hint1_C:OnActive(FruitIdList)
  UE4Helper.SetDesiredShowCursor(true, "UMG_SleepingOwl_Hint1_C")
  self.List = FruitIdList
  self:SetCommonPopUpInfo(self.PopUp1)
  self:ShowPanel(self.List[1].dataList, self.List[1].isAdd)
end

function UMG_SleepingOwl_Hint1_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.ClosePanelHandler = self.OnClose
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_SleepingOwl_Hint1_C:ShowPanel(FruitIdList, isAdd)
  _G.NRCAudioManager:PlaySound2DAuto(1009, "UMG_SleepingOwl_Hint1_C:OnActive")
  self.FruitIdList = FruitIdList
  local list = {}
  for i = 1, #FruitIdList do
    if #list > 0 then
      local index = 0
      for j = 1, #list do
        if list[j].BagItemId == FruitIdList[i].BagItemId then
          break
        end
        index = index + 1
      end
      if index >= #list then
        table.insert(list, FruitIdList[i])
      end
    else
      table.insert(list, FruitIdList[i])
    end
  end
  self.PopUp1:SetTitleTextInfo(_G.DataConfigManager:GetLocalizationConf("pet_fruit_refresh_title").msg)
  if isAdd then
    self.PopUp1:SetDescInfo(_G.DataConfigManager:GetLocalizationConf("pet_fruit_refresh_desc").msg)
    self.PopUp1.IsLock = false
  else
    self.PopUp1:SetDescInfo(_G.DataConfigManager:GetLocalizationConf("pet_fruit_refresh_desc_2").msg)
  end
  self:LoadAnimation(0)
  self.PetList:InitGridView(list)
end

function UMG_SleepingOwl_Hint1_C:OnDeactive()
  UE4Helper.ReleaseDesiredShowCursor("UMG_SleepingOwl_Hint1_C")
end

function UMG_SleepingOwl_Hint1_C:OnAddEventListener()
end

function UMG_SleepingOwl_Hint1_C:OnClose()
  table.clear(self.FruitIdList)
  self:LoadAnimation(2)
end

function UMG_SleepingOwl_Hint1_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    table.remove(self.List, 1)
    if #self.List > 0 then
      self:ShowPanel(self.List[1].dataList, self.List[1].isAdd)
    else
      self:DoClose()
    end
  elseif anim == self:GetAnimByIndex(0) then
    self:LoadAnimation(1)
  end
end

return UMG_SleepingOwl_Hint1_C
