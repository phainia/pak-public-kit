local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local Base = ViewNPCBase
local BP_StoneFloor_C = Base:Extend("BP_StoneFloor_C")
local PawnType = {
  UE.EObjectTypeQuery.Character
}

function BP_StoneFloor_C:OnLoadResource()
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not localPlayer then
    return
  end
  local World = _G.UE4Helper.GetCurrentWorld()
  local ResultArray = UE4.TArray(UE.AActor)
  local CheckRange = 500
  local Success = UE.UNRCStatics.SphereOverlapActors(World, self:K2_GetActorLocation(), CheckRange, PawnType, nil, ResultArray)
  if Success then
    for Index, Actor in tpairs(ResultArray) do
      Log.Debug("Show Overlapping Actors", Index, Actor:GetName())
    end
    localPlayer:Land()
  end
  Base.OnLoadResource(self)
end

return BP_StoneFloor_C
