local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_BagIcon_Ani_1_C = Base:Extend("UMG_BagIcon_Ani_1_C")
local BagModuleEvent = reload("NewRoco.Modules.System.Bag.BagModuleEvent")

function UMG_BagIcon_Ani_1_C:OnConstruct()
end

function UMG_BagIcon_Ani_1_C:OnDestruct()
  self:CancelDelay()
end

function UMG_BagIcon_Ani_1_C:OnItemUpdate(_data, datalist, index)
  self:PlayAnimation(self.normal)
  self.TypeIndex = _data
  self.index = index
  self:SetIcon()
  self.RedDot:SetupKey(50, {
    self.TypeIndex - 1
  })
end

function UMG_BagIcon_Ani_1_C:SetIcon()
  if 1 == self.TypeIndex then
    self.icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img__tabIcon1_png.img__tabIcon1_png'")
    self.icon_1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_tabicon1_select_png.img_tabicon1_select_png'")
  end
  if 2 == self.TypeIndex then
    self.icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_tabicon2_png.img_tabicon2_png'")
    self.icon_1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_tabicon2_select_png.img_tabicon2_select_png'")
  end
  if 3 == self.TypeIndex then
    self.icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_tabrenwu_png.img_tabrenwu_png'")
    self.icon_1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_tabrenwu_select_png.img_tabrenwu_select_png'")
  end
  if 4 == self.TypeIndex then
    self.icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img__tabIcon3_png.img__tabIcon3_png'")
    self.icon_1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img__tabIcon3_select_png.img__tabIcon3_select_png'")
  end
  if 5 == self.TypeIndex then
    self.icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img__tabIcon4_png.img__tabIcon4_png'")
    self.icon_1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img__tabIcon4_select_png.img__tabIcon4_select_png'")
  end
  if 6 == self.TypeIndex then
    self.icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img__tabIcon6_png.img__tabIcon6_png'")
    self.icon_1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img__tabIcon6_select_png.img__tabIcon6_select_png'")
  end
  if 7 == self.TypeIndex then
    self.icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img__tabIcon5_png.img__tabIcon5_png'")
    self.icon_1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img__tabIcon5_select_png.img__tabIcon5_select_png'")
  end
  if 8 == self.TypeIndex then
    self.icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img__tabIcon7_png.img__tabIcon7_png'")
    self.icon_1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img__tabIcon7_select_png.img__tabIcon7_select_png'")
  end
  if 9 == self.TypeIndex then
    self.icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_tabrenwu_png.img_tabrenwu_png'")
    self.icon_1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_tabrenwu_select_png.img_tabrenwu_select_png'")
  end
  if 10 == self.TypeIndex then
    self.icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_tabguoshi_png.img_tabguoshi_png'")
    self.icon_1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_tabguoshi_select_png.img_tabguoshi_select_png'")
  end
  if self.TypeIndex == Enum.ItemLableType.ILT_FURNITURE + 1 then
    self.icon:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Furniture_png.img_Furniture_png'")
    self.icon_1:SetPath("PaperSprite'/Game/NewRoco/Modules/System/Bag/Raw/BagStatic/Frames/img_Furniture_select_png.img_Furniture_select_png'")
    return
  end
end

function UMG_BagIcon_Ani_1_C:OnItemSelected(bSelected, bScrollChoose)
  if bSelected then
    self:StopAllAnimations()
    _G.NRCModuleManager:GetModule("BagModule"):DispatchEvent(BagModuleEvent.ChangeTypeTab, self.TypeIndex)
    self:PlayAnimation(self.change1)
    self:CancelDelay()
    self.DelayHandle = _G.DelayManager:DelaySeconds(3, function()
      self:PlayLoopAnim()
    end)
    _G.NRCAudioManager:PlaySound2DAuto(40001001, "UMG_BagIcon_Ani_1_C:OnTouchEnded")
  else
    self:CancelDelay()
    self:PlayAnimation(self.normal)
    self:StopAllAnimations()
    self:PlayAnimation(self.change2)
  end
end

function UMG_BagIcon_Ani_1_C:PlayLoopAnim()
  if self.isDestruct then
    self:CancelDelay()
    return
  end
  self:PlayAnimation(self.select_loop)
  self:CancelDelay()
  self.DelayHandle = _G.DelayManager:DelaySeconds(8, self.PlayLoopAnim, self)
end

function UMG_BagIcon_Ani_1_C:CancelDelay()
  if self.DelayHandle then
    _G.DelayManager:CancelDelayById(self.DelayHandle)
    self.DelayHandle = nil
  end
end

function UMG_BagIcon_Ani_1_C:RemoveSelected(_CurItemType)
  self:CancelDelay()
  if 0 == _CurItemType then
    self:PlayAnimation(self.normal)
    self:StopAllAnimations()
    self:PlayAnimation(self.change2)
    self:CancelDelay()
  end
end

function UMG_BagIcon_Ani_1_C:PlayDefauleSelecteAnim()
  self:PlayAnimation(self.normal)
  self:StopAllAnimations()
  self:PlayAnimation(self.change1)
end

function UMG_BagIcon_Ani_1_C:OnAnimationFinished(Anim)
  if Anim == self.change1 then
  end
end

return UMG_BagIcon_Ani_1_C
