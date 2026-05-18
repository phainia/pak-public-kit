local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ShopTab_ItemTemplate_C = Base:Extend("UMG_ShopTab_ItemTemplate_C")

function UMG_ShopTab_ItemTemplate_C:OnConstruct()
end

function UMG_ShopTab_ItemTemplate_C:OnDestruct()
end

function UMG_ShopTab_ItemTemplate_C:OnItemUpdate(_data, datalist, index)
  self.PlayAudio = false
  self.uiData = _data
  self.index = index
  self.Text:SetText(self.uiData.tab_name_2)
  self.Text1:SetText(self.uiData.tab_name_2)
  self.Text2:SetText(self.uiData.tab_name_2)
  if 1 == self.index then
    self.firstnoselect:SetVisibility(UE4.ESlateVisibility.Visible)
    self.no_select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.firstnoselect:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.no_select:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  self.select:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_ShopTab_ItemTemplate_C:OnItemSelected(_bSelected)
  if _bSelected then
    if self.PlayAudio then
      _G.NRCAudioManager:PlaySound2DAuto(1004, "UMG_ShopIcon_Template_C:OnItemSelected")
    end
    if 1 == self.index then
      self.firstnoselect:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.no_select:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self.select:SetVisibility(UE4.ESlateVisibility.Visible)
    self:PlayAnimation(self.In)
    _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.OnCmdGetStoreListReq, self.uiData.shop_id)
    _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.OnCmdCloseRefreshBtn)
  else
    if 1 == self.index then
      self.firstnoselect:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.no_select:SetVisibility(UE4.ESlateVisibility.Visible)
    end
    self.select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_ShopTab_ItemTemplate_C:OnDeactive()
end

return UMG_ShopTab_ItemTemplate_C
