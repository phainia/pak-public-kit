local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local ScenePlayerPet = require("NewRoco.Modules.Core.Scene.Actor.ScenePlayerPet")
local Base = DebugTabBase
local DebugTabRideAll = Base:Extend("DebugTabRideAll")

function DebugTabRideAll:SetupTabs()
  self:Add("\229\136\135\230\141\162\229\144\141\231\137\135\230\140\130\232\189\189\230\150\185\229\188\143", self.SwitchHud, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\230\137\147\229\141\176\229\189\147\229\137\141\230\143\146\230\167\189", self.PrintCurSocket, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\233\130\128\232\175\183\229\143\140\228\186\186\233\170\145\228\185\152", self.GMDoubleRide, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add("\229\136\135\230\141\162\230\148\128\231\128\145\228\191\161\230\129\175\230\152\190\231\164\186", self.ToggleClimbWaterFallDebugInfo, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  local RideAllTab = DataConfigManager:GetTable(DataConfigManager.ConfigTableId.ALL_RIDE_PET):GetAllDatas()
  for index, PetConf in pairs(RideAllTab) do
    self:Add(PetConf.editor_name, function()
      self:DebugRide(PetConf.id, PetConf.animation_name)
    end, self, nil, "\231\168\139\229\186\143\231\173\150\229\136\146\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "\229\136\135\230\141\162\230\152\190\231\164\186\229\157\144\233\170\145")
  end
end

function DebugTabRideAll:SwitchHud()
  if 1 == GlobalConfig.RideHudType then
    GlobalConfig.RideHudType = 2
  else
    GlobalConfig.RideHudType = 1
  end
end

function DebugTabRideAll:DrawRideCollision()
  GlobalConfig.DrawRideCollision = not GlobalConfig.DrawRideCollision
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  player.viewObj.BP_RideComponent:UpdateDrawDebugFlag()
end

function DebugTabRideAll:DebugRide(index, name)
  local AbilityHelperManager = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelperManager")
  local helper = AbilityHelperManager.GetHelper(AbilityID.RIDE_ALL)
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local ScenePet = ScenePlayerPet(nil, index, -ProtoEnum.SceneRideAllCustomGid.SRCG_LocalTest, player)
  local errorCode = helper:CanCastAbility(player, ScenePet)
  UE4.UNRCStatics.ClipboardCopy(name)
  if 0 == errorCode or 8 == errorCode or GlobalConfig.bForceRidePet then
    helper:HandleStatus(player, ScenePet)
  else
    Log.Error("\229\143\172\229\148\164\230\157\161\228\187\182\233\157\158\230\179\149")
  end
end

function DebugTabRideAll:GMDoubleRide(Name, Panel, inputText)
  local InputText
  if Panel then
    InputText = Panel.InputBox:GetText()
  else
    InputText = inputText
  end
  if nil == InputText or "" == InputText then
    Log.Error("Need Input: AttrType(from common_data.proto) Numer")
    return
  end
  _G.NRCModuleManager:DoCmd(FriendModuleCmd.ReqZonePlayerInteract, tonumber(InputText), ProtoEnum.PlayerInteractType.DoubleRide)
end

function DebugTabRideAll:SwitchForceRide()
  GlobalConfig.bForceRidePet = not GlobalConfig.bForceRidePet
  if GlobalConfig.bForceRidePet then
    Log.Warning("\229\191\189\231\149\165\230\157\161\228\187\182\229\188\186\229\136\182\229\143\172\229\148\164")
  else
    Log.Warning("\229\188\128\229\144\175\229\143\172\229\148\164\230\157\161\228\187\182\230\163\128\230\181\139")
  end
end

function DebugTabRideAll:SwitchForceFly()
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local comp = player.viewObj.BP_RideComponent
  comp.bForceFly = not comp.bForceFly
  if comp.bForceFly then
    Log.Warning("\229\144\175\231\148\168\229\188\186\229\136\182\233\163\158\232\161\140\239\188\140\228\188\154\229\142\159\229\156\176\229\188\185\233\163\15850m")
  else
    Log.Warning("\229\133\179\233\151\173\229\188\186\229\136\182\233\163\158\232\161\140")
  end
end

function DebugTabRideAll:ShowMoveInfo()
  GlobalConfig.bShowRideAllMoveInfo = not GlobalConfig.bShowRideAllMoveInfo
end

function DebugTabRideAll:PrintCurSocket()
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player and player.viewObj then
    local comp = player.viewObj.BP_RideComponent
    if comp and comp.RidePet then
      Log.Error("\229\189\147\229\137\141\233\170\145\228\185\152\231\154\132\230\143\146\230\167\189\230\152\175\239\188\154" .. comp.SocketName_Head .. " \230\158\154\228\184\190\229\128\188\228\184\186\239\188\154" .. comp.SocketType)
    end
  end
end

function DebugTabRideAll:ToggleClimbWaterFallDebugInfo()
  local isShown = UE4.UNRCStatics.GetAutoConsoleVarInt("CharacterMovement.ShowDebugInfoClimbWaterFall")
  UE4.UNRCStatics.ExecConsoleCommand("CharacterMovement.ShowDebugInfoClimbWaterFall " .. (0 == isShown and "1" or "0"))
end

return DebugTabRideAll
