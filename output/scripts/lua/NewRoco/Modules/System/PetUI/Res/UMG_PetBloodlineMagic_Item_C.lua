require("UnLuaEx")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PetBloodlineMagic_Item_C = Base:Extend("UMG_PetBloodlineMagic_Item_C")

function UMG_PetBloodlineMagic_Item_C:Initialize(Initializer)
end

function UMG_PetBloodlineMagic_Item_C:OnConstruct()
end

function UMG_PetBloodlineMagic_Item_C:OnDestruct()
end

function UMG_PetBloodlineMagic_Item_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.uiData = _data.BagItem
  self.roleMagicGid = _data.roleMagicGid
  self.teamType = _data.TeamType
  self:InitializeInfo()
  self:SetData()
end

function UMG_PetBloodlineMagic_Item_C:SetData()
  local BagItem = self.uiData
  local BagItemConf = _G.DataConfigManager:GetBagItemConf(BagItem.id)
  if BagItemConf then
    self.Text_Name:SetText(BagItemConf.name)
    self.Icon:SetPath(BagItemConf.icon)
  end
  self.RedDot:SetupKey(194, BagItem.id)
  if BagItem.gid == self.roleMagicGid then
    self.Equipped:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.RedDot:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_PetBloodlineMagic_Item_C:SetOnNewStateRemove()
  if self.uiData and self.uiData.id and self.RedDot and self.RedDot:IsRed() then
    self.RedDot:EraseRedPoint()
  end
end

function UMG_PetBloodlineMagic_Item_C:InitializeInfo()
  self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Equipped:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_PetBloodlineMagic_Item_C:SelectInfo(_bSelected)
  if _bSelected then
    self.Select:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:StopAllAnimations()
    self:PlayAnimation(self.Select_In)
    self:SetOnNewStateRemove()
  else
    self:StopAllAnimations()
    self:PlayAnimation(self.Select_Out)
  end
end

function UMG_PetBloodlineMagic_Item_C:OnItemSelected(_bSelected)
  self:SelectInfo(_bSelected)
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SelectBloodItem, self.uiData, self.index - 1, _bSelected)
end

function UMG_PetBloodlineMagic_Item_C:OnAnimationFinished(Anim)
  if Anim == self.Select_Out then
    self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_PetBloodlineMagic_Item_C
