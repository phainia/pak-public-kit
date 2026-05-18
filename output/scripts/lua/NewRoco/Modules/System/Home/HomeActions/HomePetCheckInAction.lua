local HomePetCheckInAction = Class("HomePetChcekInAction")

function HomePetCheckInAction:Ctor(owner, actionType, ownerNpc)
  self.owner = owner
  self.ownerNpc = ownerNpc
end

function HomePetCheckInAction:Execute()
  if not (self.owner and self.ownerNpc) or not self.ownerNpc.furnitureId then
    return
  end
  local petInfo = _G.DataModelMgr.PlayerDataModel:HasPet()
  if not petInfo then
    Log.PrintScreenMsgRed("no pet with player, stop showing petCheckIn")
    return
  end
  Log.Debug("HomePetCheckInAction Execute")
  _G.NRCModuleManager:DoCmd(HomeModuleCmd.OnCmdOpenPanel, "HomePetChoosing", true, self.ownerNpc.furnitureId)
  local PropsData = HomeIndoorSandbox.HomePropsServ:GetPropsDataById(self.ownerNpc.furnitureId)
  HomeIndoorSandbox.HomePropsServ:RequestPropsCamera(PropsData, true)
  _G.NRCEventCenter:RegisterEvent("HomePetCheckInAction", self, _G.NRCPanelEvent.ClosePanel, self.OnClosePanel)
end

function HomePetCheckInAction:OnClosePanel(PanelData)
  local Name = PanelData.panelName
  if "HomePetChoosing" == Name then
    HomeIndoorSandbox.HomePropsServ:ReleasePropsCamera()
    _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCPanelEvent.ClosePanel, self.OnClosePanel)
  end
  self.owner:OnPlayerLeaveActionArea()
end

return HomePetCheckInAction
