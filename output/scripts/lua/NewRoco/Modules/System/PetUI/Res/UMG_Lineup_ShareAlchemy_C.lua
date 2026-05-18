local AlchemyUtils = require("NewRoco.Modules.System.Alchemy.AlchemyUtils")
local UMG_Lineup_ShareAlchemy_C = _G.NRCPanelBase:Extend("UMG_Lineup_ShareAlchemy_C")

function UMG_Lineup_ShareAlchemy_C:OnConstruct()
  self:SetChildViews(self.PopUp4)
  self:OnAddEventListener()
end

function UMG_Lineup_ShareAlchemy_C:OnAddEventListener()
end

function UMG_Lineup_ShareAlchemy_C:OnConFirm()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Modify_C:OnClosePanel")
  self:OpenDialogPanel(self.DialogText)
end

function UMG_Lineup_ShareAlchemy_C:SetCommonPopUpInfo(ItemName, text)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.Call = self
  CommonPopUpData.TitleText = string.format(LuaText.teamshare_make_title, ItemName)
  local desc = string.format(LuaText.teamshare_make_confirm, ItemName)
  if text then
    desc = string.format("%s%s", desc, text)
  end
  CommonPopUpData.Desc = desc
  CommonPopUpData.ClosePanelHandler = self.OnClose
  CommonPopUpData.Btn_LeftHandler = self.OnClosePanel
  CommonPopUpData.Btn_RightHandler = self.OnConFirm
  CommonPopUpData.Btn_RightTitle = self.Btn_RightTitle
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp4:SetPanelInfo(CommonPopUpData)
end

function UMG_Lineup_ShareAlchemy_C:OnClosePanel()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_Lineup_ShareAlchemy_C:OnClosePanel")
  self:OnClose()
end

function UMG_Lineup_ShareAlchemy_C:OpenDialogPanel(text)
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local Context = DialogContext()
  local ContentText = text
  Context:SetTitle(LuaText.umg_shop_tips_8):SetContent(ContentText):SetMode(DialogContext.Mode.OK_CANCEL):SetCallbackOkOnly(self, self.OnChangeApply):SetCloseOnCancel(true):SetCloseOnOK(true):SetButtonText(LuaText.umg_shop_tips_9, LuaText.umg_shop_tips_10)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
end

function UMG_Lineup_ShareAlchemy_C:OnChangeApply()
  if self.caller and self.callback then
    self.callback(self.caller)
  end
  self:OnClose()
end

function UMG_Lineup_ShareAlchemy_C:OnActive(_data)
  local Cost_item = _data.Cost_item
  local Get_Item = _data.Get_Item
  local exchangeId = _data.exchangeId
  self.caller = _data.caller
  self.callback = _data.callback
  self.CostItem:InitGridView(Cost_item)
  self.GetItem:InitGridView(Get_Item)
  self.DialogText = _data.DialogText
  for i, v in ipairs(Cost_item) do
    local item = self.CostItem:GetItemByIndex(i - 1)
    if item and item.BG then
      item.BG:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Common/Raw/Frames/img_daojukuangnormal1_png.img_daojukuangnormal1_png'")
    end
  end
  for i, v in ipairs(Get_Item) do
    local item = self.GetItem:GetItemByIndex(i - 1)
    if item and item.BG then
      item.BG:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Common/Raw/Frames/img_daojukuangnormal1_png.img_daojukuangnormal1_png'")
    end
  end
  local bagItemConf = _G.DataConfigManager:GetBagItemConf(Get_Item and Get_Item[1] and Get_Item[1].itemId)
  local exchangeConf = _G.DataConfigManager:GetExchangeConf(exchangeId)
  if exchangeConf then
    local vItemConf = _G.DataConfigManager:GetVisualItemConf(exchangeConf.visual_item_cost_type)
    if nil ~= vItemConf then
      self.NRCImage_442:SetPath(vItemConf.iconPath)
      self.PopUp4.Btn_Right:SetTitleTextAndIcon(vItemConf.iconPath, exchangeConf.visual_item_cost_num)
      self.PopUp4:SetRightBtnTitleTextAndIconShow(true)
      self.Btn_RightTitle = true
    end
    self.Number:SetText(exchangeConf.visual_item_cost_num)
  end
  self.exchangeConf = _G.DataConfigManager:GetExchangeConf(exchangeId)
  local exchangeLimitId = self.exchangeConf.exchange_time_limit_group
  local text
  if exchangeLimitId and 0 ~= exchangeLimitId then
    local exchangeLimitConf = _G.DataConfigManager:GetExchangeTimeLimitConf(exchangeLimitId)
    if exchangeLimitConf then
      local exchangeGroupInfoTable = self.module.exchangeGroupInfoTable or {}
      local remainExchangeTimes = AlchemyUtils.GetRemainExchangeTimes(exchangeLimitId, exchangeGroupInfoTable)
      if remainExchangeTimes then
        text = string.format("%d", remainExchangeTimes)
        text = string.format(LuaText.teamshare_make_lefttimes, text)
      end
    end
  end
  self:SetCommonPopUpInfo(bagItemConf and bagItemConf.name, text)
end

function UMG_Lineup_ShareAlchemy_C:CreateCommonItemIconData(ItemDosageInfo)
  local itemIconData = _G.NRCCommonItemIconData()
  itemIconData.itemType = ItemDosageInfo.itemType or _G.Enum.GoodsType.GT_BAGITEM
  itemIconData.itemId = ItemDosageInfo.itemId
  itemIconData.BagNum = ItemDosageInfo.itemNum
  itemIconData.itemNum = ItemDosageInfo.needNum
  itemIconData.bShowNum = true
  itemIconData.bShowTip = false
  return itemIconData
end

function UMG_Lineup_ShareAlchemy_C:OnDeactive()
end

function UMG_Lineup_ShareAlchemy_C:OnAddEventListener()
end

return UMG_Lineup_ShareAlchemy_C
