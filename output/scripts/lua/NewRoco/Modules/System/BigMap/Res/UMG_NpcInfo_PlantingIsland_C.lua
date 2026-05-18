local UMG_NpcInfo_PlantingIsland_C = _G.NRCPanelBase:Extend("UMG_NpcInfo_PlantingIsland_C")
local FarmUtils = require("NewRoco.Modules.System.Farm.FarmUtils")

function UMG_NpcInfo_PlantingIsland_C:OnEnable(worldMap, npcInfo, rsp)
  local cellHomeBriefInfo
  if rsp then
    cellHomeBriefInfo = rsp.friend_cell_home_brief_info
  end
  self.npcDesc_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:Update(cellHomeBriefInfo, worldMap)
end

function UMG_NpcInfo_PlantingIsland_C:OnActive()
end

function UMG_NpcInfo_PlantingIsland_C:OnDeactive()
end

function UMG_NpcInfo_PlantingIsland_C:OnAddEventListener()
end

function UMG_NpcInfo_PlantingIsland_C:Update(homeInfo, worldMap)
  local plantDisplayInfos = {}
  local homeBriefInfo = HomeIndoorSandbox.Server:GetDisplayHomeBriefInfo() or {}
  local bIsDisplayHomeOwner = homeBriefInfo.home_owner_id == _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  if homeInfo then
    plantDisplayInfos = FarmUtils.ExtraPlantDisplayInfo(homeInfo, not bIsDisplayHomeOwner)
  else
    local bInHomeScene = _G.NRCModuleManager:DoCmd(HomeModuleCmd.IsInHomeScene)
    if bInHomeScene then
      local player = _G.NRCModeManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
      if player and player.serverData then
        plantDisplayInfos = FarmUtils.ExtraPlantDisplayInfo(player.serverData, not bIsDisplayHomeOwner)
      end
    else
      Log.Warning("UMG_NpcInfo_PlantingIsland_C:Update \229\143\136\228\184\141\229\156\168\229\174\182\229\155\173\233\135\140\233\157\162\239\188\140\229\143\136\230\178\161\231\148\179\232\175\183\230\149\176\230\141\174\239\188\140\230\178\161\230\149\176\230\141\174\229\177\149\231\164\186")
    end
  end
  local fmtStr = LuaText.plant_map_element_text_name
  local plantGroundName = ""
  if fmtStr then
    plantGroundName = string.format(LuaText.plant_map_element_text_name, homeBriefInfo.home_name)
  end
  self.npcName_3:SetText(plantGroundName)
  plantDisplayInfos = FarmUtils.MergePlantDisplayInfo(plantDisplayInfos, true)
  self.Icon_List:InitGridView(plantDisplayInfos)
  local desc, titleImage
  if worldMap then
    desc = worldMap.worldmap_npc_des
    local bigMapModule = _G.NRCModuleManager:GetModule("BigMapModule")
    if bigMapModule then
      titleImage = bigMapModule:GetBigMapIconRes(worldMap.world_map_NPCicon_des)
    end
  end
  self.npcDesc_2:SetText(desc or "")
  self.Title_Image:SetPath(titleImage or "")
end

return UMG_NpcInfo_PlantingIsland_C
