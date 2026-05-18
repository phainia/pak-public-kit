local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Base = ViewNPCBase
local BP_NPCStar_C = Base:Extend("BP_NPCStar_C")

function BP_NPCStar_C:Init()
  Base.Init(self)
  self.State = false
end

function BP_NPCStar_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_NPCStar_C:OnLoadResource()
  Base.OnLoadResource(self)
  local InterComp = self.sceneCharacter and self.sceneCharacter.InteractionComponent
  if InterComp then
    local Option = InterComp:GetMainAction()
    if Option then
      self.State = true
    else
      self.State = false
      self:TurnOff()
    end
  end
end

return BP_NPCStar_C
