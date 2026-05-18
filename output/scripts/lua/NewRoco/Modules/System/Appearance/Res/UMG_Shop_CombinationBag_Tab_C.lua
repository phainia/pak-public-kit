local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local AppearanceModuleEvent = require("NewRoco.Modules.System.Appearance.AppearanceModuleEvent")
local UMG_Shop_CombinationBag_Tab_C = Base:Extend("UMG_Shop_CombinationBag_Tab_C")

function UMG_Shop_CombinationBag_Tab_C:OnConstruct()
  self.FirstSelectTimer = 3
  self.SelectLoopTimer = 8
end

function UMG_Shop_CombinationBag_Tab_C:OnDestruct()
  _G.UpdateManager:UnRegister(self)
end

function UMG_Shop_CombinationBag_Tab_C:OnActive()
end

function UMG_Shop_CombinationBag_Tab_C:OnDeactive()
  _G.UpdateManager:UnRegister(self)
end

function UMG_Shop_CombinationBag_Tab_C:OnItemUpdate(_data, datalist, index)
  self.ShopType = _data
  self.FirstSelect = true
  self.UpdateTime = 0
  self.PlayAudio = false
  self.Index = index
  local Id
  if self.ShopType == Enum.ShopType.ST_FASHION_PIKA then
    Id = 1
  elseif self.ShopType == Enum.ShopType.ST_FASHION_RANDOM then
    Id = 2
    local Extrakey = {}
    local allShopData = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.SHOP_CONF):GetAllDatas()
    for k, shopData in pairs(allShopData) do
      if shopData.shop_type == Enum.ShopType.ST_FASHION_RANDOM then
        table.insert(Extrakey, k)
      end
    end
    self.RedDot:SetupKey(426, Extrakey)
  elseif self.ShopType == Enum.ShopType.ST_FASHION_DISCOUNT then
    Id = 3
  end
  local imgPath1 = string.format(UEPath.FMT_COMBINATION_SHOP_TAB, Id, 1, Id, 1)
  local imgPath2 = string.format(UEPath.FMT_COMBINATION_SHOP_TAB, Id, 2, Id, 2)
  self.PitchOn:SetPath(imgPath1)
  self.Ordinary:SetPath(imgPath2)
  self:LoadAnimation(0)
end

function UMG_Shop_CombinationBag_Tab_C:OnItemSelected(_bSelected)
  if not self.ShopType then
    return
  end
  self._bSelected = _bSelected
  self:CancelPlayLoopAnim()
  self:StopAllAnimations()
  if _bSelected then
    if self.PlayAudio then
      _G.NRCAudioManager:PlaySound2DAuto(1005, "UMG_Shop_CombinationBag_Tab_C:OnItemSelected")
    end
    self:LoadAnimation(1)
    local appearanceModule = NRCModuleManager:GetModule("AppearanceModule")
    appearanceModule:DispatchEvent(AppearanceModuleEvent.FashionMallTabClick, self.ShopType, self.Index)
  else
    self.UpdateTime = 0
    self.FirstSelect = true
    self:LoadAnimation(3)
  end
end

function UMG_Shop_CombinationBag_Tab_C:StartPlayLoopAnim()
  if not self or not UE4.UObject.IsValid(self) then
    return
  end
  self:LoadAnimation(2)
  self.loopFuncID = nil
end

function UMG_Shop_CombinationBag_Tab_C:CancelPlayLoopAnim()
  if self.loopFuncID then
    DelayManager:CancelDelayById(self.loopFuncID)
    self.loopFuncID = nil
  end
end

function UMG_Shop_CombinationBag_Tab_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(1) then
    self:LoadAnimation(2)
  elseif anim == self:GetAnimByIndex(2) then
    self:CancelPlayLoopAnim()
    if self._bSelected then
      self.loopFuncID = DelayManager:DelaySeconds(self.SelectLoopTimer, self.StartPlayLoopAnim, self)
    end
  end
end

function UMG_Shop_CombinationBag_Tab_C:OnDestruct()
  self:CancelPlayLoopAnim()
end

return UMG_Shop_CombinationBag_Tab_C
