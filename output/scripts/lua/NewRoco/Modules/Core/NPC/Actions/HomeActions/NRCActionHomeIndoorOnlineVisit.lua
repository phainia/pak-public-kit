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
    self.needSendReq = false
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
  
  if HomeIndoorSandbox:InLocalMasterIndoor() then
    OnFailed()
    return
  end
  local Uin = HomeIndoorSandbox.Server.MasterId
  local MasterName = HomeIndoorSandbox.Server.WorldData.MasterName
  local Ctx = DialogContext()
  Ctx:SetTitle(LuaText.TIPS)
  Ctx:SetContent(string.format(LuaText.offline_visit_bigworld_tips, MasterName))
  Ctx:SetMode(DialogContext.Mode.OK_CANCEL)
  Ctx:SetButtonText(LuaText.YES, LuaText.NO)
  Ctx:SetBanFullScreenBtn()
  Ctx:SetCallback(self, function(_, IsOK)
    if IsOK then
      _G.NRCModuleManager:DoCmd(FriendModuleCmd.ReqZonePlayerInteract, Uin, ProtoEnum.PlayerInteractType.Visiting)
      if OnSuccess then
        OnSuccess()
      end
    elseif OnFailed then
      OnFailed()
    end
  end)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function M:OnSubmitErrorRetInfo(RetInfo, Rsp)
  return HomeIndoorSandbox and HomeIndoorSandbox.HomeTipsServ:ConditionalDisplayError(RetInfo)
end

function M:OnCommitErrorRetInfo(RetInfo, Rsp)
  return HomeIndoorSandbox and HomeIndoorSandbox.HomeTipsServ:ConditionalDisplayError(RetInfo)
end

return M
