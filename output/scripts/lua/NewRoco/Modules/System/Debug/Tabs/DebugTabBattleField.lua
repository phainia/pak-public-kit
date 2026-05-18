local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local BattleFieldConst = require("NewRoco.Modules.Core.Battle.Common.BattleFieldConst")
local PopupData = require("NewRoco.Modules.Core.Battle.Entity.Components.BuffEffectPopup.PopupData")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local DebugUtils = require("NewRoco.Modules.Core.Scene.Common.DebugUtils")
local BattleField = require("NewRoco.Modules.Core.Battle.Common.BattleField")
local Base = DebugTabBase
local DebugTabBattleField = Base:Extend("DebugTabBattleField")

function DebugTabBattleField:Ctor()
  Base.Ctor(self)
end

local function GetBattleCenterPos(str)
  if BattleConst.FindBattleCenterByClient then
    return str .. "(\229\174\162\230\136\183\231\171\175)"
  else
    return str .. "(\230\156\141\229\138\161\229\153\168)"
  end
end

function DebugTabBattleField:SetupTabs()
  self:Add("\229\133\179\233\151\173\229\174\162\230\136\183\231\171\175\229\175\185\230\139\141", self.CloseClientContrast, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\188\128\229\144\175\229\174\162\230\136\183\231\171\175\229\175\185\230\139\141", self.OpenClientContrast, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\188\128\229\144\175\230\136\152\229\156\186\233\154\144\232\151\143", self.OpenFieldHide, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add(GetBattleCenterPos("\230\136\152\229\156\186\233\128\137\233\128\137\231\130\185"), self.SetGetBattleCenterByClient, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("InitFromEditorUse", self.InitFromEditorUse, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("ChangeScene", self.ChangeScene, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\188\128HitWall\229\176\132\231\186\191\232\176\131\232\175\149", self.OpenHitWallDebugLine, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("\229\133\179HitWall\229\176\132\231\186\191\232\176\131\232\175\149", self.CloseHitWallDebugLine, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
  self:Add("StartTick", self.StartTick, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "")
end

function DebugTabBattleField:StartTick(name, panel)
  local dataManager = UE4.UNRCBattleFieldDataManager.LoadManagerObject()
  if dataManager then
    local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    if player.viewObj then
      local PlayerLocation = player.viewObj:Abs_K2_GetActorLocation()
      num = dataManager:Init(PlayerLocation, false)
      dataManager:StartTick()
      if num > 0 then
      else
        Log.Warning("\229\164\167\228\184\150\231\149\140\230\136\152\230\150\151\233\128\137\231\130\185\230\151\160\230\149\176\230\141\174\239\188\140\233\156\128\230\163\128\230\159\165\230\149\176\230\141\174\231\148\159\230\136\144\229\175\188\229\133\165\232\191\135\231\168\139 PlayerLocation:", PlayerLocation.X, PlayerLocation.Y, PlayerLocation.Z)
      end
    else
      Log.Error("\230\136\152\230\150\151\233\128\137\231\130\185\233\162\132\229\138\160\232\189\189\239\188\140player.viewObj\228\184\186\231\169\186")
    end
  else
    Log.Error("\230\136\152\230\150\151\233\128\137\231\130\185 dataManager\229\138\160\232\189\189\229\164\177\232\180\165")
  end
end

function DebugTabBattleField:ChangeScene(name, panel, InputText)
  local SceneResId
  local inputText = panel.InputBox:GetText()
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  if nil == inputText then
    inputText = ""
  end
  local params = {}
  for w in string.gmatch(inputText, "%S+") do
    table.insert(params, w)
  end
  if 1 == #params then
    SceneResId = tonumber(params[1])
  end
  Log.Debug("DebugTabBattleField:SetForceForwardInCloseBattleField", SceneResId)
  if nil ~= SceneResId then
    BattleField.ChangeScene(SceneResId)
  end
end

function DebugTabBattleField:InitFromEditorUse()
  UE4.UNRCBattleFieldDataManager.InitFromEditorUse()
end

function DebugTabBattleField:OpenFieldHide(name, panel)
  BattleManager.DebugBattleHide = not BattleManager.DebugBattleHide
end

function DebugTabBattleField:OpenLocalServerData(name, panel)
  BattleField.debugClientContrast = true
end

function DebugTabBattleField:CloseLocalServerData(name, panel)
  BattleField.debugClientContrast = false
end

function DebugTabBattleField:LoadServerBattleField(name, panel)
end

function DebugTabBattleField:OpenLocalServerData(name, panel)
  BattleField.debugUseServerBattleField = true
end

function DebugTabBattleField:CloseLocalServerData(name, panel)
  BattleField.debugUseServerBattleField = false
end

local function DrawBattleField_Internal(radius1, ratio1, radius2, ratio2, battlefieldHeight, InCameraCenterX, InCameraCenterY, cameraCenterZ, IncameraHalfX, IncameraHalfY, cameraHalfZ)
  if not BattleField.debugLastBattleFieldAns then
    return
  end
  radius1 = radius1 * 100
  radius2 = radius2 * 100
  battlefieldHeight = battlefieldHeight * 100
  local cameraCenterX = InCameraCenterX * 100
  local cameraCenterY = -InCameraCenterY * 100
  cameraCenterZ = cameraCenterZ * 100
  local cameraHalfX = IncameraHalfX * 100
  local cameraHalfY = IncameraHalfY * 100
  cameraHalfZ = cameraHalfZ * 100
  local center = UE4.FVector(BattleField.debugLastBattleFieldAns.X, BattleField.debugLastBattleFieldAns.Y, BattleField.debugLastBattleFieldAns.Z + battlefieldHeight * 0.5)
  local rotate = UE4.UKismetMathLibrary.MakeRotator(0, 0, BattleField.debugLastBattleFieldRotateAns + 90)
  local wide1 = 1.0 * radius1 / ratio1
  local wide2 = 1.0 * radius2 / ratio2
  local a1_extent = UE4.FVector(radius1, wide1, battlefieldHeight * 0.5)
  UE4.UKismetSystemLibrary.Abs_DrawDebugBox(_G.UE4Helper.GetCurrentWorld(), center, a1_extent, UE4.FLinearColor(1, 0, 0, 1), rotate, 100)
  local a2_extent = UE4.FVector(radius2, wide2, battlefieldHeight * 0.5)
  UE4.UKismetSystemLibrary.Abs_DrawDebugBox(_G.UE4Helper.GetCurrentWorld(), center, a2_extent, UE4.FLinearColor(1, 0, 0, 1), rotate, 100)
  local a2_semi_extent = UE4.FVector(radius2 - 400, wide2, battlefieldHeight * 0.5)
  UE4.UKismetSystemLibrary.Abs_DrawDebugBox(_G.UE4Helper.GetCurrentWorld(), center, a2_semi_extent, UE4.FLinearColor(0, 0, 1, 1), rotate, 100)
  local camera_center_offset = UE4.FVector(cameraCenterX, cameraCenterY, cameraCenterZ)
  local camera_extent = UE4.FVector(cameraHalfX, cameraHalfY, cameraHalfZ)
  UE4.UNRCBattleFieldStatics.DrawDebugRotateBox(BattleField.debugLastBattleFieldAns, camera_center_offset, camera_extent, BattleField.debugLastBattleFieldRotateAns - 90, BattleField.debugLastBattleFieldRotateAns - 90, UE4.FLinearColor(1, 0, 0, 1), 100)
end

function DebugTabBattleField:DrawBattleField1(name, panel)
  DrawBattleField_Internal(BattleFieldConst.layer1Param.Radius1, BattleFieldConst.layer1Param.Ratio1, BattleFieldConst.layer1Param.Radius2, BattleFieldConst.layer1Param.Ratio2, BattleFieldConst.layer1Param.BattlefieldHeight, BattleFieldConst.layer1Param.CameraCenterX, BattleFieldConst.layer1Param.CameraCenterY, BattleFieldConst.layer1Param.CameraCenterZ, BattleFieldConst.layer1Param.CameraHalfX, BattleFieldConst.layer1Param.CameraHalfY, BattleFieldConst.layer1Param.CameraHalfZ)
end

function DebugTabBattleField:DrawBattleField2(name, panel)
  DrawBattleField_Internal(BattleFieldConst.layer2Param.Radius1, BattleFieldConst.layer2Param.Ratio1, BattleFieldConst.layer2Param.Radius2, BattleFieldConst.layer2Param.Ratio2, BattleFieldConst.layer2Param.BattlefieldHeight, BattleFieldConst.layer2Param.CameraCenterX, BattleFieldConst.layer2Param.CameraCenterY, BattleFieldConst.layer2Param.CameraCenterZ, BattleFieldConst.layer2Param.CameraHalfX, BattleFieldConst.layer2Param.CameraHalfY, BattleFieldConst.layer2Param.CameraHalfZ)
end

function DebugTabBattleField:DebugLastBattlePoint(name, panel)
  local ans = BattleField.debugLastBattleFieldAns
  if not ans then
    Log.Error("\230\178\161\230\156\137\228\184\138\230\172\161\233\128\137\231\130\185\231\187\147\230\158\156")
    return
  end
  local lineBegin = UE4.FVector(ans.X, ans.Y, ans.Z)
  local lineEnd = UE4.FVector(ans.X, ans.Y, ans.Z + 10000)
  UE4.UKismetSystemLibrary.Abs_DrawDebugLine(_G.UE4Helper.GetCurrentWorld(), lineBegin, lineEnd, UE4.FLinearColor(1, 0, 0, 1), 100)
end

function DebugTabBattleField:SetForceForward(name, panel, InputText)
  local inputForward, inputText
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  if nil == inputText then
    inputText = ""
  end
  local params = {}
  for w in string.gmatch(inputText, "%S+") do
    table.insert(params, w)
  end
  if 1 == #params then
    inputForward = tonumber(params[1])
  end
  BattleField.debugForceForward = inputForward
end

function DebugTabBattleField:CleanForceForward()
  BattleField.debugForceForward = nil
end

function DebugTabBattleField:SetForceEnterLocation(name, panel, InputText)
  local inputLocation, inputText
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  if nil == inputText then
    inputText = ""
  end
  local params = {}
  for w in string.gmatch(inputText, "%S+") do
    table.insert(params, w)
  end
  if 3 == #params then
    local x = tonumber(params[1])
    local y = tonumber(params[2])
    local z = tonumber(params[3])
    inputLocation = UE4.FVector(x, y, z)
  end
  BattleField.debugForceEnterLocation = inputLocation
end

function DebugTabBattleField:CleanForceEnterLocation()
  BattleField.debugForceEnterLocation = nil
end

function DebugTabBattleField:OpenTimeOutForceFail()
  UE4.UNRCBattleFieldDataManager.SetForceTimeOutFail(true)
end

function DebugTabBattleField:CloseTimeOutForceFail()
  UE4.UNRCBattleFieldDataManager.SetForceTimeOutFail(false)
end

function DebugTabBattleField:OpenPrintQueryTime()
  UE4.UNRCBattleFieldDataManager.SetQueryTimeLog(true)
end

function DebugTabBattleField:ClosePrintQueryTime()
  UE4.UNRCBattleFieldDataManager.SetQueryTimeLog(false)
end

function DebugTabBattleField:ForceFullStation()
  BattleField.debugForceStation = 1
end

function DebugTabBattleField:ForceNoFullStation()
  BattleField.debugForceStation = 2
end

function DebugTabBattleField:CloseForceStation()
  BattleField.debugForceStation = nil
end

function DebugTabBattleField:PrintMapIdAndFile()
  Log.Error("DebugTabBattleField:PrintMapIdAndFile lastID", BattleField.lastDataMapID)
  Log.Error("DebugTabBattleField:PrintMapIdAndFile lastfile", BattleField.lastDataFileName)
end

function DebugTabBattleField:PrintLastBattleFieldDetail()
  Log.Error("DebugTabBattleField:PrintLastBattleFieldDetail RotateBit", BattleField.debugLastEnterBattleRotateBit)
  Log.Error("DebugTabBattleField:PrintLastBattleFieldDetail OriRotate", BattleField.debugLastEnterBattleOriRotate)
end

function DebugTabBattleField:OpenBattlePointDebugLine()
  BattleField.debugBattlePointLine = true
end

function DebugTabBattleField:CloseBattlePointDebugLine()
  BattleField.debugBattlePointLine = false
end

function DebugTabBattleField:OpenHitWallDebugLine()
  BattleField.debugHitWallLine = true
end

function DebugTabBattleField:CloseHitWallDebugLine()
  BattleField.debugHitWallLine = false
end

function DebugTabBattleField:OpenBattleFieldResultPrint()
  BattleField.debugBattleFieldResultPrint = true
end

function DebugTabBattleField:CloseBattleFieldResultPrint()
  BattleField.debugBattleFieldResultPrint = false
end

function DebugTabBattleField:DebugBigWorld3DUnload()
  local TotalNum = UE4.UNRCBattleFieldDataManager.DebugGetTreeElementsNum()
  local UnLoadNum = UE4.UNRCBattleFieldDataManager.DebugUnload()
  local ResideNum = UE4.UNRCBattleFieldDataManager.DebugGetTreeElementsNum()
  Log.Error("DebugTabBattleField:DebugBigWorld3DUnload", "TotalNum", TotalNum, "UnLoadNum", UnLoadNum, "ResideNum", ResideNum)
end

function DebugTabBattleField:DebugBigWorld3DElementNum()
  local Num = UE4.UNRCBattleFieldDataManager.DebugGetTreeElementsNum()
  Log.Error("DebugTabBattleField:DebugBigWorld3DElementNum", "Num", Num)
end

function DebugTabBattleField:DisplaySmallLevel3DBattleField()
  Log.Warning("DebugTabBattleField:DisplaySmallLevel3DBattleField, lastID", BattleField.lastDataMapID)
  BattleField.LoadCurSceneData()
  if not BattleField.mapData then
    Log.Error("no mapData")
    return
  end
  UE4.UNRCBattleFieldDataManager.ClearCacheDisplayTransforms()
  local World = _G.UE4Helper.GetCurrentWorld()
  local cache = {}
  local num = 0
  for i, d in ipairs(BattleField.mapData) do
    local x = -d[4] * 100
    local y = -d[6] * 100
    local z = d[5] * 100
    local rotate = d[7]
    local hash = string.format("%d_%d_%d", math.floor(x), math.floor(y), math.floor(z))
    if not cache[hash] then
      UE4.UNRCBattleFieldDataManager.AddCacheDisplayTransforms(World, x, y, z, math.round(rotate))
      num = num + 1
      cache[hash] = 1
    end
    if #d > 9 then
      x = -d[9] * 100
      y = -d[11] * 100
      z = d[10] * 100
      rotate = d[12]
      hash = string.format("%d_%d_%d", math.floor(x), math.floor(y), math.floor(z))
      if not cache[hash] then
        UE4.UNRCBattleFieldDataManager.AddCacheDisplayTransforms(World, x, y, z, math.round(rotate))
        num = num + 1
        cache[hash] = 1
      end
    end
  end
  Log.Error("Display num", num)
  UE4.UNRCBattleFieldDataManager.OpenDisplayAll(World, 0, true)
  UE4.UNRCBattleFieldDataManager.ClearCacheDisplayTransforms()
end

function DebugTabBattleField:DisplaySmallLevel3DBattleFieldLand()
  BattleField.LoadCurSceneData()
  if not BattleField.mapData then
    return
  end
  UE4.UNRCBattleFieldDataManager.ClearCacheDisplayTransforms()
  local World = _G.UE4Helper.GetCurrentWorld()
  for i, d in ipairs(BattleField.mapData) do
    local x = d[1]
    local y = d[2]
    local z = d[3]
    UE4.UNRCBattleFieldDataManager.AddCacheDisplayTransforms(World, x, y, z)
  end
  UE4.UNRCBattleFieldDataManager.OpenDisplayAll(World, 0, true)
  UE4.UNRCBattleFieldDataManager.ClearCacheDisplayTransforms()
end

function DebugTabBattleField:Display3DBattleField1()
  UE4.UNRCBattleFieldDataManager.OpenDisplayAll(_G.UE4Helper.GetCurrentWorld(), 0)
end

function DebugTabBattleField:Display3DBattleField2()
  UE4.UNRCBattleFieldDataManager.OpenDisplayAll(_G.UE4Helper.GetCurrentWorld(), 1)
end

function DebugTabBattleField:CloseDisplay3DBattleField()
  UE4.UNRCBattleFieldDataManager.CloseDisplay()
end

function DebugTabBattleField:Use3DBattleField()
  BattleConst.bUseBattleFieldMulity = true
end

function DebugTabBattleField:UseTraditionBattleField()
  BattleConst.bUseBattleFieldMulity = false
end

function DebugTabBattleField:TogglePosInLandHit()
  SceneUtils.debugGetPosInLandHit = not SceneUtils.debugGetPosInLandHit
end

function DebugTabBattleField:SublevelUnitTest()
  BattleField.RunUnitTest3D()
end

function DebugTabBattleField:SublevelUnitTestCurrent()
  BattleField.UnitTest3D(BattleField.debugLastEnterBattlePoint, BattleField.debugLastEnterBattleRotateAns, true)
end

function DebugTabBattleField:OpenBattleField()
  Log.Debug("DebugTabBattleField:OpenBattleField")
  BattleConst.CanBattleEverywhere = false
end

function DebugTabBattleField:CloseBattleField()
  Log.Debug("DebugTabBattleField:CloseBattleField")
  BattleConst.CanBattleEverywhere = true
end

function DebugTabBattleField:SetForceForwardInCloseBattleField(name, panel, InputText)
  local inputForward, inputText
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  if nil == inputText then
    inputText = ""
  end
  local params = {}
  for w in string.gmatch(inputText, "%S+") do
    table.insert(params, w)
  end
  if 1 == #params then
    inputForward = tonumber(params[1])
  end
  Log.Debug("DebugTabBattleField:SetForceForwardInCloseBattleField", inputForward)
  BattleConst.debugForceForwardWhenClose = inputForward
end

function DebugTabBattleField:ClearForceForwardInCloseBattleField(name, panel)
  BattleConst.debugForceForwardWhenClose = nil
end

function DebugTabBattleField:ReportBattleEnterPoint()
  local pet = BattleManager.battlePawnManager:GetTeamPet(BattleEnum.Team.ENUM_TEAM, 1)
  if not pet then
    local Ctx = DialogContext()
    Ctx:SetContent("\229\189\147\229\137\141\228\184\141\229\156\168\230\136\152\230\150\151\228\184\173\239\188\140\233\156\128\232\166\129\229\156\168\230\136\152\230\150\151\228\184\173\230\137\141\232\131\189\230\177\135\230\138\165")
    Ctx:SetMode(DialogContext.Mode.OK)
    return
  end
  local enemyPet = BattleManager.battlePawnManager:GetTeamPet(BattleEnum.Team.ENUM_ENEMY, 1)
  local p1 = pet.model:Abs_K2_GetActorLocation()
  local p2 = enemyPet.model:Abs_K2_GetActorLocation()
  local p0 = UE4.FVector()
  p0.X = (p1.X + p2.X) / 2
  p0.Y = (p1.Y + p2.Y) / 2
  p0.Z = (p1.Z + p2.Z) / 2
  if BattleField.debugLastEnterBattlePoint then
    UE4.UNRCStatics.ClipboardCopy(DebugUtils.GetPosCopyStr(BattleField.debugLastEnterBattlePoint))
    local Ctx = DialogContext()
    Ctx:SetContent("\229\189\147\229\137\141\230\136\152\229\156\186\228\189\141\231\189\174" .. string.format("%f, %f, %f\n", p0.X, p0.Y, p0.Z) .. "\228\184\138\230\172\161\232\191\155\230\136\152\230\150\151\229\133\165\229\143\163\228\189\141\231\189\174" .. string.format("%f, %f, %f", BattleField.debugLastEnterBattlePoint.X, BattleField.debugLastEnterBattlePoint.Y, BattleField.debugLastEnterBattlePoint.Z))
    Ctx:SetMode(DialogContext.Mode.OK)
    NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
  else
    local Ctx = DialogContext()
    Ctx:SetContent("\230\151\160\228\184\138\230\172\161\230\136\152\229\156\186\228\189\141\231\189\174\230\159\165\232\175\162\230\136\144\229\138\159\232\174\176\229\189\149\239\188\140\229\143\175\232\131\189\232\175\165\229\140\186\229\159\159\230\178\161\230\156\137\230\136\152\229\156\186\228\191\161\230\129\175\227\128\130" .. "\229\189\147\229\137\141\230\136\152\229\156\186\228\189\141\231\189\174" .. string.format("%f, %f, %f\n", p0.X, p0.Y, p0.Z))
    NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
  end
end

function DebugTabBattleField:DebugPetSlope()
  local pitch1, pitch2, divc, divl = BattleField.GetPetSlope()
  local txt = "\232\132\154\229\186\149\229\157\161\229\186\166" .. tostring(math.abs(pitch1)) .. "\228\184\173\229\191\131\229\157\161\229\186\166" .. tostring(math.abs(pitch2)) .. "\n \228\184\173\229\191\131tan" .. tostring(math.sqrt(divc)) .. "\n \232\132\154\229\186\149tan" .. tostring(math.sqrt(divl))
  Log.Debug(txt)
  local Ctx = DialogContext()
  Ctx:SetContent(txt)
  Ctx:SetMode(DialogContext.Mode.OK)
  NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function DebugTabBattleField:FindNearestBattlePoint(name, panel, InputText)
  if not UE4.UNRCBattleFieldDataManager.IsCreateAnyOne() then
    self:StartTick()
  end
  local inputLocation
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local inputText
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  if nil == inputText then
    inputText = ""
  end
  local params = {}
  for w in string.gmatch(inputText, "%S+") do
    table.insert(params, w)
  end
  if 3 == #params then
    local x = tonumber(params[1])
    local y = tonumber(params[2])
    local z = tonumber(params[3])
    inputLocation = UE4.FVector(x, y, z)
  else
    inputLocation = player.viewObj:Abs_K2_GetActorLocation()
  end
  BattleField.FindNearestBattlePoint(inputLocation, player.viewObj:Abs_GetTransform(), true, 0, true)
end

function DebugTabBattleField:FindNearestBattlePoint2(name, panel, InputText)
  if not UE4.UNRCBattleFieldDataManager.IsCreateAnyOne() then
    self:StartTick()
  end
  local inputLocation
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local inputText
  if panel then
    inputText = panel.InputBox:GetText()
  else
    inputText = InputText
  end
  if nil == inputText then
    inputText = ""
  end
  local params = {}
  for w in string.gmatch(inputText, "%S+") do
    table.insert(params, w)
  end
  if 3 == #params then
    local x = tonumber(params[1])
    local y = tonumber(params[2])
    local z = tonumber(params[3])
    inputLocation = UE4.FVector(x, y, z)
  else
    inputLocation = player.viewObj:Abs_K2_GetActorLocation()
  end
  BattleField.FindNearestBattlePoint(inputLocation, player.viewObj:Abs_GetTransform(), false, 0, true)
end

function DebugTabBattleField:MoveToNearestBattlePoint()
  if not UE4.UNRCBattleFieldDataManager.IsCreateAnyOne() then
    self:StartTick()
  end
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local PlayerLocation = player.viewObj:Abs_K2_GetActorLocation()
  local pos, _ = BattleField.FindNearestBattlePoint(PlayerLocation, player.viewObj:Abs_GetTransform(), 0, false)
  pos.z = pos.z + 60
  player.viewObj:Abs_K2_SetActorLocation_WithoutHit(pos)
end

function DebugTabBattleField:ToggleBattlePointPreload()
  SceneUtils.debugBattleBulkDataPreload = not SceneUtils.debugBattleBulkDataPreload
end

function DebugTabBattleField:PrintPetPointAndCollision()
  if not _G.BattleManager.battlePawnManager then
    return
  end
  local PlayerTeamPets = _G.BattleManager.battlePawnManager:GetPlayerTeamPets()
  local EnemyPets = _G.BattleManager.battlePawnManager:GetEnemyAllPets()
  if 0 == #PlayerTeamPets or 0 == #EnemyPets then
    Log.Debug("BattlePet Location Info #PlayerTeamPets=", #PlayerTeamPets, "#EnemyPets=", #EnemyPets)
    return
  end
  local teamPet = PlayerTeamPets[1]
  local enemyPet = EnemyPets[1]
  if not teamPet.model or not enemyPet.model then
    Log.Debug("BattlePet Location Info teamPet.model=", teamPet.model, "teamPet.model=", teamPet.model)
    return
  end
  local pos1 = teamPet.model:Abs_K2_GetActorLocation()
  local pos2 = enemyPet.model:Abs_K2_GetActorLocation()
  local Origin1, Extend1 = teamPet.model:GetActorBounds()
  local Origin2, Extend2 = enemyPet.model:GetActorBounds()
  Log.Debug("BattlePet Location Info \230\136\145\230\150\185\231\178\190\231\129\181\228\189\141\231\189\174=", pos1, "\230\149\140\230\150\185\231\178\190\231\129\181\228\189\141\231\189\174=", pos2, "\232\183\157\231\166\187=", UE4.FVector.Dist(pos1, pos2))
  Log.Debug("BattlePet Location Info \230\136\145\230\150\185\231\178\190\231\129\181\229\140\133\229\155\180\231\155\146=", Origin1, Extend1)
  Log.Debug("BattlePet Location Info \230\149\140\230\150\185\231\178\190\231\129\181\229\140\133\229\155\180\231\155\146=", Origin2, Extend2)
  UE4.UKismetSystemLibrary.Abs_DrawDebugBox(UE4Helper.GetCurrentWorld(), pos1, Extend1, UE4.FLinearColor(1, 0, 0, 1), nil, 10)
  UE4.UKismetSystemLibrary.Abs_DrawDebugBox(UE4Helper.GetCurrentWorld(), pos2, Extend2, UE4.FLinearColor(1, 0, 0, 1), nil, 10)
end

function DebugTabBattleField:SetGetBattleCenterByClient()
  BattleConst.FindBattleCenterByClient = not BattleConst.FindBattleCenterByClient
  self:ClosePanel()
end

return DebugTabBattleField
