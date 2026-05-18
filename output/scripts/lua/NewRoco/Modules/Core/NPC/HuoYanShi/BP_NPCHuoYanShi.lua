local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Base = ViewNPCBase
local BP_NPCHuoYanShi = Base:Extend("BP_NPCHuoYanShi")

function BP_NPCHuoYanShi:OnLoadResource()
  Base.OnLoadResource(self)
  if self:CheckAvatarCanInteract() then
    self:Extinguish()
  end
end

function BP_NPCHuoYanShi:LuaBeginPlay()
  Base.LuaBeginPlay(self)
  if self:CheckAvatarCanInteract() then
    self:Extinguish()
  end
end

function BP_NPCHuoYanShi:CanEnterThrowInter(Comp)
  return Comp and Comp == self.StaticMesh
end

function BP_NPCHuoYanShi:CheckAvatarCanInteract()
  if not self.sceneCharacter then
    return false
  end
  return self.sceneCharacter.LogicStatusComponent:GetStatus(Enum.SpaceActorLogicStatus.SALS_TRIGGER_ON)
end

return BP_NPCHuoYanShi
