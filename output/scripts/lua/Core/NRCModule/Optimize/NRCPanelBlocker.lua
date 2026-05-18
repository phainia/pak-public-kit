local NRCPanelBlocker = NRCClass:Extend("BattleEventCenter")
_G.PanelBlockerType = {
  Center = {
    0,
    0,
    0,
    0.1,
    0.45,
    0.19
  },
  HalfRight = {
    0,
    -35,
    0,
    0.1,
    0.34,
    0.47
  }
}

function NRCPanelBlocker:Init()
  self.ScreenSize = UE4.UWidgetLayoutLibrary.GetViewportSize(UE4Helper.GetCurrentWorld())
  self.DefaultScreenSizeX = 2340
  self.DefaultScreenSizeY = 1080
  local factor = self.DefaultScreenSizeX / self.DefaultScreenSizeY
  local screenFactor = self.ScreenSize.X / self.ScreenSize.Y
  if screenFactor - factor < 0.1 then
    self.isEnable = true
  else
    self.isEnable = false
  end
  self.isEnable = false
  if self.isEnable then
    self.blockerPath = "/Game/NewRoco/TUI/BP_TUIBlocker.BP_TUIBlocker_C"
    self:LoadBlocker()
    self.blocker = nil
    self.registedData = {}
    self:RegisterPanel("UMG_Map_RecoveryTime", _G.PanelBlockerType.Center)
    self:RegisterPanel("LevelMain", _G.PanelBlockerType.HalfRight)
    self:RegisterPanel("SleepingOwlPanel", _G.PanelBlockerType.HalfRight)
    self:RegisterPanel("PetAltarPanel", _G.PanelBlockerType.HalfRight)
    self:RegisterPanel("ItemAltarPanel", _G.PanelBlockerType.HalfRight)
  end
end

function NRCPanelBlocker:LoadBlocker()
  local resRequest = NRCResourceManager:LoadResAsync(self, self.blockerPath, _G.PriorityEnum.UI_Panel_Blocker, 0, function(caller, resRequest, asset)
    self.blockerCla = asset
    local rotation = UE4.FQuat.FromAxisAndAngle(UE4Helper.ZeroVector, 0)
    local xfm = UE4.FTransform(rotation, _G.FVectorZero, _G.FVectorOne)
    self.blocker = UE4Helper.GetCurrentWorld():Abs_SpawnActor(self.blockerCla, xfm, UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn)
    Log.Debug("show me blocker:", self.blocker, self.blockerCla)
  end, function(caller, resRequest, errMsg)
  end, nil)
end

function NRCPanelBlocker:RegisterPanel(panelName, blockType)
  self.registedData[panelName] = blockType
end

function NRCPanelBlocker:StartBlockWithRegisted(panelName)
  if not self.isEnable then
    return
  end
  Log.Debug("StartBlockWithRegisted:", panelName)
  if self.blocker then
    local blockType = self.registedData[panelName]
    if not blockType then
      return
    end
    self.blocker:StartBlock(blockType)
  end
end

function NRCPanelBlocker:StopBlock()
  if not self.isEnable then
    return
  end
  if self.blocker then
    local component = self.blocker:GetComponentByClass(UE.UStaticMeshComponent)
    component:SetVisibility(false)
  end
end

return NRCPanelBlocker
