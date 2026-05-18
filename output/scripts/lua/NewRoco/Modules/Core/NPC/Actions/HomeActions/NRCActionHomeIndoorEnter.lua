local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local M = Base:Extend("NRCActionHomeIndoorEnter")

function M:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function M:Execute()
  self.SkipSubmit = true
  Base.Execute(self)
  
  local function OnSuccess()
    self.SkipSubmit = false
    self:Submit()
    self:Finish()
  end
  
  local function OnFailed()
    self.needSendReq = false
    self.SkipSubmit = false
    self:Submit()
    self:Finish()
  end
  
  NRCModuleManager:DoCmd(HomeModuleCmd.ReqEnterPlayerHomeIndoor, nil, nil, OnSuccess, OnFailed, true)
end

function M:OnSubmitErrorRetInfo(RetInfo, Rsp)
  return HomeIndoorSandbox and HomeIndoorSandbox.HomeTipsServ:TryProcessHomeVisitLimits(RetInfo, Rsp)
end

function M:OnCommitErrorRetInfo(RetInfo, Rsp)
  return HomeIndoorSandbox and HomeIndoorSandbox.HomeTipsServ:TryProcessHomeVisitLimits(RetInfo, Rsp)
end

return M
