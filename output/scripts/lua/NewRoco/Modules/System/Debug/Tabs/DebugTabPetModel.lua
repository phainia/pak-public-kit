local PetSensingComponent = require("NewRoco.Modules.Core.Scene.Component.Interaction.PetSensingComponent")
local TipsModuleCmd = require("NewRoco.Modules.System.TipsModule.TipsModuleCmd")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local BubbleType = require("NewRoco.Modules.Core.Scene.Component.Bubble.BubbleType")
local BubbleComponent = require("NewRoco.Modules.Core.Scene.Component.Bubble.BubbleComponent")
local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local PetSensingActivelyComponent = require("NewRoco.Modules.Core.Scene.Component.Interaction.PetSensingActivelyComponent")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local Base = DebugTabBase
local DebugTabPetModel = Base:Extend("DebugTabPetModel")
local Direction = true
local CurrentIndex = 1
local CreateNumber = 0
local Boundary = 0
local CurrentPet = {}
local AllPetForIndex = {}

function DebugTabPetModel:Ctor()
  Base.Ctor(self)
  self.PetPanelTable = {}
end

function DebugTabPetModel:SetupTabs()
end

function DebugTabPetModel:EnterEmptyScene(Name, panel)
  NRCModeManager:ActiveMode("LocalMode")
  _G.LevelHelper:OpenLevel("/Game/ArtRes/Level/Performance/BigWorldEnvForPetTest")
  _G.NRCModeManager:DoCmd(EnvSystemModuleCmd.ChangeTimeScale, 1)
  if panel then
    panel:DoClose()
  end
end

function DebugTabPetModel:ListFolderShining(Name, Panel)
  local text = Panel:GetInputNumber()
  if 0 == text then
    local SceneID = SceneUtils.GetSceneID()
    if 0 == SceneID then
      self:GeneratePetsShining(true)
      self:ClosePanel()
    else
      local Context = DialogContext()
      Context:SetContent("\229\156\168\230\184\184\230\136\143\229\156\186\230\153\175\228\184\173\231\148\159\230\136\144\230\137\128\230\156\137\231\178\190\231\129\181\226\128\148\226\128\148\229\188\130\232\137\178\228\188\154\233\128\160\230\136\144\230\184\184\230\136\143\229\141\161\233\161\191\239\188\140\232\175\183\231\161\174\232\174\164\230\152\175\229\144\166\232\166\129\231\148\159\230\136\144")
      Context:SetMode(DialogContext.Mode.OK_CANCEL)
      Context:SetClickAnywhereClose(true)
      Context:SetCloseOnCancel(true)
      Context:SetCloseOnOK(true)
      Context:SetButtonText("\231\148\159\230\136\144\239\188\129", "\231\174\151\228\186\134")
      Context:SetCallback(self, self.GeneratePetsShining)
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
    end
  else
    if CurrentPet then
      self:DestroyPet()
    end
    local modelConf = _G.DataConfigManager:GetModelConf(text)
    self.Path = nil
    if modelConf and modelConf.path then
      local temp = modelConf.path
      local temp2 = temp:gsub("^Blueprint'", ""):gsub("'$", "")
      self.Path = temp2:gsub("_C$", "")
    end
    local SceneID = SceneUtils.GetSceneID()
    if 0 == SceneID then
      self:GeneratePetsShining(true)
      self:ClosePanel()
    else
      local Context = DialogContext()
      Context:SetContent("\229\176\134\229\156\168\230\184\184\230\136\143\229\156\186\230\153\175\228\184\173\231\148\159\230\136\144\230\140\135\229\174\154\231\178\190\231\129\181\226\128\148\226\128\148\229\188\130\232\137\178\239\188\140\232\175\183\231\161\174\232\174\164\230\152\175\229\144\166\232\166\129\231\148\159\230\136\144")
      Context:SetMode(DialogContext.Mode.OK_CANCEL)
      Context:SetClickAnywhereClose(true)
      Context:SetCloseOnCancel(true)
      Context:SetCloseOnOK(true)
      Context:SetButtonText("\231\148\159\230\136\144\239\188\129", "\231\174\151\228\186\134")
      Context:SetCallback(self, self.GeneratePetsShining)
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
    end
  end
end

function DebugTabPetModel:ListFolderGlass(Name, Panel)
  local text = Panel:GetInputNumber()
  if 0 == text then
    local SceneID = SceneUtils.GetSceneID()
    if 0 == SceneID then
      self:GeneratePetsGlass(true)
      self:ClosePanel()
    else
      local Context = DialogContext()
      Context:SetContent("\229\156\168\230\184\184\230\136\143\229\156\186\230\153\175\228\184\173\231\148\159\230\136\144\230\137\128\230\156\137\231\178\190\231\129\181\226\128\148\226\128\148\231\142\187\231\146\131\228\188\154\233\128\160\230\136\144\230\184\184\230\136\143\229\141\161\233\161\191\239\188\140\232\175\183\231\161\174\232\174\164\230\152\175\229\144\166\232\166\129\231\148\159\230\136\144")
      Context:SetMode(DialogContext.Mode.OK_CANCEL)
      Context:SetClickAnywhereClose(true)
      Context:SetCloseOnCancel(true)
      Context:SetCloseOnOK(true)
      Context:SetButtonText("\231\148\159\230\136\144\239\188\129", "\231\174\151\228\186\134")
      Context:SetCallback(self, self.GeneratePetsGlass)
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
    end
  else
    if CurrentPet then
      self:DestroyPet()
    end
    local modelConf = _G.DataConfigManager:GetModelConf(text)
    self.Path = nil
    if modelConf and modelConf.path then
      local temp = modelConf.path
      local temp2 = temp:gsub("^Blueprint'", ""):gsub("'$", "")
      self.Path = temp2:gsub("_C$", "")
    end
    local SceneID = SceneUtils.GetSceneID()
    if 0 == SceneID then
      self:GeneratePetsGlass(true)
      self:ClosePanel()
    else
      local Context = DialogContext()
      Context:SetContent("\229\176\134\229\156\168\230\184\184\230\136\143\229\156\186\230\153\175\228\184\173\231\148\159\230\136\144\231\178\190\231\129\181\226\128\148\226\128\148\231\142\187\231\146\131\239\188\140\232\175\183\231\161\174\232\174\164\230\152\175\229\144\166\232\166\129\231\148\159\230\136\144")
      Context:SetMode(DialogContext.Mode.OK_CANCEL)
      Context:SetClickAnywhereClose(true)
      Context:SetCloseOnCancel(true)
      Context:SetCloseOnOK(true)
      Context:SetButtonText("\231\148\159\230\136\144\239\188\129", "\231\174\151\228\186\134")
      Context:SetCallback(self, self.GeneratePetsGlass)
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
    end
  end
end

function DebugTabPetModel:ListFolderChaos(Name, Panel)
  local text = Panel:GetInputNumber()
  if 0 == text then
    local SceneID = SceneUtils.GetSceneID()
    if 0 == SceneID then
      self:GeneratePetsChaos(true)
      self:ClosePanel()
    else
      local Context = DialogContext()
      Context:SetContent("\229\156\168\230\184\184\230\136\143\229\156\186\230\153\175\228\184\173\231\148\159\230\136\144\230\137\128\230\156\137\231\178\190\231\129\181\226\128\148\226\128\148\229\153\169\230\162\166\228\188\154\233\128\160\230\136\144\230\184\184\230\136\143\229\141\161\233\161\191\239\188\140\232\175\183\231\161\174\232\174\164\230\152\175\229\144\166\232\166\129\231\148\159\230\136\144")
      Context:SetMode(DialogContext.Mode.OK_CANCEL)
      Context:SetClickAnywhereClose(true)
      Context:SetCloseOnCancel(true)
      Context:SetCloseOnOK(true)
      Context:SetButtonText("\231\148\159\230\136\144\239\188\129", "\231\174\151\228\186\134")
      Context:SetCallback(self, self.GeneratePetsChaos)
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
    end
  else
    if CurrentPet then
      self:DestroyPet()
    end
    local modelConf = _G.DataConfigManager:GetModelConf(text)
    self.Path = nil
    if modelConf and modelConf.path then
      local temp = modelConf.path
      local temp2 = temp:gsub("^Blueprint'", ""):gsub("'$", "")
      self.Path = temp2:gsub("_C$", "")
    end
    local SceneID = SceneUtils.GetSceneID()
    if 0 == SceneID then
      self:GeneratePetsChaos(true)
      self:ClosePanel()
    else
      local Context = DialogContext()
      Context:SetContent("\229\176\134\229\156\168\230\184\184\230\136\143\229\156\186\230\153\175\228\184\173\231\148\159\230\136\144\231\178\190\231\129\181\226\128\148\226\128\148\229\153\169\230\162\166\239\188\140\232\175\183\231\161\174\232\174\164\230\152\175\229\144\166\232\166\129\231\148\159\230\136\144")
      Context:SetMode(DialogContext.Mode.OK_CANCEL)
      Context:SetClickAnywhereClose(true)
      Context:SetCloseOnCancel(true)
      Context:SetCloseOnOK(true)
      Context:SetButtonText("\231\148\159\230\136\144\239\188\129", "\231\174\151\228\186\134")
      Context:SetCallback(self, self.GeneratePetsChaos)
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
    end
  end
end

function DebugTabPetModel:ListFolderChaosTwo(Name, Panel)
  local text = Panel:GetInputNumber()
  if 0 == text then
    local SceneID = SceneUtils.GetSceneID()
    if 0 == SceneID then
      self:GeneratePetsChaosTwo(true)
      self:ClosePanel()
    else
      local Context = DialogContext()
      Context:SetContent("\229\156\168\230\184\184\230\136\143\229\156\186\230\153\175\228\184\173\231\148\159\230\136\144\230\137\128\230\156\137\231\178\190\231\129\181\226\128\148\226\128\148\229\153\169\230\162\1662\228\188\154\233\128\160\230\136\144\230\184\184\230\136\143\229\141\161\233\161\191\239\188\140\232\175\183\231\161\174\232\174\164\230\152\175\229\144\166\232\166\129\231\148\159\230\136\144")
      Context:SetMode(DialogContext.Mode.OK_CANCEL)
      Context:SetClickAnywhereClose(true)
      Context:SetCloseOnCancel(true)
      Context:SetCloseOnOK(true)
      Context:SetButtonText("\231\148\159\230\136\144\239\188\129", "\231\174\151\228\186\134")
      Context:SetCallback(self, self.GeneratePetsChaosTwo)
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
    end
  else
    if CurrentPet then
      self:DestroyPet()
    end
    local modelConf = _G.DataConfigManager:GetModelConf(text)
    self.Path = nil
    if modelConf and modelConf.path then
      local temp = modelConf.path
      local temp2 = temp:gsub("^Blueprint'", ""):gsub("'$", "")
      self.Path = temp2:gsub("_C$", "")
    end
    local SceneID = SceneUtils.GetSceneID()
    if 0 == SceneID then
      self:GeneratePetsChaosTwo(true)
      self:ClosePanel()
    else
      local Context = DialogContext()
      Context:SetContent("\229\176\134\229\156\168\230\184\184\230\136\143\229\156\186\230\153\175\228\184\173\231\148\159\230\136\144\231\178\190\231\129\181\226\128\148\226\128\148\229\153\169\230\162\1662\239\188\140\232\175\183\231\161\174\232\174\164\230\152\175\229\144\166\232\166\129\231\148\159\230\136\144")
      Context:SetMode(DialogContext.Mode.OK_CANCEL)
      Context:SetClickAnywhereClose(true)
      Context:SetCloseOnCancel(true)
      Context:SetCloseOnOK(true)
      Context:SetButtonText("\231\148\159\230\136\144\239\188\129", "\231\174\151\228\186\134")
      Context:SetCallback(self, self.GeneratePetsChaosTwo)
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
    end
  end
end

function DebugTabPetModel:GeneratePetsShining(Confirm)
  if not Confirm then
    return
  end
  if self.Path == nil then
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
    local Center = Player:GetActorLocation()
    self:SpawnPetShining(AllBP, 1, Center, 0)
  else
    local Player = self:GetPlayer()
    local Center = Player:GetActorLocation()
    local BP = {}
    table.insert(BP, self.Path)
    self:SpawnPetShining(BP, 1, Center, 0)
  end
end

function DebugTabPetModel:GeneratePetsGlass(Confirm)
  if not Confirm then
    return
  end
  if self.Path == nil then
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
    local Center = Player:GetActorLocation()
    self:SpawnPetGlass(AllBP, 1, Center, 0)
  else
    local Player = self:GetPlayer()
    local Center = Player:GetActorLocation()
    local BP = {}
    table.insert(BP, self.Path)
    self:SpawnPetGlass(BP, 1, Center, 0)
  end
end

function DebugTabPetModel:GeneratePetsChaos(Confirm)
  if not Confirm then
    return
  end
  if self.Path == nil then
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
    local Center = Player:GetActorLocation()
    self:SpawnPetChaos(AllBP, 1, Center, 0)
  else
    local Player = self:GetPlayer()
    local Center = Player:GetActorLocation()
    local BP = {}
    table.insert(BP, self.Path)
    self:SpawnPetChaos(BP, 1, Center, 0)
  end
end

function DebugTabPetModel:GeneratePetsChaosTwo(Confirm)
  if not Confirm then
    return
  end
  if self.Path == nil then
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
    local Center = Player:GetActorLocation()
    self:SpawnPetChaosTwo(AllBP, 1, Center, 0)
  else
    local Player = self:GetPlayer()
    local Center = Player:GetActorLocation()
    local BP = {}
    table.insert(BP, self.Path)
    self:SpawnPetChaosTwo(BP, 1, Center, 0)
  end
end

function DebugTabPetModel:SpawnPetShining(All, Index, Center, Angle)
  if Index <= 0 then
    return
  end
  if Index > #All then
    return
  end
  local Radius = 200 + Index * 5
  Angle = Angle + 400 / Radius / math.pi
  local Klass = _G.NRCResourceManager:LoadForDebugOnly(All[Index])
  if Klass then
    local DX = Radius * math.cos(Angle)
    local DY = Radius * math.sin(Angle)
    local Transform = UE4.FTransform(UE4.FQuat(), UE.FVector(Center.X + DX, Center.Y + DY, Center.Z + 500))
    local World = self:GetWorld()
    self.Actor = World:SpawnActor(Klass, Transform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, nil, nil)
    self.Actor:Abs_K2_SetActorLocation_WithoutHit(UE.FVector(Center.X + DX, Center.Y + DY, Center.Z + 500))
    if self.Actor and self.Actor.InitOutSceneAsync then
      self.Actor:InitOutSceneAsync(self, self.OnViewLoadedShining)
      local Root = self.Actor:K2_GetRootComponent()
      Root.bHiddenInGame = false
      self.Actor:SetActorEnableCollision(false)
      local Location = self.Actor:GetNearLandLocation()
      if not Location then
        Log.Error("\231\148\159\230\136\144\229\174\160\231\137\169\228\184\173\230\150\173\228\186\134!!")
        return
      end
      Location.Z = Location.Z + self.Actor:GetHalfHeight()
      self.Actor:SetActorLocation(Location)
      local LookAt = Center - Location
      LookAt.Z = 0
      self.Actor:K2_SetActorRotation(LookAt:ToRotator():Clamp(), true)
      table.insert(CurrentPet, self.Actor)
    else
      Log.Error("Actor\231\148\159\230\136\144\229\164\177\232\180\165", All[Index])
    end
  else
    Log.Error("Class\229\138\160\232\189\189\229\164\177\232\180\165", All[Index])
  end
  if self.Path then
    return
  else
    if Index + 1 > #All then
      Log.Error("\229\174\140\230\136\144\230\137\128\230\156\137\231\154\132\229\174\160\231\137\169\231\148\159\230\136\144", Index)
      return
    end
    _G.DelayManager:DelayFrames(1, self.SpawnPetShining, self, All, Index + 1, Center, Angle)
  end
end

function DebugTabPetModel:SpawnPetGlass(All, Index, Center, Angle)
  if Index <= 0 then
    return
  end
  if Index > #All then
    return
  end
  local Radius = 200 + Index * 5
  Angle = Angle + 400 / Radius / math.pi
  local Klass = _G.NRCResourceManager:LoadForDebugOnly(All[Index])
  if Klass then
    local DX = Radius * math.cos(Angle)
    local DY = Radius * math.sin(Angle)
    local Transform = UE4.FTransform(UE4.FQuat(), UE.FVector(Center.X + DX, Center.Y + DY, Center.Z + 500))
    local World = self:GetWorld()
    self.Actor = World:SpawnActor(Klass, Transform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, nil, nil)
    self.Actor:Abs_K2_SetActorLocation_WithoutHit(UE.FVector(Center.X + DX, Center.Y + DY, Center.Z + 500))
    if self.Actor and self.Actor.InitOutSceneAsync then
      self.Actor:InitOutSceneAsync(self, self.OnViewLoadedGlass)
      local Root = self.Actor:K2_GetRootComponent()
      Root.bHiddenInGame = false
      self.Actor:SetActorEnableCollision(false)
      local Location = self.Actor:GetNearLandLocation()
      if not Location then
        Log.Error("\231\148\159\230\136\144\229\174\160\231\137\169\228\184\173\230\150\173\228\186\134!!")
        return
      end
      Location.Z = Location.Z + self.Actor:GetHalfHeight()
      self.Actor:SetActorLocation(Location)
      local LookAt = Center - Location
      LookAt.Z = 0
      self.Actor:K2_SetActorRotation(LookAt:ToRotator():Clamp(), true)
      table.insert(CurrentPet, self.Actor)
    else
      Log.Error("Actor\231\148\159\230\136\144\229\164\177\232\180\165", All[Index])
    end
  else
    Log.Error("Class\229\138\160\232\189\189\229\164\177\232\180\165", All[Index])
  end
  if self.Path then
    return
  else
    if Index + 1 > #All then
      Log.Error("\229\174\140\230\136\144\230\137\128\230\156\137\231\154\132\229\174\160\231\137\169\231\148\159\230\136\144", Index)
      return
    end
    _G.DelayManager:DelayFrames(1, self.SpawnPetGlass, self, All, Index + 1, Center, Angle)
  end
end

function DebugTabPetModel:SpawnPetChaos(All, Index, Center, Angle)
  if Index <= 0 then
    return
  end
  if Index > #All then
    return
  end
  local Radius = 200 + Index * 5
  Angle = Angle + 400 / Radius / math.pi
  local Klass = _G.NRCResourceManager:LoadForDebugOnly(All[Index])
  if Klass then
    local DX = Radius * math.cos(Angle)
    local DY = Radius * math.sin(Angle)
    local Transform = UE4.FTransform(UE4.FQuat(), UE.FVector(Center.X + DX, Center.Y + DY, Center.Z + 500))
    local World = self:GetWorld()
    self.Actor = World:SpawnActor(Klass, Transform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, nil, nil)
    self.Actor:Abs_K2_SetActorLocation_WithoutHit(UE.FVector(Center.X + DX, Center.Y + DY, Center.Z + 500))
    if self.Actor and self.Actor.InitOutSceneAsync then
      self.Actor:InitOutSceneAsync(self, self.OnViewLoadedChaos)
      local Root = self.Actor:K2_GetRootComponent()
      Root.bHiddenInGame = false
      self.Actor:SetActorEnableCollision(false)
      local Location = self.Actor:GetNearLandLocation()
      if not Location then
        Log.Error("\231\148\159\230\136\144\229\174\160\231\137\169\228\184\173\230\150\173\228\186\134!!")
        return
      end
      Location.Z = Location.Z + self.Actor:GetHalfHeight()
      self.Actor:SetActorLocation(Location)
      local LookAt = Center - Location
      LookAt.Z = 0
      self.Actor:K2_SetActorRotation(LookAt:ToRotator():Clamp(), true)
      table.insert(CurrentPet, self.Actor)
    else
      Log.Error("Actor\231\148\159\230\136\144\229\164\177\232\180\165", All[Index])
    end
  else
    Log.Error("Class\229\138\160\232\189\189\229\164\177\232\180\165", All[Index])
  end
  if self.Path then
    return
  else
    if Index + 1 > #All then
      Log.Error("\229\174\140\230\136\144\230\137\128\230\156\137\231\154\132\229\174\160\231\137\169\231\148\159\230\136\144", Index)
      return
    end
    _G.DelayManager:DelayFrames(1, self.SpawnPetChaos, self, All, Index + 1, Center, Angle)
  end
end

function DebugTabPetModel:SpawnPetChaosTwo(All, Index, Center, Angle)
  if Index <= 0 then
    return
  end
  if Index > #All then
    return
  end
  local Radius = 200 + Index * 5
  Angle = Angle + 400 / Radius / math.pi
  local Klass = _G.NRCResourceManager:LoadForDebugOnly(All[Index])
  if Klass then
    local DX = Radius * math.cos(Angle)
    local DY = Radius * math.sin(Angle)
    local Transform = UE4.FTransform(UE4.FQuat(), UE.FVector(Center.X + DX, Center.Y + DY, Center.Z + 500))
    local World = self:GetWorld()
    self.Actor = World:SpawnActor(Klass, Transform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, nil, nil)
    self.Actor:Abs_K2_SetActorLocation_WithoutHit(UE.FVector(Center.X + DX, Center.Y + DY, Center.Z + 500))
    if self.Actor and self.Actor.InitOutSceneAsync then
      self.Actor:InitOutSceneAsync(self, self.OnViewLoadedChaosTwo)
      local Root = self.Actor:K2_GetRootComponent()
      Root.bHiddenInGame = false
      self.Actor:SetActorEnableCollision(false)
      local Location = self.Actor:GetNearLandLocation()
      if not Location then
        Log.Error("\231\148\159\230\136\144\229\174\160\231\137\169\228\184\173\230\150\173\228\186\134!!")
        return
      end
      Location.Z = Location.Z + self.Actor:GetHalfHeight()
      self.Actor:SetActorLocation(Location)
      local LookAt = Center - Location
      LookAt.Z = 0
      self.Actor:K2_SetActorRotation(LookAt:ToRotator():Clamp(), true)
      table.insert(CurrentPet, self.Actor)
    else
      Log.Error("Actor\231\148\159\230\136\144\229\164\177\232\180\165", All[Index])
    end
  else
    Log.Error("Class\229\138\160\232\189\189\229\164\177\232\180\165", All[Index])
  end
  if self.Path then
    return
  else
    if Index + 1 > #All then
      Log.Error("\229\174\140\230\136\144\230\137\128\230\156\137\231\154\132\229\174\160\231\137\169\231\148\159\230\136\144", Index)
      return
    end
    _G.DelayManager:DelayFrames(1, self.SpawnPetChaosTwo, self, All, Index + 1, Center, Angle)
  end
end

function DebugTabPetModel:ForwardCreatShining(name, Panel)
  if 0 == #AllPetForIndex then
    self:InitPetTable()
  end
  if CurrentPet then
    self:DestroyPet()
  end
  Direction = true
  CreateNumber = Panel:GetInputNumber()
  if 0 == CreateNumber then
    return
  else
    Boundary = CurrentIndex + CreateNumber
    local SceneID = SceneUtils.GetSceneID()
    if 0 == SceneID then
      self:GeneratePetsShiningDirection(true)
      self:ClosePanel()
    else
      local Context = DialogContext()
      Context:SetContent("\229\156\168\230\184\184\230\136\143\229\156\186\230\153\175\228\184\173\231\148\159\230\136\144\230\137\128\230\156\137NPC\228\188\154\233\128\160\230\136\144\230\184\184\230\136\143\229\141\161\233\161\191\239\188\140\232\175\183\231\161\174\232\174\164\230\152\175\229\144\166\232\166\129\231\148\159\230\136\144")
      Context:SetMode(DialogContext.Mode.OK_CANCEL)
      Context:SetClickAnywhereClose(true)
      Context:SetCloseOnCancel(true)
      Context:SetCloseOnOK(true)
      Context:SetButtonText("\231\148\159\230\136\144\239\188\129", "\231\174\151\228\186\134")
      Context:SetCallback(self, self.GeneratePetsShiningDirection)
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
    end
  end
end

function DebugTabPetModel:BackwardCreatShining(name, Panel)
  if 0 == #AllPetForIndex then
    self:InitPetTable()
  end
  if CurrentPet then
    self:DestroyPet()
  end
  Direction = false
  CreateNumber = Panel:GetInputNumber()
  if 0 == CreateNumber then
    return
  else
    Boundary = CurrentIndex - CreateNumber
    local SceneID = SceneUtils.GetSceneID()
    if 0 == SceneID then
      self:GeneratePetsShiningDirection(true)
      self:ClosePanel()
    else
      local Context = DialogContext()
      Context:SetContent("\229\156\168\230\184\184\230\136\143\229\156\186\230\153\175\228\184\173\231\148\159\230\136\144\230\137\128\230\156\137NPC\228\188\154\233\128\160\230\136\144\230\184\184\230\136\143\229\141\161\233\161\191\239\188\140\232\175\183\231\161\174\232\174\164\230\152\175\229\144\166\232\166\129\231\148\159\230\136\144")
      Context:SetMode(DialogContext.Mode.OK_CANCEL)
      Context:SetClickAnywhereClose(true)
      Context:SetCloseOnCancel(true)
      Context:SetCloseOnOK(true)
      Context:SetButtonText("\231\148\159\230\136\144\239\188\129", "\231\174\151\228\186\134")
      Context:SetCallback(self, self.GeneratePetsShiningDirection)
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
    end
  end
end

function DebugTabPetModel:ForwardCreatGlass(name, Panel)
  if 0 == #AllPetForIndex then
    self:InitPetTable()
  end
  if CurrentPet then
    self:DestroyPet()
  end
  Direction = true
  CreateNumber = Panel:GetInputNumber()
  if 0 == CreateNumber then
    return
  else
    Boundary = CurrentIndex + CreateNumber
    local SceneID = SceneUtils.GetSceneID()
    if 0 == SceneID then
      self:GeneratePetsGlassDirection(true)
      self:ClosePanel()
    else
      local Context = DialogContext()
      Context:SetContent("\229\156\168\230\184\184\230\136\143\229\156\186\230\153\175\228\184\173\231\148\159\230\136\144\230\137\128\230\156\137NPC\228\188\154\233\128\160\230\136\144\230\184\184\230\136\143\229\141\161\233\161\191\239\188\140\232\175\183\231\161\174\232\174\164\230\152\175\229\144\166\232\166\129\231\148\159\230\136\144")
      Context:SetMode(DialogContext.Mode.OK_CANCEL)
      Context:SetClickAnywhereClose(true)
      Context:SetCloseOnCancel(true)
      Context:SetCloseOnOK(true)
      Context:SetButtonText("\231\148\159\230\136\144\239\188\129", "\231\174\151\228\186\134")
      Context:SetCallback(self, self.GeneratePetsGlassDirection)
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
    end
  end
end

function DebugTabPetModel:BackwardCreatGlass(name, Panel)
  if 0 == #AllPetForIndex then
    self:InitPetTable()
  end
  if CurrentPet then
    self:DestroyPet()
  end
  Direction = false
  CreateNumber = Panel:GetInputNumber()
  if 0 == CreateNumber then
    return
  else
    Boundary = CurrentIndex - CreateNumber
    local SceneID = SceneUtils.GetSceneID()
    if 0 == SceneID then
      self:GeneratePetsGlassDirection(true)
      self:ClosePanel()
    else
      local Context = DialogContext()
      Context:SetContent("\229\156\168\230\184\184\230\136\143\229\156\186\230\153\175\228\184\173\231\148\159\230\136\144\230\137\128\230\156\137NPC\228\188\154\233\128\160\230\136\144\230\184\184\230\136\143\229\141\161\233\161\191\239\188\140\232\175\183\231\161\174\232\174\164\230\152\175\229\144\166\232\166\129\231\148\159\230\136\144")
      Context:SetMode(DialogContext.Mode.OK_CANCEL)
      Context:SetClickAnywhereClose(true)
      Context:SetCloseOnCancel(true)
      Context:SetCloseOnOK(true)
      Context:SetButtonText("\231\148\159\230\136\144\239\188\129", "\231\174\151\228\186\134")
      Context:SetCallback(self, self.GeneratePetsGlassDirection)
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
    end
  end
end

function DebugTabPetModel:ForwardCreatChaos(name, Panel)
  if 0 == #AllPetForIndex then
    self:InitPetTable()
  end
  if CurrentPet then
    self:DestroyPet()
  end
  Direction = true
  CreateNumber = Panel:GetInputNumber()
  if 0 == CreateNumber then
    return
  else
    Boundary = CurrentIndex + CreateNumber
    local SceneID = SceneUtils.GetSceneID()
    if 0 == SceneID then
      self:GeneratePetsChaosDirection(true)
      self:ClosePanel()
    else
      local Context = DialogContext()
      Context:SetContent("\229\156\168\230\184\184\230\136\143\229\156\186\230\153\175\228\184\173\231\148\159\230\136\144\230\137\128\230\156\137NPC\228\188\154\233\128\160\230\136\144\230\184\184\230\136\143\229\141\161\233\161\191\239\188\140\232\175\183\231\161\174\232\174\164\230\152\175\229\144\166\232\166\129\231\148\159\230\136\144")
      Context:SetMode(DialogContext.Mode.OK_CANCEL)
      Context:SetClickAnywhereClose(true)
      Context:SetCloseOnCancel(true)
      Context:SetCloseOnOK(true)
      Context:SetButtonText("\231\148\159\230\136\144\239\188\129", "\231\174\151\228\186\134")
      Context:SetCallback(self, self.GeneratePetsChaosDirection)
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
    end
  end
end

function DebugTabPetModel:BackwardCreatChaos(name, Panel)
  if 0 == #AllPetForIndex then
    self:InitPetTable()
  end
  if CurrentPet then
    self:DestroyPet()
  end
  Direction = false
  CreateNumber = Panel:GetInputNumber()
  if 0 == CreateNumber then
    return
  else
    Boundary = CurrentIndex - CreateNumber
    local SceneID = SceneUtils.GetSceneID()
    if 0 == SceneID then
      self:GeneratePetsChaosDirection(true)
      self:ClosePanel()
    else
      local Context = DialogContext()
      Context:SetContent("\229\156\168\230\184\184\230\136\143\229\156\186\230\153\175\228\184\173\231\148\159\230\136\144\230\137\128\230\156\137NPC\228\188\154\233\128\160\230\136\144\230\184\184\230\136\143\229\141\161\233\161\191\239\188\140\232\175\183\231\161\174\232\174\164\230\152\175\229\144\166\232\166\129\231\148\159\230\136\144")
      Context:SetMode(DialogContext.Mode.OK_CANCEL)
      Context:SetClickAnywhereClose(true)
      Context:SetCloseOnCancel(true)
      Context:SetCloseOnOK(true)
      Context:SetButtonText("\231\148\159\230\136\144\239\188\129", "\231\174\151\228\186\134")
      Context:SetCallback(self, self.GeneratePetsChaosDirection)
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
    end
  end
end

function DebugTabPetModel:ForwardCreatChaosTwo(name, Panel)
  if 0 == #AllPetForIndex then
    self:InitPetTable()
  end
  if CurrentPet then
    self:DestroyPet()
  end
  Direction = true
  CreateNumber = Panel:GetInputNumber()
  if 0 == CreateNumber then
    return
  else
    Boundary = CurrentIndex + CreateNumber
    local SceneID = SceneUtils.GetSceneID()
    if 0 == SceneID then
      self:GeneratePetsChaosTwoDirection(true)
      self:ClosePanel()
    else
      local Context = DialogContext()
      Context:SetContent("\229\156\168\230\184\184\230\136\143\229\156\186\230\153\175\228\184\173\231\148\159\230\136\144\230\137\128\230\156\137NPC\228\188\154\233\128\160\230\136\144\230\184\184\230\136\143\229\141\161\233\161\191\239\188\140\232\175\183\231\161\174\232\174\164\230\152\175\229\144\166\232\166\129\231\148\159\230\136\144")
      Context:SetMode(DialogContext.Mode.OK_CANCEL)
      Context:SetClickAnywhereClose(true)
      Context:SetCloseOnCancel(true)
      Context:SetCloseOnOK(true)
      Context:SetButtonText("\231\148\159\230\136\144\239\188\129", "\231\174\151\228\186\134")
      Context:SetCallback(self, self.GeneratePetsChaosTwoDirection)
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
    end
  end
end

function DebugTabPetModel:BackwardCreatChaosTwo(name, Panel)
  if 0 == #AllPetForIndex then
    self:InitPetTable()
  end
  if CurrentPet then
    self:DestroyPet()
  end
  Direction = false
  CreateNumber = Panel:GetInputNumber()
  if 0 == CreateNumber then
    return
  else
    Boundary = CurrentIndex - CreateNumber
    local SceneID = SceneUtils.GetSceneID()
    if 0 == SceneID then
      self:GeneratePetsChaosTwoDirection(true)
      self:ClosePanel()
    else
      local Context = DialogContext()
      Context:SetContent("\229\156\168\230\184\184\230\136\143\229\156\186\230\153\175\228\184\173\231\148\159\230\136\144\230\137\128\230\156\137NPC\228\188\154\233\128\160\230\136\144\230\184\184\230\136\143\229\141\161\233\161\191\239\188\140\232\175\183\231\161\174\232\174\164\230\152\175\229\144\166\232\166\129\231\148\159\230\136\144")
      Context:SetMode(DialogContext.Mode.OK_CANCEL)
      Context:SetClickAnywhereClose(true)
      Context:SetCloseOnCancel(true)
      Context:SetCloseOnOK(true)
      Context:SetButtonText("\231\148\159\230\136\144\239\188\129", "\231\174\151\228\186\134")
      Context:SetCallback(self, self.GeneratePetsChaosTwoDirection)
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
    end
  end
end

function DebugTabPetModel:GeneratePetsShiningDirection(Confirm)
  if not Confirm then
    return
  end
  local Player = self:GetPlayer()
  local Center = Player:GetActorLocation()
  self:SpawnPetShiningDirection(AllPetForIndex, CurrentIndex, Center, 0)
end

function DebugTabPetModel:GeneratePetsGlassDirection(Confirm)
  if not Confirm then
    return
  end
  local Player = self:GetPlayer()
  local Center = Player:GetActorLocation()
  self:SpawnPetGlassDirection(AllPetForIndex, CurrentIndex, Center, 0)
end

function DebugTabPetModel:GeneratePetsChaosDirection(Confirm)
  if not Confirm then
    return
  end
  local Player = self:GetPlayer()
  local Center = Player:GetActorLocation()
  self:SpawnPetChaosDirection(AllPetForIndex, CurrentIndex, Center, 0)
end

function DebugTabPetModel:GeneratePetsChaosTwoDirection(Confirm)
  if not Confirm then
    return
  end
  local Player = self:GetPlayer()
  local Center = Player:GetActorLocation()
  self:SpawnPetChaosTwoDirection(AllPetForIndex, CurrentIndex, Center, 0)
end

function DebugTabPetModel:SpawnPetShiningDirection(All, Index, Center, Angle)
  if Index <= 0 then
    return
  end
  if Index > #All then
    return
  end
  if Direction then
    if Index >= Boundary then
      CurrentIndex = Index
      return
    end
  elseif Index <= Boundary then
    CurrentIndex = Index
    return
  end
  local Radius = 200 + Index * 5
  Angle = Angle + 400 / Radius / math.pi
  local Klass = _G.NRCResourceManager:LoadForDebugOnly(All[Index])
  if Klass then
    local DX = Radius * math.cos(Angle)
    local DY = Radius * math.sin(Angle)
    local Transform = UE4.FTransform(UE4.FQuat(), UE.FVector(Center.X + DX, Center.Y + DY, Center.Z + 500))
    local World = self:GetWorld()
    self.Actor = World:SpawnActor(Klass, Transform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, nil, nil)
    self.Actor:Abs_K2_SetActorLocation_WithoutHit(UE.FVector(Center.X + DX, Center.Y + DY, Center.Z + 500))
    if self.Actor and self.Actor.InitOutSceneAsync then
      self.Actor:InitOutSceneAsync(self, self.OnViewLoadedShining)
      local Root = self.Actor:K2_GetRootComponent()
      Root.bHiddenInGame = false
      self.Actor:SetActorEnableCollision(false)
      local Location = self.Actor:GetNearLandLocation()
      if not Location then
        Log.Error("\231\148\159\230\136\144\229\174\160\231\137\169\228\184\173\230\150\173\228\186\134!!")
        return
      end
      Location.Z = Location.Z + self.Actor:GetHalfHeight()
      self.Actor:SetActorLocation(Location)
      local LookAt = Center - Location
      LookAt.Z = 0
      self.Actor:K2_SetActorRotation(LookAt:ToRotator():Clamp(), true)
      table.insert(CurrentPet, self.Actor)
    else
      Log.Error("Actor\231\148\159\230\136\144\229\164\177\232\180\165", All[Index])
    end
  else
    Log.Error("Class\229\138\160\232\189\189\229\164\177\232\180\165", All[Index])
  end
  if Direction then
    if Index + 1 > #All then
      Log.Error("\229\174\140\230\136\144\230\137\128\230\156\137\231\154\132\229\174\160\231\137\169\231\148\159\230\136\144", Index)
      return
    end
    _G.DelayManager:DelayFrames(1, self.SpawnPetShiningDirection, self, AllPetForIndex, Index + 1, Center, Angle)
  else
    if Index - 1 < 1 then
      Log.Error("\229\174\140\230\136\144\230\137\128\230\156\137\231\154\132\229\174\160\231\137\169\231\148\159\230\136\144", Index)
      return
    end
    _G.DelayManager:DelayFrames(1, self.SpawnPetShiningDirection, self, AllPetForIndex, Index - 1, Center, Angle)
  end
end

function DebugTabPetModel:SpawnPetGlassDirection(All, Index, Center, Angle)
  if Index <= 0 then
    return
  end
  if Index > #All then
    return
  end
  if Direction then
    if Index >= Boundary then
      CurrentIndex = Index
      return
    end
  elseif Index <= Boundary then
    CurrentIndex = Index
    return
  end
  local Radius = 200 + Index * 5
  Angle = Angle + 400 / Radius / math.pi
  local Klass = _G.NRCResourceManager:LoadForDebugOnly(All[Index])
  if Klass then
    local DX = Radius * math.cos(Angle)
    local DY = Radius * math.sin(Angle)
    local Transform = UE4.FTransform(UE4.FQuat(), UE.FVector(Center.X + DX, Center.Y + DY, Center.Z + 500))
    local World = self:GetWorld()
    self.Actor = World:SpawnActor(Klass, Transform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, nil, nil)
    self.Actor:Abs_K2_SetActorLocation_WithoutHit(UE.FVector(Center.X + DX, Center.Y + DY, Center.Z + 500))
    if self.Actor and self.Actor.InitOutSceneAsync then
      self.Actor:InitOutSceneAsync(self, self.OnViewLoadedGlass)
      local Root = self.Actor:K2_GetRootComponent()
      Root.bHiddenInGame = false
      self.Actor:SetActorEnableCollision(false)
      local Location = self.Actor:GetNearLandLocation()
      if not Location then
        Log.Error("\231\148\159\230\136\144\229\174\160\231\137\169\228\184\173\230\150\173\228\186\134!!")
        return
      end
      Location.Z = Location.Z + self.Actor:GetHalfHeight()
      self.Actor:SetActorLocation(Location)
      local LookAt = Center - Location
      LookAt.Z = 0
      self.Actor:K2_SetActorRotation(LookAt:ToRotator():Clamp(), true)
      table.insert(CurrentPet, self.Actor)
    else
      Log.Error("Actor\231\148\159\230\136\144\229\164\177\232\180\165", All[Index])
    end
  else
    Log.Error("Class\229\138\160\232\189\189\229\164\177\232\180\165", All[Index])
  end
  if Direction then
    if Index + 1 > #All then
      Log.Error("\229\174\140\230\136\144\230\137\128\230\156\137\231\154\132\229\174\160\231\137\169\231\148\159\230\136\144", Index)
      return
    end
    _G.DelayManager:DelayFrames(1, self.SpawnPetGlassDirection, self, AllPetForIndex, Index + 1, Center, Angle)
  else
    if Index - 1 < 1 then
      Log.Error("\229\174\140\230\136\144\230\137\128\230\156\137\231\154\132\229\174\160\231\137\169\231\148\159\230\136\144", Index)
      return
    end
    _G.DelayManager:DelayFrames(1, self.SpawnPetGlassDirection, self, AllPetForIndex, Index - 1, Center, Angle)
  end
end

function DebugTabPetModel:SpawnPetChaosDirection(All, Index, Center, Angle)
  if Index <= 0 then
    return
  end
  if Index > #All then
    return
  end
  if Direction then
    if Index >= Boundary then
      CurrentIndex = Index
      return
    end
  elseif Index <= Boundary then
    CurrentIndex = Index
    return
  end
  local Radius = 200 + Index * 5
  Angle = Angle + 400 / Radius / math.pi
  local Klass = _G.NRCResourceManager:LoadForDebugOnly(All[Index])
  if Klass then
    local DX = Radius * math.cos(Angle)
    local DY = Radius * math.sin(Angle)
    local Transform = UE4.FTransform(UE4.FQuat(), UE.FVector(Center.X + DX, Center.Y + DY, Center.Z + 500))
    local World = self:GetWorld()
    self.Actor = World:SpawnActor(Klass, Transform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, nil, nil)
    self.Actor:Abs_K2_SetActorLocation_WithoutHit(UE.FVector(Center.X + DX, Center.Y + DY, Center.Z + 500))
    if self.Actor and self.Actor.InitOutSceneAsync then
      self.Actor:InitOutSceneAsync(self, self.OnViewLoadedChaos)
      local Root = self.Actor:K2_GetRootComponent()
      Root.bHiddenInGame = false
      self.Actor:SetActorEnableCollision(false)
      local Location = self.Actor:GetNearLandLocation()
      if not Location then
        Log.Error("\231\148\159\230\136\144\229\174\160\231\137\169\228\184\173\230\150\173\228\186\134!!")
        return
      end
      Location.Z = Location.Z + self.Actor:GetHalfHeight()
      self.Actor:SetActorLocation(Location)
      local LookAt = Center - Location
      LookAt.Z = 0
      self.Actor:K2_SetActorRotation(LookAt:ToRotator():Clamp(), true)
      table.insert(CurrentPet, self.Actor)
    else
      Log.Error("Actor\231\148\159\230\136\144\229\164\177\232\180\165", All[Index])
    end
  else
    Log.Error("Class\229\138\160\232\189\189\229\164\177\232\180\165", All[Index])
  end
  if Direction then
    if Index + 1 > #All then
      Log.Error("\229\174\140\230\136\144\230\137\128\230\156\137\231\154\132\229\174\160\231\137\169\231\148\159\230\136\144", Index)
      return
    end
    _G.DelayManager:DelayFrames(1, self.SpawnPetChaosDirection, self, AllPetForIndex, Index + 1, Center, Angle)
  else
    if Index - 1 < 1 then
      Log.Error("\229\174\140\230\136\144\230\137\128\230\156\137\231\154\132\229\174\160\231\137\169\231\148\159\230\136\144", Index)
      return
    end
    _G.DelayManager:DelayFrames(1, self.SpawnPetChaosDirection, self, AllPetForIndex, Index - 1, Center, Angle)
  end
end

function DebugTabPetModel:SpawnPetChaosTwoDirection(All, Index, Center, Angle)
  if Index <= 0 then
    return
  end
  if Index > #All then
    return
  end
  if Direction then
    if Index >= Boundary then
      CurrentIndex = Index
      return
    end
  elseif Index <= Boundary then
    CurrentIndex = Index
    return
  end
  local Radius = 200 + Index * 5
  Angle = Angle + 400 / Radius / math.pi
  local Klass = _G.NRCResourceManager:LoadForDebugOnly(All[Index])
  if Klass then
    local DX = Radius * math.cos(Angle)
    local DY = Radius * math.sin(Angle)
    local Transform = UE4.FTransform(UE4.FQuat(), UE.FVector(Center.X + DX, Center.Y + DY, Center.Z + 500))
    local World = self:GetWorld()
    self.Actor = World:SpawnActor(Klass, Transform, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, nil, nil)
    self.Actor:Abs_K2_SetActorLocation_WithoutHit(UE.FVector(Center.X + DX, Center.Y + DY, Center.Z + 500))
    if self.Actor and self.Actor.InitOutSceneAsync then
      self.Actor:InitOutSceneAsync(self, self.OnViewLoadedChaosTwo)
      local Root = self.Actor:K2_GetRootComponent()
      Root.bHiddenInGame = false
      self.Actor:SetActorEnableCollision(false)
      local Location = self.Actor:GetNearLandLocation()
      if not Location then
        Log.Error("\231\148\159\230\136\144\229\174\160\231\137\169\228\184\173\230\150\173\228\186\134!!")
        return
      end
      Location.Z = Location.Z + self.Actor:GetHalfHeight()
      self.Actor:SetActorLocation(Location)
      local LookAt = Center - Location
      LookAt.Z = 0
      self.Actor:K2_SetActorRotation(LookAt:ToRotator():Clamp(), true)
      table.insert(CurrentPet, self.Actor)
    else
      Log.Error("Actor\231\148\159\230\136\144\229\164\177\232\180\165", All[Index])
    end
  else
    Log.Error("Class\229\138\160\232\189\189\229\164\177\232\180\165", All[Index])
  end
  if Direction then
    if Index + 1 > #All then
      Log.Error("\229\174\140\230\136\144\230\137\128\230\156\137\231\154\132\229\174\160\231\137\169\231\148\159\230\136\144", Index)
      return
    end
    _G.DelayManager:DelayFrames(1, self.SpawnPetChaosTwoDirection, self, AllPetForIndex, Index + 1, Center, Angle)
  else
    if Index - 1 < 1 then
      Log.Error("\229\174\140\230\136\144\230\137\128\230\156\137\231\154\132\229\174\160\231\137\169\231\148\159\230\136\144", Index)
      return
    end
    _G.DelayManager:DelayFrames(1, self.SpawnPetChaosTwoDirection, self, AllPetForIndex, Index - 1, Center, Angle)
  end
end

function DebugTabPetModel:DestroyPet()
  for _, v in pairs(CurrentPet) do
    v:K2_DestroyActor()
  end
end

function DebugTabPetModel:OnViewLoadedShining()
  PetMutationUtils.DoMutationForTest(self.Actor, _G.Enum.MutationDiffType.MDT_SHINING)
end

function DebugTabPetModel:OnViewLoadedGlass()
  PetMutationUtils.DoMutationForTest(self.Actor, _G.Enum.MutationDiffType.MDT_GLASS)
end

function DebugTabPetModel:OnViewLoadedChaos()
  PetMutationUtils.DoMutationForTest(self.Actor, _G.Enum.MutationDiffType.MDT_CHAOS)
end

function DebugTabPetModel:OnViewLoadedChaosTwo()
  PetMutationUtils.DoMutationForTest(self.Actor, _G.Enum.MutationDiffType.MDT_CHAOS_TWO)
end

function DebugTabPetModel:InitPetTable()
  local ListOfAssets = UE.TArray("")
  UE.UNRCStatics.ListFolder("/Game/ArtRes/BP/Pets", ListOfAssets, true)
  for _, Path in tpairs(ListOfAssets) do
    local Segs = string.split(Path, "/")
    if 7 == #Segs and string.StartsWith(Segs[7], "BP_") and "/Game/ArtRes/BP/Pets/Fir_HuoYu3_001/BP_NewRide_HuoYu.BP_NewRide_HuoYu" ~= Path then
      table.insert(AllPetForIndex, Path)
    end
  end
end

return DebugTabPetModel
