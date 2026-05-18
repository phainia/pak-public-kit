local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local BattlePassModuleEvent = reload("NewRoco.Modules.System.BattlePass.BattlePassModuleEvent")
local UMG_Pass_HendItme_C = Base:Extend("UMG_Pass_HendItme_C")

function UMG_Pass_HendItme_C:OnConstruct()
end

function UMG_Pass_HendItme_C:OnDestruct()
  DelayManager:CancelDelayById(self.select_loopDelay)
end

function UMG_Pass_HendItme_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.data = _data
  local id = self.data.base_conf_id
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(id)
  local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
  if modelConf then
    self.petHeadIcon:SetIconPathAndMaterial(id, self.data.mutation_type, self.data.glass_info)
  end
  if 1 == index then
    self.Chain_Default:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if index == #datalist then
    self.Chain_Default_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Pass_HendItme_C:OnItemSelected(_bSelected)
  self:StopAllAnimations()
  self.IsSelect = _bSelected
  if _bSelected then
    self:PlayAnimation(self.change1)
    _G.NRCAudioManager:PlaySound2DAuto(1004, "UMG_Pass_HendItme_C:OnItemSelected")
    _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.SetPetSelectIndex, self.index)
    _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.SetCurrentPetData, self.data)
    _G.NRCEventCenter:DispatchEvent(BattlePassModuleEvent.UpdateSelectPetData, self.data, self.index)
  else
    self:PlayAnimation(self.change2)
  end
end

function UMG_Pass_HendItme_C:OnAnimationFinished(anim)
  if anim == self.change1 then
    self:PlayAnimation(self.select_loop)
  elseif anim == self.change2 then
    self:StopAnimation(self.select_loop)
    DelayManager:CancelDelayById(self.select_loopDelay)
  elseif anim == self.select_loop and self.IsSelect then
    self.select_loopDelay = DelayManager:DelaySeconds(3, function()
      if UE.UObject.IsValid(self) then
        self:PlayAnimation(self.select_loop)
      end
    end)
  end
end

return UMG_Pass_HendItme_C
