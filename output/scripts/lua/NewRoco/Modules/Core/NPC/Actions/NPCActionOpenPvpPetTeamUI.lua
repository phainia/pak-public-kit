local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionBase
local NPCActionOpenPvpPetTeamUI = Base:Extend("NPCActionOpenPvpPetTeamUI")

function NPCActionOpenPvpPetTeamUI:Ctor(Owner, Config, Info)
  NPCActionBase.Ctor(self, Owner, Config, Info)
  self.Config = Config
  self.TeamType = Enum.PlayerTeamType[Config.action_param1]
end

function NPCActionOpenPvpPetTeamUI:ExecuteWithModel()
  if not self.TeamType then
    Log.Error("NPCActionOpenPvpPetTeamUI.ExecuteWithModel.func Error,\230\137\147\229\188\128\231\178\190\231\129\181\231\188\150\233\152\159\231\149\140\233\157\162\229\164\177\232\180\165\239\188\140\229\143\130\230\149\176\231\177\187\229\158\139\230\156\137\233\151\174\233\162\152\239\188\140action_param1=", self.Config.action_param1)
    self:EndAction()
    return
  end
  local type = self.TeamType or Enum.PlayerTeamType.PTT_PVP_BATTLE_1
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenPetTeamPanel, type, self, self.EndAction)
end

function NPCActionOpenPvpPetTeamUI:EndAction()
  self:Finish()
end

return NPCActionOpenPvpPetTeamUI
