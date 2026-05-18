local NRCSDKManagerEnum = {}
NRCSDKManagerEnum.Common = {
  APP_ID_QQ = "1110613799",
  APP_ID_WX = "wxdca9f9a612d43085"
}
NRCSDKManagerEnum.ScreenType = {
  Default = 1,
  Portrait = 2,
  Landscape = 3
}
NRCSDKManagerEnum.WebViewMsgType = {
  CloseWebViewURL = 100,
  WebViewJsCall = 101,
  WebViewJsShare = 102,
  WebViewJsSendMessage = 103
}
NRCSDKManagerEnum.AntiCheatSendType = {
  Default = 0,
  EnterBattle = 1,
  LeaveBattle = 2
}
NRCSDKManagerEnum.CreditScoreNotEnoughType = {
  Chat = 0,
  AddFriend = 1,
  GetQualificationCode = 3
}
NRCSDKManagerEnum.WebViewDirectionType = {
  LandScape = 2,
  Portrait = 3,
  Auto = 1
}
NRCSDKManagerEnum.GRobot = {
  SOURCE_PRIVACY = "xy_privacy",
  SOURCE_GAMES = "xy_games",
  GAME_ID = "21226",
  LOGIN_TYPE = "msdk",
  PC_MSDK_TYPE = "pcsdk",
  MSDK_ENV_DEV = 1,
  MSDK_ENV_PUB = 0,
  PRIVACY_PLAT_ID_IOS = 0,
  PRIVACY_PLAT_ID_ANDROID = 1,
  PRIVACY_PLAT_ID_WINDOWS = 2,
  PRIVACY_PLAT_ID_HARMONY_NEXT = 12,
  GAMES_PLAT_ID_MSDK_V5_IOS = 0,
  GAMES_PLAT_ID_MSDK_V5_ANDROID = 1,
  GAMES_PLAT_ID_MSDK_V5_WINDOWS = 2,
  GAMES_PLAT_ID_MSDK_V5_HARMONY_NEXT = 12,
  PRIVACY_SYSTEM_ID_QQ = 1,
  PRIVACY_SYSTEM_ID_WX = 2,
  GAMES_SYSTEM_ID_MSDK_V5_QQ = 1,
  GAMES_SYSTEM_ID_MSDK_V5_WX = 2,
  GAMES_SYSTEM_ID_MSDK_V5_VISITOR = 3
}
return NRCSDKManagerEnum
