local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Json = require("Common.JsonUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local ThrowSession = require("NewRoco.Modules.Core.NPC.ThrowSession")
local Base = DebugTabBase
local DebugTabHome = Base:Extend("DebugTabHome")

function DebugTabHome:SetupTabs()
  self:Add("\229\188\128\229\133\179\231\178\190\231\129\181\228\189\156\231\137\169\228\186\164\228\186\146\232\140\131\229\155\180\229\143\175\232\167\134\229\140\150", self.ActivateAIView, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("\229\174\182\229\155\173option z\232\189\180\233\171\152\229\186\166\229\143\175\232\167\134\229\140\150", self.OnDrawOptionHeight, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("\229\155\190\233\137\180\229\174\182\229\133\183\232\176\131\230\149\180\229\188\128\229\144\175/\229\133\179\233\151\173", self.OpenOrCloseAtlasSlider, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("\232\174\190\231\189\174\231\178\190\231\129\181\229\143\139\229\165\189\229\186\166\229\146\140\229\143\141\229\135\187\230\166\130\231\142\135", self.SetPetFriendlyAndCounterStatus, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("\228\184\128\233\148\174\229\136\134\232\167\163\229\174\182\229\133\183", self.DecomposeAllFurniture, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "DecomposeAllFurniture")
  self:Add("\229\143\175\232\167\134\229\140\150\229\176\143\231\170\157\231\148\159\232\155\139\232\140\131\229\155\180", self.ShowOrHidePetLayEggArea, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "DecomposeAllFurniture")
end

function DebugTabHome:OpenFoodProcessingPanel()
  _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.OpenFoodProcessingPanel)
end

function DebugTabHome:AddSpecialFurniture()
  local inputText = self:GetInputString()
  if not inputText then
    return
  end
  local inputNumbers = string.split(inputText, ",")
  if not inputNumbers or #inputNumbers < 2 then
    return
  end
  local furnitureId = tonumber(inputNumbers[1])
  local furnitureNum = tonumber(inputNumbers[2])
  local FURNITURE_ITEM_CONF = _G.DataConfigManager:GetFurnitureItemConf(furnitureId)
  if FURNITURE_ITEM_CONF then
    local req = ProtoMessage:newZoneGmClientAddItemReq()
    req.item_id = furnitureId
    req.num = furnitureNum
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CLIENT_ADD_ITEM_REQ, req, self, function()
      Log.Debug("ZONE_GM_CLIENT_ADD_ITEM_REQ send")
    end)
  end
end

function DebugTabHome:PetHarvestAll()
  local req = ProtoMessage:newZoneHomePetGmHarvestReq()
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_HOME_PET_GM_HARVEST_REQ, req, self, function(rsp)
    Log.Debug("ZONE_HOME_PET_GM_HARVEST_REQ send")
  end)
end

function DebugTabHome:AddAllFurniture()
  local FURNITURE_ITEM_CONF = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.FURNITURE_ITEM_CONF):GetAllDatas()
  
  local function dummy()
  end
  
  for k, v in pairs(FURNITURE_ITEM_CONF) do
    local req = ProtoMessage:newZoneGmClientAddItemReq()
    local IDNum = k
    local ItemNum = 1
    req.item_id = IDNum
    req.num = ItemNum
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CLIENT_ADD_ITEM_REQ, req, self, dummy)
  end
end

function DebugTabHome:AddInteriorFinish()
  local INTERIOR_FINISH_CONF = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.INTERIOR_FINISH_CONF):GetAllDatas()
  
  local function dummy()
  end
  
  for k, v in pairs(INTERIOR_FINISH_CONF) do
    local req = ProtoMessage:newZoneGmClientAddItemReq()
    local IDNum = k
    local ItemNum = 1
    req.item_id = IDNum
    req.num = ItemNum
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CLIENT_ADD_ITEM_REQ, req, self, dummy)
  end
end

function DebugTabHome:FinishExpandHome()
  if HomeIndoorSandbox and HomeIndoorSandbox:InLocalMasterIndoor() and not ENABLE_LOCAL_HOME_SERVER then
    HomeIndoorSandbox.World.Controller:ReqUpgradeHome()
  end
end

function DebugTabHome:StartExpandHome()
  if HomeIndoorSandbox and HomeIndoorSandbox:InLocalMasterIndoor() and not ENABLE_LOCAL_HOME_SERVER then
    HomeIndoorSandbox.Server:ReqStartUpgradeHome(function()
    end)
  end
end

function DebugTabHome:ReqEnterPlayerHomeIndoor(name, panel, playerUin)
  if panel then
    local inputText = panel.InputBox:GetText()
    local numbers = {}
    for number in inputText:gmatch("%d+") do
      table.insert(numbers, tonumber(number))
    end
    playerUin = numbers[1]
    NRCModuleManager:DoCmd(HomeModuleCmd.ReqEnterPlayerHomeIndoor, playerUin)
  else
    NRCModuleManager:DoCmd(HomeModuleCmd.ReqEnterPlayerHomeIndoor, playerUin)
  end
end

function DebugTabHome:ReqLeavePlayerHomeIndoor()
  NRCModuleManager:DoCmd(HomeModuleCmd.ReqLeavePlayerHomeIndoor)
end

function DebugTabHome:OpenHomeFurnitureExchangePanel()
  NRCModuleManager:DoCmd(HomeModuleCmd.OpenHomeFurnitureExchangePanel)
end

function DebugTabHome:OpenHomeLevelRewardPanel()
  NRCModuleManager:DoCmd(HomeModuleCmd.OpenHomeLevelRewardPanel)
end

function DebugTabHome:OpenFurnitureAtlasPanel()
  NRCModuleManager:DoCmd(HomeModuleCmd.OpenFurnitureAtlasPanel)
end

function DebugTabHome:OpenHomeExpandPanel()
  NRCModuleManager:DoCmd(HomeModuleCmd.OpenHomeExpandPanel)
end

function DebugTabHome:OpenHomeVisitHistoryPanel()
  NRCModuleManager:DoCmd(HomeModuleCmd.OpenHomeVisitHistoryPanel)
end

function DebugTabHome:ToggleHomeFunction()
  _G.GlobalConfig.ENABLE_HOME = not _G.GlobalConfig.ENABLE_HOME
  if _G.GlobalConfig.ENABLE_HOME then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\229\136\135\230\141\162\229\136\176\239\188\154\229\189\147\229\137\141\229\183\178\229\188\128\229\144\175\229\174\182\229\155\173\229\138\159\232\131\189")
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, "\229\136\135\230\141\162\229\136\176\239\188\154\229\189\147\229\137\141\230\156\170\229\188\128\229\144\175\229\174\182\229\155\173\229\138\159\232\131\189")
  end
end

function DebugTabHome:UpgradeHome()
  local HomeModule = NRCModuleManager:GetModule("HomeModule")
  local Controller = HomeIndoorSandbox and HomeIndoorSandbox.World and HomeIndoorSandbox.World.Controller
  if Controller then
    Controller:ReqUpgradeHome()
  end
end

function DebugTabHome:AddHomeExp(Name, Panel, Exp)
  local Input = Exp or Panel.InputBox:GetText()
  local req = ProtoMessage:newZoneSceneHomeGmAddExpReq()
  req.exp = tonumber(Input)
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_HOME_GM_ADD_EXP_REQ, req, self, self.OnAddHomeExpRsp)
end

function DebugTabHome:OnAddHomeExpRsp(rsp)
end

function DebugTabHome:ModifyRoomLevel(Name, Panel)
  local Input = Panel.InputBox:GetText()
  local req = ProtoMessage:newZoneSceneHomeGmModifyRoomLevelReq()
  req.level = tonumber(Input)
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_HOME_GM_MODIFY_ROOM_LEVEL_REQ, req, self, self.OnModifyRoomLevelRsp)
end

function DebugTabHome:OnModifyRoomLevelRsp(rsp)
  local Context = DialogContext()
  Context:SetTitle(_G.LuaText.TIPS):SetContent("[GM]\233\135\141\229\144\175\229\144\142\231\148\159\230\149\136"):SetMode(DialogContext.Mode.OK):SetButtonText(LuaText.OK):SetCountdown(DialogContext.Mode.OK, 5):SetCallback(self, function()
    Context:Close()
    UE4.UNRCStatics.QuitGame()
  end)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
end

function DebugTabHome:OpenEditHome()
  local HomeModule = NRCModuleManager:GetModule("HomeModule")
  HomeModule:OpenHomeMainPanel()
end

function DebugTabHome:EnableDrawPlane()
  local HomeModule = NRCModuleManager:GetModule("HomeModule")
  HomeModule.EditControl.HomeWorld.ENABLE_DEBUG_DRAW_PLANE = not HomeModule.EditControl.HomeWorld.ENABLE_DEBUG_DRAW_PLANE
end

function DebugTabHome:HomePlantReset(Name, Panel)
  local req = ProtoMessage:newZoneSceneHomePlantGmResetReq()
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_HOME_PLANT_GM_RESET_REQ, req, self, self.OnHomePlantResetRsp)
end

function DebugTabHome:OnHomePlantResetRsp(rsp)
end

local bActiveAIView = false
local CheckPickRadius = _G.DataConfigManager:GetHomeGlobalConfig("plant_pet_pick_distance").num or 500
local PickDrawColor = UE.FLinearColor(1.0, 0.84, 0.0, 1.0)
local HomeAIDrawColor = {
  [Enum.SkillDamType.SDT_WATER] = UE.FLinearColor(0.5, 0.8, 1.0, 1.0),
  [Enum.SkillDamType.SDT_GRASS] = UE.FLinearColor(0.1, 0.8, 0.2, 1.0)
}
local HomeAICheckRadius = {
  [Enum.SkillDamType.SDT_WATER] = _G.DataConfigManager:GetHomeGlobalConfig("plant_pet_water_distance").num or 500,
  [Enum.SkillDamType.SDT_GRASS] = _G.DataConfigManager:GetHomeGlobalConfig("plant_pet_manure_distance").num or 500
}

function DebugTabHome:ActivateAIView(Name, Panel)
  bActiveAIView = not bActiveAIView
  Log.Warning("\229\188\128\229\133\179\229\174\182\229\155\173\231\178\190\231\129\181AI\229\143\175\232\167\134\229\140\150, \230\152\175\229\144\166\228\184\186\229\188\128\229\144\175\239\188\154", bActiveAIView)
  local ActivePetSessions = ThrowSession.ActivePetSessions
  if bActiveAIView then
    if not ActivePetSessions then
      return
    end
    if #ActivePetSessions > 0 then
      _G.UpdateManager:Register(self)
    end
  else
    _G.UpdateManager:UnRegister(self)
  end
end

function DebugTabHome:CheckShouldTick()
  local ActivePetSessions = ThrowSession.ActivePetSessions
  for _, PetThrowSession in ipairs(ActivePetSessions) do
    if PetThrowSession.petData and PetThrowSession.petData.skill_dam_type and #PetThrowSession.petData.skill_dam_type > 0 and HomeAICheckType[PetThrowSession.petData.skill_dam_type[1]] then
      return true
    end
  end
  Log.Warning("\230\178\161\230\156\137\233\128\130\229\144\136\231\187\152\229\136\182\231\154\132\229\174\160\231\137\169")
  return false
end

function DebugTabHome:OnTick(DeltaTime)
  local ActivePetSessions = ThrowSession.ActivePetSessions
  if not ActivePetSessions or not next(ActivePetSessions) then
    return
  end
  for _, PetThrowSession in ipairs(ActivePetSessions) do
    local Pet = PetThrowSession.NPC
    if Pet and Pet.viewObj then
      local Center = Pet.viewObj:K2_GetActorLocation()
      local CapsuleComp = Pet.viewObj:K2_GetRootComponent()
      if CapsuleComp then
        Center.Z = Center.Z - CapsuleComp:GetScaledCapsuleHalfHeight() + 10
      end
      local SpecialColor = HomeAIDrawColor[Pet:GetConfPetData().unit_type[1]]
      local SpecialRadius = HomeAICheckRadius[Pet:GetConfPetData().unit_type[1]]
      if SpecialColor and SpecialRadius then
        UE.UKismetSystemLibrary.DrawDebugSphere(_G.UE4Helper.GetCurrentWorld(), Center, SpecialRadius, 16, SpecialColor)
      end
      UE.UKismetSystemLibrary.DrawDebugSphere(_G.UE4Helper.GetCurrentWorld(), Center, CheckPickRadius, 24, PickDrawColor)
    end
  end
end

function DebugTabHome:OnDrawOptionHeight()
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerViewObj = player and player.viewObj
  if playerViewObj then
    local inputText = self:GetInputString()
    if not inputText then
      return
    end
    local inputNumbers = string.split(inputText, ",")
    local playerMesh = playerViewObj.Mesh
    local transform = UE4.FTransform()
    UE4.UNRCStatics.GetSocketTransformInplace(playerMesh, "locator_foot", transform, 0)
    Log.Debug("transform is " .. transform.Translation.X, transform.Translation.Y, transform.Translation.Z)
    local startPos = UE4.FVector(transform.Translation.X, transform.Translation.Y + 30, transform.Translation.Z)
    local endPos = startPos + UE4.FVector(0, 0, inputNumbers)
    UE4.UKismetSystemLibrary.Abs_DrawDebugLine(UE4Helper.GetCurrentWorld(), startPos, endPos, UE4.FLinearColor(0.0, 1.0, 0.0, 1.0), 20)
  end
end

function DebugTabHome:OpenOrCloseAtlasSlider()
  _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.ChangeFurnitureAtlas)
end

function DebugTabHome:SetPetFriendlyAndCounterStatus(name, panel)
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.OpenDebugHomePetPopUp)
  if panel then
    panel:DoClose()
  end
end

function DebugTabHome:ResetHomeLevel()
  local req = ProtoMessage:newZoneSceneHomePlantGmResetReq()
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_HOME_GM_RESET_HOME_LEVEL_REQ, req, self, self.OnHomeLevelReset)
end

function DebugTabHome:OnHomeLevelReset(Rsp)
  if 0 == Rsp.ret_info.ret_code then
    _G.AppMain.BackToLogin()
  end
end

local function vec3_min(a, b)
  return UE4.FVector(math.min(a.X, b.X), math.min(a.Y, b.Y), math.min(a.Z, b.Z))
end

local function vec3_max(a, b)
  return UE4.FVector(math.max(a.X, b.X), math.max(a.Y, b.Y), math.max(a.Z, b.Z))
end

function DebugTabHome:DrawDebugSitDown()
  local NPC = self:GetNearestNpc()
  if not NPC then
    return
  end
  local FurnitureID = NPC.FurnitureID
  if not FurnitureID then
    return
  end
  local FurnitureView = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetFurnitureView, FurnitureID)
  if not FurnitureView then
    return
  end
  local InteractData = FurnitureView.InteractData
  if not InteractData then
    return
  end
  local WorldTransform = FurnitureView:Abs_GetTransform()
  local SenseExtent = NPC.SenseExtent
  if next(SenseExtent) then
    for Pos, Extent in pairs(SenseExtent) do
      UE4.UKismetSystemLibrary.Abs_DrawDebugBox(UE4Helper.GetCurrentWorld(), Pos, Extent, UE4.FLinearColor(1, 1, 0, 1), nil, 99)
    end
  end
  local AvailableData = InteractData.AvailableData
  if AvailableData then
    for i, Data in tpairs(AvailableData) do
      local Pos = WorldTransform:TransformPositionNoScale(Data.Location)
      local Rot = WorldTransform:TransformRotation(Data.Rotation:ToQuat()):ToRotator():ToVector()
      Rot:Normalize()
      UE.UKismetSystemLibrary.Abs_DrawDebugArrow(_G.UE4Helper.GetCurrentWorld(), Pos, Pos + Rot * 100, 50, UE.FLinearColor(0, 1, 1, 1), 99, 2)
      UE.UKismetSystemLibrary.Abs_DrawDebugSphere(_G.UE4Helper.GetCurrentWorld(), Pos, 10, 24, UE.FLinearColor(0, 1, 0, 1), 99, 2)
    end
  end
  local ExitData = InteractData.ExitData
  if ExitData then
    for i, Data in tpairs(ExitData) do
      local Pos = WorldTransform:TransformPositionNoScale(Data.Location)
      UE4.UKismetSystemLibrary.Abs_DrawDebugBox(UE4Helper.GetCurrentWorld(), Pos, Data.Scale, UE4.FLinearColor(0, 0, 1, 1), nil, 100)
    end
  end
end

function DebugTabHome:QuickExpandRoom()
  local req = ProtoMessage:newZoneSceneHomeGmSkipExpandWaitReq()
  req.remain_wait_secs = 10
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_SCENE_HOME_GM_SKIP_EXPAND_WAIT_REQ, req, self, self.OnQuickExpandRoom)
end

function DebugTabHome:OnQuickExpandRoom(Rsp)
end

function DebugTabHome:DecomposeAllFurniture()
  local req = ProtoMessage:newZoneHomeGmDecomposeAllFurnitureReq()
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_HOME_GM_DECOMPOSE_ALL_FURNITURE_REQ, req, self, self.OnDecomposeAllFurniture)
end

function DebugTabHome:ShowOrHidePetLayEggArea()
  _G.GlobalConfig.bShouldShowGMPetLayEggArea = not _G.GlobalConfig.bShouldShowGMPetLayEggArea
  if _G.GlobalConfig.bShouldShowGMPetLayEggArea then
    Log.Error("\230\137\147\229\188\128\231\187\152\229\136\182\229\174\160\231\137\169\228\186\167\232\155\139\229\140\186\229\159\159\229\138\159\232\131\189")
  else
    Log.Error("\229\133\179\233\151\173\231\187\152\229\136\182\229\174\160\231\137\169\228\186\167\232\155\139\229\140\186\229\159\159\229\138\159\232\131\189")
  end
end

function DebugTabHome:OnDecomposeAllFurniture(Rsp)
end

return DebugTabHome
