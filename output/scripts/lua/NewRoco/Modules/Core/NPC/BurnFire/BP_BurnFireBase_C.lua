local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Base = ViewNPCBase
local BP_BurnFireBase_C = Base:Extend("BP_BurnFireBase_C")

function BP_BurnFireBase_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_BurnFireBase_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_BurnFireBase_C:Recycle()
  Base.Recycle(self)
end

function BP_BurnFireBase_C:OnVisible()
  Base.OnVisible(self)
end

function BP_BurnFireBase_C:OnInVisible()
  Base.OnInVisible(self)
end

function BP_BurnFireBase_C:PlayDisappearPerform()
end

function BP_BurnFireBase_C:MakeDisappear()
  if self.sceneCharacter then
    self.sceneCharacter:Disappear(true)
  end
end

return BP_BurnFireBase_C
