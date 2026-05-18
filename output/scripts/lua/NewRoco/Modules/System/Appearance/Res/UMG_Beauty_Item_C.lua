local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local AppearanceModuleEvent = require("NewRoco.Modules.System.Appearance.AppearanceModuleEvent")
local UMG_Beauty_Item_C = Base:Extend("UMG_Beauty_Item_C")

function UMG_Beauty_Item_C:OnConstruct()
end

function UMG_Beauty_Item_C:OnDestruct()
end

function UMG_Beauty_Item_C:OnItemUpdate(_data, datalist, index)
  local OpenAnim = self:SetRandomOpenAnim()
  self:PlayAnimation(OpenAnim)
  self.index = index
  self.uiData = _data
  self.Selected:SetRenderOpacity(0)
  self:UpdateItemInfo()
end

function UMG_Beauty_Item_C:UpdateItemInfo()
  local SalonId = self.uiData.SalonId[1]
  local salonItemConf = _G.DataConfigManager:GetSalonItemConf(SalonId)
  self.Icon:SetPath(salonItemConf.icon)
end

function UMG_Beauty_Item_C:OnItemSelected(_bSelected)
  if _bSelected then
    self.Selected:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:PlayAnimation(self.change1)
    self:PlayAnimation(self.change1_Loop, 0, 9999)
    for i = 1, #self.uiData.SalonId do
      local colorIndex = self:GetCurColorIndex()
      local salonItemConf = _G.DataConfigManager:GetSalonItemConf(self.uiData.SalonId[1])
      if salonItemConf.type == _G.Enum.SalonLabelType.SLT_SKIN or salonItemConf.type == _G.Enum.SalonLabelType.SLT_MAKEUP then
        _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetBeauty, self.uiData.SalonId[1], false, colorIndex)
        _G.NRCAudioManager:PlaySound2DAuto(1004, "UMG_Beauty_Item1_C:OnItemSelected")
      elseif salonItemConf.type == _G.Enum.SalonLabelType.SLT_EYELASH then
        _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetBeauty, self.uiData.SalonId[1], true, colorIndex)
        _G.NRCAudioManager:PlaySound2DAuto(1004, "UMG_Beauty_Item1_C:OnItemSelected")
      elseif salonItemConf.type == _G.Enum.SalonLabelType.SLT_EYEBORWS or salonItemConf.type == _G.Enum.SalonLabelType.SLT_HAIR or salonItemConf.type == _G.Enum.SalonLabelType.SLT_EYES then
        _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetBeauty, self.uiData.SalonId[1], true, colorIndex)
        _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.GetBeautyColorList, self.uiData.SalonId[1])
      else
        _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.GetBeautyColorList, self.uiData.SalonId[1])
        _G.NRCAudioManager:PlaySound2DAuto(1004, "UMG_Beauty_Item1_C:OnItemSelected")
      end
    end
    if self.uiData.IsPlaaSound == true then
    end
  else
    self:PlayAnimation(self.change1_unselect)
    self:StopAnimation(self.change1_Loop)
    self.Selected:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_Beauty_Item_C:SetPlaySoundState(_IsPlaaSound)
  self.uiData.IsPlaySound = _IsPlaaSound
end

function UMG_Beauty_Item_C:CheckIsChoosed(curAppearChooseInfo)
  if nil == curAppearChooseInfo then
  elseif #curAppearChooseInfo > 0 then
    for i = 1, #curAppearChooseInfo do
      if curAppearChooseInfo[i].SalonId == self.uiData.SalonId[1] then
        self.bChoosed = true
        return
      else
        self.bChoosed = false
      end
    end
  end
end

function UMG_Beauty_Item_C:GetCurColorIndex()
  local tempBeautyData = _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.GetTempAppearOrBeautyData, _G.Enum.GoodsType.GT_SALON)
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

function UMG_Beauty_Item_C:SetRandomOpenAnim()
  local animations = {
    self.open_1,
    self.open_2,
    self.open_3
  }
  local randomIndex = math.random(#animations)
  return animations[randomIndex]
end

function UMG_Beauty_Item_C:OnDeactive()
end

return UMG_Beauty_Item_C
