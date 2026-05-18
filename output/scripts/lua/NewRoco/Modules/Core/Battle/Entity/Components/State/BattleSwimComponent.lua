local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleComponent = require("NewRoco.Modules.Core.Battle.Entity.BattleComponent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = BattleComponent
local BattleSwimComponent = BattleComponent:Extend("BattleSwimComponent")

function BattleSwimComponent:Ctor(owner)
  Base.Ctor(self)
  self.owner = owner
  self.IsEnable = false
  self.CanTick = false
  self.ConstTickDetal = 0.3
  self.TickDetal = 0
  self.RetainTime = 0
  self.EffectNumber = 0
  self.SwimPetMistake = 0
  self.battleManager = _G.BattleManager
  self.CurrentState = BattleEnum.DeepWaterSwimState.None
end

function BattleSwimComponent:StoreData(model)
  self.IsEnable = true
  self.CanTick = false
  self.ConstHalfHeight = model:GetHalfHeight()
  self.PetMesh = model:GetComponentByClass(UE4.USkeletalMeshComponent)
  self:ResetCanTick()
  if self.owner:GetCanSwimming() then
    local body = self.PetMesh:GetSocketLocation("locator_body")
    self.SwimPetMistake = _G.BattleManager.vBattleField.WaterHeight - body.Z
  end
end

function BattleSwimComponent:SetTickDetal(detal)
  self.ConstTickDetal = detal
end

function BattleSwimComponent:GetFootPos()
  if self.owner:GetCanSwimming() then
    local body = self.PetMesh:GetSocketLocation("locator_body")
    if body then
      body.Z = body.Z + self.SwimPetMistake
      return body
    end
  else
    return self.PetMesh:GetSocketLocation("locator_foot")
  end
end

function BattleSwimComponent:IsCanTick()
  if not self.CanTick then
    self:ResetCanTick()
  end
  return self.CanTick
end

function BattleSwimComponent:ResetCanTick()
  if not self.CanTick and self.PetMesh then
    self.CharacterMovement = self.owner.model:GetComponentByClass(UE.UCharacterMovementComponent)
    self.MoveFXComponent = self.owner.model.MoveFXComponent
  end
  self.CanTick = self.PetMesh and self.MoveFXComponent and self.CharacterMovement
  if self.CanTick then
    self.FxSetting = self.MoveFXComponent.SwimFxSetting
  end
end

function BattleSwimComponent:OnTick(deltaTime)
  if self.IsEnable then
    self.TickDetal = self.TickDetal + deltaTime
    if self.TickDetal > self.ConstTickDetal then
      if self:IsCanTick() then
        self.CurrentFootPos = self:GetFootPos()
        if self.CurrentFootPos then
          if self.LastFootPos then
            self.CurrentVector = (self.CurrentFootPos - self.LastFootPos) / self.TickDetal
            local WaterDetal = self.CurrentFootPos.Z - _G.BattleManager.vBattleField.WaterHeight
            if WaterDetal <= 15 and self.CurrentVector.Z <= 50 then
              if self.CurrentState == BattleEnum.DeepWaterSwimState.Jumping then
                self:EnterJumpEnd()
              elseif self.CurrentState == BattleEnum.DeepWaterSwimState.WillIdle then
                self:EnterIdle()
              elseif self.CurrentState ~= BattleEnum.DeepWaterSwimState.Idle then
                self:EnterWillIdle()
              end
            elseif WaterDetal > 15 and self.CurrentVector.Z > 50 or WaterDetal >= 30 and self.CurrentVector.Z > 0 then
              self:EnterJump()
            end
            self:RecordJumpHight()
          end
          self:AddRetainTime()
          self:TryClearEffect()
          self:RecordLastData()
        end
      end
      self.TickDetal = 0
    end
  end
end

function BattleSwimComponent:TryClearEffect()
  if (self.RetainTime > 1.5 and self.CurrentState == BattleEnum.DeepWaterSwimState.Jumping or self.EffectNumber > 100) and self.EffectNumber > 0 then
    self.RetainTime = 0
    self:StopAllEffect()
    if self.CurrentState == BattleEnum.DeepWaterSwimState.Idle then
      self.CurrentState = BattleEnum.DeepWaterSwimState.WillIdle
      self:EnterIdle()
    end
  end
end

function BattleSwimComponent:AddRetainTime()
  if self.LastState == self.CurrentState then
    self.RetainTime = self.RetainTime + self.TickDetal
  else
    self.RetainTime = 0
  end
end

function BattleSwimComponent:RecordLastData()
  self.LastState = self.CurrentState
  self.LastFootPos = self.CurrentFootPos
  self.LastVector = self.CurrentVector
end

function BattleSwimComponent:LeaveCurrentState()
  if self.CurrentState == BattleEnum.DeepWaterSwimState.Idle then
    self:StopSwimEffect(self.SwimIdle)
  elseif self.CurrentState == BattleEnum.DeepWaterSwimState.Jumping then
    self:ClearJumpData()
  end
  self.CurrentState = BattleEnum.DeepWaterSwimState.None
end

function BattleSwimComponent:EnterJump()
  if self.CurrentState ~= BattleEnum.DeepWaterSwimState.Jumping then
    self:LeaveCurrentState()
    self.CurrentState = BattleEnum.DeepWaterSwimState.Jumping
  end
end

function BattleSwimComponent:EnterJumpEnd()
  if self.CurrentState ~= BattleEnum.DeepWaterSwimState.JumpEnd then
    self:LeaveCurrentState()
    self.CurrentState = BattleEnum.DeepWaterSwimState.JumpEnd
    if not self.SwimJump then
      self.SwimJump = self.MoveFXComponent:GetFxFromSoftPath(self.MoveFXComponent.FxBattleSwim)
    end
    self:PlaySwimEffect(self.SwimJump)
  end
end

function BattleSwimComponent:RecordJumpHight()
  if self.CurrentState ~= BattleEnum.DeepWaterSwimState.Jumping then
    return
  end
  if self.CurrentFootPos.Z > self.LastFootPos.Z then
    if self.JumpMinHeight and self.JumpMaxHeight then
      if self.JumpMaxHeight - self.JumpMinHeight >= 20 and self.JumpMinHeight - _G.BattleManager.vBattleField.WaterHeight <= 40 then
        if not self.SwimJump then
          self.SwimJump = self.MoveFXComponent:GetFxFromSoftPath(self.MoveFXComponent.FxBattleSwim)
        end
        self:PlaySwimEffect(self.SwimJump)
      end
      self:ClearJumpData()
    end
    if not self.JumpMaxHeight or self.CurrentFootPos.Z > self.JumpMaxHeight then
      self.JumpMaxHeight = self.CurrentFootPos.Z
    end
  end
  if self.CurrentFootPos.Z < self.LastFootPos.Z and (not self.JumpMinHeight or self.CurrentFootPos.Z < self.JumpMinHeight) then
    self.JumpMinHeight = self.CurrentFootPos.Z
  end
end

function BattleSwimComponent:ClearJumpData()
  self.JumpMaxHeight = nil
  self.JumpMinHeight = nil
end

function BattleSwimComponent:EnterWillIdle()
  if self.CurrentState ~= BattleEnum.DeepWaterSwimState.WillIdle then
    self:LeaveCurrentState()
    self.CurrentState = BattleEnum.DeepWaterSwimState.WillIdle
  end
end

function BattleSwimComponent:EnterIdle()
  if self.CurrentState ~= BattleEnum.DeepWaterSwimState.Idle then
    self:LeaveCurrentState()
    self.CurrentState = BattleEnum.DeepWaterSwimState.Idle
    if not self.SwimIdle then
      self.SwimIdle = self.MoveFXComponent:GetFxFromSoftPath(self.MoveFXComponent.FxSwimIdle)
    end
    self:PlaySwimEffect(self.SwimIdle)
  end
end

function BattleSwimComponent:PlaySwimEffect(effect)
  if not effect then
    return
  end
  self.CharacterMovement.CacheWaterSurfacePos = UE.FVector(self.CurrentFootPos.X, self.CurrentFootPos.Y, self.battleManager.vBattleField.WaterHeight)
  if effect == self.SwimIdle then
    self.FxSetting.AttachmentType = UE.EFXAttachmentType.AttachToPos
    self.FxSetting.IgnoreRotation = true
    self.MoveFXComponent.FxBattleSwimIdleComp = self.MoveFXComponent:TryPlayOrStopSwimEffect(self.MoveFXComponent.FxBattleSwimIdleComp, effect, true)
  else
    self.EffectNumber = self.EffectNumber + 1
    self.FxSetting.AttachmentType = UE.EFXAttachmentType.DontAttach
    self.MoveFXComponent:TryPlayOrStopSwimEffect(self.MoveFXComponent.FxBattleSwimJumpComp, effect, true)
    _G.NRCAudioManager:PlaySound3DWithActorAuto(4070, self.owner.model, "BattleSwimComponent")
  end
end

function BattleSwimComponent:StopSwimEffect(effect)
  if not effect then
    return
  end
  if effect == self.SwimIdle then
    self.MoveFXComponent.FxBattleSwimIdleComp = self.MoveFXComponent:TryPlayOrStopSwimEffect(self.MoveFXComponent.FxBattleSwimIdleComp, effect, false)
  end
end

function BattleSwimComponent:StopAllEffect()
  if self.MoveFXComponent then
    self.MoveFXComponent:StopSwimFx()
    self.EffectNumber = 0
  end
end

function BattleSwimComponent:Clear()
  self:StopAllEffect()
  self.owner = nil
  self.PetMesh = nil
  self.SwimIdle = nil
  self.SwimJump = nil
  self.CharacterMovement = nil
  self.MoveFXComponent = nil
  self.FxSetting = nil
  self.CanTick = false
  self.enable = false
end

return BattleSwimComponent
