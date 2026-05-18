local AppearanceLocalUtils = Class()
local SuitData, SalonData
AppearanceLocalUtils.ShopNpc = nil
AppearanceLocalUtils.ShopNpcRef = nil
AppearanceLocalUtils.UMG_AvatarAnimList = nil

function AppearanceLocalUtils.DumpAppearanceSuitInfo(itemListInfo, player)
  if RocoEnv.IS_EDITOR and not NRCEnv:IsLocalMode() then
    local dir = UE4.UBlueprintPathsLibrary.ProjectSavedDir()
    local saveDir = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(dir)
    local data = {}
    data.itemInfo = itemListInfo
    data.fashionInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerFashionInfo()
    local rapidjson = require("rapidjson")
    local dumpFileName = string.format("%s%s%d.json", saveDir, "/LocalAppearanceSuitInfo_", player.gender)
    rapidjson.dump(data, dumpFileName)
  end
end

function AppearanceLocalUtils.GetAppearanceSuitInfo(gender)
  local dir = UE4.UBlueprintPathsLibrary.ProjectSavedDir()
  local saveDir = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(dir)
  local rapidjson = require("rapidjson")
  local dumpFileName = string.format("%s%s%d.json", saveDir, "/LocalAppearanceSuitInfo_", gender)
  SuitData = rapidjson.load(dumpFileName)
  return SuitData
end

function AppearanceLocalUtils.DumpAppearanceSalonInfo(itemListInfo, player)
  if RocoEnv.IS_EDITOR and not NRCEnv:IsLocalMode() then
    local dir = UE4.UBlueprintPathsLibrary.ProjectSavedDir()
    local saveDir = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(dir)
    local data = {}
    data.itemInfo = itemListInfo
    data.fashionInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerFashionInfo()
    local rapidjson = require("rapidjson")
    local dumpFileName = string.format("%s%s%d.json", saveDir, "/LocalAppearanceSalonInfo_", player.gender)
    rapidjson.dump(data, dumpFileName)
  end
end

function AppearanceLocalUtils.GetAppearanceSalonInfo(gender)
  local dir = UE4.UBlueprintPathsLibrary.ProjectSavedDir()
  local saveDir = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(dir)
  local rapidjson = require("rapidjson")
  local dumpFileName = string.format("%s%s%d.json", saveDir, "/LocalAppearanceSalonInfo_", gender)
  SalonData = rapidjson.load(dumpFileName)
  return SalonData
end

function AppearanceLocalUtils.GetShopNPC(player)
  if AppearanceLocalUtils.ShopNpc then
    return AppearanceLocalUtils.ShopNpc
  end
  if not player or not player.viewObj then
    return nil
  end
  local playerRotation = player:GetActorTransform().Rotation
  local playerLocation = player.viewObj:Abs_K2_GetActorLocation()
  local world = _G.UE4Helper.GetCurrentWorld()
  local actorClass = UE4.UClass.Load("/Game/ArtRes/BP/Scene/NPC_01001/BP_Scene_NPC_01001.BP_Scene_NPC_01001_C")
  AppearanceLocalUtils.ShopNpc = world:Abs_SpawnActor(actorClass, UE4.FTransform(playerRotation, playerLocation), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, world)
  AppearanceLocalUtils.ShopNpcRef = UnLua.Ref(AppearanceLocalUtils.ShopNpc)
  return AppearanceLocalUtils.ShopNpc
end

function AppearanceLocalUtils.OpenShop()
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local fashionInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerFashionInfo()
  if not fashionInfo then
    AppearanceLocalUtils.UpdateFashionInfo(player, player.gender)
  end
  local module = NRCModuleManager:GetModule("AppearanceModule")
  local isOpening, _ = module:HasPanel("BeautyMain")
  if isOpening then
    UE4Helper.PrintScreenMsg("\232\175\183\229\133\136\229\133\179\233\151\173\231\190\142\229\174\185\229\186\151\239\188\140\229\134\141\230\137\147\229\188\128\230\156\141\232\163\133\229\186\151")
    return
  end
  isOpening, _ = module:HasPanel("AppearanceMain")
  if isOpening then
    return
  end
  local ok, suitData = pcall(AppearanceLocalUtils.GetAppearanceSuitInfo, player.gender)
  if not ok then
    UE4Helper.PrintScreenMsg("\230\151\160\230\179\149\232\142\183\229\143\150\231\188\147\229\173\152\230\149\176\230\141\174\239\188\140\232\175\183\229\133\136\231\153\187\229\189\149\228\184\128\230\172\161\230\156\141\232\163\133\229\186\151\239\188\140\229\134\141\230\137\147\229\188\128\230\156\172\229\156\176\230\156\141\232\163\133\229\186\151")
    return
  end
  _G.NRCModeManager:DoCmd(AppearanceModuleCmd.OpenAppearanceMainPanel, suitData.itemInfo, nil)
  NRCModeManager:GetCurMode():DisablePanelByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  if 1 == GlobalConfig.OpenMainPanelFromDebugBtn then
    return
  end
  self._delayId = _G.DelayManager:DelaySeconds(2, function()
    self._delayId = nil
    local module = NRCModuleManager:GetModule("AppearanceModule")
    if not AppearanceLocalUtils.UMG_AvatarAnimList then
      local UMG_C = UE4.UClass.Load("/Game/NewRoco/TUI/EditorTool/UMG_AvatarAnimList.UMG_AvatarAnimList_C")
      AppearanceLocalUtils.UMG_AvatarAnimList = UE4.UWidgetBlueprintLibrary.Create(UE4Helper.GetCurrentWorld(), UMG_C)
    end
    AppearanceLocalUtils.UMG_AvatarAnimList:AddToViewport(10000000)
    AppearanceLocalUtils.UMG_AvatarAnimList:Init(module.AvatarPlayer)
  end)
end

function AppearanceLocalUtils.CloseShop()
  if self._delayId then
    _G.DelayManager:CancelDelayById(self._delayId)
    self._delayId = nil
  end
  if AppearanceLocalUtils.ShopNpc then
    AppearanceLocalUtils.ShopNpc:K2_DestroyActor()
    AppearanceLocalUtils.ShopNpc = nil
  end
  AppearanceLocalUtils.ShopNpcRef = nil
  NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
  if AppearanceLocalUtils.UMG_AvatarAnimList then
    AppearanceLocalUtils.UMG_AvatarAnimList:RemoveFromViewport()
  end
end

function AppearanceLocalUtils.OpenSalon()
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local fashionInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerFashionInfo()
  if not fashionInfo then
    AppearanceLocalUtils.UpdateFashionInfo(player, player.gender)
  end
  local module = NRCModuleManager:GetModule("AppearanceModule")
  local isOpening, _ = module:HasPanel("AppearanceMain")
  if isOpening then
    UE4Helper.PrintScreenMsg("\232\175\183\229\133\136\229\133\179\233\151\173\230\156\141\232\163\133\229\186\151\239\188\140\229\134\141\230\137\147\229\188\128\231\190\142\229\174\185\229\186\151")
    return
  end
  isOpening, _ = module:HasPanel("BeautyMain")
  if isOpening then
    return
  end
  player.viewObj.Mesh:SetAnimClass(nil)
  local ok, salonData = pcall(AppearanceLocalUtils.GetAppearanceSalonInfo, player.gender)
  if not ok then
    UE4Helper.PrintScreenMsg("\230\151\160\230\179\149\232\142\183\229\143\150\231\188\147\229\173\152\230\149\176\230\141\174\239\188\140\232\175\183\229\133\136\231\153\187\229\189\149\228\184\128\230\172\161\231\190\142\229\174\185\229\186\151\239\188\140\229\134\141\230\137\147\229\188\128\230\156\172\229\156\176\231\190\142\229\174\185\229\186\151")
    return
  end
  _G.NRCModeManager:DoCmd(AppearanceModuleCmd.OpenBeautyMainPanel, salonData.itemInfo, nil)
  NRCModeManager:GetCurMode():DisablePanelByLayer(Enum.UILayerType.UI_LAYER_MAIN)
end

function AppearanceLocalUtils.UpdateFashionInfo(player, gender)
  local ok, data = pcall(AppearanceLocalUtils.GetAppearanceSuitInfo, gender and gender or 1)
  if ok and data.fashionInfo then
    _G.DataModelMgr.PlayerDataModel:SetPlayerFashionInfo(data.fashionInfo)
  else
    _G.DataModelMgr.PlayerDataModel:SetPlayerFashionInfo()
  end
  NRCModuleManager:DeactiveModule("AppearanceModule")
  local localMode = NRCModeManager:GetCurMode()
  localMode:RegisterModule("AppearanceModule", "Type_System", "NewRoco.Modules.System.Appearance.AppearanceModuleHead", "NewRoco.Modules.System.Appearance.AppearanceModule")
  NRCModuleManager:ActiveModule("AppearanceModule")
end

return AppearanceLocalUtils
