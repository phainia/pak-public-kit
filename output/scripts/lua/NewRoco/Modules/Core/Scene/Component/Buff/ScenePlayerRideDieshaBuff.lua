local Base = require("NewRoco.Modules.Core.Scene.Component.Buff.ScenePlayerBuff")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local ScenePlayerRideDieshaBuff = Base:Extend("ScenePlayerRideDieshaBuff")

function ScenePlayerRideDieshaBuff:Ctor(owner, ridePet)
  Base.Ctor(self, owner)
  self._ridePet = ridePet
end

function ScenePlayerRideDieshaBuff:OnBegin()
end

function ScenePlayerRideDieshaBuff:OnUpdate(deltaTime)
  if self.owner.viewObj:GetMovementComponent():GetWaterDepth() < 60 then
    self.owner.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_DIESHA, Enum.WPST_OpCode.WPST_OPCODE_REMOVE, 1, true)
  end
end

function ScenePlayerRideDieshaBuff:OnFinish()
  if self._ridePet then
    self._ridePet:K2_DestroyActor()
    self._ridePet = nil
  end
end

function ScenePlayerRideDieshaBuff:GetRidePet()
  return self._ridePet
end

return ScenePlayerRideDieshaBuff
