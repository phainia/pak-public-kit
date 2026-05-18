local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Cabin_PetItem_C = Base:Extend("UMG_Cabin_PetItem_C")
local FarmUtils = require("NewRoco.Modules.System.Farm.FarmUtils")
local HomeUtils = require("NewRoco/Modules/System/Home/IndoorSandbox/HomeUtils")

function UMG_Cabin_PetItem_C:OnConstruct()
end

function UMG_Cabin_PetItem_C:OnDestruct()
end

function UMG_Cabin_PetItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  if not _data.plantSeedId then
    self:UpdatePet(_data)
  else
    self:UpdatePlant(_data)
  end
end

function UMG_Cabin_PetItem_C:UpdatePet(_data)
  self.NRCpetIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.PlantIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.ClientRedPoint:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.furniture_guid = _data.furniture_guid
  self.petStatus = _data.status
  self.feed_info = _data.feed_info
  self.awards_info = _data.awards_info
  local bShowRedPoint = false
  if _data.bShowRedPoint ~= nil then
    bShowRedPoint = _data.bShowRedPoint
  end
  local homeBriefInfo = HomeIndoorSandbox.Server:GetDisplayHomeBriefInfo() or {}
  local WorldOwnerUin = homeBriefInfo.home_owner_id or 0
  local BriefInfo = HomeIndoorSandbox.Server:GetLocalHomeBriefInfo() or {}
  local LoacalPlayerUin = BriefInfo.home_owner_id or 0
  if WorldOwnerUin == LoacalPlayerUin then
    self.RedDot:SetupKey(439, _data.pet_gid)
  end
  if bShowRedPoint then
    self.ClientRedPoint:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.ClientRedPoint:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if _data.base_conf_id and _data.mutation_type and _data.glass_info then
    self.NRCpetIcon:SetIconPathAndMaterial(_data.base_conf_id, _data.mutation_type, _data.glass_info)
  else
    Log.Error("UMG_Cabin_PetItem_C _data with invalid value, base_conf_id", _data.base_conf_id, ", mutation_type:", _data.mutation_type, ", glass_info", _data.glass_info)
  end
  if self.feed_info and self.petStatus == ProtoEnum.SpaceActorLogicStatus.SALS_HOME_PET_IN_PRODUCT then
    local currentTime = _G.ZoneServer:GetServerTime()
    local beginTime = self.feed_info.begin_time / 1000
    local costTime = self.feed_info.time_cost / 1000
    local progress = (currentTime - beginTime) / costTime > 1 and 1 or (currentTime - beginTime) / costTime
    if progress >= 0 and progress <= 1 then
      self.ProgressBar_76:SetPercent(progress)
    end
    local remainTimeTable = HomeUtils.GetHomePetTimer(self.feed_info)
    local remainTimeTips = ""
    if remainTimeTable and 4 == #remainTimeTable then
      if remainTimeTable[1] > 0 then
        remainTimeTips = string.format(LuaText.clear_plant_confirm_text_d, remainTimeTable[1])
      elseif remainTimeTable[2] > 0 then
        remainTimeTips = string.format(LuaText.clear_plant_confirm_text_h, remainTimeTable[2])
      elseif remainTimeTable[3] > 0 then
        remainTimeTips = string.format(LuaText.clear_plant_confirm_text_m, remainTimeTable[3])
      elseif remainTimeTable[4] > 0 then
        remainTimeTips = string.format(LuaText.clear_plant_confirm_text_s, remainTimeTable[4])
      end
      if "" ~= remainTimeTips then
        self.Text_Time:SetText(remainTimeTips)
        self.Text_Time:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self.ProducePanel:SetVisibility(UE4.ESlateVisibility.Visible)
        return
      end
    end
  end
  self.ProducePanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Cabin_PetItem_C:UpdatePlant(_data)
  self.NRCpetIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.PlantIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  local plantGrowConf = _G.DataConfigManager:GetPlantGrowConf(_data.plantSeedId)
  if plantGrowConf and plantGrowConf.plant_harvest then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(plantGrowConf.plant_harvest)
    if bagItemConf then
      self.PlantIcon:SetPath(bagItemConf.big_icon)
    end
  end
  local currentServerTimeStamp = (_G.ZoneServer:GetServerTime() or 0) / 1000
  self.plantRipTime = _data.plantRipTime
  local remainTime = self.plantRipTime - currentServerTimeStamp
  if not _data.bGrowFinish and remainTime > 0 then
    self.ProducePanel:SetVisibility(UE4.ESlateVisibility.Visible)
    local growTimeStr, outputStr, totalGrowCostTime = _G.NRCModuleManager:DoCmd(HomeModuleCmd.GenerateSeedTipsInfo, _data.plantSeedId, 2, _data.plantSeedTabLevel)
    local timeStr = FarmUtils.GenerateTimeStr(remainTime, 1)
    local progress = 0
    if totalGrowCostTime and totalGrowCostTime > 0 then
      progress = (totalGrowCostTime - remainTime) / totalGrowCostTime
    end
    self.ProgressBar_76:SetPercent(progress)
    self.Text_Time:SetText(timeStr)
  else
    self.ProducePanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local bShowRedPoint = _data.bGrowFinish
  if _data.bStealAble ~= nil then
    bShowRedPoint = _data.bStealAble
  end
  if bShowRedPoint then
    self.ClientRedPoint:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.ClientRedPoint:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Cabin_PetItem_C:OnItemSelected(_bSelected)
  if _bSelected and self.data and self.data.plantSeedId then
    local plantGrowConf = _G.DataConfigManager:GetPlantGrowConf(self.data.plantSeedId)
    if plantGrowConf and plantGrowConf.plant_harvest then
      _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenItemTips, plantGrowConf.plant_harvest, Enum.GoodsType.GT_BAGITEM, false)
    end
  end
end

function UMG_Cabin_PetItem_C:OnDeactive()
end

return UMG_Cabin_PetItem_C
