require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BP_NPCTorchBase_C = Base:Extend("BP_NPCTorchBase_C")

function BP_NPCTorchBase_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
  self.Interacting = false
  self.IsBurning = false
  self.AudioSession = nil
end

function BP_NPCTorchBase_C:ReceiveDestroyed()
  if self.AudioSession ~= nil then
    _G.NRCAudioManager:ReleaseSession(self.AudioSession, true, "BP_NPCTorchBase_C:ReceiveDestroyed")
  end
end

function BP_NPCTorchBase_C:UpdateBurningState(ForceUpdate)
  if self.Interacting then
    Log.Debug("Interacting... Skill update burning state", self.IsBurning)
    return
  end
  local ShouldBurn = SceneUtils.IsLogicStatusTriggerOn(self.sceneCharacter)
  if not ForceUpdate and ShouldBurn == self.IsBurning then
    return
  end
  if ShouldBurn then
    self:LightUp()
  else
    self:PutDown(ForceUpdate)
  end
end

function BP_NPCTorchBase_C:OnVisible()
  Base.OnVisible(self)
  self:UpdateBurningState(true)
end

function BP_NPCTorchBase_C:LightUp()
  if not self or not UE4.UObject.IsValid(self) then
    return
  end
  self.IsBurning = true
  if self.Scene_fire_Loop then
    self.Scene_fire_Loop:SetActive(true)
  end
  if self.PointLight then
    self.PointLight:SetVisibility(true)
  end
  if self.OnLightUp then
    self:OnLightUp()
  end
  _G.DelayManager:DelaySeconds(0.5, function()
    if not self or not UE4.UObject.IsValid(self) then
      return
    end
    if self.AudioID then
      self.AudioSession = _G.NRCAudioManager:PlaySound3DWithActorAuto(self.AudioID, self, "BP_NPCTorchBase_C:LightUp")
    end
  end)
end

function BP_NPCTorchBase_C:PutDown(ForceUpdate)
  if self.AudioSession ~= nil then
    _G.NRCAudioManager:ReleaseSession(self.AudioSession, true, "BP_NPCTorchBase_C:ReceiveDestroyed")
  end
  if self.OnFirePutDown then
    self:OnFirePutDown()
  end
  self.IsBurning = false
  if self.Scene_fire_Loop then
    self.Scene_fire_Loop:SetActive(false)
  end
  if self.PointLight then
    if ForceUpdate then
      self.PointLight:SetVisibility(false)
    else
      _G.DelayManager:DelaySeconds(0.3, function(PointLight)
        if UE.UObject.IsValid(PointLight) then
          PointLight:SetVisibility(false)
        end
      end, self.PointLight)
    end
  end
end

function BP_NPCTorchBase_C:CanEnterThrowInter(Comp)
  return Comp and (Comp == self.ActionArea or Comp == self.StaticMesh)
end

function BP_NPCTorchBase_C:Recycle()
  self:PutDown()
  Base.Recycle(self)
end

function BP_NPCTorchBase_C:SetInteracting(Interacting)
  self.Interacting = Interacting
  self:UpdateBurningState()
end

return BP_NPCTorchBase_C
