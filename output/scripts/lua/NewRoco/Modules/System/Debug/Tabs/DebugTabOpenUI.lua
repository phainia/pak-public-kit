local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local TUIModuleCmd = reload("NewRoco.Modules.System.TUI.TUIModuleCmd")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = DebugTabBase
local DebugTabOpenUI = Base:Extend("DebugTabOpenUI")

function DebugTabOpenUI:Ctor()
  Base.Ctor(self)
end

function DebugTabOpenUI:SetupTabs()
  self:Add("\229\174\182\229\155\173", self.OpenHomeMainPanel, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\144\141\231\137\135\231\187\132\228\187\182\233\128\137\230\139\169", self.OpenCardComponentSelectList, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\229\144\136\231\133\167\230\181\139\232\175\149Demo", self.OpenPhotoPanel, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("\231\187\169\231\130\185\229\149\134\229\159\142", self.FinishNPCActionOpenGPShop, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
end

function DebugTabOpenUI:OpenPanelLobbyMainInner()
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.OpenPanelLobbyMainInner)
  self:ClosePanel()
end

function DebugTabOpenUI:OpenWorldMap()
  _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.OpenWorldMap)
  self:ClosePanel()
end

function DebugTabOpenUI:OpenPanelPetMain()
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenPanelPetMain)
  self:ClosePanel()
end

function DebugTabOpenUI:OpenHandbookCover()
  _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.OpenHandbookCover)
  self:ClosePanel()
end

function DebugTabOpenUI:OpenPetFreePanel()
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenPetFreePanel)
  self:ClosePanel()
end

function DebugTabOpenUI:OpenPetwarehousePanel()
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenPetwarehousePanel)
  self:ClosePanel()
end

function DebugTabOpenUI:OpenTestPetReportPanel()
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenTestPetReportPanel)
  self:ClosePanel()
end

function DebugTabOpenUI:OpenTravelMainMap()
  _G.NRCModuleManager:DoCmd(_G.BigMapModuleCmd.OpenTravelMainMap)
  self:ClosePanel()
end

function DebugTabOpenUI:TestOpenAlchemyPanel()
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.TestOpenAlchemyPanel)
  self:ClosePanel()
end

function DebugTabOpenUI:TestOpenMagicalStudy()
  _G.NRCModuleManager:DoCmd(_G.AlchemyModuleCmd.TestOpenMagicalStudy)
  self:ClosePanel()
end

function DebugTabOpenUI:OpenActivityMainPanel()
  _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.OpenMainPanel)
  self:ClosePanel()
end

function DebugTabOpenUI:OpenMagicManual()
  _G.NRCModuleManager:DoCmd(_G.MagicManualModuleCmd.OpenMagicManual)
  self:ClosePanel()
end

function DebugTabOpenUI:OpenNewTaskPanel()
  _G.NRCModuleManager:DoCmd(_G.TaskModuleCmd.OpenNewTaskPanel)
  self:ClosePanel()
end

function DebugTabOpenUI:OpenBagMainPanel()
  _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.OpenBagMainPanel)
  self:ClosePanel()
end

function DebugTabOpenUI:OpenFriendMainPanel()
  _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.OpenMainPanel)
  self:ClosePanel()
end

function DebugTabOpenUI:OpenStudentCardPanel()
  _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.OpenStudentCardPanel)
  self:ClosePanel()
end

function DebugTabOpenUI:OpenRecoveryTime()
  _G.NRCModuleManager:DoCmd(_G.StarChainModuleCmd.OpenRecoveryTime)
  self:ClosePanel()
end

function DebugTabOpenUI:OpenSystemSettingMainPanel()
  _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.OpenMainPanel)
  self:ClosePanel()
end

function DebugTabOpenUI:OpenTeachingManualMainPanel()
  _G.NRCModuleManager:DoCmd(_G.TeachingManualModuleCmd.OpenMainPanel)
  self:ClosePanel()
end

function DebugTabOpenUI:OpenShopMainPanel()
  _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.OpenMainPanel)
  self:ClosePanel()
end

function DebugTabOpenUI:RequestOpenLevelPanel()
  _G.NRCModuleManager:DoCmd(_G.LevelUpUIModuleCmd.RequestOpenLevelPanel)
  self:ClosePanel()
end

function DebugTabOpenUI:OpenEmailMainPanel()
  _G.NRCModuleManager:DoCmd(_G.EmailModuleCmd.OpenMainPanel)
  self:ClosePanel()
end

function DebugTabOpenUI:OpenPVPMatch()
  _G.NRCModuleManager:DoCmd(_G.BattleUIModuleCmd.OpenPVPMatch)
  self:ClosePanel()
end

function DebugTabOpenUI:FinishNPCActionOpenShop()
  _G.NRCModuleManager:DoCmd(_G.NPCShopUIModuleCmd.FinishNPCActionOpenShop)
  self:ClosePanel()
end

function DebugTabOpenUI:TestGetBeautyStoreListReq()
  _G.NRCModuleManager:DoCmd(_G.NPCShopUIModuleCmd.TestGetBeautyStoreListReq)
  self:ClosePanel()
end

function DebugTabOpenUI:TestGetAppearanceStoreListReq()
  _G.NRCModuleManager:DoCmd(_G.NPCShopUIModuleCmd.TestGetAppearanceStoreListReq)
  self:ClosePanel()
end

function DebugTabOpenUI:OpenPetAltarPanel()
  _G.NRCModuleManager:DoCmd(_G.AltarModuleCmd.OpenPetAltarPanel)
  self:ClosePanel()
end

function DebugTabOpenUI:OpenItemAltarPanel()
  _G.NRCModuleManager:DoCmd(_G.AltarModuleCmd.OpenItemAltarPanel)
  self:ClosePanel()
end

function DebugTabOpenUI:OpenSleepingOwlPanel()
  _G.NRCModuleManager:DoCmd(_G.SleepingOwlModuleCmd.OpenSleepingOwlPanel)
  self:ClosePanel()
end

function DebugTabOpenUI:DialogueTest()
  _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.DialogueTest)
  self:ClosePanel()
end

function DebugTabOpenUI:OpenHomeMainPanel()
  _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.OpenHomeMainPanel)
end

function DebugTabOpenUI:OpenCardComponentSelectList()
  Log.Debug("DebugTabOpenUI:OpenCardComponentSelectList")
  _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.OpenCardComponentSelectList)
end

function DebugTabOpenUI:OpenNeedNpcPanel()
  _G.NRCModuleManager:DoCmd(_G.DebugModuleCmd.OpenAnNiNpcShopPanel)
  self:ClosePanel()
end

function DebugTabOpenUI:FinishNPCActionOpenGPShop()
  _G.NRCModuleManager:DoCmd(_G.NPCShopUIModuleCmd.FinishNPCActionOpenGPShop)
  self:ClosePanel()
end

function DebugTabOpenUI:OpenUITestScene()
  _G.GlobalConfig.DebugOpenUI = true
  _G.GlobalConfig.OpenTestUIScene = true
  local config = _G.GlobalConfig
  collectgarbage("incremental", 100, 1000, config.GCIncStep)
  local Interval = 5
  local TimeLeft = 5
  _G.UpdateManager:Register({
    OnTick = function(self, deltaTime)
      TimeLeft = TimeLeft - deltaTime
      if TimeLeft < 0 then
        TimeLeft = 5
        UE4.UNRCStatics.ReleaseUnuseSlateRenderResource()
        Log.Debug("ReleaseUnuseSlateRenderResource")
      end
    end
  })
end

function DebugTabOpenUI:CreateUITestNPC()
  local NPCList = self.module.NPCList
  local Index = 0
  for i, ID in pairs(NPCList) do
    Index = Index + 1
    self:DebugCreateNPC(ID.NPCID, ID.ConfID, Index)
  end
end

function DebugTabOpenUI:DebugCreateNPC(ID, RefreshID, i)
  local flag = SceneUtils.debugCloseCreateNPC
  SceneUtils.debugCloseCreateNPC = false
  self:InterDebugCreateNPC(ID, RefreshID, i)
  _G.DelayManager:DelaySeconds(1.5, self.ToggleCreateFlag, self, flag)
end

function DebugTabOpenUI:ToggleCreateFlag(flag)
  SceneUtils.debugCloseCreateNPC = flag
end

function DebugTabOpenUI:InterDebugCreateNPC(id, refreshID, i)
  local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local Pos = Player:GetActorLocationFrameCache()
  local Rot = Player:GetActorRotationFrameCache()
  local Point = ProtoMessage:newPoint()
  Pos = Pos + Rot:RotateVector(UE.FVector(i * 100, 0, 0))
  Point.pos.x = math.round(Pos.X)
  Point.pos.y = math.round(Pos.Y)
  Point.pos.z = math.round(Pos.Z)
  local Rotator = Rot:ToRotator()
  Point.dir.z = math.round((-Rotator.Yaw or 0) * 10)
  Point.dir.x = 0
  Point.dir.y = 0
  local req = ProtoMessage:newZoneGmCreateNpcReq()
  req.content_cfg_id = refreshID
  req.npc_pos = Point
  req.only_test = self:GetInputNumber(0) > 0
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_GM_CREATE_NPC_REQ, req, self, self.OnServerCreateDebugNPC)
end

function DebugTabOpenUI:OnServerCreateDebugNPC(rsp)
end

return DebugTabOpenUI
