require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewDropNPCBase")
local BP_NPCSkeletalBase_C = Base:Extend("BP_NPCSkeletalBase_C")

function BP_NPCSkeletalBase_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_NPCSkeletalBase_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
  self:AddSkeletalMeshRes(self.MeshRes, self.SkeletalMesh)
  self:AddParticleRes(self.iconDropRes, self.Icon_Drop)
  self:AddParticleRes(self.itemGleamRes, self.Item_Gleam)
end

return BP_NPCSkeletalBase_C
