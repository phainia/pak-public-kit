require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local BP_NPCParticle_C = Base:Extend("BP_NPCParticle_C")

function BP_NPCParticle_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_NPCParticle_C:Init()
  Base.Init(self)
  self.bEmptyNPC = true
end

function BP_NPCParticle_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_NPCParticle_C:LoadLockEffect()
end

function BP_NPCParticle_C:PlayUnlockEffect(lockNum)
end

function BP_NPCParticle_C:PlayNiagaraSystem(NiagaraPath)
  self.NRCNiagaraSystem.OnSystemFinished:Add(self, self.NiagaraDone)
  self.NRCNiagaraSystem:SetPath(NiagaraPath)
end

function BP_NPCParticle_C:NiagaraDone(NiagaraSystem)
  Log.Error("Niagara System Down")
  _G.NRCModuleManager:DoCmd(NPCModuleCmd.DeleteParticleNPC, self.sceneCharacter)
end

return BP_NPCParticle_C
