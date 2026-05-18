local CreatePlayerModule = NRCModuleBase:Extend("CreatePlayerModule")
local CreatePlayerFsm = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerFsm")
local CreatePlayerUtils = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerUtils")
local LoginModuleEvent = require("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local CreatePlayerEvent = require("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerEvent")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local LoadingUIModuleCmd = require("NewRoco.Modules.System.LoadingUIModule.LoadingUIModuleCmd")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")

function CreatePlayerModule:OnConstruct()
  _G.CreatePlayerModuleCmd = reload("NewRoco.Modules.System.CreatePlayerModule.CreatePlayerModuleCmd")
  self:RegisterCmd(CreatePlayerModuleCmd.GetCreatePlayerFsm, self.GetCreatePlayerFsm)
  self:RegisterCmd(CreatePlayerModuleCmd.InsertChildFsm, self.InsertChildFsm)
  self:RegisterCmd(CreatePlayerModuleCmd.BindCameraToController, self.BindCameraToController)
  self:RegisterCmd(CreatePlayerModuleCmd.OpenCharacterPickPanel, self.OpenCharacterPickPanel)
  self:RegisterCmd(CreatePlayerModuleCmd.OnFemaleBtnClick, self.OnFemaleBtnClick)
  self:RegisterCmd(CreatePlayerModuleCmd.OnMaleBtnClick, self.OnMaleBtnClick)
  self:RegisterCmd(CreatePlayerModuleCmd.RevertCameraToPlayer, self.RevertCameraToPlayer)
  self:RegisterCmd(CreatePlayerModuleCmd.RecordCameraRotation, self.RecordCameraRotation)
  self:RegisterCmd(CreatePlayerModuleCmd.TeleportToBirthplace, self.TeleportToBirthplace)
  self:RegisterCmd(CreatePlayerModuleCmd.UploadLevelInfo, self.UploadLevelInfo)
  self:RegisterCmd(CreatePlayerModuleCmd.CheckNameUsable, self.OnCmdCheckNameUsable)
  self:RegisterCmd(CreatePlayerModuleCmd.GetLevelData, self.GetLevelData)
  self:RegisterCmd(CreatePlayerModuleCmd.UploadDimoLocation, self.UploadDimoLocation)
  self:RegisterCmd(CreatePlayerModuleCmd.GetPlayerActor, self.GetPlayerActor)
  self:RegisterCmd(CreatePlayerModuleCmd.GetAsset, self.GetAsset)
  self:RegisterCmd(_G.CreatePlayerModuleCmd.PlayCreatePlayerMusic, self.PlayCreatePlayerMusic)
  self:RegisterCmd(_G.CreatePlayerModuleCmd.StopCreatePlayerMusic, self.StopCreatePlayerMusic)
  self:RegisterCmd(_G.CreatePlayerModuleCmd.GetTutorialData, self.GetTutorialData)
  self:RegPanel("CharacterPick", "/Game/NewRoco/Modules/System/LoginModule/UMG_CharacterPick", _G.Enum.UILayerType.UI_LAYER_FULLSCREEN, true, nil, true)
  self:RegPanel("PlayerMain", "/Game/NewRoco/Modules/System/MainUI/Res/Controller/UMG_DimoControl", _G.Enum.UILayerType.UI_LAYER_BG)
  self:AddEventListener()
  self.CreatePlayerSoundSession = nil
end

function CreatePlayerModule:OnDestruct()
  self:RemoveEventListener()
  if self.CreatePlayerFsm then
    self.CreatePlayerFsm:Stop()
  end
  if self.delayHandle then
    DelayManager:CancelDelayById(self.delayHandle)
    self.delayHandle = nil
  end
end

function CreatePlayerModule:OnActive()
end

function CreatePlayerModule:AddEventListener()
  NRCEventCenter:RegisterEvent("CreatePlayerModule", self, LoginModuleEvent.EnableSelection, self.EnableSelection)
end

function CreatePlayerModule:RemoveEventListener()
  NRCEventCenter:UnRegisterEvent(self, LoginModuleEvent.EnableSelection, self.EnableSelection)
end

function CreatePlayerModule:InitCreatePlayerFsm(levelData, posData)
  self.levelData = levelData
  self.CreatePlayerFsm = CreatePlayerFsm(levelData)
  self.CreatePlayerFsm:SetProperty("ParentModule", self)
  self.CreatePlayerFsm:Play()
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  self.playerActor = player.playerActor
  if posData then
    self:ResetPosition(posData)
  end
end

function CreatePlayerModule:GetCreatePlayerFsm()
  if self.CreatePlayerFsm then
    return self.CreatePlayerFsm
  end
end

function CreatePlayerModule:InsertChildFsm(fsm)
  if not self.ChildFsms then
    self.ChildFsms = {}
  end
  table.insert(self.ChildFsms, fsm)
end

function CreatePlayerModule:BindCameraToController()
  local TheCameras = UE4.UGameplayStatics.GetAllActorsOfClassWithTag(world, UE4.AActor, "TheCamera"):ToTable()
  local CameraActor = TheCameras[1]
  local Controller = CreatePlayerUtils.GetLoginController()
  Controller.centerCamera = CameraActor
end

function CreatePlayerModule:RegPanel(name, path, layer, customRendering, openAnimName, enablePcEsc)
  local registerData = _G.NRCPanelRegisterData()
  registerData.panelName = name
  registerData.panelPath = string.format(path)
  registerData.panelLayer = layer
  registerData.customDisableRendering = customRendering
  registerData.openAnimName = openAnimName
  registerData.enablePcEsc = enablePcEsc
  self:RegisterPanel(registerData)
end

function CreatePlayerModule:EnableSelection()
  Log.Debug("EnableSelection")
  if not self:HasPanel("CharacterPick") then
    self:OpenPanel("CharacterPick")
  else
    local panel = self:GetPanel("CharacterPick")
    panel:OnActive()
  end
end

function CreatePlayerModule:OpenCharacterPickPanel()
  self:OpenPanel("CharacterPick")
end

function CreatePlayerModule:UploadDimoLocation()
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local playerLocation = player.playerActor:K2_GetActorLocation()
  local playerRotation = player.playerActor:K2_GetActorRotation()
  local PlayerCameraManager = player:GetUEController().PlayerCameraManager
  local cameraPosition = PlayerCameraManager:GetCameraLocation()
  local cameraRotation = PlayerCameraManager:GetCameraRotation()
  local playerPos = ProtoMessage:newPosition()
  local playerDir = ProtoMessage:newPosition()
  playerPos.x = math.floor(playerLocation.X)
  playerPos.y = math.floor(playerLocation.Y)
  playerPos.z = math.floor(playerLocation.Z)
  playerDir.x = math.floor(playerRotation.Pitch)
  playerDir.y = math.floor(playerRotation.Yaw)
  playerDir.z = math.floor(playerRotation.Roll)
  local playerPoint = ProtoMessage:newPoint()
  playerPoint.pos = playerPos
  playerPoint.dir = playerDir
  local PointList = ProtoMessage:newPointList()
  table.insert(PointList.points, playerPoint)
  self:UploadInfo(PointList)
end

function CreatePlayerModule:UploadInfo(pointList)
  _G.DataModelMgr.RemoteStorage:Set("DimoPosInfo", ".Next.PointList", pointList, self, self.UploadInfoSucc)
end

function CreatePlayerModule:UploadInfoSucc(rsp)
  if 0 == rsp.ret_info.ret_code then
  end
end

function CreatePlayerModule:DownloadInfo()
  _G.DataModelMgr.RemoteStorage:Get("DimoPosInfo", ".Next.PointList", self, self.OnDownloadInfoRsp)
end

function CreatePlayerModule:OnDownloadInfoRsp(data)
  Log.Dump(data, 2, "OnDownloadInfoRsp")
  self.loginData = data
  self:ResetPosition(data)
end

function CreatePlayerModule:ResetPosition(data)
  if data and data.points then
    local xPos = data.points[1].pos.x
    local yPos = data.points[1].pos.y
    local zPos = data.points[1].pos.z
    local xDir = data.points[1].dir.x
    local yDir = data.points[1].dir.y
    local zDir = data.points[1].dir.z
    if UE4.UObject.IsValid(self.playerActor) then
      self.playerActor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(xPos, yPos, zPos))
      self.playerActor:K2_SetActorRotation(UE4.FRotator(xDir, yDir, zDir), false)
    end
  else
  end
end

function CreatePlayerModule:OnFemaleBtnClick()
  if self:HasPanel("CharacterPick") then
    local panel = self:GetPanel("CharacterPick")
    panel:OnFemaleBtnClick()
  end
end

function CreatePlayerModule:OnMaleBtnClick()
  if self:HasPanel("CharacterPick") then
    local panel = self:GetPanel("CharacterPick")
    panel:OnMaleBtnClick()
  end
end

function CreatePlayerModule:RevertCameraToPlayer()
  local Controller = CreatePlayerUtils.GetLoginController()
  local world = _G.UE4Helper.GetCurrentWorld()
  local SequencerActors = UE4.UGameplayStatics.GetAllActorsOfClassWithTag(world, UE4.AActor, "SequencerActor"):ToTable()
  local rotator = UE4.FRotator(13.875, 314.725, 0.00424)
  Controller:SetControlRotation(rotator)
  Controller:SetViewTargetWithBlend(self.playerActor, 1)
end

function CreatePlayerModule:OnLogin()
  Log.Debug("OnLogin")
  self:DownloadInfo()
end

function CreatePlayerModule:RecordCameraRotation()
  local Controller = CreatePlayerUtils.GetLoginController()
  local rotation = Controller:GetControlRotation()
end

function CreatePlayerModule:UploadLevelInfo(x1, y1, z1, x2, y2, z2)
  local PointList = ProtoMessage:newPointList()
  local levelPoint = ProtoMessage:newPoint()
  levelPoint.pos.x = x1
  levelPoint.pos.y = y1
  levelPoint.pos.z = z1
  levelPoint.dir.x = x2
  levelPoint.dir.y = y2
  levelPoint.dir.z = z2
  table.insert(PointList.points, levelPoint)
  _G.DataModelMgr.RemoteStorage:Set("CreatePlayerLevelInfo", ".Next.PointList", PointList, self, self.UploadInfoSucc)
end

function CreatePlayerModule:DownloadLevelInfo()
  _G.DataModelMgr.RemoteStorage:Get("CreatePlayerLevelInfo", ".Next.PointList", self, self.DownLevelInfoSucc)
end

function CreatePlayerModule:OnCmdCheckNameUsable()
  local hasPanel = self:HasPanel("CharacterPick")
  if hasPanel then
    local panel = self:GetPanel("CharacterPick")
    panel:CheckNameUsable()
  end
end

function CreatePlayerModule:GetLevelData()
  self:DownloadCreatePlayerLevelInfo()
end

function CreatePlayerModule:DownloadCreatePlayerLevelInfo()
  _G.DataModelMgr.RemoteStorage:Get("CreatePlayerLevelInfo", ".Next.PointList", self, self.DownloadCreatePlayerLevelInfoSucc)
end

function CreatePlayerModule:DownloadCreatePlayerLevelInfoSucc(data)
  self.levelData = data
  _G.DataModelMgr.RemoteStorage:Get("DimoPosInfo", ".Next.PointList", self, self.OnDownloadGMInfoRsp)
end

function CreatePlayerModule:OnDownloadGMInfoRsp(data)
  self.posData = data
  local textStr = ""
  if not self.self.levelData.points then
    Log.Error("\230\151\160\229\133\179\229\141\161\230\149\176\230\141\174\239\188\140\232\142\183\229\143\150\229\164\177\232\180\165")
    return
  end
  local DebugData = {
    "\229\189\147\229\137\141\229\183\178\231\156\139\229\174\140\231\172\172\228\184\128\230\174\181sequence\n",
    "\231\167\187\229\138\168\230\149\153\231\168\139\229\183\178\229\174\140\230\136\144\n",
    "\230\187\145\229\138\168\229\177\143\229\185\149\230\149\153\231\168\139\229\183\178\229\174\140\230\136\144\n",
    "\229\134\178\229\136\186\230\149\153\231\168\139\229\183\178\229\174\140\230\136\144\n",
    "\232\183\179\232\183\131\230\149\153\231\168\139\229\183\178\229\174\140\230\136\144\n",
    "\229\183\178\232\191\155\229\133\165\230\141\143\232\132\184\233\152\182\230\174\181\n",
    "\229\189\147\229\137\141\232\191\170\232\142\171\228\189\141\231\189\174\239\188\154"
  }
  if 1 == self.levelData.points[1].pos.x then
    textStr = textStr .. DebugData[1]
  end
  if 1 == self.levelData.points[1].pos.y then
    textStr = textStr .. DebugData[2]
  end
  if 1 == self.levelData.points[1].pos.z then
    textStr = textStr .. DebugData[3]
  end
  if 1 == self.levelData.points[1].dir.x then
    textStr = textStr .. DebugData[4]
  end
  if 1 == self.levelData.points[1].dir.y then
    textStr = textStr .. DebugData[5]
  end
  if 1 == self.levelData.points[1].dir.z then
    textStr = textStr .. DebugData[6]
  end
  local posX = data.points[1].pos.x
  local posY = data.points[1].pos.y
  local posZ = data.points[1].pos.z
  textStr = textStr .. DebugData[7] .. posX .. "," .. posY .. "," .. posZ
  local Context = DialogContext()
  Context:SetTitle("\229\136\155\232\167\146\229\133\179\229\141\161\228\191\161\230\129\175"):SetContent(textStr):SetMode(DialogContext.Mode.NotBtn):SetCloseOnOK(true):SetCloseOnCancel(true):SetButtonText(LuaText.YES, LuaText.NO)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenLongDialog, Context)
end

function CreatePlayerModule:GetPlayerActor()
  return self.playerActor
end

function CreatePlayerModule:SetAssetLoader(AssetLoader)
  self.AssetLoader = AssetLoader
end

function CreatePlayerModule:ResetAssetLoader()
  self.AssetLoader = nil
end

function CreatePlayerModule:GetAsset(AssetName)
  if self.AssetLoader then
    return self.AssetLoader:Get(AssetName)
  end
end

function CreatePlayerModule:OnOpenPanelCallback(panelName, panelIndex, isSucc)
  NRCModuleBase.OnOpenPanelCallback(self, panelName, panelIndex, isSucc)
  if "PlayerMain" == panelName then
    self:DispatchEvent(CreatePlayerEvent.DimoControlUIOpen)
  end
end

function CreatePlayerModule:PlayCreatePlayerMusic()
  if self.CreatePlayerSoundSession == nil then
    self.CreatePlayerSoundSession = _G.NRCAudioManager:PlaySound2DAuto(9035, "PlayCreatePlayerMusic")
    _G.NRCAudioManager:SetCreatingPlayer(true)
  end
end

function CreatePlayerModule:StopCreatePlayerMusic()
  if self.CreatePlayerSoundSession then
    _G.NRCAudioManager:SetCreatingPlayer(false)
    _G.NRCAudioManager:PlaySound2DAuto(9036, "StopCreatePlayerMusic")
    self.CreatePlayerSoundSession = nil
  end
end

function CreatePlayerModule:TeleportToBirthplace()
  local Controller = CreatePlayerUtils.GetLoginController()
  self.playerActor:Abs_K2_SetActorLocation_WithoutHit(UE4.FVector(-5796, 2939, 60))
  local rotator = UE4.FRotator(13.875, 314.725, 0.00424)
  self.playerActor:K2_SetActorRotation(UE4.FRotator(0, -46, 0), false)
  Controller:SetControlRotation(rotator)
  NRCModuleManager:DoCmd(LoadingUIModuleCmd.OpenCreatePlayerLoadingUI)
  self.delayHandle = DelayManager:DelaySeconds(1, function()
    NRCModuleManager:DoCmd(LoadingUIModuleCmd.CloseCreatePlayerLoadingUI)
  end)
end

function CreatePlayerModule:GetTutorialData()
  return self.levelData
end

return CreatePlayerModule
