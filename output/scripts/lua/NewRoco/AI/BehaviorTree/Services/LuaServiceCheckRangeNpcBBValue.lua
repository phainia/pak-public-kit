local Base = require("NewRoco.AI.BehaviorTree.LuaServiceBase")
local LuaServiceCheckRangeNpcBBValue = Base:Extend("LuaServiceCheckRangeNpcBBValue")

function LuaServiceCheckRangeNpcBBValue:OnStart(OwnerController, ...)
  local args = {
    ...
  }
  local owner = OwnerController
  local testNpcIds = self.TestNpcIds:GetValue(owner)
  self.arrayTestNpcId = UE4.TArray(0)
  if not string.IsNilOrEmpty(testNpcIds) then
    local strArrIds = string.Split(testNpcIds, ",")
    for i, v in ipairs(strArrIds) do
      if not string.IsNilOrEmpty(v) then
        local curId = tonumber(v)
        self.arrayTestNpcId:Add(curId)
      end
    end
  end
  self.bbVal = self.BBVal:GetValue(owner)
  self.testDis = self.TestDistance:GetValue(owner)
  self.ifTestSameIdNpc = self.IfTestSameIdNpc:GetValue(owner)
  self.world = owner:GetWorld()
  self.UKismetSystemLibrary = UE4.UKismetSystemLibrary
end

function LuaServiceCheckRangeNpcBBValue:OnEnd(...)
  self.world = nil
  self.UKismetSystemLibrary = nil
end

function LuaServiceCheckRangeNpcBBValue:OnUpdateService(OwnerController, DeltaTime, ...)
  local owner = OwnerController
  if owner.Npc.viewObj == nil then
    return
  end
  local testResult = false
  local selfId = owner.Npc.config.id
  local ownerLocation = owner.Npc:GetActorLocation()
  local outActors, result = self.UKismetSystemLibrary.Abs_SphereOverlapActors(self.world, ownerLocation, self.testDis, nil, nil, nil)
  if result then
    for i = 1, outActors:Length() do
      local curActor = outActors:Get(i)
      local curController = curActor.Controller
      if nil == curController then
      end
      if not (curController and curController.Npc and curController.Npc.viewObj) or UE4.UNRCStatics.GetObjectUniqueID(curController.Npc.viewObj) == UE4.UNRCStatics.GetObjectUniqueID(owner.Npc.viewObj) then
      elseif self.ifTestSameIdNpc then
        if curController.Npc.config.id == selfId and self:CheckBBValue(curController) then
          testResult = true
          break
        end
      else
        if self.arrayTestNpcId:Length() > 0 then
          for j = 1, self.arrayTestNpcId:Length() do
            local curNpcId = self.arrayTestNpcId:Get(j)
            if curController.Npc.config.id == curNpcId and self:CheckBBValue(curController) then
              testResult = true
              break
            end
          end
        else
        end
      end
    end
  end
  local prevResult = self.OutTestResult:GetValue(owner)
  if true == prevResult or false == prevResult and true == testResult then
    self.OutTestResult:SetValue(owner, testResult)
  end
end

function LuaServiceCheckRangeNpcBBValue:CheckBBValue(AiController)
  local bbValue
  if string.find(self.BBKey.key, "_]") then
    local targetKeyName = string.split(self.BBKey.key, "]_")[2]
    bbValue = AiController:QueryCrossBlackboardValue(targetKeyName, self.BBKey.type)
  else
    bbValue = self.BBKey:GetValue(AiController)
  end
  return bbValue == self.bbVal
end

return LuaServiceCheckRangeNpcBBValue
