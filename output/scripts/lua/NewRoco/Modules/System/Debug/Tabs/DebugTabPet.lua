local PetSensingComponent = require("NewRoco.Modules.Core.Scene.Component.Interaction.PetSensingComponent")
local TipsModuleCmd = require("NewRoco.Modules.System.TipsModule.TipsModuleCmd")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BubbleType = require("NewRoco.Modules.Core.Scene.Component.Bubble.BubbleType")
local BubbleComponent = require("NewRoco.Modules.Core.Scene.Component.Bubble.BubbleComponent")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local PetSensingActivelyComponent = require("NewRoco.Modules.Core.Scene.Component.Interaction.PetSensingActivelyComponent")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local PetStatusComponent = require("NewRoco.Modules.Core.Scene.Component.Status.PetStatusComponent")
local PetStatusType = require("NewRoco.Modules.Core.Scene.Component.Status.PetStatusType")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local Base = DebugTabBase
local DebugTabPet = Base:Extend("DebugTabPet")

function DebugTabPet:Ctor()
  Base.Ctor(self)
  self.PetPanelTable = {}
end

function DebugTabPet:SetupTabs()
  self:Add("\230\148\190\231\148\159\233\154\143\232\186\171\232\131\140\229\140\133\231\178\190\231\129\181", self.FangShengPet, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\159\165\232\175\162\229\173\181\229\140\150\231\130\185\230\149\176", self.CheckHatchStatus, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\137\147\229\188\128\229\141\161\231\137\140\229\183\165\229\133\183", self.OpenCardDebugPanel, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  local Raw = _G.DataConfigManager:GetAllByName("EMOTION_CONF")
  for Name, Value in pairs(Raw) do
    self:Add(string.format("Bubble:%s", table.getKeyName(Enum.EmotionType, Name)), function(Tab, ButtonName, Panel)
      local NPC = self:GetNearestNpc()
      local Player = self:GetPlayer()
      local Comp = NPC:EnsureComponent(BubbleComponent)
      Comp:Play(Player, Name, self, self.OnBubbleFinish)
    end, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "\230\181\139\232\175\149\230\131\133\231\187\170\231\148\168\231\154\132")
  end
  self:Add("\232\191\155\229\133\165\233\154\144\232\186\171&\231\173\137\229\190\133", self.EnterWaitAndHide, self)
  self:Add("\231\166\187\229\188\128\233\154\144\232\186\171&\231\173\137\229\190\133", self.ExitWaitAndHide, self)
end

function DebugTabPet:Bubble(Name, Tab, ButtonName, Panel)
  local NPC = self:GetNearestNpc()
  local Player = self:GetPlayer()
  local Comp = NPC:EnsureComponent(BubbleComponent)
  Comp:Play(Player, Name, self, self.OnBubbleFinish)
end

function DebugTabPet:SetPlayerInitPetCat()
  local req = _G.ProtoMessage:newZoneGmSelectAdventurePetReq()
  req.uin = _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.uin
  req.pet_conf_id = 2000670
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_SELECT_ADVENTURE_PET_REQ, req, self, self.SetPlayerInitPet)
end

function DebugTabPet:SetPlayerInitPetFire()
  local req = _G.ProtoMessage:newZoneGmSelectAdventurePetReq()
  req.uin = _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.uin
  req.pet_conf_id = 2000672
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_SELECT_ADVENTURE_PET_REQ, req, self, self.SetPlayerInitPet)
end

function DebugTabPet:SetPlayerInitPetWater()
  local req = _G.ProtoMessage:newZoneGmSelectAdventurePetReq()
  req.uin = _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.uin
  req.pet_conf_id = 2000671
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_SELECT_ADVENTURE_PET_REQ, req, self, self.SetPlayerInitPet)
end

function DebugTabPet:OpenPetLog()
  _G.PetLog = true
end

function DebugTabPet:ClosePetLog()
  _G.PetLog = false
end

function DebugTabPet:OnBubbleFinish(Success)
  Log.Error("Play Bubble, OK?", Success)
end

function DebugTabPet:SetHeadLookAt(Name, Panel)
end

function DebugTabPet:QueryNPC(Name, Panel)
  local Player = self:GetPlayer()
  local View = Player.viewObj
  local World = _G.UE4Helper.GetCurrentWorld()
  local Klass = _G.NRCResourceManager:LoadForDebugOnly("/Game/NewRoco/Modules/Core/NPC/BP_NPCCharacter")
  local ResultArray = UE4.TArray(UE.AActor)
  local Success = UE.UKismetSystemLibrary.SphereOverlapActors(World, View:K2_GetActorLocation(), 1000, {
    UE.EObjectTypeQuery.WorldDynamic,
    UE.EObjectTypeQuery.Pawn
  }, Klass, nil, ResultArray)
  if Success then
    for Index, Actor in tpairs(ResultArray) do
      Log.Error("Show Overlapping Actors", Index, Actor:GetName())
    end
  end
  Log.Dump(getmetatable(UE.EObjectTypeQuery), 3, "EObjectTypeQuery")
  Log.Dump(getmetatable(UE.ETraceTypeQuery), 3, "ETraceTypeQuery")
  Log.Dump(getmetatable(UE.ECollisionChannel), 3, "ECollisionChannel")
end

function DebugTabPet:SetNPCPosition(Name, Panel)
  local NPC = self:GetNearestNpc()
  local Pos = NPC.viewObj:GetNearLandLocation()
  Log.Error("Show Pos ", Pos.X, Pos.Y, Pos.Z)
  local HalfHeight = NPC.viewObj:GetHalfHeight()
  Pos.Z = Pos.Z + HalfHeight
  NPC:SetActorLocation(Pos)
end

function DebugTabPet:ListFolder(Name, Panel)
  local SceneID = SceneUtils.GetSceneID()
  if 0 == SceneID then
    self:GeneratePets(true)
    self:ClosePanel()
  else
    local Context = DialogContext()
    Context:SetContent("\229\156\168\230\184\184\230\136\143\229\156\186\230\153\175\228\184\173\231\148\159\230\136\144\230\137\128\230\156\137NPC\228\188\154\233\128\160\230\136\144\230\184\184\230\136\143\229\141\161\233\161\191\239\188\140\232\175\183\231\161\174\232\174\164\230\152\175\229\144\166\232\166\129\231\148\159\230\136\144")
    Context:SetMode(DialogContext.Mode.OK_CANCEL)
    Context:SetClickAnywhereClose(true)
    Context:SetCloseOnCancel(true)
    Context:SetCloseOnOK(true)
    Context:SetButtonText("\231\148\159\230\136\144\239\188\129", "\231\174\151\228\186\134")
    Context:SetCallback(self, self.GeneratePets)
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
  end
end

function DebugTabPet:NPCListFolder(Name, Panel)
  local SceneID = SceneUtils.GetSceneID()
  if 0 == SceneID then
    self:GenerateNPCs(true)
    self:ClosePanel()
  else
    local Context = DialogContext()
    Context:SetContent("\229\156\168\230\184\184\230\136\143\229\156\186\230\153\175\228\184\173\231\148\159\230\136\144\230\137\128\230\156\137NPC\228\188\154\233\128\160\230\136\144\230\184\184\230\136\143\229\141\161\233\161\191\239\188\140\232\175\183\231\161\174\232\174\164\230\152\175\229\144\166\232\166\129\231\148\159\230\136\144")
    Context:SetMode(DialogContext.Mode.OK_CANCEL)
    Context:SetClickAnywhereClose(true)
    Context:SetCloseOnCancel(true)
    Context:SetCloseOnOK(true)
    Context:SetButtonText("\231\148\159\230\136\144\239\188\129", "\231\174\151\228\186\134")
    Context:SetCallback(self, self.GenerateNPCs)
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
  end
end

function DebugTabPet:ListFolderLineUP(Name, Panel)
  local SceneID = SceneUtils.GetSceneID()
  if 0 == SceneID then
    self:GeneratePetsLineUP(true)
    self:ClosePanel()
  else
    local Context = DialogContext()
    Context:SetContent("\229\156\168\230\184\184\230\136\143\229\156\186\230\153\175\228\184\173\231\148\159\230\136\144\230\137\128\230\156\137NPC\228\188\154\233\128\160\230\136\144\230\184\184\230\136\143\229\141\161\233\161\191\239\188\140\232\175\183\231\161\174\232\174\164\230\152\175\229\144\166\232\166\129\231\148\159\230\136\144")
    Context:SetMode(DialogContext.Mode.OK_CANCEL)
    Context:SetClickAnywhereClose(true)
    Context:SetCloseOnCancel(true)
    Context:SetCloseOnOK(true)
    Context:SetButtonText("\231\148\159\230\136\144\239\188\129", "\231\174\151\228\186\134")
    Context:SetCallback(self, self.GeneratePetsLineUP)
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
  end
end

function DebugTabPet:ListFolderPlane(Name, Panel)
  local SceneID = SceneUtils.GetSceneID()
  if 0 == SceneID then
    self:GeneratePetsPlane(true)
    self:ClosePanel()
  else
    local Context = DialogContext()
    Context:SetContent("\229\156\168\230\184\184\230\136\143\229\156\186\230\153\175\228\184\173\231\148\159\230\136\144\230\137\128\230\156\137NPC\228\188\154\233\128\160\230\136\144\230\184\184\230\136\143\229\141\161\233\161\191\239\188\140\232\175\183\231\161\174\232\174\164\230\152\175\229\144\166\232\166\129\231\148\159\230\136\144")
    Context:SetMode(DialogContext.Mode.OK_CANCEL)
    Context:SetClickAnywhereClose(true)
    Context:SetCloseOnCancel(true)
    Context:SetCloseOnOK(true)
    Context:SetButtonText("\231\148\159\230\136\144\239\188\129", "\231\174\151\228\186\134")
    Context:SetCallback(self, self.GeneratePetsPlane)
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
  end
end

function DebugTabPet:GeneratePets(Confirm)
  if not Confirm then
    return
  end
  local ListOfAssets = UE.TArray("")
  UE.UNRCStatics.ListFolder("/Game/ArtRes/BP/Pets", ListOfAssets, true)
  local AllBP = {}
  for _, Path in tpairs(ListOfAssets) do
    local Segs = string.split(Path, "/")
    if 7 == #Segs and string.StartsWith(Segs[7], "BP_") and "/Game/ArtRes/BP/Pets/Fir_HuoYu3_001/BP_NewRide_HuoYu.BP_NewRide_HuoYu" ~= Path then
      table.insert(AllBP, Path)
    end
  end
  local Player = self:GetPlayer()
  local Transform = Player:GetActorTransform()
  local Center = Player:GetActorLocation()
  self:SpawnPet(AllBP, 1, Center, 0)
end

function DebugTabPet:GenerateNPCs(Confirm)
  if not Confirm then
    return
  end
  local ListOfAssets = UE.TArray("")
  UE.UNRCStatics.ListFolder("/Game/ArtRes/BP/Scene", ListOfAssets, true)
  local AllBP = {}
  for _, Path in tpairs(ListOfAssets) do
    local Segs = string.split(Path, "/")
    local num = #Segs
    if num > 7 then
      num = 8
    else
      num = 7
    end
    if #Segs == num and string.StartsWith(Segs[num], "BP_") then
      table.insert(AllBP, Path)
    end
  end
  local Player = self:GetPlayer()
  local Transform = Player:GetActorTransform()
  local Center = Player:GetActorLocation()
  self:SpawnPetLineUP(AllBP, 1, Center, 0)
end

function DebugTabPet:GeneratePetsLineUP(Confirm)
  if not Confirm then
    return
  end
  local ListOfAssets = UE.TArray("")
  UE.UNRCStatics.ListFolder("/Game/ArtRes/BP/Pets", ListOfAssets, true)
  local AllBP = {}
  for _, Path in tpairs(ListOfAssets) do
    local Segs = string.split(Path, "/")
    if 7 == #Segs and string.StartsWith(Segs[7], "BP_") and "/Game/ArtRes/BP/Pets/Fir_HuoYu3_001/BP_NewRide_HuoYu.BP_NewRide_HuoYu" ~= Path then
      table.insert(AllBP, Path)
    end
  end
  local Player = self:GetPlayer()
  local Transform = Player:GetActorTransform()
  local Center = Player:GetActorLocation()
  self:SpawnPetLineUP(AllBP, 1, Center, 0)
end

function DebugTabPet:GeneratePetsPlane(Confirm)
  if not Confirm then
    return
  end
  local ListOfAssets = UE.TArray("")
  UE.UNRCStatics.ListFolder("/Game/ArtRes/BP/Pets", ListOfAssets, true)
  local AllBP = {}
  for _, Path in tpairs(ListOfAssets) do
    local Segs = string.split(Path, "/")
    if 7 == #Segs and string.StartsWith(Segs[7], "BP_") then
      table.insert(AllBP, Path)
    end
  end
  local Player = self:GetPlayer()
  local Transform = Player:GetActorTransform()
  local Center = Player:GetActorLocation()
  local BP_PlanePet = _G.NRCResourceManager:LoadForDebugOnly("/Game/ArtRes/Temp/shovenzhang/TestMap/IKTEST/BP_FootIKTest_Child.BP_FootIKTest_Child")
  local planePet = UE4.UGameplayStatics.GetAllActorsOfClass(_G.UE4Helper.GetCurrentWorld(), BP_PlanePet)
  if planePet then
    for _, p in tpairs(planePet) do
      table.insert(self.PetPanelTable, p)
    end
  end
  self:SpawnPetPlane(AllBP, 1, Center, 0)
end

function DebugTabPet:SpawnPet(All, Index, Center, Angle)
  if Index <= 0 then
    return
  end
  if Index > #All then
    return
  end
  local Radius = 200 + Index * 20
  Angle = Angle + 500 / Radius / math.pi
  local Klass = _G.NRCResourceManager:LoadForDebugOnly(All[Index])
  if Klass then
    local DX = Radius * math.cos(Angle)
    local DY = Radius * math.sin(Angle)
    local Transform = UE4.FTransform(UE4.FQuat(), UE.FVector(Center.X + DX, Center.Y + DY, Center.Z + 500))
    local World = self:GetWorld()
    local Actor = World:SpawnActor(Klass, Transform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, nil, nil)
    Actor:Abs_K2_SetActorLocation_WithoutHit(UE.FVector(Center.X + DX, Center.Y + DY, Center.Z + 500))
    if Actor and Actor.InitOutSceneAsync then
      Actor:InitOutSceneAsync()
      local Root = Actor:K2_GetRootComponent()
      Root.bHiddenInGame = false
      Actor:SetActorEnableCollision(false)
      local Location = Actor:GetNearLandLocation()
      if not Location then
        Log.Error("\231\148\159\230\136\144\229\174\160\231\137\169\228\184\173\230\150\173\228\186\134!!")
        return
      end
      Location.Z = Location.Z + Actor:GetHalfHeight()
      Actor:SetActorLocation(Location)
      local LookAt = Center - Location
      LookAt.Z = 0
      Actor:K2_SetActorRotation(LookAt:ToRotator():Clamp(), true)
    else
      Log.Error("Actor\231\148\159\230\136\144\229\164\177\232\180\165", All[Index])
    end
  else
    Log.Error("Class\229\138\160\232\189\189\229\164\177\232\180\165", All[Index])
  end
  if Index + 1 >= #All then
    Log.Error("\229\174\140\230\136\144\230\137\128\230\156\137\231\154\132\229\174\160\231\137\169\231\148\159\230\136\144", Index)
    return
  end
  _G.DelayManager:DelayFrames(1, self.SpawnPet, self, All, Index + 1, Center, Angle)
end

function DebugTabPet:SpawnPetLineUP(All, Index, Center, Angle)
  if Index <= 0 then
    return
  end
  if Index > #All then
    return
  end
  local Klass = _G.NRCResourceManager:LoadForDebugOnly(All[Index])
  if Klass then
    local DX = Index // 20 + 1
    local DY = Index % 20
    local DDX = DX * 400
    local DDY = -4000 + DY * 400
    local Transform = UE4.FTransform(UE4.FQuat(), UE.FVector(Center.X - DDX, Center.Y - DDY, Center.Z + 500))
    local World = self:GetWorld()
    local Actor = World:SpawnActor(Klass, Transform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, nil, nil)
    Actor:Abs_K2_SetActorLocation_WithoutHit(UE.FVector(Center.X - DDX, Center.Y - DDY, Center.Z + 500))
    if Actor and Actor.InitOutSceneAsync then
      Actor:InitOutSceneAsync()
      Actor:SetActorEnableCollision(false)
      local Location = Actor:GetNearLandLocation()
      if not Location then
        Log.Error("\231\148\159\230\136\144\229\174\160\231\137\169\228\184\173\230\150\173\228\186\134!!")
        return
      end
      Location.Z = Location.Z + Actor:GetHalfHeight()
      Actor:SetActorLocation(Location)
      local LookAt = Center - Location
      LookAt.Z = 0
    else
      Log.Error("Actor\231\148\159\230\136\144\229\164\177\232\180\165", All[Index])
    end
  else
    Log.Error("Class\229\138\160\232\189\189\229\164\177\232\180\165", All[Index])
  end
  if Index + 1 >= #All then
    Log.Error("\229\174\140\230\136\144\230\137\128\230\156\137\231\154\132\229\174\160\231\137\169\231\148\159\230\136\144", Index)
    return
  end
  _G.DelayManager:DelayFrames(1, self.SpawnPetLineUP, self, All, Index + 1, Center, Angle)
end

function DebugTabPet:SpawnPetPlane(All, Index, Center, Angle)
  if Index <= 0 then
    return
  end
  if Index > #All then
    return
  end
  if Index > #self.PetPanelTable then
    Log.Error(" ====== Index = ", Index, " self.PetPanelTable = ", #self.PetPanelTable)
    Log.Error(" \231\148\159\230\136\144\231\178\190\231\129\181\230\149\176\233\135\143\229\164\154\228\189\153\230\157\191\229\157\151\230\149\176\233\135\143 \230\151\160\230\179\149\232\191\155\232\161\140\231\148\159\230\136\144\231\178\190\231\129\181 ")
    return
  end
  local Klass = _G.NRCResourceManager:LoadForDebugOnly(All[Index])
  if Klass then
    local PetPanelActor = self.PetPanelTable[Index]
    local PPT = PetPanelActor:Abs_GetTransform()
    local PetLocation = PPT.Translation
    local DX = PetLocation.X
    local DY = PetLocation.Y
    local DZ = PetLocation.Z
    local Transform = UE4.FTransform(UE4.FQuat(), UE.FVector(DX, DY, DZ + 500))
    local World = self:GetWorld()
    local Actor = World:Abs_SpawnActor(Klass, Transform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, nil, nil)
    if Actor and Actor.InitOutSceneAsync then
      Actor:InitOutSceneAsync()
      Actor:SetActorEnableCollision(false)
      local Location = Actor:GetNearLandLocation()
      if not Location then
        Log.Error("\231\148\159\230\136\144\229\174\160\231\137\169\228\184\173\230\150\173\228\186\134!!")
        return
      end
      Location.Z = Location.Z + Actor:GetHalfHeight()
      Actor:SetActorLocation(Location)
    else
      Log.Error("Actor\231\148\159\230\136\144\229\164\177\232\180\165", All[Index])
    end
  else
    Log.Error("Class\229\138\160\232\189\189\229\164\177\232\180\165", All[Index])
  end
  if Index + 1 >= #All then
    Log.Error("\229\174\140\230\136\144\230\137\128\230\156\137\231\154\132\229\174\160\231\137\169\231\148\159\230\136\144", Index)
    return
  end
  _G.DelayManager:DelayFrames(1, self.SpawnPetPlane, self, All, Index + 1, Center, Angle)
end

function DebugTabPet:PlayPerceptionSkill(Name, Panel)
  local Player = self:GetPlayer()
  local Comp = Player:EnsureComponent(PetSensingComponent)
  Comp:PlayPerceptionSkill()
end

function DebugTabPet:StopPerceptionSkill(Name, Panel)
  local Player = self:GetPlayer()
  local Comp = Player:EnsureComponent(PetSensingComponent)
  Comp:StopPerceptionSkill()
end

function DebugTabPet:PlayActivePerceptionSkill(Name, Panel)
  local Player = self:GetPlayer()
  local Comp = Player:EnsureComponent(PetSensingActivelyComponent)
  Comp:PlayPerceptionSkill(self:GetInputNumber(1))
end

function DebugTabPet:StopActivePerceptionSkill(Name, Panel)
  local Player = self:GetPlayer()
  local Comp = Player:EnsureComponent(PetSensingActivelyComponent)
  Comp:StopPerceptionSkill()
end

function DebugTabPet:SetRandomMeshScale(Name, Panel)
  local NPC = self:GetNearestNpc()
  UE.UNRCCharacterUtils.SetCharacterMeshScale(NPC.viewObj, math.random(50, 500) / 100)
  UE.UNRCCharacterUtils.SetActorOnGround(NPC.viewObj)
end

function DebugTabPet:ShowPool(Name, Panel)
  local NPCModule = self:GetModule("NPCModule")
  NPCModule.npcActorPool:PrintInfo()
  self:Inspect(NPCModule.npcActorPool)
end

function DebugTabPet:OpenPetUpgrade()
  _G.NRCModuleManager:DoCmd(MainUIModuleCmd.OpenPetLevelUpPage)
end

function DebugTabPet:OpenPetBag()
  _G.NRCModuleManager:DoCmd(MainUIModuleCmd.OpenPetBagUI)
end

function DebugTabPet:ForceRefreshNamePlat(Name, Panel)
  local npc = self:GetNearestNpc()
  local HUDComp = npc.PetHUDComponent
  if not HUDComp then
    return
  end
  local DebugName = "Debug Hud"
  if UE.UObject.IsValid(npc.viewObj) then
    local HeadWidget = npc.viewObj.HeadWidget
    if UE.UObject.IsValid(HeadWidget) then
      if not HeadWidget:GetUserWidgetObject() then
        local hudClass = _G.NRCResourceManager:LoadForDebugOnly("WidgetBlueprint'/Game/NewRoco/Modules/System/MainUI/Res/UMG_Hud_Pet.UMG_Hud_Pet_C'")
        local hud = UE4.UWidgetBlueprintLibrary.Create(UE4Helper.GetCurrentWorld(), hudClass)
        HeadWidget:SetWidget(hud)
        if UE.UObject.IsValid(hud) then
          hud:SetParentHUD(HeadWidget)
        end
        HUDComp._headHud = HeadWidget:GetUserWidgetObject()
      end
      HeadWidget:SetVisibility(true, true)
      HeadWidget:SetComponentTickEnabled(true)
      HeadWidget:SetTickWhenOffscreen(true)
      local NpcTrans = npc.viewObj:GetTransform()
      UE.UKismetSystemLibrary.DrawDebugSphere(npc.viewObj, NpcTrans.Translation, 100, 8, UE.FLinearColor(1, 0, 0, 1), 50)
      local WidgetTrans = HeadWidget:K2_GetComponentToWorld()
      UE.UKismetSystemLibrary.DrawDebugSphere(npc.viewObj, WidgetTrans.Translation, 50, 8, UE.FLinearColor(0, 1, 0, 1), 50)
      HeadWidget:K2_SetWorldTransform(WidgetTrans)
      local BoxElems = HeadWidget.BodySetup.AggGeom.BoxElems:Get(1)
      UE.UKismetSystemLibrary.DrawDebugSphere(npc.viewObj, BoxElems.Center + NpcTrans.Translation, 30, 8, UE.FLinearColor(0, 0, 1, 1), 50)
    end
  else
    Log.Error("NPC View invalid")
  end
  HUDComp:ForceUpdate()
  HUDComp._headHud:SetVisibility(UE.ESlateVisibility.Visible)
  HUDComp._headHud:SetName(DebugName)
  HUDComp._headHud:SetVisible(true)
  self:ClosePanel()
end

function DebugTabPet:ShowInteractQuantity()
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  localPlayer:EnsurePetInfoMap()
  for id, petInfo in pairs(localPlayer.petInfoMap) do
    local pet = _G.DataModelMgr.PlayerDataModel:GetPetByGid(petInfo.gid)
    Log.Error(string.format("\231\178\190\231\129\181%s\231\154\132\228\186\178\229\175\134\229\186\166\228\184\186: %d/%d", pet.config.name, petInfo.interact_quantity, petInfo.interact_quantity_threshold))
  end
  Log.Error("\228\187\165\228\184\139\230\152\175\228\189\160\232\186\171\228\184\138\231\154\132\231\178\190\231\129\181\228\186\178\229\175\134\229\186\166\228\191\161\230\129\175")
end

function DebugTabPet:ShowInteractQuantityWhenChange()
  _G.GlobalConfig.bShowHintWhenInteractQuantityChange = not _G.GlobalConfig.bShowHintWhenInteractQuantityChange
  if _G.GlobalConfig.bShowHintWhenInteractQuantityChange then
    Log.Error("\228\186\164\228\186\146\233\135\143\229\143\152\229\140\150\230\152\190\231\164\186\229\188\128\229\144\175")
  else
    Log.Error("\228\186\164\228\186\146\233\135\143\229\143\152\229\140\150\230\152\190\231\164\186\229\133\179\233\151\173")
  end
end

function DebugTabPet:PetInARow(Name, Panel)
  local NPCModule = self:GetModule("NPCModule")
  for i = 10, 4, -1 do
    local NPC = NPCModule:CreateLocalNPC(self:GetInputNumber(10059), {
      x = 0,
      y = 300 * (i - 3),
      z = 0
    }, 0)
    NPC:SetSignificant(false, i)
    NPC.AIComponent:ForceLock(true, true)
    NPC:PlayAnim("CallOut", 1.0, 0, 0, 0, 999, 1)
  end
end

function DebugTabPet:PetModelAdjustTool(Name, Panel)
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.OpenPetAdjustVisualTool)
end

function DebugTabPet:PetUIAdjustTool(Name, Panel)
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.OpenPetUIAdjustTool)
end

function DebugTabPet:SetPetLevel(name, panel, level)
  if panel then
    local req = ProtoMessage:newZoneGmSetPetLevelReq()
    req.pet_level = panel:GetInputNumber()
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_SET_PET_LEVEL_REQ, req, self, self.SetPetLevelRsp)
  elseif level then
    local req = ProtoMessage:newZoneGmSetPetLevelReq()
    local num = tonumber(level)
    req.pet_level = num
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_SET_PET_LEVEL_REQ, req, self, self.SetPetLevelRsp)
  end
end

function DebugTabPet:SetPetLevelRsp(name, panel, level)
end

function DebugTabPet:FangShengPet(name, panel, level, InputNumber)
  local num
  if panel then
    num = panel:GetInputNumber()
  else
    num = tonumber(InputNumber)
  end
  local backpackPetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBackpackPetInfo()
  if backpackPetList and #backpackPetList > 0 then
    if num > #backpackPetList then
      num = #backpackPetList
    end
    local PetGidList = {}
    for i = #backpackPetList, 1, -1 do
      if self:IsCanFree(backpackPetList[i]) and num >= #PetGidList then
        table.insert(PetGidList, backpackPetList[i].gid)
      end
    end
    _G.NRCModuleManager:DoCmd(PetUIModuleCmd.SendFangShengPet, PetGidList)
  end
end

function DebugTabPet:IsCanFree(petData)
  if petData.partner_mark and petData.partner_mark ~= ProtoEnum.PetPartnerMarkType.PPMT_NONE then
    local tip = _G.DataConfigManager:GetPetGlobalConfig("collection_cant_release").str
    return false
  end
  local IsTeamPet = _G.DataModelMgr.PlayerDataModel:GetIsTeamPetByGid(petData.gid)
  if IsTeamPet then
    return false
  end
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
  if petBaseConf.ban_free and 1 == petBaseConf.ban_free then
    return false
  end
  local isTravel = _G.NRCModuleManager:DoCmd(_G.TravelModuleCmd.GetPetIsTravel, petData.gid)
  if isTravel then
    return false
  end
  return true
end

function DebugTabPet:CheckHatchStatus()
  if self.bIsCheckingHatchStatus then
    return
  end
  local backpack_info = _G.DataModelMgr.PlayerDataModel.playerInfo.pet_info.backpack_info
  if backpack_info and backpack_info.egg_gid then
    Log.Error("\228\187\165\228\184\139\230\152\175\229\173\181\229\140\150\228\191\161\230\129\175")
    self.hatchCount = #backpack_info.egg_gid
    self.hatchIndex = 1
    self.AllEggGid = {}
    self.bIsCheckingHatchStatus = true
    self.AllHatchInfoTest = {}
    for i = 1, #backpack_info.egg_gid do
      table.insert(self.AllEggGid, backpack_info.egg_gid[i])
    end
    local req = _G.ProtoMessage:newZoneGetHatchStatusReq()
    req.egg_gid = self.AllEggGid[self.hatchIndex]
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_HATCH_STATUS_REQ, req, self, self.OnZoneGetHatchStatusRsp)
  else
    Log.Error("\230\178\161\230\156\137\229\173\181\229\140\150\228\191\161\230\129\175\239\188\140\230\178\161\230\156\137\230\173\163\229\156\168\229\173\181\229\140\150\228\184\173\231\154\132\232\155\139")
  end
end

function DebugTabPet:OnZoneGetHatchStatusRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    local hatched_secs = rsp.hatched_secs
    if rsp.ret_info.egg_Data then
      local eggData = rsp.ret_info.egg_Data
      local eggConf = _G.DataConfigManager:GetPetEggConf(eggData.conf_id)
      local eggMaxSeces = eggConf.hatch_data
      local eggName = eggConf.name
      local progress = math.clamp(hatched_secs / eggMaxSeces * 100)
      local hatchInfoText = string.format("\229\173\181\229\140\150\231\178\190\231\129\181\229\144\141%s         \229\183\178\229\173\181\229\140\150\230\151\182\233\151\180\239\188\154%s         \229\137\169\228\189\153\229\173\181\229\140\150\232\191\155\229\186\166\239\188\154%s%", eggName, hatched_secs, progress)
      Log.Error(hatchInfoText)
      table.insert(self.AllHatchInfoTest, hatchInfoText)
    else
      Log.Error(string.format("\231\172\172%s\229\143\183\231\178\190\231\129\181\232\155\139\229\173\181\229\140\150\231\130\185\230\149\176\228\184\186\239\188\154%s", self.hatchIndex, hatched_secs))
      table.insert(self.AllHatchInfoTest, string.format("\231\172\172%s\229\143\183\231\178\190\231\129\181\232\155\139\229\173\181\229\140\150\231\130\185\230\149\176\228\184\186\239\188\154%s", self.hatchIndex, hatched_secs))
      if self.hatchIndex < self.hatchCount then
        self.hatchIndex = self.hatchIndex + 1
        _G.DelayManager:DelaySeconds(1, function()
          local req = _G.ProtoMessage:newZoneGetHatchStatusReq()
          req.egg_gid = self.AllEggGid[self.hatchIndex]
          _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_HATCH_STATUS_REQ, req, self, self.OnZoneGetHatchStatusRsp)
        end)
      else
        local hatchInfoText = table.concat(self.AllHatchInfoTest, "\n")
        local Context = DialogContext()
        Context:SetTitle("\229\173\181\229\140\150\228\191\161\230\129\175")
        Context:SetContent(hatchInfoText)
        Context:SetMode(DialogContext.Mode.NotBtn)
        Context:SetClickAnywhereClose(true)
        _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
        self.AllHatchInfoTest = nil
        self.bIsCheckingHatchStatus = nil
      end
    end
  end
end

function DebugTabPet:AddPet(name, panel, petID, num)
  if panel then
    local req = ProtoMessage:newZoneGmClientAddPetReq()
    local inputText = panel.InputBox:GetText()
    local numbers = {}
    for number in inputText:gmatch("%d+") do
      table.insert(numbers, tonumber(number))
    end
    req.pet_conf_id = numbers[1]
    req.num = numbers[2]
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CLIENT_ADD_PET_REQ, req, self, self.GetRsp)
  elseif petID and num then
    local req = ProtoMessage:newZoneGmClientAddPetReq()
    local IDNum = tonumber(petID)
    local petNum = tonumber(num)
    req.pet_conf_id = IDNum
    req.num = petNum
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CLIENT_ADD_PET_REQ, req, self, self.GetRsp)
  end
end

function DebugTabPet:GetRsp()
end

function DebugTabPet:ReportPetUIAdjustTool(Name, Panel)
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.ReportPetUIAdjustTool)
end

function DebugTabPet:EnterWaitAndHide(Name, Panel)
  local NPC = self:GetNearestNpc()
  if not NPC then
    self:ShowTips("\233\153\132\232\191\145\230\178\161\230\137\190\229\136\176NPC")
    return
  end
  local StatusComp = NPC:EnsureComponent(PetStatusComponent)
  StatusComp:SetStatus(PetStatusType.Wait)
  _G.DelayManager:DelayFrames(10, function()
    NPC:SetHidden(true, NPCModuleEnum.NpcReasonFlags.EXPLODE)
  end)
end

function DebugTabPet:ExitWaitAndHide(Name, Panel)
  local NPC = self:GetNearestNpc()
  if not NPC then
    self:ShowTips("\233\153\132\232\191\145\230\178\161\230\137\190\229\136\176NPC")
    return
  end
  local StatusComp = NPC:EnsureComponent(PetStatusComponent)
  StatusComp:SetStatus(PetStatusType.None)
  _G.DelayManager:DelayFrames(10, function()
    NPC:SetHidden(false, NPCModuleEnum.NpcReasonFlags.EXPLODE)
  end)
end

function DebugTabPet:OpenCardDebugPanel()
  _G.NRCModuleManager:DoCmd(_G.ShareUIModuleCmd.OpenShareCardDebugPanel)
end

return DebugTabPet
