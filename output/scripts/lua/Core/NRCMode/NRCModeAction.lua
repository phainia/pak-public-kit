local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local FsmAction = require("NewRoco.Modules.Core.Fsm.FsmAction")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = FsmAction
local NRCModeAction = Base:Extend("NRCModeAction")

function NRCModeAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.timeout = 99999999999999999
end

function NRCModeAction:OnEnter()
end

function NRCModeAction:OnExit()
end

function NRCModeAction:ActiveModule(moduleName)
  local status, err, _ = xpcall(function()
    _G.NRCModuleManager:ActiveModule(moduleName)
  end, debug.traceback)
  if not status then
    if not _G.RocoEnv.IS_EDITOR then
      _G.NRCSDKManager:CrashSightReportExceptionWithReason(string.format("Module:OnActive\229\188\130\229\184\184%s", moduleName), "Lua,OnTick,Exception", err)
    end
    self:PopError(moduleName, err)
    Log.Error(err)
  end
end

function NRCModeAction:PopError(moduleName, err)
  if _G.RocoEnv.IS_SHIPPING then
    return
  end
  self.fsm:Pause()
  local Errors = string.split(err, "\n")
  local NewLines = {}
  for i = 1, 5 do
    if Errors[i] then
      table.insert(NewLines, Errors[i])
    else
      break
    end
  end
  local Shorten = table.concat(NewLines, "\n")
  local Ctx = DialogContext()
  Ctx:SetTitle("\229\143\145\231\148\159\228\184\165\233\135\141\233\148\153\232\175\175")
  Ctx:SetContent(string.format("\230\168\161\229\157\151%s\229\136\157\229\167\139\229\140\150\233\148\153\232\175\175\239\188\140\232\175\183\229\176\134\230\156\172\230\136\170\229\155\190\229\143\145\231\187\153\229\174\162\230\136\183\231\171\175\229\188\128\229\143\145\239\188\140\232\176\162\232\176\162\n%s", moduleName, Shorten))
  Ctx:SetMode(DialogContext.Mode.OK)
  Ctx:SetCallback(nil, function()
    UE.UNRCStatics.QuitGame()
  end)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function NRCModeAction:DoCmdAsync(cmd, tCallback, ...)
  NRCModeManager:DoCmdAsync({owner = self, callback = tCallback}, cmd, ...)
end

function NRCModeAction:DoCmdAsyncToFinish(cmd, tCallback)
  local callback = tCallback or self.Finish
  NRCModuleManager:DoCmdAsync({owner = self, callback = callback}, cmd)
end

function NRCModeAction:DoCmd(cmd, ...)
  NRCModuleManager:DoCmd(cmd, ...)
end

return NRCModeAction
