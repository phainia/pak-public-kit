local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionQueryNearestObject = Base:Extend("LuaActionQueryNearestObject")

function LuaActionQueryNearestObject:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  local queryRange = self.QueryRange:GetValue(owner)
  local queryIds = {}
  if self.QueryId then
    for _, v in ipairs(self.QueryId) do
      table.insert(queryIds, v:GetValue(owner))
    end
  end
  if 0 == #queryIds then
    table.insert(queryIds, owner.Npc.config.id)
  end
  local skipTargetBBCheck = false
  if self.SkipTargetBBCheck then
    skipTargetBBCheck = self.SkipTargetBBCheck:GetValue(owner)
  end
  local ownerLocation = owner.Npc:GetActorLocation()
  local outActors, result = UE4.UKismetSystemLibrary.Abs_SphereOverlapActors(owner:GetWorld(), ownerLocation, queryRange, nil, nil, nil)
  local queryResult
  if result then
    result = false
    local distance = queryRange
    for i = 1, outActors:Length() do
      local curActor = outActors:Get(i)
      if curActor.sceneCharacter and curActor.sceneCharacter.config and #queryIds > 0 then
        for _, id in ipairs(queryIds) do
          if curActor.sceneCharacter.config.id == id then
            if UE4.UNRCStatics.GetObjectUniqueID(curActor.sceneCharacter.viewObj) == UE4.UNRCStatics.GetObjectUniqueID(owner.Npc.viewObj) then
              break
            end
            if not skipTargetBBCheck then
              local targetKeyName = string.split(self.TargetKey.key, "]_")[2]
              local curController = curActor.Controller
              if not curController then
                break
              end
              do
                local targetBBVal = curController:QueryCrossBlackboardValue(targetKeyName, self.TargetKey.type)
                if nil ~= targetBBVal then
                  if self.SameAs:GetValue(owner) ~= targetBBVal then
                    break
                  end
                else
                  Log.Warning("[LuaActionQueryNearestObject] Cant find target BBVal by [" .. targetKeyName .. "], ignored filter")
                  goto lbl_142
                  break
                end
              end
            end
            ::lbl_142::
            local CurLocation = curActor.sceneCharacter:GetActorLocation()
            if ownerLocation and CurLocation then
              do
                local curDistance = UE4.FVector.Dist(ownerLocation, curActor.sceneCharacter:GetActorLocation())
                if distance > curDistance then
                  distance = distance - curDistance
                  queryResult = curActor
                  result = true
                end
              end
              break
            end
            Log.Warning("[LuaActionQueryNearestObject] DebugUse: Invalid <Dist> params", ownerLocation, CurLocation)
            break
          end
        end
      end
    end
  end
  if result and queryResult then
    self.OutObject:SetValue(owner, queryResult.sceneCharacter)
  end
  self:Finish(result)
end

return LuaActionQueryNearestObject
