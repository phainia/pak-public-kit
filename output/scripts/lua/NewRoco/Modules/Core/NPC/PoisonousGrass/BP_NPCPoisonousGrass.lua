local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Base = ViewNPCBase
local BP_NPCPoisonousGrass = Base:Extend("BP_NPCPoisonousGrass")

function BP_NPCPoisonousGrass:OnLoadResource()
  Base.OnLoadResource(self)
  self:InitABPState()
end

function BP_NPCPoisonousGrass:LuaBeginPlay()
  Base.LuaBeginPlay(self)
  self:InitABPState()
end

function BP_NPCPoisonousGrass:InitABPState()
  local animInst = self:GetAnimInstance()
  if not animInst then
    Log.Error("PoisonousGrass cannot find AnimInstance!")
    return
  end
  animInst.isAbsorbed = self:CheckAvatarCanInteract()
end

function BP_NPCPoisonousGrass:GetAnimInstance()
  if not self.SkeletalMesh then
    return nil
  end
  return self.SkeletalMesh:GetAnimInstance()
end

function BP_NPCPoisonousGrass:CanEnterThrowInter(Comp)
  return Comp and Comp == self.SkeletalMesh
end

function BP_NPCPoisonousGrass:CheckAvatarCanInteract()
  if not self.sceneCharacter then
    return false
  end
  return self.sceneCharacter.LogicStatusComponent:GetStatus(Enum.SpaceActorLogicStatus.SALS_TRIGGER_ON)
end

return BP_NPCPoisonousGrass
