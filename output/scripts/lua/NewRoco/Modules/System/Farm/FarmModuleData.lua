local FarmModuleEvent = require("NewRoco.Modules.System.Farm.FarmModuleEvent")
local FarmModuleData = _G.NRCData:Extend("FarmModuleData")

function FarmModuleData:Ctor()
  NRCData.Ctor(self)
  self.isUnlock = false
  self:InitConf()
  self:GetOriginRotationVector()
  if _G.DataModelMgr.PlayerDataModel:HasStoryFlag(_G.Enum.PlayerStoryFlagEnum.PSF_FUNC_UNLOCK_PLANT_LAND) then
    self.isUnlock = true
  end
  self.currentLandId = nil
  self:InitFarmMagicBan()
end

function FarmModuleData:InitConf()
  local lengthSideConf = _G.DataConfigManager:GetHomeGlobalConfig("plant_length_side")
  if not lengthSideConf then
    Log.Error("FarmModuleData:InitConf plant_length_side not found")
    return
  end
  self.length_side = lengthSideConf.num
  local roleSelectLengthConf = _G.DataConfigManager:GetHomeGlobalConfig("plant_coord_role_select_length")
  if not roleSelectLengthConf then
    Log.Error("FarmModuleData:InitConf plant_coord_role_select_length not found")
    return
  end
  self.role_select_length = roleSelectLengthConf.num
  local harvestIconConf = _G.DataConfigManager:GetHomeGlobalConfig("plant_seed_harvestimg_path")
  if not harvestIconConf then
    Log.Error("FarmModuleData:InitConf plant_seed_harvestimg_path not found")
    return
  end
  self.harvestIconPath = harvestIconConf.str
  local roleSelectHeightConf = _G.DataConfigManager:GetHomeGlobalConfig("plant_coord_role_select_high")
  if not roleSelectHeightConf then
    Log.Error("FarmModuleData:InitConf plant_coord_role_select_high not found")
    return
  end
  self.role_select_height = roleSelectHeightConf.num
  local initialGlobalConf = _G.DataConfigManager:GetHomeGlobalConfig("plant_initial_coord")
  if not initialGlobalConf then
    Log.Error("FarmModuleData:InitConf plant_initial_coord not found")
    return
  end
  local areaConf = _G.DataConfigManager:GetAreaConf(initialGlobalConf.num)
  if not areaConf then
    Log.Error("FarmModuleData:InitConf areaConf not found", initialGlobalConf.num)
    return
  end
  if not areaConf.pos[1] then
    Log.Error("FarmModuleData:InitConf areaConf.pos[1] not found")
    return
  end
  if not areaConf.pos[1].position_xyz then
    Log.Error("FarmModuleData:InitConf areaConf.pos[1].position_xyz not found")
    return
  end
  if not areaConf.pos[1].rotation_xyz then
    Log.Error("FarmModuleData:InitConf areaConf.pos[1].rotation_xyz not found")
    return
  end
  if not self.originLocation then
    self.originLocation = UE.FVector(areaConf.pos[1].position_xyz[1], areaConf.pos[1].position_xyz[2], areaConf.pos[1].position_xyz[3])
  end
  if not self.originRotation then
    self.originRotation = UE4.FRotator(areaConf.pos[1].rotation_xyz[2], areaConf.pos[1].rotation_xyz[3], areaConf.pos[1].rotation_xyz[1])
  end
end

function FarmModuleData:GetOriginRotationVector()
  if not self.originRotation then
    return
  end
  if not self.vecForward then
    self.vecForward = UE4.UKismetMathLibrary.GetForwardVector(self.originRotation)
  end
  if not self.vecRight then
    self.vecRight = UE4.UKismetMathLibrary.GetRightVector(self.originRotation)
  end
  return self.vecForward, self.vecRight
end

function FarmModuleData:InitFarmMagicBan()
  local Conf = DataConfigManager:GetHomeGlobalConfig("scene_magic_ban_plant")
  if Conf then
    local banTypeNames = string.split(Conf.str, ";")
    local banTypes = {}
    for i, v in pairs(banTypeNames) do
      banTypes[Enum.SceneMagicType[v]] = true
    end
    self.MagicBanTypes = banTypes
  end
end

return FarmModuleData
