local LevelUpUtils = require("NewRoco.Modules.System.LevelUpUI.LevelUpUtils")
local NPCActionModelBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionModelBase
local NPCActionPromoteUI = Base:Extend("NPCActionPromoteUI")

function NPCActionPromoteUI:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionPromoteUI:ExecuteWithModel()
  local worldLevel = LevelUpUtils.GetWorldLevelConf()
  if worldLevel then
    _G.NRCModuleManager:DoCmd(LevelUpUIModuleCmd.OpenLevelMagicianPanel, {action = self})
  else
    self:EndAction()
  end
end

function NPCActionPromoteUI:TryOpenLevelMagicianPanel(rsp)
end

function NPCActionPromoteUI:OnCameraStartEnd()
end

function NPCActionPromoteUI:EndAction()
  self:Finish()
end

return NPCActionPromoteUI
