local Base = require("NewRoco.Modules.Core.Scene.Component.Buff.ScenePlayerBuff")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local ScenePlayerRideBuff = Base:Extend("ScenePlayerGlidingBuff")

function ScenePlayerRideBuff:Ctor(owner, ridePet)
  Base.Ctor(self, owner)
  self._ridePet = ridePet
end

function ScenePlayerRideBuff:OnBegin()
end

function ScenePlayerRideBuff:OnFinish()
  if self._ridePet then
    self._ridePet:K2_DestroyActor()
    self._ridePet = nil
  end
end

function ScenePlayerRideBuff:GetRidePet()
  return self._ridePet
end

return ScenePlayerRideBuff
