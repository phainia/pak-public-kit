local UMG_JumpTips_C = _G.NRCPanelBase:Extend("UMG_JumpTips_C")

function UMG_JumpTips_C:OnActive()
  Log.Debug("[UMG_JumpTips_C:OnActive]")
  self.TitleText1:SetText(LuaText.game_matrix_tips_title)
  self.NRCText2:SetText(LuaText.game_matrix_tips_content)
  self.Btn.Title_1:SetText(LuaText.game_matrix_tips_download)
  self:AddButtonListener(self.Btn.btnLevelUp, self.OnClickBtn)
  self:ReqGameMatrixReward()
end

function UMG_JumpTips_C:OnDeactive()
  Log.Debug("[UMG_JumpTips_C:OnDeactive]")
end

function UMG_JumpTips_C:OnAddEventListener()
end

function UMG_JumpTips_C:OnClickBtn()
  Log.Warning("GAMEMATRIX:TRY_PLAY_END")
  local GameInstance = UE4.UNRCPlatformGameInstance.GetInstance()
  if not GameInstance then
    return
  end
  local GameMatrixMgr = GameInstance:GetGameMatrixMgr()
  if not GameMatrixMgr then
    return
  end
  GameMatrixMgr:PrintAndroidLog("GAMEMATRIX:TRY_PLAY_END")
end

function UMG_JumpTips_C:ReqGameMatrixReward()
  Log.Debug("[UMG_JumpTips_C:ReqGameMatrixReward]")
  local req = _G.ProtoMessage:newZoneQueryDownloadRewardsReq()
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_QUERY_DOWNLOAD_REWARDS_REQ, req, self, self.OnGameMatrixRewardRsp, false, true)
end

function UMG_JumpTips_C:OnGameMatrixRewardRsp(rsp)
  Log.Debug("[UMG_JumpTips_C:OnGameMatrixRewardRsp]")
  if not rsp and not rsp.items and #rsp.items <= 0 then
    Log.Warning("[UMG_JumpTips_C:OnGameMatrixRewardRsp] rsp.items is empty")
    return
  end
  local RewardList = {}
  for k, v in pairs(rsp.items) do
    Log.Debug("[UMG_JumpTips_C:OnGameMatrixRewardRsp] id:", v.id, "num:", v.num, "type:", v.type)
    local RewardItem = _G.NRCCommonItemIconData()
    RewardItem.itemType = v.type or _G.Enum.GoodsType.GT_BAGITEM
    RewardItem.itemId = v.id
    RewardItem.itemNum = v.num
    RewardItem.bShowNum = true
    RewardItem.bShowTip = true
    table.insert(RewardList, RewardItem)
  end
  self.Award:InitGridView(RewardList)
end

return UMG_JumpTips_C
