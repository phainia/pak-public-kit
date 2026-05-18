local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local CrouchBuff = require("NewRoco.Modules.Core.Scene.Component.Buff.ScenePlayerCrouchBuff")
local StartCrouchAbility = Base:Extend("StartCrouchAbility")

function StartCrouchAbility:Init(abilityConf)
  Base.Init(self, abilityConf)
  self._buffName = "PlayerCrouchBuff"
end

function StartCrouchAbility:Start(onFinished)
  Base.Start(self, onFinished)
  local player = self.caster
  player.buffComponent:AddBuff(self._buffName, CrouchBuff, player)
end

function StartCrouchAbility:Recover(owner)
  owner.buffComponent:AddBuff(self._buffName, CrouchBuff, owner)
  if owner.CrouchComponent then
    owner.CrouchComponent:OnEnterGrass()
    owner.CrouchComponent:TryCrouch()
  end
end

return StartCrouchAbility
