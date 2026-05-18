local PGCModule = NRCModuleBase:Extend("PGCModule")
local PGCModuleEvent = require("NewRoco.Modules.System.PGC.PGCModuleEvent")
local PGCModuleCmd = reload("NewRoco.Modules.System.PGC.PGCModuleCmd")

function PGCModule:OnConstruct()
  self.data = self:SetData("PGCModuleData", "NewRoco.Modules.System.PGC.PGCModuleData")
  self:RegPanel("MainView", "/Game/NewRoco/Modules/System/PGC/Res/UMG_MainView", _G.Enum.UILayerType.UI_LAYER_MAIN, "In", "Out")
end

function PGCModule:OnDestruct()
end

function PGCModule:OnActive()
end

function PGCModule:OnDeactive()
end

function PGCModule:RegPanel(name, path, layer, openAnimName, closeAnimName, enablePcEsc, customDisableRendering)
  local registerData = _G.NRCPanelRegisterData()
  registerData.panelName = name
  registerData.panelPath = path
  registerData.panelLayer = layer
  registerData.openAnimName = openAnimName
  registerData.closeAnimName = closeAnimName
  registerData.enablePcEsc = enablePcEsc or false
  registerData.customDisableRendering = customDisableRendering or false
  self:RegisterPanel(registerData)
end

function PGCModule:CreateDataWidget(Text)
  local Path = "/Game/NewRoco/Modules/System/Debug/Res/UMG_DebugLabel"
  local CurrentWorld = _G.UE4Helper.GetCurrentWorld()
  local WidgetClass = UE4.UClass.Load(Path)
  local WidgetInstance = UE4.UWidgetBlueprintLibrary.Create(CurrentWorld, WidgetClass)
  WidgetInstance.Label:SetText(Text)
  return WidgetInstance
end

function PGCModule:OnOpenMainView()
  self:OpenPanel(PGCModuleEnum.PanelNames.MainView)
end

function PGCModule:OnCloseMainView()
  self:ClosePanel(PGCModuleEnum.PanelNames.MainView)
end

function PGCModule:OnLoadDataList(dataType)
  local mainView = self:GetPanel(PGCModuleEnum.PanelNames.MainView)
  local ListData = PGCModuleData:GetDataList(dataType, mainView)
  if not ListData then
    return
  end
  local dataList = mainView and mainView.DataList
  if not dataList then
    return
  end
  dataList:InitList(ListData)
  if dataType == PGCModuleEnum.DataType.NPCType and #ListData > 0 then
    local firstData = ListData[1]
    self:OnShowDataDetail(firstData)
  end
end

function PGCModule:OnShowDataDetail(data)
  local mainView = self:GetPanel(PGCModuleEnum.PanelNames.MainView)
  local dataDetail = mainView and mainView.DataDetail
  if not dataDetail then
    return
  end
  dataDetail:ClearChildren()
  local TestWidget = self:CreateDataWidget("\230\149\176\230\141\174\229\144\141\231\167\176: " .. data.name)
  dataDetail:AddChild(TestWidget)
end

function PGCModule:OnSimulateServerNPCEnter(npcId)
  local rsp = ProtoMessage:newZoneScenePlayActsNotify()
  ZoneServer:BroadcastProcotolEvent(0, ProtoCMD.ZoneSvrCmd.ZONE_SCENE_PLAY_ACTS_NOTIFY, rsp)
end

function PGCModule:OnSimulateServerNPCLeave(npcGid)
  local rsp = ProtoMessage:newZoneScenePlayActsNotify()
  ZoneServer:BroadcastProcotolEvent(0, ProtoCMD.ZoneSvrCmd.ZONE_SCENE_PLAY_ACTS_NOTIFY, rsp)
end

function PGCModule:OnSimulateServerNextAction(npcGid)
end

function PGCModule:OnAddDataItem()
  self:OnSimulateServerNPCEnter(580001)
end

function PGCModule:OnRemoveDataItem()
end

function PGCModule:OnModifyDataItem()
end

return PGCModule
