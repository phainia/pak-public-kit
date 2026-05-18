require("UnLuaEx")
local BP_TestSequencePlayer_C = NRCClass()

function BP_TestSequencePlayer_C:Initialize(Initializer)
end

function BP_TestSequencePlayer_C:InnerTick(Delta)
  if self.SkeletonComp and self.Skeleton and self.SequencePlayer:IsPlaying() then
    table.insert(self.SnapTable, self.SkeletonComp:SnapshotPose())
    table.insert(self.FrameTable, self.SequencePlayer:GetCurrentTime().Time.FrameNumber.Value)
  end
end

function BP_TestSequencePlayer_C:BeginPlay()
  self.SequencePlayer.OnPlay:Add(self, self.OnPlay)
  self.SequencePlayer.OnFinished:Add(self, self.OnFinished)
  self.SequencePlayer:Play()
end

function BP_TestSequencePlayer_C:OnPlay()
  self.SnapTable = {}
  self.FrameTable = {}
  local SkelAct = UE4.UGameplayStatics.GetAllActorsOfClassWithTag(UE4Helper.GetCurrentWorld(), UE4.ASkeletalMeshActor, "SequencerActor"):Get(1)
  self.SkeletonComp = SkelAct:GetComponentByClass(UE4.USkeletalMeshComponent)
  self.Skeleton = self.SkeletonComp.SkeletalMesh
end

function BP_TestSequencePlayer_C:OnFinished()
  self:Eval()
  local Kllass
  local Widget = UE4.UWidgetBlueprintLibrary.Create(UE4Helper.GetCurrentWorld(), Kllass, UE4.UGameplayStatics:GetPlayerController(0))
  if self.IllegalText then
    Widget.Text:SetText(self.IllegalText)
  end
  Widget:AddToViewport()
end

function BP_TestSequencePlayer_C:Eval()
  self.IllegalText = nil
  local Extent = self.Skeleton:GetImportedBounds().SphereRadius * 3
  local BoneTransArrt = self.SnapTable[1].BoneNames
  local Indx = 1
  for i = 1, BoneTransArrt:Length() - 1 do
    if BoneTransArrt:Get(i) == "Bip001-Pelvis" then
      Indx = i
      break
    end
  end
  for index, snap in ipairs(self.SnapTable) do
    local BoneTransArr = snap.LocalTransforms
    local BaseTrans = BoneTransArr:Get(Indx)
    for i = Indx + 1, BoneTransArr:Length() - 1 do
      local DistanceBetween = BaseTrans.Translation:Dist(BoneTransArr:Get(i).Translation)
      local BoneName = snap.BoneNames:Get(i)
      if Extent < DistanceBetween then
        self.IllegalText = "\232\182\133\229\135\186\232\140\131\229\155\180!!!! \232\183\157\231\166\187\239\188\154" .. DistanceBetween .. " \233\170\168\233\170\188\229\144\141\231\167\176\239\188\154" .. BoneName .. " \229\175\185\230\175\148\233\170\168\233\170\188\229\144\141\231\167\176\239\188\154" .. snap.BoneNames:Get(Indx) .. " \229\143\145\231\148\159\229\184\167\230\149\176\239\188\154" .. self.FrameTable[index] .. " \233\170\140\232\175\129\232\140\131\229\155\180\239\188\154" .. Extent
        return
      end
    end
  end
end

return BP_TestSequencePlayer_C
