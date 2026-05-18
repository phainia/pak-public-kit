local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_Base_C")
local ShopModuleEvent = require("NewRoco.Modules.System.Shop.ShopModuleEvent")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")
local UMG_Activity_TopUpRebate_C = Base:Extend("UMG_Activity_TopUpRebate_C")

function UMG_Activity_TopUpRebate_C:BindUIElements()
  local uiElements = {}
  uiElements.particularsBtn = self.ParticularsBtn
  uiElements.openAnimName = "In"
  uiElements.changeAnimName = "In"
  uiElements.closeAnimName = "Out"
  return uiElements
end

function UMG_Activity_TopUpRebate_C:OnConstruct()
  Base.OnConstruct(self)
  self.Text_Title:SetText(self.activityInst:GetActivityName())
  self.Text_Describe:SetText(self.activityInst:GetActivityPromptText())
  self:RefreshInfo()
  self:OnAddEventListener()
  local _activityInst = self.activityInst
  local ActivityType = self.activityInst:GetActivityType()
  if ActivityType == Enum.ActivityType.ATP_ACTIVITY_WEBSITE_PART then
    local _itemObject = _activityInst:CreateWebSiteItem(_activityInst:GetSinglePartId())
    if _itemObject then
      self.Btn_TopUpNow:SetBtnText(_itemObject:GetInteractiveText())
    end
  end
end

local function SortCost(a, b)
  return a.origin_price > b.origin_price
end

function UMG_Activity_TopUpRebate_C:RefreshInfo()
  local Save_Amt, distribute_amt, totalTestAmt = _G.NRCModuleManager:DoCmd(PayModuleCmd.GetSaveAmt)
  local AllAmt = (Save_Amt or 0) + (distribute_amt or 0) + (totalTestAmt or 0)
  local SaveAmt = math.ceil(AllAmt / 10)
  local MallGoods = _G.DataConfigManager:GetAllByName("NORMAL_SHOP_CONF")
  local moneyCost = {}
  if MallGoods then
    for _, v in pairs(MallGoods) do
      if v.price_goods_type == Enum.GoodsType.GT_VITEM and v.price_goods_id == Enum.VisualItem.VI_MONEY then
        table.insert(moneyCost, v)
      end
    end
  end
  table.sort(moneyCost, SortCost)
  local SaveCostTemp = 0
  local Rebate = 0
  if SaveAmt > 2000 then
    Rebate = math.ceil(26688 + (SaveAmt - 2000) * 10 * 1.113)
  else
    for i, v in pairs(moneyCost) do
      if SaveAmt >= v.origin_price and v.item_num > 1 then
        SaveCostTemp = SaveAmt - v.origin_price
        Rebate = v.item_num
        break
      end
      if i == #moneyCost then
        Rebate = SaveAmt * 10
        SaveCostTemp = 0
      end
    end
    while SaveCostTemp > 0 do
      for i, v in pairs(moneyCost) do
        if SaveCostTemp >= v.origin_price and v.item_num > 1 then
          SaveCostTemp = SaveCostTemp - v.origin_price
          Rebate = Rebate + v.item_num
          break
        end
        if i == #moneyCost then
          Rebate = Rebate + SaveCostTemp * 10
          SaveCostTemp = 0
        end
      end
    end
    Rebate = math.ceil(Rebate * 1.2)
  end
  self.TimeRemaining_1:SetText(SaveAmt)
  self.TimeRemaining_3:SetText(Rebate)
end

function UMG_Activity_TopUpRebate_C:OnDestruct()
  Base.OnDestruct(self)
  _G.NRCEventCenter:UnRegisterEvent(self, ShopModuleEvent.RefreshTopUpRebateData, self.RefreshInfo)
end

function UMG_Activity_TopUpRebate_C:OnAddEventListener()
  self:AddButtonListener(self.Btn_TopUpNow.btnLevelUp, self.OpenToShop)
  _G.NRCEventCenter:RegisterEvent("UMG_Activity_TopUpRebate_C", self, ShopModuleEvent.RefreshTopUpRebateData, self.RefreshInfo)
end

function UMG_Activity_TopUpRebate_C:OpenToShop()
  _G.NRCAudioManager:PlaySound2DAuto(40008005, "UMG_Activity_TopUpRebate_C:OpenToShop")
  local ActivityType = self.activityInst:GetActivityType()
  if ActivityType == Enum.ActivityType.ATP_ACTIVITY_WEBSITE_PART then
    self:DelaySeconds(0.1, function()
      local _activityInst = self.activityInst
      if _activityInst then
        local _itemObject = _activityInst:GetWebSiteItem(_activityInst:GetSinglePartId())
        return _activityInst:PerformActivityInteraction(ActivityEnum.ActivityInteractionType.Join, _itemObject)
      end
    end)
  else
    _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.OnCmdOpenTopUpShop)
  end
end

return UMG_Activity_TopUpRebate_C
