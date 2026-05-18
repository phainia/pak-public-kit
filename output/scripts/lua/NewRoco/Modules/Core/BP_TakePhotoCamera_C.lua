require("UnLua")
local BP_TakePhotoCamera_C = NRCClass()

function BP_TakePhotoCamera_C:ReceiveBeginPlay()
  self.alpha = 0
  self.isVisible = not self.bHidden
  if self.ActionArea then
    self.ActionArea:SetCollisionObjectType(UE4.ECollisionChannel.ECC_Pawn)
    self.ActionArea:SetCollisionEnabled(UE.ECollisionEnabled.QueryOnly)
  end
end

function BP_TakePhotoCamera_C:SetMeshAlpha(Alpha)
  if self.alpha ~= Alpha then
    self.alpha = Alpha
    self:UpdateVisible()
  end
end

function BP_TakePhotoCamera_C:SetVisible(isVisible)
  if self.isVisible ~= isVisible then
    self.isVisible = isVisible
    self:UpdateVisible()
  end
end

function BP_TakePhotoCamera_C:UpdateVisible()
  if self.isVisible and 0 == self.alpha then
    self:SetActorHiddenInGame(false)
  else
    self:SetActorHiddenInGame(true)
  end
end

return BP_TakePhotoCamera_C
