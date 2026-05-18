local UMG_NpcInfo_MysteriousStore_C = _G.NRCPanelBase:Extend("UMG_NpcInfo_MysteriousStore_C")
local UIUtils = require("NewRoco.Utils.UIUtils")
local NPCShopUtils = require("NewRoco.Modules.System.NPCShopUI.NPCShopUtils")

function UMG_NpcInfo_MysteriousStore_C:OnConstruct()
  self.disableTime = nil
  self.resetTime = 0
  self.NextRefreshTime = 0
  self.shopData = nil
end

function UMG_NpcInfo_MysteriousStore_C:OnActive(npcInfo)
  local worldMapCfgID = npcInfo.world_map_cfg_id
  local worldMapCfg = _G.DataConfigManager:GetWorldMapConf(worldMapCfgID)
  if worldMapCfg then
    self.NPCDes:SetText(worldMapCfg.worldmap_npc_des)
  end
  self.HotItemText:SetText(LuaText.map_random_shop_text_4)
  self.CollectGoodsDesText:SetText(LuaText.map_random_shop_text_2)
  self.updateTimer = _G.TimerManager:CreateTimer(self, "UMG_NpcInfo_MysteriousStore_C:OnUpdate", math.maxinteger, self.OnUpdate, nil, 1)
  local module = _G.NRCModuleManager:GetModule("BigMapModule")
  if module then
    local rsp = module.data:GetShopData()
    if rsp then
      self:UpdatePanelInfo(rsp)
    end
  end
end

function UMG_NpcInfo_MysteriousStore_C:OnDeactive()
  if self.updateTimer then
    _G.TimerManager:RemoveTimer(self.updateTimer)
    self.updateTimer = nil
  end
end

function UMG_NpcInfo_MysteriousStore_C:OnAddEventListener()
end

function UMG_NpcInfo_MysteriousStore_C:OnEnable(npcInfo)
  Log.Debug("UMG_NpcInfo_MysteriousStore_C:OnEnable", npcInfo)
end

function UMG_NpcInfo_MysteriousStore_C:OnUpdate()
  local nowTime = _G.ZoneServer:GetServerTime() / 1000
  local bShouldReq = false
  if self.NextRefreshTime and self.NextRefreshTime > 0 then
    local leftTime = self.NextRefreshTime - nowTime
    if leftTime <= 0 then
      bShouldReq = true
    end
    self.BatchItemTime:SetText(UIUtils.FormatTimeString(leftTime))
  else
    self.BatchItemTime:SetText("00:00:00")
  end
  if self.disableTime and self.disableTime ~= "" then
    local disableTimeSec = self.disableTime
    if disableTimeSec and disableTimeSec > 0 then
      local leftSec = UIUtils.GetRemainingTime(disableTimeSec, nowTime)
      self.HotItemTime:SetText(UIUtils.FormatTimeString(leftSec))
      if leftSec <= 0 then
        bShouldReq = true
      end
    else
      self.HotItemTime:SetText("00:00:00")
    end
  else
    self.HotItemTime:SetText("00:00:00")
  end
  if bShouldReq and self.shopData then
    local shopId = self.shopData.id
    local req = _G.ProtoMessage:newZoneShopGetInfoReq()
    req.shop_id = shopId
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SHOP_GET_INFO_REQ, req, self, self.UpdatePanelInfo, false, false)
  end
end

function UMG_NpcInfo_MysteriousStore_C:UpdatePanelInfo(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    Log.Warning("UMG_NpcInfo_MysteriousStore_C:UpdatePanelInfo", rsp.ret_info.ret_code)
    return
  end
  local shopData = rsp.shop_data
  self.shopData = shopData
  local shopCfg = _G.DataConfigManager:GetShopConf(shopData.id)
  if shopCfg then
    self.ShopName:SetText(shopCfg.shop_name)
  end
  local HotItemList = {}
  local CommonItemList = {}
  local earliestDisableTime = math.maxinteger
  local showIconGoodID
  for _, item in ipairs(shopData.goods_data) do
    local itemCfg = _G.DataConfigManager:GetRandomGoodsConf(item.goods_id)
    if itemCfg then
      if itemCfg.is_special_good ~= nil and itemCfg.is_special_good == true then
        table.insert(HotItemList, item)
      else
        table.insert(CommonItemList, item)
      end
      showIconGoodID = item.goods_id
      if item.disable_time and (not earliestDisableTime or earliestDisableTime > item.disable_time) and 0 ~= item.disable_time then
        earliestDisableTime = item.disable_time
      end
    end
  end
  self.disableTime = earliestDisableTime
  if #HotItemList > 0 then
    self.CanvasPanel:SetVisibility(UE4.ESlateVisibility.Visible)
    local shopList = _G.NRCModuleManager:DoCmd(_G.NPCShopUIModuleCmd.SetMysteriousStoreShopList, HotItemList)
    self.HotItemGridView:InitGridView(shopList)
  else
    self.CanvasPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HotItemGridView:InitGridView({})
  end
  if #CommonItemList > 0 then
    self.NextRefreshTime = CommonItemList[1].next_refresh_time
    self.CanvasPanel_Batch:SetVisibility(UE4.ESlateVisibility.Visible)
    local shopList = _G.NRCModuleManager:DoCmd(_G.NPCShopUIModuleCmd.SetMysteriousStoreShopList, CommonItemList)
    self.BatchItemGridView:InitGridView(shopList)
  else
    self.CanvasPanel_Batch:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.BatchItemGridView:InitGridView({})
  end
  if showIconGoodID then
    local iconPath, displayName = NPCShopUtils:GetGoodsCurrencyIconPath(shopData.id, showIconGoodID)
    if iconPath then
      self.MoneyIcon:SetPath(iconPath)
      self.MoneyName:SetText(displayName)
    end
    local num = NPCShopUtils:GetGoodsCurrencyNum(shopData.id, showIconGoodID)
    self.MoneyNum:SetText(num)
  end
  local BatchTextContent = string.format(LuaText.map_random_shop_text_3, rsp.shop_data.refresh_count, rsp.shop_data.max_refresh_count)
  self.BatchText:SetText(BatchTextContent)
  self:OnUpdate()
end

return UMG_NpcInfo_MysteriousStore_C
