local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_ExChangeGrowUpItemPanel_C = _G.NRCPanelBase:Extend("UMG_ExChangeGrowUpItemPanel_C")

function UMG_ExChangeGrowUpItemPanel_C:OnConstruct()
  self:SetChildViews(self.PopUp4)
end

function UMG_ExChangeGrowUpItemPanel_C:OnDestruct()
end

function UMG_ExChangeGrowUpItemPanel_C:OnActive(NeedExChangeCount, DiffItem)
  local ExChangeItemConf = _G.DataConfigManager:GetBagItemConf(_G.DataConfigManager:GetPetGlobalConfig("universal_growth_material").num)
  local ExChangeItem = {
    {
      bShowTip = true,
      bShowNum = true,
      itemCfg = ExChangeItemConf,
      itemCount = NeedExChangeCount,
      itemType = Enum.GoodsType.GT_BAGITEM,
      itemId = _G.DataConfigManager:GetPetGlobalConfig("universal_growth_material").num,
      itemNum = NeedExChangeCount
    }
  }
  local Items = DiffItem
  local ExChangeStr = string.format("%d\228\184\170<span color=\"#d56c1fff\">%s</>", NeedExChangeCount, ExChangeItemConf.name)
  local DiffItemStr = ""
  for i = 1, #DiffItem do
    if DiffItem[i].itemCfg and DiffItem[i].itemCount then
      DiffItemStr = DiffItemStr .. string.format("%d\228\184\170<span color=\"#d56c1fff\">%s</>", DiffItem[i].itemCount, DiffItem[i].itemCfg.name)
      if i < #DiffItem then
        DiffItemStr = DiffItemStr .. "\227\128\129"
      end
    end
  end
  local TextStr = string.format("\230\137\128\233\156\128\230\136\144\233\149\191\230\157\144\230\150\153\228\184\141\232\182\179\239\188\140\230\152\175\229\144\166\230\182\136\232\128\151%s\239\188\140\232\161\165\229\133\133%s", ExChangeStr, DiffItemStr)
  self:SetCommonPopUpInfo(self.PopUp4)
  self.PopUp4:SetDescInfo(TextStr)
  self.ExChangeItemList:InitGridView(ExChangeItem)
  self.ItemList:InitGridView(Items)
  self:OnAddEventListener()
  self:LoadAnimation(0)
end

function UMG_ExChangeGrowUpItemPanel_C:OnDeactive()
end

function UMG_ExChangeGrowUpItemPanel_C:SetCommonPopUpInfo(PopUp, TitleText, TitleIcon)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  if TitleText then
    CommonPopUpData.TitleText = TitleText
  end
  if TitleIcon then
    CommonPopUpData.TitleIcon = TitleIcon
  end
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnBtnCancelClick
  CommonPopUpData.Btn_RightHandler = self.OnBtnOkClick
  CommonPopUpData.ClosePanelHandler = self.OnBtnCancelClick
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_ExChangeGrowUpItemPanel_C:OnBtnCancelClick()
  self:DispatchEvent(PetUIModuleEvent.OnGrowUp, false)
  self:LoadAnimation(2)
end

function UMG_ExChangeGrowUpItemPanel_C:OnBtnOkClick()
  self:DispatchEvent(PetUIModuleEvent.OnGrowUp, true)
  self:LoadAnimation(2)
end

function UMG_ExChangeGrowUpItemPanel_C:OnAddEventListener()
end

function UMG_ExChangeGrowUpItemPanel_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(0) then
    self:LoadAnimation(1)
  elseif anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

return UMG_ExChangeGrowUpItemPanel_C
