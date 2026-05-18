local EventDispatcher = require("Common.EventDispatcher")
local AbilitySlot = Class("AbilitySlot")

function AbilitySlot:Ctor(AbilityComponent)
  self.AbilityComp = AbilityComponent
  self.SlotEnum = ASlotDefine.SlotEnum.None
  self.CurrentAbility = nil
  self.Dispatcher = EventDispatcher()
end

function AbilitySlot:GetCurrentAbility()
  return self.CurrentAbility
end

function AbilitySlot:SetCurSlotBlock(isBlock)
  self.isSlotBlock = isBlock
  self.Dispatcher:SendEvent(ASlotDefine.Event.OnSlotCurAbilityChanged, self)
end

function AbilitySlot:SetCurrentAbility(ability)
  if self.CurrentAbility == ability then
    return
  end
  if self.CurrentAbility then
    self.CurrentAbility:OnRemoveFromSlot(self)
  end
  self.CurrentAbility = ability
  self.CurrentAbility:OnAddToSlot(self)
  self.Dispatcher:SendEvent(ASlotDefine.Event.OnSlotCurAbilityChanged, self)
end

function AbilitySlot:CastAbility(OnFinished, ...)
  if self.CurrentAbility then
    self.AbilityComp:CastAbility(self.CurrentAbility.config.id, OnFinished, ...)
  elseif TipsModuleCmd then
    NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, "\230\138\128\232\131\189\232\191\152\230\178\161\230\156\137\232\167\163\233\148\129~")
  end
end

function AbilitySlot:StopAbility(Force)
  if self.CurrentAbility and self.CurrentAbility:IsCasting() then
    self.AbilityComp:StopAbility(Force)
  end
end

function AbilitySlot:GetSlotIcon()
  if not self.CurrentAbility then
    return
  end
  return self.CurrentAbility:GetIcon(self.isSlotBlock)
end

function AbilitySlot:RefreshSlot()
  self.Dispatcher:SendEvent(ASlotDefine.Event.OnSlotCurAbilityChanged, self)
end

function AbilitySlot:OnStatusChange(status, value)
  if self.CurrentAbility then
    local statusComponent = self.AbilityComp.owner.statusComponent
    local addStatus = self.CurrentAbility.add_status
    for _, v in addStatus, nil, nil, nil do
      local canApply, _ = statusComponent:PreApplyStatus(v)
      if not canApply then
        self.isSlotBlock = true
        break
      end
    end
    self.isSlotBlock = false
  end
  self.Dispatcher:SendEvent(ASlotDefine.Event.OnSlotCurAbilityChanged, self)
end

return AbilitySlot
