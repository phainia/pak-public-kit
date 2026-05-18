require("UnLuaEx")
local UMG_AllCharacters_C = NRCClass()

function UMG_AllCharacters_C:Ctor()
  self.HangingStartPos = nil
  self.hanging = false
end

function UMG_AllCharacters_C:OpenAssetEditor(asset)
  if asset then
    UE.UNRCEditorAssetLibrary.OpenAssetEditor(asset)
  else
    error("Not valid asset")
  end
end

function UMG_AllCharacters_C:DuplicateCurveForActor(Actor, MemberName, suffix)
  local classPath = Actor:GetClass():GetFullName()
  local arg = classPath and string.split(classPath, " ")
  if arg and 2 == #arg then
    classPath = arg[2]
  end
  if not classPath then
    error("Failed!")
    return
  end
  local rawPath = string.sub(classPath, 1, string.find(classPath, "/[^/]*$") - 1)
  local npcName = string.sub(rawPath, string.find(rawPath, "/[^/]*$") + 1)
  local destPath = string.format("%s/Curves/C_%s_%s", rawPath, npcName, suffix)
  Log.Warning(destPath)
  UE.UNRCEditorAssetLibrary.DuplicateAssetAndAssignNewOne(Actor, MemberName, destPath)
end

function UMG_AllCharacters_C:HangingAction(Actor, Distance)
  if not Actor then
    return
  end
  Distance = math.max(0, Distance or 800)
  local comp = Actor:GetComponentByClass(UE.UAnimDrivenMoveComponent)
  comp = comp or Actor:AddComponentByClass(UE.UAnimDrivenMoveComponent, false, UE4.FTransform(), false)
  local actorPos = Actor:Abs_K2_GetActorLocation()
  if not self.HangingStartPos then
    self.HangingStartPos = actorPos - UE.FVector(0, 0, Actor:GetCurrentHalfHeight())
  end
  if not self.hanging then
    local startPos = actorPos
    local endPos = actorPos + UE.FVector(0, 0, Distance)
    comp:RequestDirectLerpMoving("HangingStart", startPos, endPos, 1, 0.2, 0, false, "HangingLoop")
    self.hanging = true
  else
    local startPos = actorPos
    local endPos = self.HangingStartPos
    comp:RequestDirectLerpMoving("HangingEnd", startPos, endPos + UE.FVector(0, 0, Actor:GetCurrentHalfHeight()), 1, 0.2, 0.2, true)
    self.hanging = false
  end
end

function UMG_AllCharacters_C:InitPetSwimTable()
  self._PetSwimTable = {}
  local ModelConf = DataConfigManager:GetTable(DataConfigManager.ConfigTableId.MODEL_CONF):GetAllDatas()
  for _, v in pairs(ModelConf) do
    if v.habitat_flag == Enum.HABITAT_FLAG.HAB_WATER then
      local match = string.match(v.path, "/([^/]+)/BP_")
      if match and "" ~= match then
        self._PetSwimTable[match] = 1
      end
    end
  end
end

function UMG_AllCharacters_C:CanPetSwim(MeshName)
  if not self._PetSwimTable or not self._PetSwimTable[MeshName] then
    return false
  end
  return true
end

return UMG_AllCharacters_C
