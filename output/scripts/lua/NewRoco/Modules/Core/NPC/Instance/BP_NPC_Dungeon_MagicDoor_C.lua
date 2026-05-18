local Base = require("NewRoco.Modules.Core.NPC.Instance.BP_NPCInstanceMechanismBase_C")
local BP_NPC_Dungeon_MagicDoor_C = Base:Extend("BP_NPC_Dungeon_MagicDoor_C")

function BP_NPC_Dungeon_MagicDoor_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_NPC_Dungeon_MagicDoor_C:ReceiveDestroyed()
  if self.doorInitHandle then
    _G.DelayManager:CancelDelay(self.doorInitHandle)
    self.doorInitHandle = nil
  end
  Base.ReceiveDestroyed(self)
end

function BP_NPC_Dungeon_MagicDoor_C:OnVisible()
  if 1 == self.CurrentState then
    self:ForceHide()
  else
    self:Deactivate(false)
  end
end

function BP_NPC_Dungeon_MagicDoor_C:Activate(bInit)
  if bInit then
    self:ForceHide()
    return
  end
  _G.NRCAudioManager:PlaySound3DWithActor(10020004, self, "BP_NPC_Dungeon_MagicDoor", false, false)
  self:SetNiagaraState(self.Normal, false)
  self:SetNiagaraState(self.Active, true)
  self.doorInitHandle = _G.DelayManager:DelaySeconds(2.0, self.SetDoorState, self, false)
end

function BP_NPC_Dungeon_MagicDoor_C:Deactivate(bInit)
  if bInit then
    return
  end
  self:SetNiagaraState(self.Normal, true)
  self:SetNiagaraState(self.Active, false)
  self:SetDoorState(true)
end

function BP_NPC_Dungeon_MagicDoor_C:SetNiagaraState(niagara, bIsActive)
  if not niagara or not UE4.UObject.IsValid(niagara) then
    return
  end
  niagara:SetVisibility(bIsActive)
  if bIsActive then
    niagara:Activate(true)
  else
    niagara:Deactivate()
  end
end

function BP_NPC_Dungeon_MagicDoor_C:SetDoorState(bIsClocked)
  if not self.sceneCharacter or not UE4.UObject.IsValid(self) then
    return
  end
  self.doorInitHandle = nil
  if bIsClocked then
    self.Box:SetCollisionProfileName("InvisibleWall")
  else
    self.Box:SetCollisionProfileName("NoCollision")
  end
end

function BP_NPC_Dungeon_MagicDoor_C:ForceHide()
  self:SetNiagaraState(self.Normal, false)
  self:SetNiagaraState(self.Active, false)
  self:SetDoorState(false)
end

return BP_NPC_Dungeon_MagicDoor_C
