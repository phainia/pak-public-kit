local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local NpcOptionEvent = require("NewRoco.Modules.Core.NPC.Executors.NpcOptionEvent")
local Base = ViewNPCBase
local BP_ShenShou_Transmit_Com_C = Base:Extend("BP_ShenShou_Transmit_Com_C")

function BP_ShenShou_Transmit_Com_C:Ctor()
  Base.Ctor(self)
end

function BP_ShenShou_Transmit_Com_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_ShenShou_Transmit_Com_C:CheckIsActivated()
  local isActivated = false
  local LogicComp = self.sceneCharacter.LogicStatusComponent
  if LogicComp then
    isActivated, _, _ = LogicComp:GetStatus(Enum.SpaceActorLogicStatus.SALS_INTERACTING)
  end
  return isActivated
end

function BP_ShenShou_Transmit_Com_C:CheckActivatedEffect()
  if self:CheckIsActivated() then
    self:Start()
  end
end

return BP_ShenShou_Transmit_Com_C
