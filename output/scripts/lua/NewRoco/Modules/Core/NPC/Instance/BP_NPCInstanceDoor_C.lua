require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.Instance.BP_NPCInstanceMechanismBase_C")
local BP_NPCInstanceDoor_C = Base:Extend("BP_NPCInstanceDoor_C")
local UseSound = 1393
local CreateSound = 1394

function BP_NPCInstanceDoor_C:OnFirstVisible()
  Base.OnFirstVisible(self)
  _G.NRCAudioManager:PlaySound2DAuto(CreateSound, "BP_NPCInstanceDoor_C:OnFirstVisible")
end

function BP_NPCInstanceDoor_C:ReceiveDestroyed()
  if self.DelayHandle then
    _G.DelayManager:CancelDelayById(self.DelayHandle)
  end
  Base.ReceiveDestroyed(self)
end

function BP_NPCInstanceDoor_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
  self.action = nil
  self.isInteraction = false
end

function BP_NPCInstanceDoor_C:PlayUseEffect(action)
  if self.isInteraction then
    return
  end
  self.isInteraction = true
  self.action = action
  self:SetEffectShow(self.Use, true, true)
  _G.NRCAudioManager:PlaySound2DAuto(UseSound, "BP_NPCInstanceDoor_C:PlayUseEffect")
  self.DelayHandle = _G.DelayManager:DelaySeconds(1, self.OnUseEffectFinish, self)
end

function BP_NPCInstanceDoor_C:OnUseEffectFinish()
  if self.action then
    NRCModuleManager:DoCmd(InstanceModuleCmd.OpenLeavePanel, self.action)
  end
  self.isInteraction = false
end

function BP_NPCInstanceDoor_C:OnActionFinish()
  self:SetEffectShow(self.Use, false, true)
end

function BP_NPCInstanceDoor_C:SetEffectShow(effect, isShow, isReset)
  isReset = isReset or false
  if isShow and isReset then
    effect:ReinitializeSystem()
  end
  effect:SetActive(isShow, isReset)
  effect:SetVisibility(isShow, true)
end

return BP_NPCInstanceDoor_C
