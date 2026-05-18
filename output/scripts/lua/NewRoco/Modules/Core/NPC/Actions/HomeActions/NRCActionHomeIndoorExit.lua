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
  
  _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.OnZoneSceneHomeTeamQueryReq, OnSuccess, OnFailed)
end

function M:OnSubmitErrorRetInfo(RetInfo, Rsp)
  return HomeIndoorSandbox and HomeIndoorSandbox.HomeTipsServ:ConditionalDisplayError(RetInfo)
end

function M:OnCommitErrorRetInfo(RetInfo, Rsp)
  return HomeIndoorSandbox and HomeIndoorSandbox.HomeTipsServ:ConditionalDisplayError(RetInfo)
end

return M
