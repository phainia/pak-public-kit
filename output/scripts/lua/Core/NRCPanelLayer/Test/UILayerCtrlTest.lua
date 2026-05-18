local UILayerCtrlTest = {}

function UILayerCtrlTest.TestOpenPanel(PanelData)
  local LoginModule = NRCModuleManager:GetModule("LoginModule")
  if LoginModule.panelDataDict[PanelData.panelName] then
  else
    LoginModule:RegisterPanel(PanelData)
  end
  LoginModule:OpenPanel(PanelData.panelName)
end

function UILayerCtrlTest.TestClosePanel(PanelName)
  local LoginModule = NRCModuleManager:GetModule("LoginModule")
  LoginModule:ClosePanel(PanelName)
end

function UILayerCtrlTest.ClickTest()
  Log.Debug("UILayerCtrlTest ClickTest")
  if UILayerCtrlTest._testUICount == nil then
    UILayerCtrlTest._testUICount = 0
  end
  local panelData
  local count = UILayerCtrlTest._testUICount
  if 0 == count then
    panelData = _G.NRCPanelRegisterData()
    panelData.panelName = "UMG_Test_Main_Blue"
    panelData.panelPath = "/Game/NewRoco/Modules/System/TestLayerCtrl/UMG_Test_Main_Blue"
    panelData.panelLayer = Enum.UILayerType.UI_LAYER_MAIN
    UILayerCtrlTest.TestOpenPanel(panelData)
  elseif 1 == count then
    panelData = _G.NRCPanelRegisterData()
    panelData.panelName = "UMG_Test_Main_Green"
    panelData.panelPath = "/Game/NewRoco/Modules/System/TestLayerCtrl/UMG_Test_Main_Green"
    panelData.panelLayer = Enum.UILayerType.UI_LAYER_MAIN
    UILayerCtrlTest.TestOpenPanel(panelData)
  elseif 2 == count then
    panelData = _G.NRCPanelRegisterData()
    panelData.panelName = "UMG_Test_Full_Red"
    panelData.panelPath = "/Game/NewRoco/Modules/System/TestLayerCtrl/UMG_Test_Full_Red"
    panelData.panelLayer = Enum.UILayerType.UI_LAYER_FULLSCREEN
    UILayerCtrlTest.TestOpenPanel(panelData)
  elseif 3 == count then
    panelData = _G.NRCPanelRegisterData()
    panelData.panelName = "UMG_Test_Full_Yellow"
    panelData.panelPath = "/Game/NewRoco/Modules/System/TestLayerCtrl/UMG_Test_Full_Yellow"
    panelData.panelLayer = Enum.UILayerType.UI_LAYER_FULLSCREEN
    UILayerCtrlTest.TestOpenPanel(panelData)
  elseif 4 == count then
    UILayerCtrlTest.TestClosePanel("UMG_Test_Full_Yellow")
  elseif 5 == count then
    panelData = _G.NRCPanelRegisterData()
    panelData.panelName = "UMG_Test_Pop_Grape"
    panelData.panelPath = "/Game/NewRoco/Modules/System/TestLayerCtrl/UMG_Test_Pop_Grape"
    panelData.panelLayer = Enum.UILayerType.UI_LAYER_POPUP
    UILayerCtrlTest.TestOpenPanel(panelData)
  elseif 6 == count then
    panelData = _G.NRCPanelRegisterData()
    panelData.panelName = "UMG_Test_Pop_Oringe"
    panelData.panelPath = "/Game/NewRoco/Modules/System/TestLayerCtrl/UMG_Test_Pop_Oringe"
    panelData.panelLayer = Enum.UILayerType.UI_LAYER_POPUP
    UILayerCtrlTest.TestOpenPanel(panelData)
  elseif 7 == count then
    UILayerCtrlTest.TestClosePanel("UMG_Test_Pop_Oringe")
  elseif 8 == count then
    panelData = _G.NRCPanelRegisterData()
    panelData.panelName = "UMG_Test_Pop_Oringe"
    panelData.panelPath = "/Game/NewRoco/Modules/System/TestLayerCtrl/UMG_Test_Pop_Oringe"
    panelData.panelLayer = Enum.UILayerType.UI_LAYER_POPUP
    UILayerCtrlTest.TestOpenPanel(panelData)
  elseif 9 == count then
    panelData = _G.NRCPanelRegisterData()
    panelData.panelName = "UMG_Test_Full_Yellow"
    panelData.panelPath = "/Game/NewRoco/Modules/System/TestLayerCtrl/UMG_Test_Full_Yellow"
    panelData.panelLayer = Enum.UILayerType.UI_LAYER_FULLSCREEN
    UILayerCtrlTest.TestOpenPanel(panelData)
  elseif 10 == count then
    panelData = _G.NRCPanelRegisterData()
    panelData.panelName = "UMG_Test_Pop_gray"
    panelData.panelPath = "/Game/NewRoco/Modules/System/TestLayerCtrl/UMG_Test_Pop_gray"
    panelData.panelLayer = Enum.UILayerType.UI_LAYER_POPUP
    UILayerCtrlTest.TestOpenPanel(panelData)
  elseif 11 == count then
    UILayerCtrlTest.TestClosePanel("UMG_Test_Full_Yellow")
  elseif 12 == count then
    UILayerCtrlTest.TestClosePanel("UMG_Test_Pop_gray")
  elseif 13 == count then
    UILayerCtrlTest.TestClosePanel("UMG_Test_Pop_Oringe")
  elseif 14 == count then
    UILayerCtrlTest.TestClosePanel("UMG_Test_Pop_Grape")
  elseif 15 == count then
    UILayerCtrlTest.TestClosePanel("UMG_Test_Full_Red")
  elseif 16 == count then
    UILayerCtrlTest.TestClosePanel("UMG_Test_Main_Green")
  end
  UILayerCtrlTest._testUICount = count + 1
end

return UILayerCtrlTest
