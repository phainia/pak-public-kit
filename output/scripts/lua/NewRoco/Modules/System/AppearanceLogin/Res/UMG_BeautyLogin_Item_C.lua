local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_BeautyLogin_Item_C = Base:Extend("UMG_BeautyLogin_Item_C")

function UMG_BeautyLogin_Item_C:OnConstruct()
end

function UMG_BeautyLogin_Item_C:OnDestruct()
end

function UMG_BeautyLogin_Item_C:OnItemUpdate(_data, datalist, index)
  self:PlayAnimation(self.open_1)
  Log.Dump(_data, 3, "UMG_Beauty_Item_C:OnItemUpdate")
  self.index = index
  self.uiData = _data
  self.salonItemConf = nil
  self.suitConf = nil
  if type(_data) == "table" then
    if _data.salonItems and #_data.salonItems > 0 then
      self.salonItemConf = _G.DataConfigManager:GetSalonItemConf(_data.salonItems[1])
    end
  elseif type(_data) == "number" then
    self.suitConf = _G.DataConfigManager:GetFashionSuitsConf(_data)
  end
  self.Selected:SetRenderOpacity(0)
  self:UpdateItemInfo()
end

function UMG_BeautyLogin_Item_C:OnTouchEnded(MyGeometry, InTouchEvent)
  local ret = Base.OnTouchEnded(self, MyGeometry, InTouchEvent)
  _G.NRCAudioManager:PlaySound2DAuto(41401007, "UMG_BeautyLogin_Item_C:OnTouchEnded")
  return ret
end

function UMG_BeautyLogin_Item_C:UpdateItemInfo()
  if self.suitConf then
    self.Icon:SetPath(self.suitConf.suits_icon)
  elseif self.salonItemConf then
    self.Icon:SetPath(self.salonItemConf.icon)
  end
end

function UMG_BeautyLogin_Item_C:OnItemSelected(_bSelected)
  if _bSelected then
    self.Selected:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.change1)
    self:PlayAnimation(self.change1_Loop, 0, 9999)
    if self.suitConf then
      _G.NRCModuleManager:DoCmd(_G.AppearanceLoginModuleCmd.SetAvatarSuit, self.suitConf.item_id, self.suitConf.id)
    elseif self.salonItemConf then
      if 1 == #self.uiData.salonItems then
        _G.NRCModuleManager:DoCmd(_G.AppearanceLoginModuleCmd.SetAvatarSalon, self.salonItemConf.avatar_id, self.salonItemConf.texture_id)
      else
        _G.NRCModuleManager:DoCmd(_G.AppearanceLoginModuleCmd.SetBeautyColorList, self.uiData.salonItems)
      end
    end
  else
    self:PlayAnimation(self.change1_unselect)
    self:StopAnimation(self.change1_Loop)
    self.Selected:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_BeautyLogin_Item_C:OnDeactive()
end

function UMG_BeautyLogin_Item_C:GetCurColorIndex()
  local tempBeautyData = _G.NRCModuleManager:DoCmd(_G.AppearanceLoginModuleCmd.GetTempBeautyDataByGender, _G.NRCModuleManager:DoCmd(LoginModuleCmd.GetCurRegisterGender))
  Log.Dump(tempBeautyData, 4, "UMG_Beauty_Item_C:GetCurColorIndex")
  if tempBeautyData and #tempBeautyData > 0 then
    for k, v in ipairs(tempBeautyData) do
      if v.SalonId == self.uiData.SalonId[1] then
        return v.SalonColorIndex
      end
    end
    local salonItemConf = _G.DataConfigManager:GetSalonItemConf(self.uiData.SalonId[1])
    for k, v in ipairs(tempBeautyData) do
      if v.SalonType == salonItemConf.type then
        return v.SalonColorIndex
      end
    end
  end
  return 4
end

return UMG_BeautyLogin_Item_C
