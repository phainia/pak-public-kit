local Base = require("NewRoco.Modules.Core.Scene.Component.Buff.RideAllMain.RideAllBuff_SkillBase")
local StatType = require("NewRoco.Modules.Core.Scene.Component.Stat.StatType")
local AbilityEvent = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityEvent")
local PerceptionBuff = require("NewRoco.Modules.Core.Scene.Component.Buff.ScenePlayerPerceptionBuff")
local RideAllBuff_Perception = Base:Extend("RideAllBuff_Perception")

function RideAllBuff_Perception:OnBuffBegin(Owner, SkillConf)
  Base.OnBuffBegin(self, Owner, SkillConf)
  Log.Debug("RideAllBuff_Perception:OnBegin")
  self._buffName = "PerceptionBuff"
  self._cachedMoveType = self.RideComp.RideMoveType
end

function RideAllBuff_Perception:OnStartCostVitalityFinish(StartCostSuccess)
  if StartCostSuccess then
    local player = self.owner
    self.buff = player.buffComponent:GetBuff(self._buffName)
    if self.buff == nil then
      player.buffComponent:AddBuff(self._buffName, PerceptionBuff, player)
      self.buff = player.buffComponent:GetBuff(self._buffName)
      self.buff:OnCmdInitPetInfo(self.SceneRidePet)
    else
      self.buff:OnCmdOverride(self.SceneRidePet)
    end
    self._curTime = 0
    self._shouldTick = true
  else
    self:StartFail()
  end
end

function RideAllBuff_Perception:OnBuffUpdate(deltaTime)
  self.buff = self.owner.buffComponent:GetBuff(self._buffName)
  if self.buff == nil then
    self:StopActiveSKill()
  end
end

function RideAllBuff_Perception:OnMainAbilityReleased(...)
end

function RideAllBuff_Perception:OnBuffFinish(param)
  if self.buff ~= nil then
    self.buff:OnCmdFinish()
  end
  Base.OnBuffFinish(self, param)
end

function RideAllBuff_Perception:OnRidePetChangeMoveType()
  if self.RideComp.RideMoveComp.MovementMode == UE.EMovementMode.MOVE_Falling then
    return
  end
  if self._cachedMoveType == self.RideComp.RideMoveType then
    return
  end
  self:StopActiveSKill()
end

return RideAllBuff_Perception
