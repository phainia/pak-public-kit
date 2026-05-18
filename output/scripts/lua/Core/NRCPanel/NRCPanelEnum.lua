local NRCPanelEnum = {}
NRCPanelEnum.PanelTypeEnum = {
  PANEL_3DUI1 = 1,
  PANEL_3DUI2 = 2,
  PANEL_POPUP_UNTRANS = 3,
  PANEL_POPUP_TRANS = 4,
  PANEL_HALFSCREEN = 5,
  PANEL_FULLSCREEN = 6
}
NRCPanelEnum.OpenFailedReason = {RspError = 1}
NRCPanelEnum.PanelDisableReason = {
  None = 0,
  Default = 1,
  LayerCtrl = 2,
  WaitTogetherPlayer = 4
}
return NRCPanelEnum
