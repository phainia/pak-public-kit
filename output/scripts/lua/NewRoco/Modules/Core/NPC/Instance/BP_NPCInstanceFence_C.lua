require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.Instance.BP_NPCInstanceMechanismBase_C")
local BP_NPCInstanceFence_C = Base:Extend("BP_NPCInstanceFence_C")

function BP_NPCInstanceFence_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
  self.IsPlaying = false
end

function BP_NPCInstanceFence_C:ChangeState(State, bInit)
  if self.sceneCharacter then
    local luaObj = self.sceneCharacter.luaObj
    local serverState = luaObj.LogicStatus
    if 1 == serverState and bInit and self.IsOpening ~= nil then
      self.IsOpening = true
    end
  end
  Base.ChangeState(self, State, bInit)
end

return BP_NPCInstanceFence_C
