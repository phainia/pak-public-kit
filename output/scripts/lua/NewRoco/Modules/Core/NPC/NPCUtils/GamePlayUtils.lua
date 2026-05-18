local GamePlayUtils = {}

function GamePlayUtils.GetLastSectionInMontage(montage, trackId)
  if not montage then
    return nil
  end
  trackId = trackId or 1
  local n = montage.SlotAnimTracks:Length()
  if trackId > n then
    return nil
  end
  local slot = montage.SlotAnimTracks:Get(trackId)
  local n = slot.AnimTrack.AnimSegments:Length()
  local animSegment = slot.AnimTrack.AnimSegments:Get(n)
  return animSegment.AnimReference
end

function GamePlayUtils.GetLandSoundSwitchByHitType(hit)
  local surfaceType = UE4.UGameplayStatics.GetSurfaceType(hit)
  local _, _, _, _, location, _, normal, _, _, _, hitComp, _, _, faceIndex, _, _ = UE4.UGameplayStatics.BreakHitResult(hit)
  local table = {
    [UE4.EPhysicalSurface.SurfaceType1] = function()
      local staticMeshComp = hitComp:Cast(UE4.UStaticMeshComponent)
      if staticMeshComp then
        local color = UE4.UNewRocoHelperLibrary.GetFaceColorOfMesh(staticMeshComp, faceIndex)
        local channel = UE4.UNewRocoHelperLibrary.GetSurfaceChannel(color)
        local layerName = string.format("Layer%d_D", channel)
        local materialInterface = hitComp:GetMaterialFromCollisionFaceIndex(faceIndex)
        local materialTexture = UE4.UNewRocoHelperLibrary.GetMaterialTexture(materialInterface, layerName)
        local materialName = UE4.UKismetSystemLibrary.GetDisplayName(materialTexture)
        if string.find(materialName, "caodi") then
          return "grass"
        else
          return "land"
        end
      else
        Log.Debug("GamePlayUtils.GetLandSoundSwitchByHitType \230\178\161\230\156\137\230\137\190\229\136\176StaticMesh\239\188\140hit\231\154\132\229\143\175\232\131\189\228\184\141\230\152\175\229\156\176\233\157\162")
        return "grass"
      end
    end,
    [UE4.EPhysicalSurface.SurfaceType2] = function()
      return "sand"
    end,
    [UE4.EPhysicalSurface.SurfaceType3] = function()
      return "water"
    end,
    [UE4.EPhysicalSurface.SurfaceType4] = function()
      return "land"
    end,
    [UE4.EPhysicalSurface.SurfaceType5] = function()
      return "water"
    end,
    [UE4.EPhysicalSurface.SurfaceType6] = function()
      return "grass"
    end,
    [UE4.EPhysicalSurface.SurfaceType7] = function()
      return "stone"
    end
  }
  if table[surfaceType] then
    return table[surfaceType]()
  else
    Log.Debug("GamePlayUtils.GetLandSoundSwitchByHitType \230\156\170\230\137\190\229\136\176\231\154\132Surface\231\177\187\229\158\139")
    return "grass"
  end
end

return GamePlayUtils
