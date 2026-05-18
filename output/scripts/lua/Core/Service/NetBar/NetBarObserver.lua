local LoginUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")
local NetBarObserver = NRCClass()

function NetBarObserver:Initialize()
  Log.Debug("NetBarObserver")
  NRCEventCenter:RegisterEvent("NetBarObserver", self, _G.NRCGlobalEvent.ON_LOGIN, self.OnLogin)
end

function NetBarObserver:OnReqNetbarLv2(nb)
  if RocoEnv.PLATFORM_WINDOWS then
    local open_id
    local loginData = LoginUtils.GetLoginData()
    if nil ~= loginData then
      open_id = loginData:GetOpenID()
    else
      Log.Info("LoginData is nil")
      open_id = NRCModuleManager:DoCmd(OnlineModuleCmd.GetOpenID)
    end
    Log.Info("NetBarObserver:OnReqNetbarLv2 ", nb.retCode, nb.macs:Num(), " local open id ", open_id, " passed_in open id ", nb.openId)
    if 0 == nb.retCode and open_id == nb.openId then
      local token = nb.token
      local ip = nb.ip
      local mac_arr = {}
      for i = 1, nb.macs:Num() do
        table.insert(mac_arr, nb.macs:Get(i))
      end
      Log.Info("token: ", token, " ip ", ip, " macs ", table.concat(mac_arr, ";"))
      NRCModuleManager:DoCmd(OnlineModuleCmd.SetNetBarData, nb.openId, nb.retCode, token, ip, mac_arr)
    else
      Log.Error("NetBarObserver:OnReqNetbarLv2 failed retCode ", nb.retCode)
      if 0 == nb.retCode then
        NRCModuleManager:DoCmd(OnlineModuleCmd.SetNetBarData, nil, -9999)
      end
    end
  end
end

function NetBarObserver:OnLogin()
  local netBarData = NRCModuleManager:DoCmd(OnlineModuleCmd.GetNetBarData)
  if not netBarData then
    Log.Info("NetBarObserver:OnLogin netbardata is nil")
    return
  end
  local ret_code = netBarData.net_bar_ret_code
  local open_id = NRCModuleManager:DoCmd(OnlineModuleCmd.GetOpenID)
  local net_bar_open_id = netBarData.open_id
  Log.Info("NetBarObserver:OnLogin ", ret_code, " open_id ", open_id, " net_bar_open_id ", net_bar_open_id, " net_bar_client_ip ", netBarData.net_bar_client_ip, " net_bar_token ", netBarData.net_bar_token, " net_bar_macs ", netBarData.net_bar_macs and table.concat(netBarData.net_bar_macs, ";") or "nil")
  if RocoEnv.PLATFORM_WINDOWS then
    if ret_code and 0 == ret_code and open_id and net_bar_open_id and open_id == net_bar_open_id then
      local req = _G.ProtoMessage:newZoneClaimNetbarRewardReq()
      req.ip = netBarData.net_bar_client_ip
      req.netbar_token = netBarData.net_bar_token
      req.macs = netBarData.net_bar_macs
      _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_CLAIM_NETBAR_REWARD_REQ, req, self, self.OnClaimNetBarRewardRsp)
    end
    NRCModuleManager:DoCmd(OnlineModuleCmd.SetNetBarData)
  end
end

function NetBarObserver:OnClaimNetBarRewardRsp(rsp)
  if RocoEnv.PLATFORM_WINDOWS then
    if nil == rsp then
      Log.Error("NetBarObserver:OnClaimNetBarRewardRsp rsp is nil")
      return
    end
    Log.Info("NetBarObserver:OnClaimNetBarRewardRsp ", rsp.netbar_errcode)
    if rsp.ret_info then
      Log.Info("NetBarObserver:OnClaimNetBarRewardRsp ", rsp.ret_info.ret_code, rsp.ret_info.ret_msg)
    end
  end
end

return NetBarObserver
