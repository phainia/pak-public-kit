local UMG_LockPet_C = require("NewRoco.Modules.System.MainUI.Res.UMG_LockPet_C")
local UMG_LockPetPart3_C = _G.NRCPanelBase:Extend("UMG_LockPetPart3_C")

function UMG_LockPetPart3_C:OnConstruct()
end

function UMG_LockPetPart3_C:OnDestruct()
end

function UMG_LockPetPart3_C:OnActive()
end

function UMG_LockPetPart3_C:OnDeactive()
end

function UMG_LockPetPart3_C:SetShowIcon(type)
  if type == UMG_LockPet_C.LockingType.NAD_REWARD then
    self.Hand:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Hand:SetPath("PaperSprite'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUI/Frames/img_caiji_png.img_caiji_png'")
  elseif type == UMG_LockPet_C.LockingType.NAD_WILD_PET then
    self.Hand:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Hand:SetPath("PaperSprite'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUI/Frames/icon_suodingtou_png.icon_suodingtou_png'")
  elseif type == UMG_LockPet_C.LockingType.NAD_SPEOBJ then
    self.Hand:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Hand:SetPath("PaperSprite'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUI/Frames/img_QuasiHeart_ExclamationMark_png.img_QuasiHeart_ExclamationMark_png'")
  elseif type == UMG_LockPet_C.LockingType.NAD_NORMAL then
    self.Hand:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Dot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif type == UMG_LockPet_C.LockingType.NAD_NONE then
    self.Hand:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Dot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_LockPetPart3_C:PlayOpenAnim()
  self:PlayAnimation(self.open)
end

function UMG_LockPetPart3_C:PlayLoopAnim()
  self:PlayAnimation(self.loop, 0.0, 0)
end

function UMG_LockPetPart3_C:PlayCloseAnim()
  self:PlayAnimation(self.close)
end

function UMG_LockPetPart3_C:PlayClickAnim()
  self:PlayAnimation(self.click)
end

function UMG_LockPetPart3_C:PlayLockAnim()
  self:PlayAnimation(self.lock)
end

function UMG_LockPetPart3_C:PlayLockLoopAnim()
  self:PlayAnimation(self.lock_loop, 0.0, 0)
end

function UMG_LockPetPart3_C:PlayLockCancelAnim()
  self:PlayAnimation(self.lock_cancle)
end

function UMG_LockPetPart3_C:OnAnimationFinished(anim)
  if anim == self.open then
    self:PlayLoopAnim()
  end
end

function UMG_LockPetPart3_C:StopAllAnim()
  if self:IsAnyAnimationPlaying() then
    self:StopAllAnimations()
  end
end

return UMG_LockPetPart3_C
