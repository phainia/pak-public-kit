require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local BP_NPCIronPan_C = Base:Extend("BP_NPCIronPan_C")

function BP_NPCIronPan_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_NPCIronPan_C:Init()
  Base.Init(self)
end

function BP_NPCIronPan_C:OnVisible()
  Base.OnVisible(self)
  self.NRCNiagaraSystem:K2_AttachToComponent(self.NRCSkeletalMesh, "Bone_guo_U_06Socket", UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget)
end

function BP_NPCIronPan_C:OnInVisible()
  Base.OnInVisible(self)
end

return BP_NPCIronPan_C
