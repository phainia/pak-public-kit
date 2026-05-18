local DebugUtils = {}

function DebugUtils.GetPosCopyStr(pos)
  if not pos then
    return "\231\169\186\229\157\144\230\160\135"
  end
  return string.format("(X=%f,Y=%f,Z=%f)", pos.X, pos.Y, pos.Z)
end

function DebugUtils.GetLocalPlayerPosStr()
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerLocation = player.viewObj:Abs_K2_GetActorLocation()
  return DebugUtils.GetPosCopyStr(playerLocation)
end

function DebugUtils.GetActorPosStr(viewObj)
  if not viewObj then
    return
  end
  return DebugUtils.GetPosCopyStr(viewObj:Abs_K2_GetActorLocation())
end

function DebugUtils.DebugPointByLine(pos, time)
  time = time or 100
  local debugStart = UE4.FVector(pos.X, pos.Y, pos.Z)
  local debugEnd = UE4.FVector(pos.X, pos.Y, pos.Z + 100)
  Log.Debug("DebugPointByLine", debugStart.X, debugStart.Y, debugStart.Z)
  UE4.UKismetSystemLibrary.Abs_DrawDebugLine(_G.UE4Helper.GetCurrentWorld(), debugStart, debugEnd, UE4.FLinearColor(1, 0, 0, 1), time)
end

function DebugUtils.DebugDrawBox(p1, time, color)
  time = time or 25
  color = color or UE4.FLinearColor(1, 0, 0, 1)
  local extend = UE4.FVector(10, 10, 10)
  UE4.UKismetSystemLibrary.Abs_DrawDebugBox(UE4Helper.GetCurrentWorld(), p1, extend, color, nil, time)
end

function DebugUtils.DebugVec(startPos, vec, time, color)
  time = time or 25
  color = color or UE4.FLinearColor(1, 0, 0, 1)
  UE4.UKismetSystemLibrary.Abs_DrawDebugLine(_G.UE4Helper.GetCurrentWorld(), startPos, startPos + vec, color, time)
end

function DebugUtils.DebugSegmentBox(p1, p2, time, color)
  time = time or 25
  color = color or UE4.FLinearColor(1, 0, 0, 1)
  UE4.UKismetSystemLibrary.Abs_DrawDebugLine(_G.UE4Helper.GetCurrentWorld(), p1, p2, color, time)
  local extend = UE4.FVector(10, 10, 10)
  UE4.UKismetSystemLibrary.Abs_DrawDebugBox(UE4Helper.GetCurrentWorld(), p1, extend, color, nil, time)
  UE4.UKismetSystemLibrary.Abs_DrawDebugBox(UE4Helper.GetCurrentWorld(), p2, extend, color, nil, time)
end

function DebugUtils.DebugSegmentSphere(p1, p2, time, color)
  time = time or 25
  color = color or UE4.FLinearColor(1, 0, 0, 1)
  UE4.UKismetSystemLibrary.Abs_DrawDebugLine(_G.UE4Helper.GetCurrentWorld(), p1, p2, color, time)
  local extend = UE4.FVector(10, 10, 10)
  UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), p1, 10, 12, color, time)
  UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), p2, 10, 12, color, time)
end

function DebugUtils.SplitBitSet(BitSet, DebugTab)
  DebugTab = DebugTab or {}
  while BitSet > 0 do
    local SplitMinValue = BitSet & -BitSet
    local Index = math.log(SplitMinValue, 2)
    Log.Warning("BitSet\229\140\133\229\144\171:", table.getKeyName(DebugTab, Index))
    BitSet = BitSet & ~SplitMinValue
  end
end

return DebugUtils
