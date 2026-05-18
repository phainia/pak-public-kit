local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local AppearanceModuleEvent = require("NewRoco.Modules.System.Appearance.AppearanceModuleEvent")
local UMG_Appearance_Item1_C = Base:Extend("UMG_Appearance_Item1_C")

function UMG_Appearance_Item1_C:OnConstruct()
end

function UMG_Appearance_Item1_C:OnDestruct()
end

function UMG_Appearance_Item1_C:OnItemUpdate(_data, datalist, index)
  self.IsPlayAnim = false
  self.uiData = _data
  self.index = index
  self.bChoosed = false
  self.Selected:SetRenderOpacity(0)
  self:UpdateItemInfo()
end

function UMG_Appearance_Item1_C:UpdateItemInfo()
  local OpenAnim = self:SetRandomOpenAnim()
  self:PlayAnimation(OpenAnim)
  local FashionId = self.uiData.FashionId
  if 1 == #self.uiData.FashionGoodsId then
    local fashionItemConf = _G.DataConfigManager:GetFashionItemConf(FashionId[1])
    if fashionItemConf.icon then
      self.Icon:SetPath(fashionItemConf.icon)
    else
      self.Icon:SetPath("")
    end
  else
    local fashionSuitConf = _G.DataConfigManager:GetFashionSuitsConf(self.uiData.SuitIndex)
    if fashionSuitConf.suits_icon then
      self.Icon:SetPath(fashionSuitConf.suits_icon)
    else
      self.Icon:SetPath("")
    end
  end
end

function UMG_Appearance_Item1_C:OnItemSelected(_bSelected)
  if _bSelected then
    if self.bChoosed then
      self:PlayAnimation(self.Unselect)
      self:StopAnimation(self.Select_Loop)
      for i = 1, #self.uiData.FashionId do
        _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetAppearance, self.uiData.FashionId[i], self.uiData.FashionGoodsId, false)
        self.bChoosed = false
      end
    else
      _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetAppearConfirmBtnClickable, false)
      local TempAppearData = _G.NRCModuleManager:DoCmd(AppearanceModuleCmd.GetTempAppearOrBeautyData, _G.Enum.GoodsType.GT_FASHION)
      local tempTable = {}
      if #self.uiData.FashionId > 1 and TempAppearData and #TempAppearData > 0 then
        for k, v in ipairs(TempAppearData) do
          local fashionType = _G.DataConfigManager:GetFashionItemConf(v.FashionId)
          local hasFashion = false
          for i = 1, #self.uiData.FashionId do
            local fashionItemConf = _G.DataConfigManager:GetFashionItemConf(self.uiData.FashionId[i])
            if fashionItemConf.type == fashionType then
              hasFashion = true
            end
          end
          if false == hasFashion then
            table.insert(tempTable, v)
          end
        end
      end
      for k, v in ipairs(tempTable) do
        _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetAppearance, v.FashionId, v.FashionGoodsId, false)
      end
      self:PlayAnimation(self.Select_Loop, 0, 9999)
      self:PlayAnimation(self.Select)
      local IsFirstPlay = false
      for i = 1, #self.uiData.FashionId do
        _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetAppearance, self.uiData.FashionId[i], self.uiData.FashionGoodsId, true)
        if self.IsPlayAnim then
          if #self.uiData.FashionId > 1 and not IsFirstPlay then
            _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.PlayAvatarAnim, true)
            IsFirstPlay = true
          end
          if #self.uiData.FashionId <= 1 and not IsFirstPlay then
            _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.PlayAvatarAnim, false, self.uiData.FashionId[i])
          end
        else
          self.IsPlayAnim = true
        end
        self.bChoosed = true
      end
    end
    _G.NRCAudioManager:PlaySound2DAuto(1072, "UMG_Appearance_Item1_C:OnItemSelected")
  else
    self:PlayAnimation(self.Unselect)
    self:StopAnimation(self.Select_Loop)
    self.bChoosed = false
  end
end

function UMG_Appearance_Item1_C:CheckIsChoosed(curAppearChooseInfo)
  if nil == curAppearChooseInfo then
  elseif #curAppearChooseInfo > 0 then
    for i = 1, #curAppearChooseInfo do
      if curAppearChooseInfo[i].FashionId == self.uiData.FashionId[1] then
        self.bChoosed = true
        return
      else
        self.bChoosed = false
      end
    end
  end
end

function UMG_Appearance_Item1_C:SetRandomOpenAnim()
  local animations = {
    self.open_1,
    self.open_2,
    self.open_3
  }
  local randomIndex = math.random(#animations)
  return animations[randomIndex]
end

function UMG_Appearance_Item1_C:OnDeactive()
end

return UMG_Appearance_Item1_C
