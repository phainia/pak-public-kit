local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleDelayExecuteActionBase = require("NewRoco.Modules.Core.Battle.Fsm.Actions.Base.BattleDelayExecuteActionBase")
local Base = BattleDelayExecuteActionBase
local BattleHideSceneTreesAction = Base:Extend("BattleHideSceneTreesAction")
FsmUtils.MergeMembers(Base, BattleHideSceneTreesAction, {})

function BattleHideSceneTreesAction:Ctor(name, properties)
  Base.Ctor(self, name, properties)
end

function BattleHideSceneTreesAction:OnEnter()
  Base.OnEnter(self)
  self:Finish()
end

function BattleHideSceneTreesAction:DelayRun()
  Base.DelayRun(self)
  local batleaf_hidden_distance = DataConfigManager:GetMapGlobalConfig("batleaf_hidden_distance").num
  UE4.UNRCStatics.Abs_SetBattleGrassVisibleAndDist(BattleManager.battleRuntimeData.NearbyValidBattleLocation, 1, BattleConst.HideObjectParam.HideGrassDist, batleaf_hidden_distance)
  self:ChangeBattleGrass()
  NRCModeManager:DoCmd(TaskModuleCmd.SetSplineVisible, false)
  if BattleConst.DonntHideTree then
    self:Finish()
    return
  end
  self.isShowDebugBox = false
  self:HideTreesInSphere()
  self:DelayComplete()
end

function BattleHideSceneTreesAction:ChangeBattleGrass()
  BattleManager.vBattleField:ChangeGrass()
end

function BattleHideSceneTreesAction:HideTreesInSphere()
  Log.Debug("BattleHideSceneTreesAction HideTreesInSphere:", BattleConst.Define.BattleFieldRange)
  if BattleConst.debugCloseHideScene then
    return
  end
  local playerPos = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER).viewObj:Abs_K2_GetActorLocation()
  local lineBegin = UE4.FVector(playerPos.X, playerPos.Y, playerPos.Z + 1500)
  local lineEnd = UE4.FVector(playerPos.X, playerPos.Y, playerPos.Z - 1500)
  local hits, result = UE4.UKismetSystemLibrary.SphereTraceMulti(_G.UE4Helper.GetCurrentWorld(), lineBegin, lineEnd, BattleConst.Define.BattleFieldRange, UE4.ETraceTypeQuery.TraceTypeQuery_MAX, false, nil)
  if result then
    for i = 1, hits:Length() do
      local hitActor = hits:Get(i)
      if hitActor.Actor:IsA(UE4.AInstancedFoliageActor) then
        Log.Debug("BattleHideSceneTreesAction HideTreesInSphere hitActor.Component:GetName():", hitActor.Component:GetName())
        local Origin, Extend = hitActor.Component:GetLocalBounds()
        if not self:IsValidToShow(Extend.X, Extend.Y, Extend.Z) then
          local tf = hitActor.Component:GetInstanceTransform(hitActor.Item)
          local treeGroupName = hitActor.Component:GetName()
          Log.Debug("hitactor is instance:", hitActor.Component:GetName(), hitActor.Item, tf.Translation, Origin, Extend)
          if self.isShowDebugBox then
            UE4.UKismetSystemLibrary.Abs_DrawDebugBox(UE4Helper.GetCurrentWorld(), tf.Translation, Extend, UE4.FLinearColor(1, 0, 0, 1), nil, 10000)
          end
          if not self:GetTreeDict()[treeGroupName] then
            self:GetTreeDict()[treeGroupName] = {}
            table.insert(self:GetTreeDict()[treeGroupName], hitActor)
          end
          table.insert(self:GetTreeDict()[treeGroupName], tf)
          BattleManager.battleRuntimeData.battleHideTreeHitActorDict = hitActor
          tf.Scale3D = UE4.FVector(0, 0, 0)
          hitActor.Component:UpdateInstanceTransform(hitActor.Item, tf, false)
        else
          Log.Debug("BattleHideScenePetAction donnt hide:")
        end
      else
        local Origin, Extend = hitActor.Actor:GetActorBounds()
        Log.Debug("hitactor is static mesh:", hitActor.Actor:GetName(), hitActor.Actor:IsA(UE4.AStaticMeshActor), Origin, Extend)
        if hitActor.Actor:IsA(UE4.AStaticMeshActor) and not self:IsValidToShow(Extend.X, Extend.Y, Extend.Z) then
          Log.Debug("hitactor hide actor", hitActor.Actor:GetName(), Origin, Extend)
          hitActor.Actor:SetActorHiddenInGame(true)
          if self.isShowDebugBox then
            UE4.UKismetSystemLibrary.Abs_DrawDebugBox(UE4Helper.GetCurrentWorld(), Origin, Extend, UE4.FLinearColor(1, 0, 1, 1), nil, 10000)
          end
          table.insert(BattleManager.battleRuntimeData.battleHideStaticMeshLst, hitActor.Actor)
        end
      end
    end
  end
end

function BattleHideSceneTreesAction:IsValidToShow(x, y, z)
  if x * y * z >= BattleConst.HideObjectParam.DonntHideVolume then
    return true
  end
  if x >= BattleConst.HideObjectParam.DonntHideSizeX or y >= BattleConst.HideObjectParam.DonntHideSizeY or z >= BattleConst.HideObjectParam.DonntHideSizeZ then
    return true
  else
    return false
  end
end

function BattleHideSceneTreesAction:GetTreeDict()
  return BattleManager.battleRuntimeData.battleHideTreeDict
end

function BattleHideSceneTreesAction:ClearTreeDict()
  BattleManager.battleRuntimeData.battleHideTreeDict = {}
end

function BattleHideSceneTreesAction:OnExit()
end

return BattleHideSceneTreesAction
