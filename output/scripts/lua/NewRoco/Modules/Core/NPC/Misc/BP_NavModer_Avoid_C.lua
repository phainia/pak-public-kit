local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BP_NavModer_Avoid_C = Class()

function BP_NavModer_Avoid_C:Ctor()
  self.can_disperse = false
  self.force_disperse = false
  self.cooldown_delay = nil
  self.owner_area = nil
end

function BP_NavModer_Avoid_C:OnMeshOverlap(OtherActor)
  if self.owner_area == nil then
    self.OverlapOtherActorOnSpawn = OtherActor
    return
  end
  self:OnMeshOverlapImp(OtherActor)
end

function BP_NavModer_Avoid_C:OnMeshOverlapImp(OtherActor)
  local Player = SceneUtils.GetPlayer()
  if Player and Player.viewObj and Player.viewObj == OtherActor then
    self.can_disperse = true
    if not self.force_disperse then
      self:DisperseNpc()
    end
    return
  end
  local npc = UE.UObject.IsA(OtherActor, UE.ANPCBaseCharacter) and OtherActor.sceneCharacter
  if npc and self.owner_area and self.owner_area.overlap_callback then
    self.owner_area.overlap_callback(self.owner_area.overlap_caller, npc, true)
  end
end

function BP_NavModer_Avoid_C:OnMeshUnoverlap(OtherActor)
  local Player = SceneUtils.GetPlayer()
  if not Player then
    return
  end
  if not Player.viewObj then
    return
  end
  if Player.viewObj == OtherActor then
    self.can_disperse = false
  end
end

function BP_NavModer_Avoid_C:DisperseNpc()
  if not self or not UE4.UObject.IsValid(self) then
    return
  end
  if self.can_disperse or self.force_disperse then
    local bInbattle = self.owner_area and self.owner_area.InBattle
    NRCEventCenter:DispatchEvent(NPCModuleEvent.TO_DISPERSE_AI, self:Abs_K2_GetActorLocation(), self:GetActorScale3D().X * 50 + 300, 2, bInbattle)
    if not self.cooldown_delay then
      self.cooldown_delay = DelayManager:DelaySeconds(2, function()
        self.cooldown_delay = nil
        self:DisperseNpc()
      end)
    end
  end
end

function BP_NavModer_Avoid_C:SetForceDisperse(enable)
  self.force_disperse = enable
  if not self.cooldown_delay then
    self:DisperseNpc()
  end
end

function BP_NavModer_Avoid_C:ReceiveEndPlay(EndPlayReason)
  if self.cooldown_delay then
    DelayManager:CancelDelayById(self.cooldown_delay)
    self.cooldown_delay = nil
  end
end

return BP_NavModer_Avoid_C
