local PayModuleEvent = reload("NewRoco.Modules.System.ChargePay.PayModuleEvent")
local NRCSDKManagerEnum = require("Core.Service.SDKManager.NRCSDKManagerEnum")
local NRCSDKManagerEvent = require("Core.Service.SDKManager.NRCSDKManagerEvent")
local JsonUtils = require("Common.JsonUtils")
local PayEnum = require("NewRoco.Modules.System.ChargePay.PayEnum")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local LoginEnum = require("NewRoco.Modes.LoginMode.LoginEnum")
local CommonUtils = require("NewRoco.Utils.CommonUtils")
local PayModule = NRCModuleBase:Extend("PayModule")

function PayModule:OnConstruct()
  self.payData = self:SetData("PayData", "NewRoco.Modules.System.ChargePay.PayData")
  self.lastCallTime = os.time()
  self.delay = 1
  self.payStatus = PayEnum.PayStatus.None
end

function PayModule:OnActive()
  _G.NRCSDKManager:AddEventListener(self, NRCSDKManagerEvent.OnWebViewOptNotify, self.OnWebViewOptNotify)
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.ON_LOGIN, self.OnLogin)
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.ON_CONNECTED_KICK_OUT_TYPE, self.SetIsKickOutNeedReconnect)
  _G.NRCEventCenter:RegisterEvent(self.name, self, PayModuleEvent.MidasPayFailed, self.CallRelogin)
  _G.ZoneServer:AddProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_MONEY_INFO_CHANGE_NOTITY, self.OnMoneyInfoChanged)
end

function PayModule:OnWebViewOptNotify(webViewRet)
  if self.payStatus ~= PayEnum.PayStatus.None then
    _G.ZoneServer:CloseWaitingUI("Pay")
  end
  if webViewRet.msgType == NRCSDKManagerEnum.WebViewMsgType.CloseWebViewURL and self:IsPaying() then
    self:UpdateBalance()
    return
  elseif webViewRet.msgType ~= NRCSDKManagerEnum.WebViewMsgType.WebViewJsCall then
    return
  end
  local jsMessage = JsonUtils.StringToJson(tostring(webViewRet.msgJsonData))
  Log.Dump(jsMessage, 2, "jsMessage from H5", false, Log.LOG_LEVEL.ELogInfo)
  if jsMessage.type ~= "midasbuyGoodsReturn" then
    return
  end
  self.payStatus = PayEnum.PayStatus.None
  local extraData = jsMessage.extraData
  if nil == extraData then
    Log.Error("extraData nil")
    return
  end
  extraData = JsonUtils.StringToJson(self:UrlDecode(extraData))
  if 0 == jsMessage.code or jsMessage.code == "0" then
    Log.Dump(extraData, 3, "extraData from H5", false, Log.LOG_LEVEL.ELogInfo)
    if extraData.goods_type and extraData.goods_type == PayEnum.PayType.DirectPurchase or extraData.goods_type == "1" then
      NRCEventCenter:DispatchEvent(PayModuleEvent.MidasPaySuccess, PayEnum.PayType.DirectPurchase, extraData.shop_id)
      return
    elseif extraData.goods_type and extraData.goods_type == PayEnum.PayType.PurchaseTool or "0" == extraData.goods_type then
      NRCEventCenter:DispatchEvent(PayModuleEvent.MidasPaySuccess, PayEnum.PayType.PurchaseTool, extraData.shop_id)
      return
    end
  elseif 1 == jsMessage.code or jsMessage.code == "1" then
    NRCEventCenter:DispatchEvent(PayModuleEvent.MidasPayFailed, PayEnum.PayType.DirectPurchase, PayEnum.FailType.USER_CANCEL, extraData.shop_id)
    _G.GEMPostManager:SendPayFailEvent(PayEnum.FailType.USER_CANCEL, webViewRet.msgJsonData or "")
    self:ShowFailTips(PayEnum.MidasCodePC.USER_CANCELED)
    return
  end
  _G.GEMPostManager.SendPayFailEvent(PayEnum.FailType.OTHER, webViewRet.msgJsonData or "")
  NRCEventCenter:DispatchEvent(PayModuleEvent.MidasPayFailed, jsMessage.goods_type, PayEnum.FailType.OTHER, extraData.shop_id)
  self:ShowFailTips(PayEnum.MidasCodePC.PAGE_ERROR)
end

function PayModule:InitializeMidas()
  if RocoEnv.PLATFORM_ANDROID or RocoEnv.PLATFORM_IOS or RocoEnv.PLATFORM_OPENHARMONY then
    UE.UMidasStatics.SetPermissionOnAndroid()
    local midasObserver = _G.NRCSDKManager:GetMidasObserver()
    if nil ~= midasObserver then
      local midasReqWrapper = NewObject(UE4.UMidasReqWrapper, _G.UE4Helper.GetCurrentWorld())
      if RocoEnv.PLATFORM_IOS then
        midasReqWrapper.OfferId = "1450311736"
      elseif RocoEnv.PLATFORM_ANDROID then
        midasReqWrapper.OfferId = "1450311650"
      elseif RocoEnv.PLATFORM_OPENHARMONY then
        midasReqWrapper.OfferId = "1450450341"
      end
      midasReqWrapper.OpenId = self.payData.openId
      midasReqWrapper.OpenKey = self.payData.payToken
      midasReqWrapper.Pf = self.payData.pf
      midasReqWrapper.PfKey = self.payData.pfKey
      UE.UMidasStatics.InitializeMidas(midasReqWrapper, midasObserver)
    else
      NRCEventCenter:DispatchEvent(PayModuleEvent.MidasPayFailed, -1, PayEnum.FailType.OTHER)
    end
  elseif RocoEnv.PLATFORM_WINDOWS then
  end
end

function PayModule:UrlEncode(str)
  if not str then
    return ""
  end
  str = tostring(str)
  str = string.gsub(str, "([^0-9a-zA-Z !'()*._~-])", function(c)
    return string.format("%%%02X", string.byte(c))
  end)
  str = string.gsub(str, " ", "%%20")
  return str
end

function PayModule:UrlDecode(str)
  if not str then
    return ""
  end
  str = string.gsub(str, "%%(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end)
  str = string.gsub(str, "%%20", " ")
  return str
end

function PayModule:UpdateBalanceWithHandler(actionAfterQuery)
  if nil == actionAfterQuery then
    Log.Error("actionAfterQuery nil")
    return
  end
  local req = _G.ProtoMessage:newZoneQueryBalanceReq()
  req.token_info.pf = self.payData.pf
  req.token_info.access_token = self.payData.accessToken
  req.token_info.pay_token = self.payData.payToken
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_QUERY_BALANCE_REQ, req, self, function(rsp)
    Log.Dump(rsp, 3, "ZoneQueryBalanceRsp")
    if rsp.ret_info ~= nil then
      if rsp.ret_info.ret_code == ProtoEnum.MOBA_RET.ZoneErr.ERR_ZONE_PAY_TOKEN_INVALID then
        Log.Warning("ZoneQueryBalanceRsp return ERR_ZONE_PAY_TOKEN_INVALID")
        NRCEventCenter:DispatchEvent(PayModuleEvent.NeedReLogin)
        return
      elseif 0 == rsp.ret_info.ret_code then
        local midasBalance = rsp.money_info.midas_balance
        self.payData:UpdateBalanceData(midasBalance)
        self.payData:UpdateSave_amtData(rsp.money_info.midas_save_amt)
        self.payData:UpdateDistribute_amtData(rsp.money_info.distribute_amt, rsp.money_info.total_test_amt)
        NRCEventCenter:DispatchEvent(PayModuleEvent.UpdateBalanceSuccess)
        return
      end
    end
    NRCEventCenter:DispatchEvent(PayModuleEvent.UpdateBalanceFail)
    if actionAfterQuery then
      Log.Debug("actionAfterQuery invoked")
      actionAfterQuery()
    end
  end, true, true)
end

function PayModule:LaunchMidasPage(goodsTokenUrl, goodsType, shopID)
  if RocoEnv.PLATFORM_ANDROID then
    local bIsH5GameCloudEnv = CommonUtils.IsH5GameCloudEnv()
    if bIsH5GameCloudEnv then
      Log.Warning("[PayModule:LaunchMidasPage] IsH5GameCloudEnv")
      local Context = DialogContext()
      Context:SetTitle(LuaText.game_matrix_pay_title):SetContent(LuaText.game_matrix_pay_tips):SetMode(DialogContext.Mode.OK):SetCloseOnOK(true):SetCloseOnCancel(true):SetButtonText(LuaText.YES)
      NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog2, Context)
      return
    end
  end
  _G.ZoneServer:OpenWaitingUI("Pay", LuaText.charge_tips_23)
  _G.DelayManager:DelaySeconds(4, function()
    _G.ZoneServer:CloseWaitingUI("Pay")
  end)
  if RocoEnv.PLATFORM_ANDROID or RocoEnv.PLATFORM_IOS or RocoEnv.PLATFORM_OPENHARMONY then
    self:UpdateBalance()
    local midasObserver = _G.NRCSDKManager:GetMidasObserver()
    if nil ~= midasObserver then
      local midasReqWrapper = NewObject(UE4.UMidasReqWrapper, _G.UE4Helper.GetCurrentWorld())
      midasReqWrapper.OpenId = self.payData.openId
      midasReqWrapper.OpenKey = self.payData.payToken
      midasReqWrapper.Pf = self.payData.pf
      midasReqWrapper.GoodsTokenUrl = goodsTokenUrl
      midasReqWrapper.PfKey = self.payData.pfKey
      if RocoEnv.PLATFORM_IOS then
        midasReqWrapper.OfferId = "1450311736"
      elseif RocoEnv.PLATFORM_ANDROID then
        midasReqWrapper.OfferId = "1450311650"
      elseif RocoEnv.PLATFORM_OPENHARMONY then
        midasReqWrapper.OfferId = "1450450341"
      end
      local extraTable = {
        GoodsType = goodsType,
        enableScanPay = 1,
        ShopID = shopID
      }
      self:SetPayGoodsInfo(extraTable)
      local extraStr = ""
      if table.len(extraTable) > 0 then
        for k, v in pairs(extraTable) do
          extraStr = extraStr .. k .. "=" .. v .. "&"
        end
      end
      if string.len(extraStr) > 2 and string.match(extraStr, "%&$") then
        extraStr = string.sub(extraStr, 1, -2)
      end
      midasReqWrapper.Extras = extraStr
      Log.Debug(string.format("openid:%s, openKey:%s, pf:%s, goodsTokenUrl:%s, pfKey:%s, extra:%s", midasReqWrapper.OpenId, midasReqWrapper.OpenKey, midasReqWrapper.Pf, midasReqWrapper.GoodsTokenUrl, midasReqWrapper.PfKey, midasReqWrapper.Extras))
      UE.UMidasStatics.Pay(midasReqWrapper, midasObserver)
    else
      Log.Error("Invalid MidasObserver")
      NRCEventCenter:DispatchEvent(PayModuleEvent.MidasPayFailed, goodsType, PayEnum.FailType.OTHER)
    end
  elseif RocoEnv.PLATFORM_WINDOWS then
    local function openPageAfterQuery()
      local midasUrl = "https://rocom.qq.com/cp/a20241202mdspay?"
      
      local extraData = {goods_type = goodsType, shop_id = shopID}
      local extraDataStr = self:UrlEncode(JsonUtils.EncodeTable(extraData))
      Log.Debug("extraDataStr is " .. extraDataStr)
      local queryParameters = {
        appid = "1450311751",
        session_id = "itopid",
        session_type = "itop",
        goodstokenurl = goodsTokenUrl,
        pf = self.payData.pf,
        openid = self.payData.openId,
        openkey = self.payData.payToken,
        extraData = extraDataStr,
        sandbox = _G.AppMain:GetFormalPipeline() and "0" or "1"
      }
      for key, value in pairs(queryParameters) do
        midasUrl = midasUrl .. key .. "=" .. value .. "&"
      end
      midasUrl = string.sub(midasUrl, 1, -2)
      Log.PrintScreenMsg("payOnPC with url : %s", midasUrl)
      UE.UMidasStatics.PayOnPC(midasUrl)
    end
    
    self:UpdateBalanceWithHandler(openPageAfterQuery)
  end
end

function PayModule:GetPayType(itemId)
  if nil == itemId then
    Log.Error("itemId is nil")
    return PayEnum.PayType.PurchaseTool
  end
  local goodsConf = _G.DataConfigManager:GetNormalShopConf(itemId)
  if nil == goodsConf then
    Log.Error("goodsConf is nil", itemId)
    return PayEnum.PayType.PurchaseTool
  end
  if goodsConf.buy_access == _G.Enum.BuyAccess.BA_ZHIGOU then
    return PayEnum.PayType.DirectPurchase
  end
  return PayEnum.PayType.PurchaseTool
end

function PayModule:OnCmdPayForChargeReq(itemId, shopId)
  if nil == itemId then
    Log.Error("itemId is nil")
    return
  end
  if nil == shopId then
    Log.Error("shopId is nil")
    return
  end
  if os.time() <= self.lastCallTime + self.delay then
    return
  else
    self.lastCallTime = os.time()
  end
  local req = _G.ProtoMessage:newZoneBuyGoodsByMidasReq()
  req.goods_id = itemId
  req.type = self:GetPayType(itemId)
  req.token_info.access_token = self.payData.accessToken
  req.token_info.pay_token = self.payData.payToken
  req.token_info.pf = self.payData.pf
  req.shop_id = shopId
  local version = _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.OnCmdGetShopVersion, shopId)
  req.version = version
  Log.Debug("OnCmdPayForChargeReq with access_token:", req.token_info.access_token, ", pay_token:", req.token_info.pay_token, ", pf:", req.token_info.pf, "goods_id:", req.goods_id, ", shop_id:", req.shop_id, ", version:", req.version, ", type:", req.type)
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_BUY_GOODS_BY_MIDAS_REQ, req, self, self.QueryForItemURLRsp, true, true)
end

function PayModule:OnCmdPayForItemReq(itemId, shopId)
  if nil == itemId then
    Log.Error("itemId is nil")
    return
  end
  if nil == shopId then
    Log.Error("shopId is nil")
    return
  end
  if os.time() <= self.lastCallTime + self.delay then
    return
  else
    self.lastCallTime = os.time()
  end
  local req = _G.ProtoMessage:newZoneBuyGoodsByMidasReq()
  req.goods_id = itemId
  req.type = self:GetPayType(itemId)
  req.token_info.access_token = self.payData.accessToken
  req.token_info.pay_token = self.payData.payToken
  req.token_info.pf = self.payData.pf
  req.shop_id = shopId
  local version = _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.OnCmdGetShopVersion, shopId)
  req.version = version
  Log.Debug("OnCmdPayForItemReq with access_token:", req.token_info.access_token, ", pay_token:", req.token_info.pay_token, ", pf:", req.token_info.pf, "goods_id:", req.goods_id, ", shop_id:", req.shop_id, ", version:", req.version, ", type:", req.type)
  self.payStatus = PayEnum.PayStatus.PayForItemSvrReq
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_BUY_GOODS_BY_MIDAS_REQ, req, self, self.QueryForItemURLRsp, true, true)
end

function PayModule:QueryForItemURLRsp(rsp)
  Log.Dump(rsp, 3, "QueryForItemURLRsp")
  Log.Debug(string.format("QueryForItemURLRsp ret_code:%s, url_param:%s", rsp.ret_info.ret_code, rsp.url_param))
  if 0 ~= rsp.ret_info.ret_code then
    Log.Warning("ZoneQueryBalanceRsp return ERR_ZONE_PAY_TOKEN_INVALID")
    NRCEventCenter:DispatchEvent(PayModuleEvent.MidasPayFailed, rsp.type ~= nil and rsp.type or -1, PayEnum.FailType.BACKGROUND_ERROR)
    self.payStatus = PayEnum.PayStatus.None
    if rsp.ret_info.ret_code == ProtoEnum.MOBA_RET.ZoneErr.ERR_ZONE_PAY_TOKEN_INVALID then
    else
      self:ShowBackGroundErr(rsp.ret_info.ret_code)
      if rsp.ret_info and rsp.ret_info.ret_code == ProtoEnum.MOBA_RET.ZoneErr.ERR_ZONE_SHOP_VERSION_NOT_MATCH then
        Log.Warning("QueryForItemURLRsp ERR_ZONE_SHOP_VERSION_NOT_MATCH")
        if nil ~= rsp.shop_id then
          Log.Debug("QueryForItemURLRsp ERR_ZONE_SHOP_VERSION_NOT_MATCH, shop_id:", rsp.shop_id)
          _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.GetStoreListReq, rsp.shop_id)
        else
          Log.Warning("QueryForItemURLRsp ERR_ZONE_SHOP_VERSION_NOT_MATCH, shop_id is nil")
        end
      end
    end
    return
  end
  self.payStatus = PayEnum.PayStatus.PayForItemMidasReq
  local shopID = rsp.shop_id
  self:LaunchMidasPage(rsp.url_param, rsp.type, shopID)
  NRCEventCenter:DispatchEvent(PayModuleEvent.ReceiveGoodsTokenUrl)
end

function PayModule:UpdateBalance()
  local req = _G.ProtoMessage:newZoneQueryBalanceReq()
  req.token_info.pf = self.payData.pf
  req.token_info.access_token = self.payData.accessToken
  req.token_info.pay_token = self.payData.payToken
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_QUERY_BALANCE_REQ, req, self, self.UnifiedQueryRsp, true, true)
end

function PayModule:SetIsKickOutNeedReconnect(bIsKickOutNeedReconnect)
  Log.Debug("[PayModule:SetIsKickOutNeedReconnect] ", bIsKickOutNeedReconnect)
  self.bIsKickOutNeedReconnect = bIsKickOutNeedReconnect
end

function PayModule:OnLogin()
  if self.bIsKickOutNeedReconnect then
    Log.Debug("[PayModule:OnLogin] server restart, no need to update balance")
    return
  end
  Log.Debug("[PayModule:OnLogin]")
  self:UpdateBalance()
end

function PayModule:UnifiedQueryRsp(rsp)
  Log.Dump(rsp, 3, "ZoneQueryBalanceRsp")
  if rsp.ret_info ~= nil then
    if rsp.ret_info.ret_code == ProtoEnum.MOBA_RET.ZoneErr.ERR_ZONE_PAY_TOKEN_INVALID then
      Log.Warning("ZoneQueryBalanceRsp return ERR_ZONE_PAY_TOKEN_INVALID")
      NRCEventCenter:DispatchEvent(PayModuleEvent.NeedReLogin)
      return
    elseif 0 == rsp.ret_info.ret_code then
      local midasBalance = rsp.money_info.midas_balance
      self.payData:UpdateBalanceData(midasBalance)
      self.payData:UpdateSave_amtData(rsp.money_info.midas_save_amt)
      self.payData:UpdateDistribute_amtData(rsp.money_info.distribute_amt, rsp.money_info.total_test_amt)
      NRCEventCenter:DispatchEvent(PayModuleEvent.UpdateBalanceSuccess)
      return
    end
  end
  NRCEventCenter:DispatchEvent(PayModuleEvent.UpdateBalanceFail)
end

function PayModule:SetPayInfo(payInfo)
  if type(payInfo) ~= "table" then
    Log.Debug("PayModuleCmd.SetPayInfo with payInfo which is not table")
    return
  end
  self.payData:UpdatePayInfo(payInfo)
end

function PayModule:ShowBackGroundErr(errorCode)
  if 0 == errorCode then
    return
  end
  local tipsContent = ""
  local tipsTmp = ""
  errorCode = nil ~= errorCode and errorCode or PayEnum.MidasCodeAndroid.SYSTEM_ERROR
  if errorCode == ProtoEnum.MOBA_RET.ZoneErr.ERR_ZONE_SHOP_BUY_IOS_LIMIT and RocoEnv.PLATFORM_IOS then
    tipsTmp = LuaText.ios_ban_pay_tips
  elseif _G.DataConfigManager:GetLocalizationConf(string.format("PAY_ERROR_%s", errorCode)) then
    tipsTmp = _G.DataConfigManager:GetLocalizationConf(string.format("PAY_ERROR_%s", errorCode)).msg
  else
    tipsTmp = LuaText.charge_tips_14
  end
  tipsContent = string.format(tipsTmp, tostring(errorCode))
  local Context = DialogContext()
  Context:SetTitle(LuaText.umg_login_new_2):SetContent(tipsContent):SetMode(DialogContext.Mode.OK):SetCloseOnOK(true):SetCloseOnCancel(true):SetButtonText(LuaText.YES)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
end

function PayModule:ShowFailTips(errorCode)
  if 0 == errorCode then
    return
  end
  local tipsContent = ""
  local tipsTmp = ""
  errorCode = nil ~= errorCode and errorCode or PayEnum.MidasCodeAndroid.SYSTEM_ERROR
  local errorCodePrefix = "PAY_ERROR_"
  if RocoEnv.PLATFORM_ANDROID then
    errorCodePrefix = errorCodePrefix .. "ANDROID"
  elseif RocoEnv.PLATFORM_IOS then
    errorCodePrefix = errorCodePrefix .. "IOS"
  elseif RocoEnv.PLATFORM_OPENHARMONY then
    errorCodePrefix = errorCodePrefix .. "OPENHARMONY"
  end
  if RocoEnv.PLATFORM_ANDROID and errorCode == PayEnum.MidasCodeAndroid.USER_CANCELED or RocoEnv.PLATFORM_IOS and errorCode == PayEnum.MidasCodeIOS.USER_CANCELED or RocoEnv.PLATFORM_OPENHARMONY and errorCode == PayEnum.MidasCodeOpenHarmony.USER_CANCELLED or RocoEnv.PLATFORM_WINDOWS and errorCode == PayEnum.MidasCodePC.USER_CANCELED then
    tipsContent = string.format(LuaText.charge_tips_0, tostring(errorCode))
  else
    if _G.DataConfigManager:GetLocalizationConf(string.format("%s_%s", errorCodePrefix, errorCode)) then
      tipsTmp = _G.DataConfigManager:GetLocalizationConf(string.format("%s_%s", errorCodePrefix, errorCode)).msg
    else
      tipsTmp = LuaText.charge_tips_1
    end
    tipsContent = string.format(tipsTmp, tostring(errorCode))
  end
  local Context = DialogContext()
  Context:SetTitle(LuaText.umg_login_new_2):SetContent(tipsContent):SetMode(DialogContext.Mode.OK):SetCloseOnOK(true):SetCloseOnCancel(true):SetButtonText(LuaText.YES)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog2, Context)
end

function PayModule:CallRelogin(goodsType, errorCode)
  if errorCode ~= PayEnum.FailType.NEED_LOGIN and errorCode ~= ProtoEnum.MOBA_RET.ZoneErr.ERR_ZONE_PAY_TOKEN_INVALID then
    return
  end
  local content = string.format(LuaText.charge_tips_19, tostring(errorCode))
  Log.PrintScreenMsg("CallRelogin invoked")
  
  local function ReLogin()
    if RocoEnv.PLATFORM_ANDROID or RocoEnv.PLATFORM_IOS or RocoEnv.PLATFORM_OPENHARMONY then
      local userAccountInfo = NRCModuleManager:DoCmd(OnlineModuleCmd.GetUserAccountInfo)
      local loginChannel = userAccountInfo.loginChannel
      if table.contains(LoginEnum.ChannelNames, loginChannel) then
        Log.Debug("LoginStatics.Login invoked")
        local loginExtraParam = ""
        if string.lower(loginChannel) == "wechat" and not UE.ULoginStatics.IsVxInstalled() then
          loginExtraParam = "{\"QRCode\":true}"
        end
        UE.ULoginStatics.Login(loginChannel, "", "", loginExtraParam)
      else
        Log.Error("invalid channel")
        return
      end
    elseif RocoEnv.PLATFORM_WINDOWS then
      UE.UNRCStatics.QuitGame()
    end
  end
  
  local Context = DialogContext()
  Context:SetTitle(LuaText.umg_login_new_2):SetContent(content):SetMode(DialogContext.Mode.OK_CANCEL):SetCloseOnOK(true):SetCloseOnCancel(true):SetButtonText(LuaText.charge_tips_21, LuaText.charge_tips_20):SetCallbackOkOnly(self, ReLogin)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
end

function PayModule:GetPayInfo()
  return self.payData:GetPayInfo()
end

function PayModule:GetSaveAmt()
  return self.payData.save_amt, self.payData.distribute_amt, self.payData.totalTestAmt
end

function PayModule:IsPaying()
  return self.payStatus ~= PayEnum.PayStatus.None
end

function PayModule:SetPayStatus(status)
  self.payStatus = status
end

function PayModule:ClearPayInfo()
  self.payData:ClearPayInfo()
end

function PayModule:SetPayGoodsInfo(payGoodsInfo)
  Log.Debug("SetPayGoodsInfo with payGoodsInfo" .. table.tostring(payGoodsInfo))
  self.payGoodsInfo = payGoodsInfo
end

function PayModule:GetPayGoodsInfo()
  return self.payGoodsInfo
end

function PayModule:ShutDown()
  self:ClearPayInfo()
end

function PayModule:OnMoneyInfoChanged(rsp)
  if rsp.coupon_change_val == nil then
    Log.Error("OnMoneyInfoChanged with coupon_change_val is nil")
    return
  end
  Log.Debug("OnMoneyInfoChanged with coupon_change_val" .. rsp.coupon_change_val)
  if rsp.coupon_change_val > 0 then
    _G.NRCEventCenter:DispatchEvent(PayModuleEvent.OnChargeBackgroundSuccess)
    local Context = DialogContext()
    Context:SetTitle(LuaText.umg_login_new_2):SetContent(LuaText.charge_tips_22):SetMode(DialogContext.Mode.OK):SetCloseOnOK(true):SetCloseOnCancel(true):SetButtonText(LuaText.YES)
    NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenDialog, Context)
    self.payData:UpdateBalanceData(rsp.data.midas_balance)
  end
end

return PayModule
