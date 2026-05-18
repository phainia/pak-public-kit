local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local PayModuleEvent = require("NewRoco.Modules.System.ChargePay.PayModuleEvent")
local Base = DebugTabBase
local DebugTabPay = Base:Extend("DebugTabPay")

function DebugTabPay:Ctor()
  Base.Ctor(self)
end

function DebugTabPay:SetupTabs()
  self:Add("\230\139\137\232\181\183PC\230\148\175\228\187\152\233\161\181", self.LaunchPayPageOnPC, self)
  self:Add("\229\146\149\229\153\156\231\144\131\232\161\165\231\187\153", self.PayForGoods, self)
  self:Add("\232\180\173\228\185\176\230\180\155\229\133\139\233\146\187", self.PayForGameCoin, self)
  self:Add("\230\159\165\232\175\162\228\189\153\233\162\157", self.QueryBalance, self)
  self:Add("\229\136\157\229\167\139\229\140\150\231\177\179\229\164\167\229\184\136", self.InitMidas, self)
  _G.NRCSDKManager:AddEventListener(self, PayModuleEvent.MidasPaySuccess, self.ProcessSuccessPayResult)
  _G.NRCSDKManager:AddEventListener(self, PayModuleEvent.MidasPayFailed, self.ProcessFailPayResult)
  _G.NRCSDKManager:AddEventListener(self, PayModuleEvent.UserCanceled, self.ProcessCancel)
end

function DebugTabPay:ShowReadMe(name, panel)
  UE4.UKismetSystemLibrary.LaunchURL("https://iwiki.woa.com/pages/viewpage.action?pageId=827460344")
end

function DebugTabPay:LaunchPayPageOnPC()
  NRCModuleManager:DoCmd(PayModuleCmd.LaunchMidasPage)
end

function DebugTabPay:PayForGoods()
  local itemId = self:GetInputNumber(18008)
  NRCModuleManager:DoCmd(PayModuleCmd.PayForItem, itemId)
end

function DebugTabPay:PayForGameCoin()
  local itemId = self:GetInputNumber(18001)
  NRCModuleManager:DoCmd(PayModuleCmd.PayForCharge, 18001)
end

function DebugTabPay:QueryBalance()
  NRCModuleManager:DoCmd(PayModuleCmd.UpdateBalance)
end

function DebugTabPay:InitMidas()
  NRCModuleManager:DoCmd(PayModuleCmd.InitializeMidas)
end

function DebugTabPay:ProcessSuccessPayResult()
  Log.PrintScreenMsg("pay success!")
end

function DebugTabPay:ProcessFailPayResult(goodsType, ext)
  Log.PrintScreenMsg("Pay failed with goodsType:%s and ext:%s ", goodsType, ext)
end

function DebugTabPay:ProcessCancel(goodsType)
  Log.PrintScreenMsg("User Canceled with goodsType :%s", goodsType)
end

return DebugTabPay
