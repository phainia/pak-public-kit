local UMG_ColorfulDyeing_C = _G.NRCPanelBase:Extend("UMG_ColorfulDyeing_C")

function UMG_ColorfulDyeing_C:OnActive()
end

function UMG_ColorfulDyeing_C:OnDeactive()
end

function UMG_ColorfulDyeing_C:OnAddEventListener()
end

function UMG_ColorfulDyeing_C:UpdateState(itemID, wearGlassInfo, unlockedGlassInfo)
  if self.bOpen then
    self:EraseRedPoint()
  end
  self.bOpen = false
  self:RemoveButtonListener(self.BtnRight.btnLevelUp)
  self:AddButtonListener(self.BtnRight.btnLevelUp, self.OnClickedDetail)
  self.itemID = itemID
  self.BtnRight.RedDot:SetupKey(462, {
    self.itemID
  })
  self.BtnRight:SetText(LuaText.fashion_item_color_tint_btn)
  self.unlockedGlassInfo = unlockedGlassInfo
  if unlockedGlassInfo and #unlockedGlassInfo > 0 then
    self.TextColorfulQuantity:SetText(tostring(#unlockedGlassInfo))
    local glassList = {
      {
        glassInfo = {},
        itemID = self.itemID
      }
    }
    local selectedGlassInfo = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.GetCurSelectedItemGlassMap, self.itemID)
    local index = 0
    for i, glassInfo in pairs(unlockedGlassInfo or {}) do
      if glassInfo then
        local temp = {
          glassInfo = glassInfo,
          itemID = self.itemID
        }
        table.insert(glassList, temp)
      end
      if wearGlassInfo and glassInfo.glass_type == wearGlassInfo.glass_type and glassInfo.glass_value == wearGlassInfo.glass_value then
        index = i
      elseif selectedGlassInfo and glassInfo.glass_type == selectedGlassInfo.glass_type and glassInfo.glass_value == selectedGlassInfo.glass_value then
        index = i
      end
    end
    self.MutationOption:InitList(glassList)
    self.MutationOption:SelectItemByIndex(index)
  end
  self.Details:SetRenderOpacity(0)
  self.Details:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
end

function UMG_ColorfulDyeing_C:CheckOpenState()
  if self:IsAnimationPlaying(self.Details_In) or self:IsAnimationPlaying(self.Details_Out) then
    return
  end
  if self.bOpen then
    self:OnClickedClose()
  end
end

function UMG_ColorfulDyeing_C:OnClickedDetail()
  if self:IsAnimationPlaying(self.Details_In) or self:IsAnimationPlaying(self.Details_Out) then
    return
  end
  if self.bOpen then
    self:OnClickedClose()
  else
    _G.NRCAudioManager:PlaySound2DAuto(40002013, "UMG_ColorfulDyeing_C:OnClickedDetail")
    self.BtnRight.ItemName:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Details:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Details:SetRenderOpacity(1)
    self:PlayAnimation(self.Details_In)
    self.bOpen = true
  end
end

function UMG_ColorfulDyeing_C:OnClickedClose()
  _G.NRCAudioManager:PlaySound2DAuto(40002014, "UMG_ColorfulDyeing_C:OnClickedClose")
  self.BtnRight.ItemName:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:PlayAnimation(self.Details_Out)
  self.bOpen = false
  self:EraseRedPoint()
end

function UMG_ColorfulDyeing_C:OnAnimationFinished(Anim)
  if Anim == self.Details_Out then
    self.Details:SetRenderOpacity(0)
    self.Details:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  end
end

function UMG_ColorfulDyeing_C:EraseRedPoint()
  local EraseRedList = {}
  for _, glassInfo in pairs(self.unlockedGlassInfo or {}) do
    if glassInfo and glassInfo.glass_type and glassInfo.glass_value then
      table.insert(EraseRedList, {
        self.itemID,
        glassInfo.glass_type,
        glassInfo.glass_value
      })
    end
  end
  if EraseRedList and #EraseRedList > 0 then
    if self.eraseRedItemID and self.eraseRedListNum and self.eraseRedItemID == self.itemID and self.eraseRedListNum == #EraseRedList then
      return
    end
    self.eraseRedItemID = self.itemID
    self.eraseRedListNum = #EraseRedList
    _G.NRCModuleManager:DoCmd(_G.RedPointModuleCmd.EraseRedPointWithExtraKeyList, 461, EraseRedList)
  end
end

function UMG_ColorfulDyeing_C:OnTouchEnded(MyGeometry, InTouchEvent)
  return UE4.UWidgetBlueprintLibrary.Handled()
end

return UMG_ColorfulDyeing_C
