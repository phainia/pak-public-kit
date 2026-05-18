local ThrowSessionStatusEnum = {
  None = 0,
  InHand = 1,
  InAir = 2,
  PreReleasing = 3,
  Releasing = 4,
  Interacting = 5,
  CriticalInteracting = 6,
  PostInteract = 7,
  Recycling = 8,
  Destroyed = 9,
  WaitBeginDrop = 10,
  WaitEnter = 11,
  Abandon = 12,
  WaitForRecycle = 13,
  Catching = 14,
  FriendRiding = 15
}
return ThrowSessionStatusEnum
