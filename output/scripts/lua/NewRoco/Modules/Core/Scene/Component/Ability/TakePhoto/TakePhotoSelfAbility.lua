local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local TakePhotoSelfAbility = Base:Extend("TakePhotoSelfAbility")

function TakePhotoSelfAbility:Start(OnFinished)
  local player = self.caster
  local isTakePhoto = player.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO_SELF)
  player.viewObj.TakePhotoSelf = isTakePhoto
  if isTakePhoto then
    if player.isLocal then
      player.viewObj.HandIkTargetActorOffset = UE.FVector(0, 0, 0)
      player.viewObj:SetEightDirectionMoveEnable(true)
    end
  elseif player.isLocal then
    player.viewObj.HandIkTargetActor = nil
    player.viewObj.HandIkTargetActorOffset = UE.FVector(0, 0, 0)
    player.viewObj:SetEightDirectionMoveEnable(false)
  end
end

function TakePhotoSelfAbility:Recover(owner)
  if owner and UE.UObject.IsValid(owner.viewObj) then
    local isTakePhoto = owner.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_TAKE_PHOTO_SELF)
    owner.viewObj.TakePhotoSelf = isTakePhoto
    if owner.isLocal and not isTakePhoto then
      owner.viewObj.HandIkTargetActor = nil
      owner.viewObj.HandIkTargetActorOffset = UE.FVector(0, 0, 0)
      owner.viewObj:SetEightDirectionMoveEnable(false)
    end
  end
end

return TakePhotoSelfAbility
