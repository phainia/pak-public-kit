local MapRegionAreaUtil = require("NewRoco.Modules.Core.Scene.Map.MapRegionAreaUtil")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabMiniGame = Base:Extend("DebugTabMiniGame")

function DebugTabMiniGame:Ctor()
  Base.Ctor(self)
  self.fake_trigger_npc_obj_id = "DebugTabMiniGame"
end

function DebugTabMiniGame:SetupTabs()
  self:Add("\230\181\139\232\175\149\229\176\143\230\184\184\230\136\143\229\164\141\230\180\187\231\130\185", self.TestMiniGameRestartPoint, self)
  self:Add("\230\181\139\232\175\149\230\137\147\229\188\128\229\137\170\229\189\177\230\140\145\230\136\152\229\133\179\229\141\161", self.OpenBattleSilhouette, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\181\139\232\175\149\230\137\147\229\188\128\233\166\150\233\162\134\232\167\146\230\150\151\230\140\145\230\136\152\229\133\179\229\141\161", self.OpenLeveSelect, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
end

function DebugTabMiniGame:TestMiniGameRestartPoint()
  local MiniGameID = self:GetInputNumber()
  local MiniGameModule = self:GetModule("MiniGameModule")
  MiniGameModule:TeleportPlayerToStart(_G.DataConfigManager:GetMinigameConf(MiniGameID), true)
end

function DebugTabMiniGame:Camera()
  local Mini = NRCModuleManager:GetModule("MiniGameModule")
  local conf = {}
  local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
  conf.RefreshId = npc.serverData.npc_base.npc_content_cfg_id
  Mini:SimpleCamera(conf)
end

function DebugTabMiniGame:Start()
  local FakeStart = ProtoMessage:newSpaceAct_MinigameNotify()
  FakeStart.status = ProtoEnum.MinigameStatus.MS_OPEN
  FakeStart.remain_time = 130
  FakeStart.minigame_cfg_id = 10004
  FakeStart.trigger_npc_obj_id = self.fake_trigger_npc_obj_id
  local FakeProgress = ProtoMessage:newMinigameProgress()
  FakeProgress.value = 4
  FakeProgress.npc_cfg_id = 1234
  FakeStart.progress = {FakeProgress, FakeProgress}
  NRCModuleManager:DoCmd(MiniGameModuleCmd.OnMinigameNotify, FakeStart)
end

function DebugTabMiniGame:End()
  local FakeStart = ProtoMessage:newSpaceAct_MinigameNotify()
  FakeStart.status = ProtoEnum.MinigameStatus.MS_EXIT
  FakeStart.remain_time = 20
  FakeStart.trigger_npc_obj_id = self.fake_trigger_npc_obj_id
  local FakeProgress = ProtoMessage:newMinigameProgress()
  FakeProgress.value = 5
  FakeProgress.npc_cfg_id = 1234
  FakeStart.progress = {FakeProgress, FakeProgress}
  NRCModuleManager:DoCmd(MiniGameModuleCmd.OnMinigameNotify, FakeStart)
end

function DebugTabMiniGame:Recover()
  local FakeStart = ProtoMessage:newSpaceAct_MinigameNotify()
  FakeStart.status = ProtoEnum.MinigameStatus.MS_RECOVERY
  FakeStart.remain_time = 20
  FakeStart.trigger_npc_obj_id = self.fake_trigger_npc_obj_id
  local FakeProgress = ProtoMessage:newMinigameProgress()
  FakeProgress.value = 5
  FakeProgress.npc_cfg_id = 1234
  FakeStart.progress = {FakeProgress, FakeProgress}
  NRCModuleManager:DoCmd(MiniGameModuleCmd.OnMinigameNotify, FakeStart)
end

function DebugTabMiniGame:Prog()
  local FakeStart = ProtoMessage:newSpaceAct_MinigameNotify()
  FakeStart.status = ProtoEnum.MinigameStatus.MS_PROGRESS
  FakeStart.remain_time = 20
  FakeStart.trigger_npc_obj_id = self.fake_trigger_npc_obj_id
  local FakeProgress = ProtoMessage:newMinigameProgress()
  FakeProgress.value = 5
  FakeProgress.npc_cfg_id = 1234
  FakeStart.progress = {FakeProgress, FakeProgress}
  NRCModuleManager:DoCmd(MiniGameModuleCmd.OnMinigameNotify, FakeStart)
end

function DebugTabMiniGame:fail()
  local FakeStart = ProtoMessage:newSpaceAct_MinigameNotify()
  FakeStart.status = ProtoEnum.MinigameStatus.MS_TIMEOUT
  FakeStart.remain_time = 0
  FakeStart.trigger_npc_obj_id = self.fake_trigger_npc_obj_id
  local FakeProgress = ProtoMessage:newMinigameProgress()
  FakeProgress.value = 4
  FakeProgress.npc_cfg_id = 1234
  FakeStart.progress = {FakeProgress, FakeProgress}
  NRCModuleManager:DoCmd(MiniGameModuleCmd.OnMinigameNotify, FakeStart)
end

function DebugTabMiniGame:fin()
  local FakeStart = ProtoMessage:newSpaceAct_MinigameNotify()
  FakeStart.status = ProtoEnum.MinigameStatus.MS_FINISH
  FakeStart.remain_time = 0
  FakeStart.trigger_npc_obj_id = self.fake_trigger_npc_obj_id
  local FakeProgress = ProtoMessage:newMinigameProgress()
  FakeProgress.value = 4
  FakeProgress.npc_cfg_id = 1234
  FakeStart.progress = {FakeProgress, FakeProgress}
  NRCModuleManager:DoCmd(MiniGameModuleCmd.OnMinigameNotify, FakeStart)
end

function DebugTabMiniGame:ShowGameArea(Name, Panel)
  local CurrentID = 0
  local Module = _G.NRCModuleManager:GetModule("MiniGameModule")
  if Module then
    CurrentID = Module.ConfigId or 0
  end
  local ID = self:GetInputNumber(CurrentID)
  if 0 == ID then
    self:ShowTips("\229\189\147\229\137\141\230\178\161\230\156\137\229\188\128\229\144\175\231\154\132\229\176\143\230\184\184\230\136\143\230\136\150\232\128\133\230\178\161\230\156\137\232\190\147\229\133\165\229\176\143\230\184\184\230\136\143ID")
    self:ClosePanel()
    return
  end
  local Conf = _G.DataConfigManager:GetMinigameConf(ID)
  if not Conf then
    self:ShowTips("\232\190\147\229\133\165\231\154\132\229\176\143\230\184\184\230\136\143ID\230\156\137\232\175\175")
    self:ClosePanel()
    return
  end
  local AreaID = Conf.gameplay_area
  local Utils = MapRegionAreaUtil()
  local AreaObject = Utils:GetMapArea(AreaID)
  if not AreaObject then
    self:ShowTips("\230\178\161\230\156\137\233\133\141\231\189\174\230\156\137\231\142\169\229\140\186\229\159\159\230\136\150\232\128\133\229\140\186\229\159\159\229\138\160\232\189\189\229\164\177\232\180\165")
    self:ClosePanel()
    return
  end
  local Region = AreaObject._inRegion
  Region:BuildGrids(UE4.FVector2D(100, 100))
  Region:Visualize(string.format("MiniGameGameplayArea-%d-%d", ID, Conf.gameplay_area))
  local Viz = Region.Visualization
  if Viz then
    Viz.LineWidth = 300
    Viz:UpdateMesh(Region)
  end
  local BlockConf = _G.DataConfigManager:GetBlockConf(Conf.block_id)
  if BlockConf then
    local centerX = BlockConf.position[1]
    local centerY = BlockConf.position[2]
    local centerZ = BlockConf.position[3] or 0
    
    local function getPoints(positions)
      local points = UE4.TArray(UE4.FVector)
      for _, pos in pairs(positions) do
        local pos_xyz = pos.Position
        local point = UE4.FVector(pos_xyz[1] + centerX, pos_xyz[2] + centerY, pos_xyz[3] + centerZ)
        points:Add(point)
      end
      return points
    end
    
    local world = _G.UE4Helper.GetCurrentWorld()
    local blockMatTemplate = LoadObject("/Game/ArtRes/Temp/RegionEditorTest/M_RegionLineColor.M_RegionLineColor")
    local blockMat = UE4.UKismetMaterialLibrary.CreateDynamicMaterialInstance(Viz, blockMatTemplate)
    if blockMat then
      blockMat:SetVectorParameterValue("Color", UE4.FLinearColor(0, 0, 1, 0.5))
    end
    local wall = UE4.UAirWallStatics.BuildVisualWall(world, getPoints(BlockConf.spline_point), blockMat, 500)
    if nil ~= wall and UE4.UObject.IsValid(wall) == true and RocoEnv.IS_EDITOR then
      wall:SetActorLabelNoFlush(string.format("MiniGameBlock-%d-%d", ID, Conf.block_id), false)
    end
  end
end

function DebugTabMiniGame:CheckShouldHide(name, panel)
  _G.DebugMiniGameShowHide = not _G.DebugMiniGameShowHide
end

function DebugTabMiniGame:OpenBattleSilhouette()
  _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.OpenLeveBattleSilhouette)
end

function DebugTabMiniGame:OpenLeveSelect()
  _G.NRCModuleManager:DoCmd(LevelSelectionModuleCmd.OpenLeveSelect)
end

return DebugTabMiniGame
