local FarmUtils = require("NewRoco.Modules.System.Farm.FarmUtils")
local FarmModuleEnum = require("NewRoco.Modules.System.Farm.FarmModuleEnum")
local Base = require("NewRoco.Modules.System.MainUI.Res.UMG_Hud_Base")
local UMG_Hud_HomePlantingStatus_C = Base:Extend("UMG_Hud_HomePlantingStatus_C")

function UMG_Hud_HomePlantingStatus_C:OnEnable(NpcType, ...)
  if NpcType == FarmModuleEnum.NPCType.Land then
    self:UpdateSingleLandStatus(...)
  elseif NpcType == FarmModuleEnum.NPCType.Entrance then
    self:UpdateFarmEntranceStatus()
  elseif NpcType == FarmModuleEnum.NPCType.Board then
    self:UpdateFarmBoardStatus(...)
  end
end

function UMG_Hud_HomePlantingStatus_C:OnActive()
end

function UMG_Hud_HomePlantingStatus_C:OnDeactive()
end

function UMG_Hud_HomePlantingStatus_C:OnAddEventListener()
end

function UMG_Hud_HomePlantingStatus_C:OnRefreshStatus(parentHud, type, ...)
  if type == FarmModuleEnum.NPCType.Land then
    self:UpdateSingleLandStatus(...)
  elseif type == FarmModuleEnum.NPCType.Board then
    self:UpdateFarmBoardStatus(...)
  elseif type == FarmModuleEnum.NPCType.Entrance then
    self:UpdateFarmEntranceStatus()
  end
  parentHud:SubmitChange()
end

function UMG_Hud_HomePlantingStatus_C:UpdateFarmBoardStatus(isLogicStatusPlantUnlockLand)
  if self:IsAnimationPlaying(self.Loop) then
    self:StopAllAnimations()
  end
  self.BgLight:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local isFarmBoardUnlockValid = FarmUtils.IsFarmBoardUnlockValid() and isLogicStatusPlantUnlockLand
  if isFarmBoardUnlockValid then
    local path = _G.DataConfigManager:GetHomeGlobalConfig("plant_coord_noticeboard_head_icon").str
    self.Icon:SetPath(path)
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Hud_HomePlantingStatus_C:UpdateFarmEntranceStatus()
  if not self:IsAnimationPlaying(self.Loop) then
    self:PlayAnimation(self.Loop, 0, 10000)
  end
  self.BgLight:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local isFarmCollectAvailable = FarmUtils.IsFarmCollectAvailable(nil, true)
  if isFarmCollectAvailable then
    local path = _G.DataConfigManager:GetHomeGlobalConfig("plant_get_path").str
    self.Icon:SetPath(path)
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Hud_HomePlantingStatus_C:UpdateSingleLandStatus(landId)
  if not self:IsAnimationPlaying(self.Loop) then
    self:PlayAnimation(self.Loop, 0, 10000)
  end
  if landId then
    self.landId = landId
  end
  local plantOptionStatus = FarmUtils.GetLandOptionStatus(self.landId, nil, true)
  if self.plantOptionStatus == plantOptionStatus then
    return
  end
  self.BgLight:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.plantOptionStatus = plantOptionStatus
  local path
  if plantOptionStatus == FarmModuleEnum.OptionType.Watering then
    path = _G.DataConfigManager:GetHomeGlobalConfig("plant_water_path").str
  elseif plantOptionStatus == FarmModuleEnum.OptionType.Fertilizing then
    path = _G.DataConfigManager:GetHomeGlobalConfig("plant_manure_path").str
  elseif plantOptionStatus == FarmModuleEnum.OptionType.Harvesting or plantOptionStatus == FarmModuleEnum.OptionType.Stealing then
    path = _G.DataConfigManager:GetHomeGlobalConfig("plant_get_path").str
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  self.Icon:SetPath(path)
  self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
end

return UMG_Hud_HomePlantingStatus_C
