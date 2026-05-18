local LuaMathUtils = require("NewRoco.Utils.LuaMathUtils")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local Base = require("NewRoco.AI.Requester.RequesterDefault")
local TurnRequester = Base:Extend("TurnRequester")
TurnRequester:SetMemberCount(8)

function TurnRequester:Ctor()
  Base.Ctor(self)
  self.owner = nil
  self.bInitializedTurningMap = false
  self.bUseAnimPreset = false
  self.TurnPresets = nil
  self.ticking = false
  self.isPlayer = false
end

function TurnRequester:Attach(owner)
  self.owner = owner
end

function TurnRequester:DeAttach()
  self:EnableTick(false)
  if self:IsTuring() then
    self:OnActEnd(AIDefines.ActionResult.Aborted)
  end
  self.owner = nil
end

TurnRequester.TimingMethod = {Time = false, Anim = true}

function TurnRequester.CreateParam()
  return {
    Yaw = 0,
    PlayDefaultAnim = true,
    TimingMethod = false,
    Time = 0,
    AnimRate = 1.0,
    UseAdditive = false
  }
end

function TurnRequester:OnActEnd(result)
  Base.OnActEnd(self, result)
  if not self:IsTuring() and self.owner then
    self.owner:SendEvent(NPCModuleEvent.TURN_END)
  end
end

local WALK_ANIM = "Walk"
local SWIM_ANIM = "Swim1"
local FLY_ANIM = "FlyHover"
local DEFAULT_TURN_PRESET_THRESHOLD = 90

function TurnRequester:Action(param)
  if not self.owner then
    Log.Debug("[TurnRequester] not attached yet")
    return self:ActEnd(AIDefines.ActionResult.Invalid)
  end
  local Rot = self.owner:GetActorRotation()
  local Target, Now, Delta = LuaMathUtils.DiffAngle(param.Yaw or 0, Rot.Yaw or 0)
  if 0 == Delta then
    return self:ActEnd(AIDefines.ActionResult.Success)
  end
  local threshold = DEFAULT_TURN_PRESET_THRESHOLD
  local View = self.owner.viewObj
  if param.PlayDefaultAnim and (View.TurnTarget or param.UseAdditive) then
    if View.OnTurn then
      View:OnTurn(param.Yaw, param.Time)
      return
    else
      if math.abs(Delta) < 30 then
        View:Event_Turn(Delta, param.Time)
        self:ActEnd(AIDefines.ActionResult.Success)
        return
      end
      threshold = 90
      self.isPlayer = true
    end
  end
  local AnimComponent = self.owner:GetAnimComponent()
  if not AnimComponent then
    Log.Debug("[TurnRequester] legacy turning, bug can't get AnimComponent")
    return self:ActEnd(AIDefines.ActionResult.Invalid)
  end
  self:InitializeTurningMap()
  local preset = self:GetTurnAnimPreset(Delta, threshold, param.UseAdditive)
  if math.abs(Delta) > 10 and param.Time > 0.033 then
    self.bUseAnimPreset = preset and param.PlayDefaultAnim
    self.CurrentAnim = nil
    if self.bUseAnimPreset then
      self.TargetYaw = Target
      self.StartYaw = Now
      self.DeltaYaw = Delta
      local AnimName
      if Delta > 0 then
        AnimName = preset.R
      else
        AnimName = preset.L
      end
      local AnimLength
      self.CurLinkTag = "None"
      if self.isPlayer then
        local RawAnimLength = AnimComponent:GetAnimLengthByName(AnimName)
        local PlayRate
        if true == param.TimingMethod then
          PlayRate = param.AnimRate or 1.0
        else
          PlayRate = RawAnimLength and RawAnimLength > 1.0E-4 and RawAnimLength / param.Time or 1.0
        end
        if param.UseAdditive then
          AnimLength = self.owner:PlayAnim(AnimName, PlayRate, 0, 0.2, 0.1, 1, 0, "None", false, "LowerBody")
        else
          AnimLength = self.owner:PlayAnim(AnimName, PlayRate, 0, 0.2, 0.1, 1, 0, "Locomotion")
          self.CurLinkTag = "Locomotion"
        end
        AnimLength = math.max(AnimLength, 0.01)
        AnimLength = AnimLength / PlayRate
      else
        local RawAnimLength = AnimComponent:GetAnimLengthByName(AnimName)
        local PlayRate
        if true == param.TimingMethod then
          PlayRate = param.AnimRate or 1.0
        else
          PlayRate = RawAnimLength and RawAnimLength > 1.0E-4 and RawAnimLength / param.Time or 1.0
        end
        AnimLength = self.owner:PlayAnim(AnimName, PlayRate, 0, 0.2, 0.2)
        AnimLength = math.max(AnimLength, 0.01)
        AnimLength = AnimLength / PlayRate
      end
      self.TurnTime = AnimLength
      self.RemainTime = AnimLength
      self.CurrentAnim = AnimName
    else
      self.TargetYaw = Target
      self.StartYaw = Now
      self.DeltaYaw = Delta
      if param.PlayDefaultAnim then
        local played = false
        local model = self.owner.viewObj
        if model and model:IsA(UE.ACharacter) and model.CharacterMovement then
          local MoveComp = model.CharacterMovement
          if MoveComp:IsSwimming() then
            local result = self.owner:PlayAnim(SWIM_ANIM, 2, 0, 0.1, 0, -1)
            self.CurrentAnim = SWIM_ANIM
            played = 0 ~= result
          elseif not MoveComp:IsMovingOnGround() then
            local result = self.owner:PlayAnim(FLY_ANIM, 2, 0, 0.1, 0, -1)
            self.CurrentAnim = FLY_ANIM
            played = 0 ~= result
          end
        end
        if not played then
          self.owner:PlayAnim(WALK_ANIM, 2, 0, 0.1, 0, -1)
          self.CurrentAnim = WALK_ANIM
        end
      end
      self.TurnTime = param.Time
      self.RemainTime = param.Time
    end
    self:EnableTick(true)
  else
    Rot.Yaw = param.Yaw
    self.owner:SetActorRotation(Rot)
    self:ActEnd(AIDefines.ActionResult.Success)
  end
end

function TurnRequester:Interrupt()
  local View = self.owner and self.owner.viewObj
  if View and View.TurnTarget and View.OnStopTurn then
    View:OnStopTurn()
    return
  else
  end
  if self.owner then
    if self.bUseAnimPreset then
      if self.CurrentAnim then
        self.owner:StopAnim(self.CurrentAnim, 0.15, self.CurLinkTag)
      end
    elseif self.CurrentAnim then
      self.owner:StopAnim(self.CurrentAnim, 0.15)
    else
      self.owner:StopAnim("Walk", 0.15)
      self.owner:StopAnim("Swim1", 0.15)
      self.owner:StopAnim("FlyHover", 0.15)
    end
  end
  self:EnableTick(false)
end

local TurnAngle

function TurnRequester:InitializeTurningMap()
  if self.bInitializedTurningMap then
    return
  end
  if not self.owner then
    return
  end
  local AnimComponent = self.owner:GetAnimComponent()
  if not AnimComponent then
    return
  end
  local TurnPresets = table.new(4)
  local TurnPresets_Additive = table.new(4)
  if AnimComponent:GetAnimSequenceByName("TurnR45") then
    table.insert(TurnPresets, {
      angle = 45,
      L = "TurnL45",
      R = "TurnR45"
    })
  end
  if AnimComponent:GetAnimSequenceByName("TurnR90") then
    table.insert(TurnPresets, {
      angle = 90,
      L = "TurnL90",
      R = "TurnR90"
    })
  end
  if AnimComponent:GetAnimSequenceByName("TurnR135") then
    table.insert(TurnPresets, {
      angle = 135,
      L = "TurnL135",
      R = "TurnR135"
    })
  end
  if AnimComponent:GetAnimSequenceByName("TurnR180") then
    table.insert(TurnPresets, {
      angle = 180,
      L = "TurnL180",
      R = "TurnR180"
    })
  end
  self.TurnPresets = TurnPresets
  if AnimComponent:GetAnimSequenceByName("TurnR45_Additive") then
    table.insert(TurnPresets_Additive, {
      angle = 45,
      L = "TurnL45_Additive",
      R = "TurnR45_Additive"
    })
  end
  if AnimComponent:GetAnimSequenceByName("TurnR90_Additive") then
    table.insert(TurnPresets_Additive, {
      angle = 90,
      L = "TurnL90_Additive",
      R = "TurnR90_Additive"
    })
  end
  if AnimComponent:GetAnimSequenceByName("TurnR135_Additive") then
    table.insert(TurnPresets_Additive, {
      angle = 135,
      L = "TurnL135_Additive",
      R = "TurnR135_Additive"
    })
  end
  if AnimComponent:GetAnimSequenceByName("TurnR180_Additive") then
    table.insert(TurnPresets_Additive, {
      angle = 180,
      L = "TurnL180_Additive",
      R = "TurnR180_Additive"
    })
  end
  self.TurnPresets = TurnPresets_Additive
  self.bInitializedTurningMap = true
end

function TurnRequester:GetTurnAnimPreset(DeltaYaw, threshold, UseAdditive)
  local minDeltaToPreset = threshold or 60
  local selectedPreset
  local FindList = UseAdditive and self.TurnPresets_Additive or self.TurnPresets
  for _, preset in ipairs(FindList) do
    local deltaToPreset = math.abs(math.abs(DeltaYaw) - preset.angle)
    if minDeltaToPreset > deltaToPreset then
      minDeltaToPreset = deltaToPreset
      selectedPreset = preset
    end
  end
  return selectedPreset
end

function TurnRequester:IsTuring()
  return self.state == AIDefines.ActionState.Working
end

function TurnRequester:SetYaw(Yaw)
  local view = self.owner.viewObj
  if view and UE.UObject.IsValid(view) then
    local Rot = self.owner:GetActorRotation()
    Rot.Yaw = Yaw
    Rot = Rot:Clamp()
    self.owner:SetActorRotation(Rot)
  end
end

function TurnRequester:AddYaw(Yaw)
  if not self.owner.viewObj then
    return
  end
  local Rot = UE4.FRotator(0, Yaw, 0)
  self.owner.viewObj:K2_AddActorWorldRotation(Rot)
end

function TurnRequester:OnTick(DeltaTime)
  if not self.owner then
    return
  end
  if not self:IsTuring() then
    return
  end
  if not self.StartYaw then
    Log.Warning("[TurnRequester] OnTick \229\188\130\229\184\184\230\151\182\229\186\143")
    self:EnableTick(false)
    self:ActEnd(AIDefines.ActionResult.Invalid)
    return
  end
  self.RemainTime = math.clamp(self.RemainTime - DeltaTime, 0, self.TurnTime)
  local RemainRatio = 0 == self.TurnTime and 0 or self.RemainTime / self.TurnTime
  self:SetYaw((1 - RemainRatio) * self.DeltaYaw + self.StartYaw)
  if RemainRatio <= 0 then
    if not self.bUseAnimPreset then
      if self.CurrentAnim then
        self.owner:StopAnim(self.CurrentAnim, 0.15)
      else
        self.owner:StopAnim("Walk", 0.15)
        self.owner:StopAnim("Swim1", 0.15)
        self.owner:StopAnim("FlyHover", 0.15)
      end
    end
    self:EnableTick(false)
    self:ActEnd(AIDefines.ActionResult.Success)
  end
end

function TurnRequester:GetFutureRotator()
  if self._requests:Size() > 0 then
    local param = self._requests:Last()
    return UE.FRotator(0, param.Yaw, 0)
  end
  return UE.FRotator()
end

function TurnRequester:EnableTick(enable)
  if self.ticking == enable then
    return
  end
  if enable then
    _G.UpdateManager:Register(self)
  else
    _G.UpdateManager:UnRegister(self)
  end
  self.ticking = enable
end

return TurnRequester
