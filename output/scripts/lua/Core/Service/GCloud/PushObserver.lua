local rapidjson = require("rapidjson")
local OnlineModuleCmd = require("NewRoco.Modules.Core.Online.OnlineModuleCmd")
local LoginUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")
local PushObserver = Class()

function PushObserver:Ctor()
end

function PushObserver:OnPushOptNotify(base_ret)
  Log.Debug("PushObserver:OnPushOptNotify ", base_ret.method_id, base_ret.ret_code, base_ret.ret_msg, base_ret.third_code, base_ret.third_msg, base_ret.extra_json)
  if base_ret.method_id == 10401 then
    local extra_json = tostring(base_ret.extra_json)
    Log.Debug("RegisterPush ", base_ret.ret_code, extra_json)
    local status, extraTable = pcall(rapidjson.decode, extra_json)
    Log.Info("PushObserver:OnPushOptNotify ", status, extraTable)
    if status and extraTable then
      local xgTpnsToken = extraTable.xgTpnsToken
      Log.Info("PushObserver:OnPushOptNotify xgTpnsToken=", xgTpnsToken)
      if xgTpnsToken and "" ~= xgTpnsToken then
        if LoginUtils.GetLoginData() then
          LoginUtils.GetLoginData():SetTpnsToken(xgTpnsToken)
        end
        if _G.NRCModuleManager:GetModule("OnlineModule") then
          _G.NRCModuleManager:DoCmd(OnlineModuleCmd.SetTpnsToken, xgTpnsToken)
        end
      end
    end
  elseif base_ret.method_id == 10402 then
    Log.Debug("UnRegisterPush ", base_ret.ret_code)
  end
end

function PushObserver:OnReceiveNotification(push_ret)
end

return PushObserver
