local Base = require("NewRoco.AI.BehaviorTree.LuaServiceBase")
local LuaServiceQueryRangeNpc = Base:Extend("LuaServiceQueryRangeNpc")

function LuaServiceQueryRangeNpc:OnStart(AIController, ...)
  local args = {
    ...
  }
  local owner = AIController
  self.queryIds = {}
  if self.QueryId then
    for _, v in ipairs(self.QueryId) do
      table.insert(self.queryIds, v:GetValue(owner))
    end
  end
  if 0 == #self.queryIds or -1 == self.queryIds[1] then
    table.insert(self.queryIds, owner.Npc.config.id)
  end
  self.queryRange = self.QueryRange:GetValue(owner)
  self.skipTargetBBCheck = self.SkipTargetBBCheck:GetValue(owner)
  self.lastResult = false
  self.outActors = UE4.TArray(UE4.UObject)
end

function LuaServiceQueryRangeNpc:OnUpdateService(AIController, DeltaTime)
  local owner = AIController
  local ownerLocation = owner.Npc:GetActorLocation()
  local _, result = UE4.UKismetSystemLibrary.Abs_SphereOverlapActors(owner:GetWorld(), ownerLocation, self.queryRange, nil, nil, nil, self.outActors)
  if result then
    for i = 1, self.outActors:Length() do
      local curActor = self.outActors:Get(i)
      if curActor.sceneCharacter and curActor.sceneCharacter.config and #self.queryIds > 0 then
        for _, id in ipairs(self.queryIds) do
          if curActor.sceneCharacter.config.id == id then
            if UE4.UNRCStatics.GetObjectUniqueID(curActor.sceneCharacter.viewObj) ~= UE4.UNRCStatics.GetObjectUniqueID(owner.Npc.viewObj) then
              if self.skipTargetBBCheck then
                self:FoundWithResult(owner, true)
                do return end
                break
              end
              local targetKeyName = string.split(self.TargetKey.key, "]_")[2]
              local curController = curActor.Controller
              if curController then
                local targetBBVal = curController:QueryCrossBlackboardValue(targetKeyName, self.TargetKey.type)
                if nil ~= targetBBVal then
                  if self.SameAs:GetValue(owner) == targetBBVal then
                    self:FoundWithResult(owner, true)
                    return
                  end
                  break
                end
                Log.Warning("[LuaActionQueryNearestObject] Cant find target BBVal by [" .. targetKeyName .. "], ignored filter")
              end
            end
            break
          end
        end
      end
    end
  end
  self:FoundWithResult(owner, false)
end

function LuaServiceQueryRangeNpc:FoundWithResult(AIController, result)
  if result ~= self.lastResult then
    self.OutBBValue:SetValue(AIController, result)
    self.lastResult = result
  end
end

return LuaServiceQueryRangeNpc
