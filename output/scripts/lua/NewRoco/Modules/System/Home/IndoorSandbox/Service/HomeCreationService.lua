local HomeCreationService = Class("HomeCreationService")

function HomeCreationService:Ctor()
end

function HomeCreationService:OnExitHome()
end

function HomeCreationService:EnterFurnitureCreation(ProtoData, ExtraInfo)
  ExtraInfo = ExtraInfo or {}
  HomeIndoorSandbox.Module.data:EvalCollectBagFurnitureItemInfo()
  if ProtoData then
    self:OnCreationConditionReady(ExtraInfo, true, ProtoData)
  else
    local PanelData = HomeIndoorSandbox.Module:GetPanelData("HomeFurnitureCreation")
    NRCPanelManager:PreloadPanel(PanelData.panelPath)
    HomeIndoorSandbox.Server:ReqFurnitureCreationList(FPartial(self.OnCreationConditionReady, self, ExtraInfo))
  end
end

function HomeCreationService:OnCreationConditionReady(ExtraInfo, bSuccess, BuildListRsp)
  if bSuccess and HomeIndoorSandbox:InHomeIndoor() then
    HomeIndoorSandbox.Module:OpenPanel("HomeFurnitureCreation", BuildListRsp, ExtraInfo)
  end
end

return HomeCreationService
