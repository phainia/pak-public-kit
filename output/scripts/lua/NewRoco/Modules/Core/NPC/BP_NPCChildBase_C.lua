require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local BP_NPCChildBase_C = Base:Extend("BP_NPCChildBase_C")

function BP_NPCChildBase_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
  self.UnlockDestroyHandler = -1
end

function BP_NPCChildBase_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_NPCChildBase_C:OnLoadResource()
  Base.OnLoadResource(self)
end

function BP_NPCChildBase_C:OnUnLoadResource()
  Base.OnUnLoadResource(self)
end

function BP_NPCChildBase_C:Init()
  Base.Init(self)
  self.UnlockDestroyHandler = -1
end

function BP_NPCChildBase_C:Recycle()
  if self.UnlockDestroyHandler > 0 then
    _G.DelayManager:CancelDelayById(self.UnlockDestroyHandler)
    self.UnlockDestroyHandler = -1
  end
  Base.Recycle(self)
end

function BP_NPCChildBase_C:UnlockDestroy()
  self.UnlockDestroyHandler = -1
  if not self.sceneCharacter then
    return
  end
  self.sceneCharacter:SetNotDestroyFlag(false)
  if not self.sceneCharacter.shouldDestroy then
    return
  end
  local serverId = self.sceneCharacter.serverData.base.actor_id
  _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.RemoveNPC, serverId)
end

function BP_NPCChildBase_C:PlayOptRefreshEffect()
  Log.Debug("BP_NPCChildBase_C:PlayOptRefreshEffect", self:GetDebugInfo())
  local actor = self.ChildActor:GetChildActor()
  if actor then
    if actor.RefreshShow then
      Log.Debug("actor.RefreshShow")
      actor:RefreshShow()
    else
      Log.Debug("\231\190\142\230\156\175\229\136\182\228\189\156\231\154\132\232\147\157\229\155\190\230\178\161\230\156\137RefreshShow\229\135\189\230\149\176\239\188\140\232\175\183\230\163\128\230\159\165")
    end
  else
    Log.Error("\230\151\160\230\179\149\232\142\183\229\143\150ChildActor", UE.UObject.GetName(self))
  end
end

function BP_NPCChildBase_C:PlayOptTimesOverLoopEffect()
  Log.Debug("BP_NPCChildBase_C:PlayOptTimesOverLoopEffect", self:GetDebugInfo())
  local actor = self.ChildActor:GetChildActor()
  if actor then
    if actor.InitShowOver then
      Log.Debug("actor.InitShowOver")
      actor:InitShowOver()
    else
      Log.Debug("\231\190\142\230\156\175\229\136\182\228\189\156\231\154\132\232\147\157\229\155\190\230\178\161\230\156\137InitShowOver\229\135\189\230\149\176\239\188\140\232\175\183\230\163\128\230\159\165")
    end
  else
    Log.Error("\230\151\160\230\179\149\232\142\183\229\143\150ChildActor", UE.UObject.GetName(self))
  end
end

function BP_NPCChildBase_C:PlayOptTimesOverEffect(Operator)
  Log.Debug("BP_NPCChildBase_C:PlayOptTimesOverEffect", self:GetDebugInfo())
  local actor = self.ChildActor:GetChildActor()
  if actor then
    if actor.Show then
      self.sceneCharacter:SetNotDestroyFlag(true)
      actor:Show(Operator and Operator.viewObj)
      if self.UnlockDestroyHandler > 0 then
        _G.DelayManager:CancelDelayById(self.UnlockDestroyHandler)
        self.UnlockDestroyHandler = -1
      end
      self.UnlockDestroyHandler = _G.DelayManager:DelaySeconds(3, self.UnlockDestroy, self)
    else
      Log.Error("\231\190\142\230\156\175\229\136\182\228\189\156\231\154\132\232\147\157\229\155\190\230\178\161\230\156\137Show\229\135\189\230\149\176\239\188\140\232\175\183\230\163\128\230\159\165")
    end
  else
    Log.Error("\230\151\160\230\179\149\232\142\183\229\143\150ChildActor", UE.UObject.GetName(self))
  end
end

local NPCLuaUtils = require("NewRoco.Modules.Core.NPC.NPCLuaUtils")

function BP_NPCChildBase_C:SetCustomDepth(Depth)
  local Child = self.ChildActor:GetChildActor()
  if not Child then
    return
  end
  local Comps = Child:K2_GetComponentsByClass(UE.UMeshComponent)
  for _, Comp in tpairs(Comps) do
    if not Comp:IsA(UE.UWidgetComponent) then
      NPCLuaUtils.SetCompCustomDepth(Comp, Depth)
    end
  end
end

return BP_NPCChildBase_C
