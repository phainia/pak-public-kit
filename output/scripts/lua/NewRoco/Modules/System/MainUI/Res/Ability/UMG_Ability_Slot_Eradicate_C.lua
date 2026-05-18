local FarmModuleEvent = require("NewRoco.Modules.System.Farm.FarmModuleEvent")
local FarmUtils = require("NewRoco.Modules.System.Farm.FarmUtils")
local FarmModuleEnum = require("NewRoco.Modules.System.Farm.FarmModuleEnum")
local Base = require("NewRoco.Modules.System.MainUI.Res.Ability.UMG_Ability_Slot_C")
local UMG_Ability_Slot_Eradicate_C = Base:Extend("UMG_Ability_Slot_Eradicate_C")

function UMG_Ability_Slot_Eradicate_C:OnConstruct()
  self.bFinishConstruct = false
  Base.OnConstruct(self)
  NRCEventCenter:RegisterEvent("UMG_Ability_Slot_Seed_C", self, FarmModuleEvent.OnPlayerStandFarmLandChanged, self.HandleOnPlayerStandFarmLandChanged)
  NRCEventCenter:RegisterEvent("UMG_Ability_Slot_Seed_C", self, FarmModuleEvent.OnFarmLandInfoChanged, self.HandleOnFarmLandInfoChanged)
  NRCEventCenter:RegisterEvent("UMG_Ability_Slot_Seed_C", self, FarmModuleEvent.OnFarmSingleLandInfoChanged, self.HandleOnFarmSingleLandInfoChanged)
  FunctionBanManager:AddFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_HOME_CLEAR_PLANT, self, self.OnFunctionBan)
  self.slotIndex = 1
  self.slotSubIndex = 4
  self.StandingFarmLandId = 0
  if _G.FarmModuleCmd and _G.NRCModuleManager:GetModule("FarmModule") then
    self.StandingFarmLandId = _G.NRCModuleManager:DoCmd(_G.FarmModuleCmd.GetCurrentStandingLandId) or 0
  end
  self:RefreshUI(true)
  _G.UpdateManager:UnRegister(self)
  self.bFinishConstruct = true
end

function UMG_Ability_Slot_Eradicate_C:OnDestruct()
  NRCEventCenter:UnRegisterEvent(self, FarmModuleEvent.OnPlayerStandFarmLandChanged, self.HandleOnPlayerStandFarmLandChanged)
  NRCEventCenter:UnRegisterEvent(self, FarmModuleEvent.OnFarmLandInfoChanged, self.HandleOnFarmLandInfoChanged)
  NRCEventCenter:UnRegisterEvent(self, FarmModuleEvent.OnFarmSingleLandInfoChanged, self.HandleOnFarmSingleLandInfoChanged)
  FunctionBanManager:RemoveFunctionStateListener(Enum.PlayerFunctionBanType.PFBT_HOME_CLEAR_PLANT, self, self.OnFunctionBan)
  Base.OnDestruct(self)
end

function UMG_Ability_Slot_Eradicate_C:RefreshUI()
  local newVisible = false
  local Ban = _G.FunctionBanManager:GetFunctionState(Enum.PlayerFunctionBanType.PFBT_HOME_CLEAR_PLANT)
  if Ban then
  elseif self.StandingFarmLandId > 0 then
    newVisible = FarmUtils.IsLandRemovingAvailable(self.StandingFarmLandId)
  end
  self._isVisible = newVisible
  self:SetVisible(self._isVisible, Ban)
end

function UMG_Ability_Slot_Eradicate_C:OnSlotClicked(bind)
  local Ban = _G.FunctionBanManager:GetFunctionState(Enum.PlayerFunctionBanType.PFBT_HOME_CLEAR_PLANT)
  if Ban then
    return
  end
  self:PlayAnimation(self.Press)
  self:DoRemovePlantAction()
end

function UMG_Ability_Slot_Eradicate_C:DoRemovePlantAction()
  if self.StandingFarmLandId > 0 then
    FarmUtils.ExecuteFarmNPCOption(FarmModuleEnum.OptionType.Removing, self.StandingFarmLandId, false)
  end
end

function UMG_Ability_Slot_Eradicate_C:HandleOnFarmSingleLandInfoChanged(landId)
  if self.StandingFarmLandId and self.StandingFarmLandId == landId then
    self:RefreshUI()
  end
end

function UMG_Ability_Slot_Eradicate_C:HandleOnFarmLandInfoChanged()
  self:RefreshUI()
end

function UMG_Ability_Slot_Eradicate_C:HandleOnPlayerStandFarmLandChanged(bEnter, farmLandId)
  if bEnter then
    self.StandingFarmLandId = farmLandId
  else
    self.StandingFarmLandId = 0
  end
  self:RefreshUI()
end

function UMG_Ability_Slot_Eradicate_C:OnFunctionBan()
  self:RefreshUI()
end

return UMG_Ability_Slot_Eradicate_C
