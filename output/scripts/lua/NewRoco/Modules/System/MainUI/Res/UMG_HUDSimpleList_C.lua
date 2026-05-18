local MainUIModuleUtils = require("NewRoco.Modules.System.MainUI.MainUIModuleUtils")
local UMG_HUDSimpleList_C = _G.NRCPanelBase:Extend("UMG_HUDSimpleList_C")

function UMG_HUDSimpleList_C:OnActive(type)
  self:SetListInfo(type)
  self:PlayAnimation(self.open)
  self.IsCollapse = false
end

function UMG_HUDSimpleList_C:OnDeactive()
end

function UMG_HUDSimpleList_C:OnAddEventListener()
end

function UMG_HUDSimpleList_C:OnEnable()
  self:StopAllAnimations()
  if self.IsCollapse then
    self:Disable()
    return
  end
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:PlayAnimation(self.open)
end

function UMG_HUDSimpleList_C:OnDisable()
end

function UMG_HUDSimpleList_C:OnConstruct()
  self.CanPress = true
end

function UMG_HUDSimpleList_C:OnDestruct()
end

function UMG_HUDSimpleList_C:ClosePanel()
  if self.IsCollapse then
    return
  end
  self.IsCollapse = true
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(40008025, "UMG_HUDSimpleList_C:ClosePanel")
  self:PlayAnimation(self.close)
end

function UMG_HUDSimpleList_C:SetListInfo(type)
  self.IsCollapse = false
  local itemList = {}
  local itemListFull = {}
  if type == ProtoEnum.BagItemType.BI_MAGIC then
    itemList = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetBagItemArrayByType, ProtoEnum.BagItemType.BI_MAGIC)
    if itemList then
      itemList = MainUIModuleUtils.SortMagicListByPriority(itemList)
      for i = 1, #itemList do
        table.insert(itemListFull, itemList[i])
      end
    else
      Log.Error("UMG_HUDSimpleList_C:SetListInfo, itemList is nil!!!")
    end
  end
  self.List:InitGridView(itemListFull)
  self.Particle1:PlayAnimation(self.Particle1.loop, 0)
  self.Particle2:PlayAnimation(self.Particle2.loop, 0)
end

function UMG_HUDSimpleList_C:OnAnimationFinished(anim)
  if anim == self.close then
    _G.NRCModeManager:DoCmd(MainUIModuleCmd.SwitchPetAfterAnim)
  elseif anim == self.open then
    self:PlayAnimation(self.loop)
  end
end

function UMG_HUDSimpleList_C:OnPCSelectPet0(action_type, index)
  if 0 == action_type then
    _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.PCKeyPressCloseFriendPanelTeam)
    if self.CanPress then
      self.CanPress = false
      for i = 1, 6 do
        if index == i then
          self.Item = self.List:GetItemByIndex(i - 1)
          if self.Item then
            if not self.Item.MyAbilityErrorCode then
              self.List:SelectItemByIndex(i - 1)
            else
              self.Item:OnItemClicked()
            end
          end
        end
      end
    end
  else
    self.CanPress = true
  end
end

return UMG_HUDSimpleList_C
