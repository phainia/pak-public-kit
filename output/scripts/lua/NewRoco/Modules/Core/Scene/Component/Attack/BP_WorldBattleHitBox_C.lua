require("UnLuaEx")
local BP_WorldBattleHitBox_C = Class("BP_WorldBattleHitBox_C")
local TempArray = UE.TArray(UE.AActor)

function BP_WorldBattleHitBox_C:GetOverlapSceneActors()
  local result = {}
  if not self.Area then
    return result
  end
  self.Area:GetOverlappingActors(TempArray, UE.AActor)
  for idx, actor in tpairs(TempArray) do
    local sceneActor = actor.sceneCharacter
    if sceneActor then
      table.insert(result, sceneActor)
    end
  end
  return result
end

return BP_WorldBattleHitBox_C
