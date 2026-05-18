local UMG_Nourish_Hint1_C = _G.NRCPanelBase:Extend("UMG_Nourish_Hint1_C")

function UMG_Nourish_Hint1_C:OnActive(FruitIdList, placeName)
  _G.NRCAudioManager:PlaySound2DAuto(1009, "CampingModule:OpenNourishRightFruit")
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
  Log.Dump(list, 6, "UMG_Nourish_Hint1_C:OnActive")
  self.NRCTitle_1:SetText(_G.DataConfigManager:GetLocalizationConf("pet_fruit_refresh_title").msg)
  self.textBuffDesc:SetText(string.format(_G.DataConfigManager:GetLocalizationConf("pet_fruit_refresh_desc").msg, placeName))
  self:PlayAnimation(self.In)
  self.PetList:InitGridView(list)
  self:OnAddEventListener()
  UE4Helper.SetDesiredShowCursor(true, "UMG_Nourish_Hint1_C")
end

function UMG_Nourish_Hint1_C:OnDeactive()
  UE4Helper.ReleaseDesiredShowCursor("UMG_Nourish_Hint1_C")
end

function UMG_Nourish_Hint1_C:OnAddEventListener()
  self:AddButtonListener(self.btnCloseRenamePanel, self.OnClose)
end

function UMG_Nourish_Hint1_C:OnClose()
  table.clear(self.FruitIdList)
  self:PlayAnimation(self.Out)
end

function UMG_Nourish_Hint1_C:OnAnimationFinished(anim)
  if anim == self.Out then
    self:DoClose()
  end
end

return UMG_Nourish_Hint1_C
