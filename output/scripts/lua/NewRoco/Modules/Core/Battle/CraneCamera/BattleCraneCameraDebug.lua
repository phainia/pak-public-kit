local BattleCraneCameraDebug = NRCClass()

function BattleCraneCameraDebug:Ctor()
end

function BattleCraneCameraDebug:BindCamera()
end

function BattleCraneCameraDebug:DrawDebugLine()
  local CameraActor = _G.BattleManager:GetCraneCamera()
  if CameraActor then
    self.CameraComponent = CameraActor:GetComponentByClass(UE4.UCameraComponent)
    local pos1 = self.CameraComponent:Abs_K2_GetComponentLocation()
    local pos2 = CameraActor:Abs_K2_GetActorLocation()
    local World = UE4Helper.GetCurrentWorld()
    if pos1 and pos2 then
      UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(World, pos1, 5, 10, UE4.FLinearColor(0, 1, 0, 1), 0, 2)
      UE4.UKismetSystemLibrary.Abs_DrawDebugLine(World, pos2, pos1, UE4.FLinearColor(1, 0, 0, 1), 0, 1)
    end
    local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
    local pet1 = BattleManager.vBattleField.battleCraneCamera.confData.targetPos1
    local pet2 = BattleManager.vBattleField.battleCraneCamera.confData.targetPos2
    UE4.UKismetSystemLibrary.Abs_DrawDebugLine(World, pet1, pet2, UE4.FLinearColor(1, 0, 0, 1), 0, 1)
    local GetAidRotationCam = _G.BattleManager:GetAidRotationCam()
    local AidCamPos = GetAidRotationCam:Abs_K2_GetActorLocation()
    UE4.UKismetSystemLibrary.Abs_DrawDebugLine(World, AidCamPos, pos1, UE4.FLinearColor(1, 0, 0, 1), 0, 1)
    local pets = BattleManager.battlePawnManager:GetPlayerTeamPets()
    for _, pet in pairs(pets) do
      local Location = _G.BattleManager.vBattleField:GetBattleFieldLocationByAttachPoint(pet.AttachPoint)
      if Location then
        UE4.UKismetSystemLibrary.Abs_DrawDebugLine(World, pos1, Location, UE4.FLinearColor(0, 1, 0, 1), 0, 1)
        UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(World, Location, 5, 10, UE4.FLinearColor(0, 1, 0, 1), 0, 2)
      end
    end
    pets = BattleManager.battlePawnManager:GetEnemyAllPets()
    for _, pet in pairs(pets) do
      local Location = _G.BattleManager.vBattleField:GetBattleFieldLocationByAttachPoint(pet.AttachPoint)
      if Location then
        UE4.UKismetSystemLibrary.Abs_DrawDebugLine(World, pos1, Location, UE4.FLinearColor(0, 1, 0, 1), 0, 1)
        UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(World, Location, 5, 10, UE4.FLinearColor(0, 1, 0, 1), 0, 2)
      end
    end
  end
end

return BattleCraneCameraDebug
