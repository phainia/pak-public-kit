local UMG_EntryHudVS_V_2_C = _G.NRCPanelBase:Extend("UMG_EntryHudVS_V_2_C")

function UMG_EntryHudVS_V_2_C:OnActive(battlePlayerData, successCallBack)
  self.UMG_BattleShowImage:SetTeamData(battlePlayerData, self, successCallBack, self.UMG_BattleShowImage.SetTeamDataType.USE_BATTLE_PLAYER_INFO)
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.All:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_EntryHudVS_V_2_C:OnDeactive()
end

function UMG_EntryHudVS_V_2_C:OnAddEventListener()
end

function UMG_EntryHudVS_V_2_C:OnTick()
end

function UMG_EntryHudVS_V_2_C:OnLogin()
end

function UMG_EntryHudVS_V_2_C:OnConstruct()
end

function UMG_EntryHudVS_V_2_C:Quit()
  self.UMG_BattleShowImage:ClearWorld()
  self:OnClose()
end

function UMG_EntryHudVS_V_2_C:OnDestruct()
end

function UMG_EntryHudVS_V_2_C:OnAnimationFinished(anim)
end

return UMG_EntryHudVS_V_2_C
