local NPCActionModelBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionModelBase
local NPCActionEnablePetSubmit = Base:Extend("NPCActionEnablePetSubmit")

function NPCActionEnablePetSubmit:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionEnablePetSubmit:ExecuteWithModel()
  ProtoMessage:newZonePetTeamChangeReq()
  local CampFire = self:GetOwnerNPCView()
  CampFire.sceneCharacter.InteractionComponent:TryDisableInteraction()
end

function NPCActionEnablePetSubmit:OnSubmit(rsp)
  local CampFire = self:GetOwnerNPCView()
  CampFire.sceneCharacter.InteractionComponent:TryEnableInteraction()
  self:Finish()
end

function NPCActionEnablePetSubmit:Callback(Characters)
end

function NPCActionEnablePetSubmit:OnCameraStartEnd(Event, Skill)
end

function NPCActionEnablePetSubmit:EndAction()
  self:Finish()
end

function NPCActionEnablePetSubmit:OnCameraEndEnd(Event, Skill)
end

return NPCActionEnablePetSubmit
