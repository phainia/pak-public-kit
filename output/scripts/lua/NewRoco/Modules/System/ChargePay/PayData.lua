local JsonUtils = require("Common.JsonUtils")
local ShopModuleEvent = reload("NewRoco.Modules.System.Shop.ShopModuleEvent")
local PayData = _G.NRCData:Extend("PayData")

function PayData:Ctor()
  NRCData.Ctor(self)
  self.openId = ""
  self.accessToken = ""
  self.payToken = ""
  self.pf = ""
  self.pfKey = ""
  self.midasBalance = 0
  self.save_amt = 0
  self.distribute_amt = 0
  self.totalTestAmt = 0
end

function PayData:UpdateBalanceData(balance)
  Log.Debug("UpdateBalanceData with balance: ", balance)
  self.midasBalance = balance
end

function PayData:UpdateSave_amtData(save_amt)
  Log.Debug("UpdateBalanceData with Save_amt: ", save_amt)
  self.save_amt = save_amt
  _G.NRCEventCenter:DispatchEvent(ShopModuleEvent.RefreshTopUpRebateData)
end

function PayData:UpdateDistribute_amtData(distribute_amt, totalTestAmt)
  Log.Debug("UpdateBalanceData with distribute_amt: ", distribute_amt)
  self.distribute_amt = distribute_amt
  self.totalTestAmt = totalTestAmt
  _G.NRCEventCenter:DispatchEvent(ShopModuleEvent.RefreshTopUpRebateData)
end

function PayData:UpdatePayInfo(payInfo)
  Log.Dump(payInfo, 1, "UpdatePayInfo")
  self.openId = payInfo.openId ~= nil and payInfo.openId or ""
  self.accessToken = nil ~= payInfo.token and payInfo.token or ""
  local channelInfo = nil ~= payInfo.channelInfo and payInfo.channelInfo or ""
  local channel = payInfo.channel
  if RocoEnv.PLATFORM_ANDROID or RocoEnv.PLATFORM_IOS or RocoEnv.PLATFORM_OPENHARMONY then
    if "WeChat" == channel then
      self.payToken = nil ~= payInfo.token and payInfo.token or ""
    elseif "QQ" == channel then
      local ChannelInfo = JsonUtils.StringToJson(channelInfo)
      self.payToken = nil ~= ChannelInfo.pay_token and ChannelInfo.pay_token or ""
    else
      Log.Error("payToken set support WeChat and QQ only")
      self.payToken = ""
    end
    self.pf = nil ~= payInfo.pf and payInfo.pf or ""
    self.pfKey = nil ~= payInfo.pfKey and payInfo.pfKey or ""
  elseif RocoEnv.PLATFORM_WINDOWS then
    self.payToken = nil ~= payInfo.token and payInfo.token or ""
    self.pfKey = nil ~= payInfo.pfKey and payInfo.pfKey or ""
    self.pf = nil ~= payInfo.pf and payInfo.pf:gsub("web", "android") or ""
    self.pf = self.pf:gsub("h5", "android")
  end
  NRCModuleManager:DoCmd(OnlineModuleCmd.SetUserPayInfo, self.pf, self.payToken)
end

function PayData:GetPayInfo()
  return self.pf, self.payToken
end

function PayData:ClearPayInfo()
  self.openId = ""
  self.accessToken = ""
  self.payToken = ""
  self.pf = ""
  self.pfKey = ""
  self.midasBalance = 0
end

return PayData
