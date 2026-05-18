local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local UMG_PetEvolutionItemTemple_C = _G.NRCViewBase:Extend("UMG_PetEvolutionItemTemple_C")

function UMG_PetEvolutionItemTemple_C:OnConstruct()
  self.btnItemIcon.OnClicked:Add(self, self.OnBtnItemIconClick)
  NRCEventCenter:RegisterEvent("UMG_PetEvolutionItemTemple_C", self, BagModuleEvent.BagItemAdd, self.OnBagChange)
  NRCEventCenter:RegisterEvent("UMG_PetEvolutionItemTemple_C", self, BagModuleEvent.BagItemUpdate, self.OnBagChange)
end

function UMG_PetEvolutionItemTemple_C:OnDestruct()
  Log.Debug("UMG_PetEvolutionItemTemple_C OnDestruct")
  self.btnItemIcon.OnClicked:Remove(self, self.OnBtnItemIconClick)
  NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.BagItemAdd, self.OnBagChange)
  NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.BagItemUpdate, self.OnBagChange)
  self.uiData = nil
  self.itemIcon:ReleaseForce()
  self.itemIconBG:ReleaseForce()
  self.itemCount:ReleaseForce()
end

function UMG_PetEvolutionItemTemple_C:SetData(_data)
  self.uiData = _data
  self:UpdateItemInfo()
end

function UMG_PetEvolutionItemTemple_C:UpdateItemInfo()
  if not self.uiData then
    self:SetQuality(0)
    self.itemIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.txtFinish:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.Panel_Count:SetVisibility(UE4.ESlateVisibility.Hidden)
    return
  end
  self.Panel_Count:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local itemCfg = self.uiData.itemCfg
  if itemCfg then
    self.itemIcon:SetPath(itemCfg.icon)
    self:SetQuality(itemCfg.item_quality)
    self.itemIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetQuality(0)
    self.itemIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  if self.uiData.isShowFinish then
    self.txtFinish:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.itemCount:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self.txtFinish:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.itemCount:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local itemCount = self.uiData.itemCount or 0
    local needCount = self.uiData.needCount or 0
    if itemCount >= needCount then
      self.itemCount:SetText(string.format("%d/%d", itemCount, needCount))
    else
      self.itemCount:SetText(string.format("<span color=\"#FF494B\">%d</>/%d", itemCount, needCount))
    end
  end
end

function UMG_PetEvolutionItemTemple_C:SetQuality(quality)
  if 0 == quality then
    self.itemIconBG:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Common/Raw/Frames/img_daojukuangkong_png.img_daojukuangkong_png'")
  elseif 1 == quality then
    self.itemIconBG:SetPath(UEPath.PROP_QUALITY_1)
  elseif 2 == quality then
    self.itemIconBG:SetPath(UEPath.PROP_QUALITY_2)
  elseif 3 == quality then
    self.itemIconBG:SetPath(UEPath.PROP_QUALITY_3)
  elseif 4 == quality then
    self.itemIconBG:SetPath(UEPath.PROP_QUALITY_4)
  elseif 5 == quality then
    self.itemIconBG:SetPath(UEPath.PROP_QUALITY_5)
  end
end

function UMG_PetEvolutionItemTemple_C:ClearSelectAnim()
  local ani = self.select
  if self:IsAnimationPlaying(ani) then
    self:StopAnimation(ani)
    self:PlayAnimation(self.normal)
  end
end

function UMG_PetEvolutionItemTemple_C:OnBagChange(_itemId)
  if self.uiData and _itemId == self.uiData.itemId then
    local itemData = NRCModeManager:DoCmd(BagModuleCmd.GetBagItemByID, _itemId)
    if itemData then
      self.uiData.itemCount = itemData.num or 0
      self:UpdateItemInfo()
    end
  end
end

function UMG_PetEvolutionItemTemple_C:OnBtnItemIconClick()
  if self.uiData and self.uiData.itemId and self.uiData.itemId > 0 then
    local ani = self.select
    if not self:IsAnimationPlaying(ani) then
      self:PlayAnimation(ani, 0, 0)
    end
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1004, "UMG_PetEvolutionItemTemple_C:OnBtnItemIconClick")
    _G.NRCModeManager:DoCmd(_G.TipsModuleCmd.Tips_OpenItemTips, self.uiData.itemId, _G.Enum.GoodsType.GT_BAGITEM)
  end
end

return UMG_PetEvolutionItemTemple_C
