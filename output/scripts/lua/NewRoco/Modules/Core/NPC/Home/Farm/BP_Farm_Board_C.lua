require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local FarmModuleEnum = require("NewRoco.Modules.System.Farm.FarmModuleEnum")
local PetHUDComponent = require("NewRoco.Modules.Core.Scene.Component.HUD.PetHUDComponent")
local BP_Farm_Board_C = Base:Extend("BP_Farm_Board_C")

function BP_Farm_Board_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_Farm_Board_C:Init()
  Base.Init(self)
end

function BP_Farm_Board_C:OnFrameLoad(distanceRatio)
  if not SceneUtils.debugCloseNPCFacialAndWidget then
    local Character = self.sceneCharacter
    if Character then
      local hud = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetHudFromPool, "UMG_Hud_Pet")
      if not hud then
        local hudClass = _G.NRCBigWorldPreloader:Get("PET_HUD")
        hud = UE4.UWidgetBlueprintLibrary.Create(self, hudClass)
      end
      Log.Debug("BP_Farm_Entrance_C:OnFrameLoad SetWidget")
      if UE.UObject.IsValid(hud) and self.HeadWidget then
        self.HeadWidget:SetWidget(hud)
        hud:SetParentHUD(self.HeadWidget)
      end
      Character:EnsureComponent(PetHUDComponent)
      if Character.PetHUDComponent then
        Character.PetHUDComponent:OnFrameLoaded()
      end
    end
  end
  Base.OnFrameLoad(self, distanceRatio)
end

function BP_Farm_Board_C:OnLoadResource()
  Base.OnLoadResource(self)
end

function BP_Farm_Board_C:OnVisible()
  Base.OnVisible(self)
  self:FixCoord(true, true)
  self:RefreshUnlockState()
end

function BP_Farm_Board_C:SetSceneCharacter(sceneCharacter)
  if sceneCharacter then
    Base.SetSceneCharacter(self, sceneCharacter)
    self:Register()
  else
    self:Unregister()
    Base.SetSceneCharacter(self, sceneCharacter)
  end
end

function BP_Farm_Board_C:Register()
  if not self.sceneCharacter then
    return
  end
  if not self.resourceLoaded then
    return
  end
end

function BP_Farm_Board_C:Unregister()
  if not self.sceneCharacter then
    return
  end
end

function BP_Farm_Board_C:OnLogicStatusChange(ChangeInfo)
  if not ChangeInfo or ChangeInfo.changed_status.status ~= _G.Enum.SpaceActorLogicStatus.SALS_HOME_PLANT_UNLOCK_LAND then
    return
  end
  if not self.sceneCharacter then
    return
  end
  self:RefreshUnlockState()
end

function BP_Farm_Board_C:RefreshUnlockState()
  if self.NRCChildActor ~= nil and nil ~= self.sceneCharacter then
    local child = self.NRCChildActor:GetChildActor()
    if child and UE.UObject.IsValid(child) then
      if SceneUtils.IsLogicStatusPlantUnlockLand(self.sceneCharacter) then
        child:SetUnlockState()
      else
        child:SetLockState()
      end
    end
  end
  if self.sceneCharacter and self.sceneCharacter.PetHUDComponent then
    self.sceneCharacter.PetHUDComponent:OnRefreshFarmNpcStatus(FarmModuleEnum.NPCType.Board, SceneUtils.IsLogicStatusPlantUnlockLand(self.sceneCharacter))
  end
end

return BP_Farm_Board_C
