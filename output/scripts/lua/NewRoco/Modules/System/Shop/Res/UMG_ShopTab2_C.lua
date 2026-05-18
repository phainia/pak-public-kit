local UMG_ShopTab2_C = _G.NRCViewBase:Extend("UMG_ShopTab2_C")

function UMG_ShopTab2_C:OnActive()
end

function UMG_ShopTab2_C:OnDeactive()
end

function UMG_ShopTab2_C:SetTabList(tablist)
  self.TabGridView:InitGridView(tablist)
end

function UMG_ShopTab2_C:OnAddEventListener()
end

return UMG_ShopTab2_C
