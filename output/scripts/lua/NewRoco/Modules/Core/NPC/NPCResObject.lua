local ResObjectBase = require("NewRoco.Utils.ResObjectBase")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local ResObjectState = require("NewRoco.Utils.ResObjectState")
local Base = ResObjectBase
local NPCResObject = Base:Extend("NPCResObject")

function NPCResObject.MakeNPC(ConfID, Position, Dir, PetGID, Priority)
  if not ConfID or 0 == ConfID then
    return nil
  end
  local Res = NPCResObject(ConfID, Position, Dir, PetGID, Priority)
  return Res
end

function NPCResObject.MakeLocalPet(Session, Priority)
  if not Session then
    return nil
  end
  local Res = NPCResObject()
  Res.Session = Session
  Res.Priority = Priority or -1
  return Res
end

function NPCResObject:Ctor(ConfID, Position, Dir, PetGID, Priority)
  Base.Ctor(self)
  self.NPC = nil
  self.ConfID = ConfID
  self.Position = Position
  self.Dir = Dir
  self.PetGID = PetGID
  self.ID = 0
  self.DisableFixCoord = false
  self.ShouldCreateView = false
  self.Priority = Priority or -1
end

function NPCResObject:DoLoad()
  local NPC
  if self.Session then
    NPC = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.CreateLocalPet, self.Session, self.Priority)
    if NPC then
      NPC:SetVisibleForCallOutReason(false)
      if NPC.AIComponent then
        NPC.AIComponent:ForceLockForReason(true, true, AIDefines.LockReason.BORN_DIE)
      end
    end
  elseif self.NPC then
    NPC = self.NPC
    if NPC and not NPC.viewObj and self.ShouldCreateView then
      NPC:CreateView(false, self.Priority)
    end
  else
    NPC = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.CreateLocalNPC, self.ConfID, self.Position, self.Dir, self.PetGID, self.Priority)
  end
  if not NPC then
    self:FireCallback(false)
    return
  end
  NPC:UpdateFlags()
  NPC:AddEventListener(self, NPCModuleEvent.On_NPC_Destroy, self.OnNPCDestroyed)
  self.ID = NPC:GetServerId()
  self.NPC = NPC
  if NPC.viewObj then
    self:OnViewShellReady(NPC)
  else
    NPC:AddEventListener(self, NPCModuleEvent.VIEW_SHELL_LOADED, self.OnViewShellReady)
  end
end

function NPCResObject:DoGet()
  if self.NPC then
    return self.NPC
  end
  return _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, self.ID)
end

function NPCResObject:DoRelease()
  if self.NPC then
    self.NPC:RemoveEventListener(self, NPCModuleEvent.VIEW_SHELL_LOADED, self.OnViewShellReady)
    self.NPC:RemoveEventListener(self, NPCModuleEvent.On_NPC_Destroy, self.OnNPCDestroyed)
  end
  self.ID = 0
  self.NPC = nil
end

function NPCResObject:OnViewShellReady(NPC)
  if not NPC then
    self:FireCallback(false)
    return
  end
  NPC:RemoveEventListener(self, NPCModuleEvent.VIEW_SHELL_LOADED, self.OnViewShellReady)
  local View = NPC.viewObj
  if self.DisableFixCoord then
    View.forbidFixCoord = true
  end
  if View.resourceLoaded then
    self:OnViewResReady(View)
  else
    View:TriggerLoadResources(self, self.OnViewResReady)
  end
end

function NPCResObject:OnViewResReady(View)
  if not View then
    self:FireCallback(false)
    return
  end
  local Character = View.sceneCharacter
  if not Character then
    self:FireCallback(false)
    return
  end
  Character:RemoveEventListener(self, NPCModuleEvent.On_NPC_Destroy, self.OnNPCDestroyed)
  Character:UpdateFlags()
  self:FireCallback(true)
  if Character.AIComponent then
    Character.AIComponent:ForceLockForReason(false, true, AIDefines.LockReason.BORN_DIE)
  end
end

function NPCResObject:OnNPCDestroyed(NPC)
  NPC:RemoveEventListener(self, NPCModuleEvent.On_NPC_Destroy, self.OnNPCDestroyed)
  if self.State ~= ResObjectState.Loading then
    return
  end
  self:FireCallback(false)
end

return NPCResObject
