require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local BP_NPCStonePile_C = Base:Extend("BP_NPCStonePile_C")

function BP_NPCStonePile_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_NPCStonePile_C:Init()
  Base.Init(self)
end

function BP_NPCStonePile_C:UpdateState()
  self.RocoAnim:PlayAnimByName("Idle")
  if not self.sceneCharacter then
    return
  end
  self.sceneCharacter.shouldDestroy = false
  if self.sceneCharacter.InteractionComponent then
    self.sceneCharacter.InteractionComponent:TryEnableInteraction()
  end
end

return BP_NPCStonePile_C
