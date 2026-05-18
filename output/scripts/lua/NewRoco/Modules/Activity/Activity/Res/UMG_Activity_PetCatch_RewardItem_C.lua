local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_ItemBase_C")
local UMG_Activity_PetCatch_RewardItem_C = Base:Extend("UMG_Activity_PetCatch_RewardItem_C")

function UMG_Activity_PetCatch_RewardItem_C:SetQuantity(_str)
  self.Text_quantity:SetText(_str)
end

function UMG_Activity_PetCatch_RewardItem_C:SetItemData(_itemData)
  self.ListItemIcon:OnItemUpdate(_itemData, nil, self.index)
end

function UMG_Activity_PetCatch_RewardItem_C:SelectItem()
  self.ListItemIcon:OnItemSelected(true)
end

function UMG_Activity_PetCatch_RewardItem_C:SetRewardAvailable()
  self.ListItemIcon:SetCanClick(true)
  self:TryPlayAnimation(self.select, false, 0)
  self:TryPlayAnimation(self.Available, false, 1000, true)
end

function UMG_Activity_PetCatch_RewardItem_C:SetRewardAvailable_SeasonItem()
  self.ListItemIcon:SetCanClick(true)
  self:TryPlayAnimation(self.select_1, false, 0)
  self:TryPlayAnimation(self.Available, false, 1000, true)
end

function UMG_Activity_PetCatch_RewardItem_C:SetupRedPoint(_key, _extraKey)
  self.redPointNew:SetupKey(_key, _extraKey)
end

function UMG_Activity_PetCatch_RewardItem_C:BroadcastOnClicked()
  if not self.ParentView then
    self:SelectItem()
  end
end

function UMG_Activity_PetCatch_RewardItem_C:SetAlreadyReceived(_received, _playGetAnim, _SeasonItem)
  if _received then
    self.ListItemIcon:SetCanClick(false)
    self:TryStopAnimation(self.Available)
    if _playGetAnim then
      self:PlayRewardGetAnimation()
    end
    if _SeasonItem then
      self:PlayRewardGetAnimation_SeasonItem()
    end
  end
  self.ListItemIcon:SetAlreadyReceived(_received)
end

function UMG_Activity_PetCatch_RewardItem_C:PlayRewardGetAnimation()
  self:TryStopAnimation(self.Available, true)
  self:TryPlayAnimation(self.Get, false, 10)
end

function UMG_Activity_PetCatch_RewardItem_C:PlayRewardGetAnimation_SeasonItem()
  self:TryStopAnimation(self.Available, true)
  self:TryPlayAnimation(self.Get_1, false, 10)
end

function UMG_Activity_PetCatch_RewardItem_C:OnAnimationStarted(anim)
  Base.OnAnimationStarted(self, anim)
end

return UMG_Activity_PetCatch_RewardItem_C
