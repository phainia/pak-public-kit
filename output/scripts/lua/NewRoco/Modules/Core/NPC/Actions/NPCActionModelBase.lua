local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local Base = NPCActionBase
local NPCActionModelBase = Base:Extend("NPCActionModelBase")

function NPCActionModelBase:Ctor(Owner, Config, Info, OwnerNpc)
  Base.Ctor(self, Owner, Config, Info, OwnerNpc)
end

function NPCActionModelBase:Execute(playerId, needSendReq)
  Base.Execute(self, playerId, needSendReq)
  local NPC = self:GetOwnerNPC()
  if not NPC or NPC.isDestroy then
    Log.Error("\230\173\163\229\156\168\228\186\164\228\186\146\231\154\132NPC\232\162\171\229\136\160\228\186\134!!!!!!!!")
    self:Finish(false)
    return
  end
  if NPC then
    if self:GetOwnerNPCView() then
      self:ExecuteWithModel()
    else
      NPC:AddEventListener(self, NPCModuleEvent.VIEW_LOADED, self.ExecuteWithModel)
    end
  end
end

function NPCActionModelBase:ExecuteWithModel()
end

function NPCActionModelBase:Finish(success, data, param)
  Base.Finish(self, success, data, param)
end

function NPCActionModelBase:GetOwnerNPC()
  return Base.GetOwnerNPC(self)
end

function NPCActionModelBase:GetOwnerNPCView()
  return Base.GetOwnerNPCView(self)
end

function NPCActionModelBase:UpdateInfo(Info, Reconnect, InteractingAvatarID)
  Base.UpdateInfo(self, Info, Reconnect, InteractingAvatarID)
end

function NPCActionModelBase:OnNpcAction()
  return Base.OnNpcAction(self)
end

return NPCActionModelBase
