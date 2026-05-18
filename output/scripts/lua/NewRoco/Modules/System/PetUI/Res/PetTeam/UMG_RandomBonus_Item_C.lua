local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local UMG_RandomBonus_Item_C = Base:Extend("UMG_RandomBonus_Item_C")
UMG_RandomBonus_Item_C.ContentType = {
  None = -1,
  Star = 0,
  Reword = 2
}

function UMG_RandomBonus_Item_C:OnConstruct()
end

function UMG_RandomBonus_Item_C:OnDestruct()
end

function UMG_RandomBonus_Item_C:OnItemUpdate(_data, datalist, index)
  local nextProps = {}
  table.copy(_data, nextProps)
  local prevProps = self.props
  self.props = nextProps
  BattleUtils.SetPvpScoreIcon(self.NRCImage_132)
  self:RenderWidget(prevProps, nextProps)
  self:OnWidgetDidUpdate(prevProps, nextProps)
end

function UMG_RandomBonus_Item_C:OnItemSelected(_bSelected)
end

function UMG_RandomBonus_Item_C:RenderWidget(prevProps, nextProps)
  if prevProps == nextProps then
    return
  end
  self.Text_describe:SetText(nextProps.titleText)
  self.Switcher_0:SetActiveWidgetIndex(nextProps.contentType)
  local amountText = tostring(nextProps.amountTextPrefix or "") .. tostring(nextProps.amount)
  self.Array:SetText(amountText)
end

function UMG_RandomBonus_Item_C:OnWidgetDidUpdate(prevProps, nextProps)
  if prevProps ~= nextProps then
    self:PlayAnimation(self.In)
  end
end

function UMG_RandomBonus_Item_C:OnDeactive()
end

return UMG_RandomBonus_Item_C
