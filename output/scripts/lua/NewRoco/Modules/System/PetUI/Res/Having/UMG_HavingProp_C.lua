local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UIUtils = require("NewRoco.Modules.System.TipsModule.Utils.UIUtils")
local UMG_HavingProp_C = Base:Extend("UMG_HavingProp_C")

function UMG_HavingProp_C:Initialize(Initializer)
end

function UMG_HavingProp_C:OnConstruct()
  Log.Error("UMG_HavingProp_C:OnConstruct")
  self:OnAddEventListener()
end

function UMG_HavingProp_C:OnDestruct()
  self:OnRemoveEventListener()
end

function UMG_HavingProp_C:OnEnable()
end

function UMG_HavingProp_C:OnDisable()
end

function UMG_HavingProp_C:OnAddEventListener()
end

function UMG_HavingProp_C:OnRemoveEventListener()
end

function UMG_HavingProp_C:OnItemUpdate(data, datalist, index)
  self.index = index
  self._data = data
  self:updateItemInfo()
end

function UMG_HavingProp_C:updateItemInfo()
  self.AddImage:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.CanvasGood:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.NotOpenCnavas:SetVisibility(UE4.ESlateVisibility.Hidden)
  if self._data.open then
    self:ShowOpenInfo()
  else
    self:NotOpen()
  end
end

function UMG_HavingProp_C:ShowOpenInfo()
  if self._data.possessionItem ~= nil and nil ~= self._data.possessionItem.conf_id then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(self._data.possessionItem.conf_id)
    if bagItemConf then
      self.Icon:SetPath(bagItemConf.big_icon)
      self.Quality:SetPath(self._data.bgIcon[bagItemConf.item_quality])
      self.NameTxt:SetText(bagItemConf.name)
      self.NameTxt:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor(UIUtils.QualityTextColors[bagItemConf.item_quality]))
    end
    self.CanvasGood:SetVisibility(UE4.ESlateVisibility.Visible)
    if self._data.playAnima then
      self.CanvasPanel_anima:SetVisibility(UE4.ESlateVisibility.Visible)
      self:PlayAnimation(self.Change)
    end
  else
    self.Quality:SetPath(self._data.bgIcon[1])
    self.AddImage:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_HavingProp_C:NotOpen()
  self.Quality:SetPath(self._data.bgIcon[1])
  self.Grade:SetActiveWidgetIndex(self._data.breakData.breakOpenIndex - 1)
  self.NotOpenCnavas:SetVisibility(UE4.ESlateVisibility.Visible)
end

function UMG_HavingProp_C:OnItemSelected(selected)
  if selected then
    self:OnChangeHaveClick()
  end
end

function UMG_HavingProp_C:OnChangeHaveClick()
  if self._data.open ~= true then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1226, "UMG_HavingProp_C:OnItemSelected")
    return
  end
  if self._data.callbackCaller and self._data.callbackFunc then
    tcall(self._data.callbackCaller, self._data.callbackFunc, self._data.pos)
  end
  if self._data.possessionItem.conf_id == nil then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1216, "UMG_HavingProp_C:OnItemSelected")
  else
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1226, "UMG_HavingProp_C:OnItemSelected")
  end
end

return UMG_HavingProp_C
