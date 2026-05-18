local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = ViewNPCBase
local BP_MissileTest = Base:Extend("BP_MissileTest")

function BP_MissileTest:Ctor()
end

function BP_MissileTest:ReceiveBeginPlay()
  Base.ReceiveBeginPlay(self)
end

function BP_MissileTest:OnVisible()
  Base.OnVisible(self)
  self.Overridden.OnVisible(self)
end

return BP_MissileTest
