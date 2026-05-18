local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local UMG_BattleAI_Visible_C = _G.NRCPanelBase:Extend("UMG_BattleAI_Visible_C")

function UMG_BattleAI_Visible_C:OnActive()
  self:OnAddEventListener()
  self.RoundNumber = -1
  self.battleId = -1
  self.GMRound = {}
  self:InitData()
end

function UMG_BattleAI_Visible_C:InitData()
  if _G.BattleManager.isInBattle then
    if self.battleId ~= _G.BattleManager.battleRuntimeData:GetBattleID() then
      self.battleId = _G.BattleManager.battleRuntimeData:GetBattleID()
      self.GMRound = {}
      self.BattleIdText:SetText(string.format("  \230\156\172\229\156\186\230\136\152\230\150\151ID:%d", _G.BattleManager.battleRuntimeData.battleStartParam.battleCfg.id))
      local petInfo = ""
      local enemy = _G.BattleManager.battlePawnManager:GetAllEnemyTeam(BattleEnum.Team.ENUM_TEAM)
      for _, v in pairs(enemy) do
        for _, card in pairs(v.player.deck.cards) do
          card:GetDisplaySkills()
          petInfo = petInfo .. card.name .. string.format("(%d) \230\139\165\230\156\137\230\138\128\232\131\189 : (", card.guid)
          for _, skill in pairs(card.skillRoundData) do
            petInfo = petInfo .. skill.id .. "  "
          end
          petInfo = petInfo .. ")\n"
        end
      end
      self.PetsInfoText:SetText(petInfo)
    end
    self:UpdateData()
  end
end

function UMG_BattleAI_Visible_C:UpdateData()
  if _G.BattleManager.AIRound ~= self.RoundNumber then
    self.RoundNumber = _G.BattleManager.AIRound
    local historyText = ""
    for i = 0, self.RoundNumber do
      local v = _G.BattleManager.AIHistoryInfo[i]
      if v then
        historyText = historyText .. string.format("\231\172\172%d\229\155\158\229\144\136 : ", i)
        for _, op in pairs(v) do
          if op.type == "UseSkill" then
            historyText = historyText .. string.format(" (%d \228\189\191\231\148\168\230\138\128\232\131\189 %d) ", op.petId, op.skillId)
          else
            historyText = historyText .. " (\230\155\180\230\141\162\229\174\160\231\137\169 \228\184\139\229\156\186\229\174\160\231\137\169: "
            for _, old in pairs(op.oldPets) do
              historyText = historyText .. old .. "  "
            end
            historyText = historyText .. " \228\184\138\229\156\186\229\174\160\231\137\169: "
            for _, new in pairs(op.newPets) do
              historyText = historyText .. new .. "  "
            end
            historyText = historyText .. ") "
          end
        end
        if table.contains(self.GMRound, i) then
          historyText = historyText .. [[
 
 GM !!!]]
        end
        historyText = historyText .. "\n"
      end
    end
    self.HistoryInfoText:SetText(historyText)
  end
end

function UMG_BattleAI_Visible_C:OnDeactive()
  self:RemoveAllButtonListener()
  _G.BattleEventCenter:UnBind(self)
end

function UMG_BattleAI_Visible_C:OnAddEventListener()
  self:AddButtonListener(self.CloseButton, self.OnClickClose)
  self:AddButtonListener(self.RestartBtn, self.OnClickRestart)
  self:AddButtonListener(self.ChangePet, self.OnClickChangePet)
  self:AddButtonListener(self.NoAttack, self.OnClickNoAttack)
  _G.BattleEventCenter:Bind(self, BattleEvent.RECORD_AI_OP)
end

function UMG_BattleAI_Visible_C:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.RECORD_AI_OP then
    self:InitData()
  end
end

function UMG_BattleAI_Visible_C:OnClickClose()
  self:DoClose()
end

function UMG_BattleAI_Visible_C:OnClickRestart()
  local req = ProtoMessage:newZoneBattleGmReq()
  req.gm_type = ProtoEnum.ZoneBattleGmReq.BATTLE_GM_TYPE.B_GM_TYPE_AI
  req.gm_op_type = 1
  req.side = 1
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrGmCmd.ZONE_BATTLE_GM_REQ, req, self, self.RestartRsp, false, false)
end

function UMG_BattleAI_Visible_C:RestartRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    table.insert(self.GMRound, self.RoundNumber)
    self.RoundNumber = -1
    _G.BattleManager.AIHistoryInfo[_G.BattleManager.AIRound] = {}
  end
end

function UMG_BattleAI_Visible_C:OnClickChangePet()
  local req = ProtoMessage:newZoneBattleGmReq()
  req.gm_type = ProtoEnum.ZoneBattleGmReq.BATTLE_GM_TYPE.B_GM_TYPE_AI
  req.gm_op_type = 2
  req.param1 = 1
  req.side = 1
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_BATTLE_GM_REQ, req)
end

function UMG_BattleAI_Visible_C:OnClickNoAttack()
  local req = ProtoMessage:newZoneBattleGmReq()
  req.gm_type = ProtoEnum.ZoneBattleGmReq.BATTLE_GM_TYPE.B_GM_TYPE_AI
  req.gm_op_type = 3
  req.param1 = 1
  req.side = 1
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_BATTLE_GM_REQ, req)
end

return UMG_BattleAI_Visible_C
