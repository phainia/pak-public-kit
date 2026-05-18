local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local Base = require("Core.NRCModule.NRCPanelBase")
local UMG_MagicCreationPanel_C = Base:Extend("UMG_MagicCreationPanel_C")

function UMG_MagicCreationPanel_C:OnActive(action)
  self.Btn_PutIn:SetBtnText("\232\189\172\230\141\162")
  if _G.GlobalConfig.DebugOpenUI then
    _G.NRCModuleManager:DoCmd(MainUIModuleCmd.ClosePanelLobbyMain)
  end
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnClickCancel)
  self:AddButtonListener(self.Btn_PutIn.btnLevelUp, self.OnClickConfirm)
  _G.NRCEventCenter:RegisterEvent("UMG_MagicCreationPanel_C", self, DialogueModuleEvent.DialogueEnded, self.OnDialogueEnded)
  self:SetCommonTitle()
  local items = {}
  if action then
    self.optionId = action.Owner.config.id
    self.npcId = action.Owner.owner.serverData.base.actor_id
    self.satisfy = true
    self.action = action
    local paramStr = action.Config.action_param1
    local params = paramStr:split(";")
    self.Title:SetText("\229\141\135\231\186\167\233\173\148\229\138\155\230\158\162\231\186\189")
    for i = 1, #params, 2 do
      local item = {}
      item.id = tonumber(params[i])
      local bagItemData = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemByID, item.id)
      if bagItemData then
        item.cur = bagItemData.num
      else
        item.cur = 0
      end
      item.need = tonumber(params[i + 1])
      if item.cur < item.need then
        self.satisfy = false
      end
      table.insert(items, item)
    end
  end
  self.List:InitGridView(items)
end

function UMG_MagicCreationPanel_C:OnClickCancel()
  if self.action == nil then
    _G.NRCModuleManager:DoCmd(_G.MagicCreationModuleCmd.CloseTransferNpcPanel)
    return
  end
  if self.action.CancelSubmit then
    self.action:CancelSubmit()
  elseif self.action.Finish then
    self.action:Finish(false, nil, nil)
  end
  self.action = nil
  _G.NRCModuleManager:DoCmd(_G.MagicCreationModuleCmd.CloseTransferNpcPanel)
end

function UMG_MagicCreationPanel_C:OnClickConfirm()
  if self.satisfy then
    if self.action then
      if self.action.CheckTransferValid then
        self.action:CheckTransferValid()
      elseif self.action.SubmitItem then
        self.action:SubmitItem()
      end
      self.action = nil
    end
    _G.NRCModuleManager:DoCmd(_G.MagicCreationModuleCmd.CloseTransferNpcPanel)
  else
    local tipTxt = _G.DataConfigManager:GetLocalizationConf("Error_Code_2055")
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, tipTxt.msg)
  end
end

function UMG_MagicCreationPanel_C:SetCommonTitle()
  self.titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  self.Title1:Set_MainTitle(self.titleConf.title)
  self.Title1:SetBg(self.titleConf.head_icon)
  self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
end

function UMG_MagicCreationPanel_C:OnDeactive()
  if _G.GlobalConfig.DebugOpenUI then
    _G.NRCModuleManager:DoCmd(MainUIModuleCmd.OpenPanelLobbyMain)
  end
  _G.NRCEventCenter:UnRegisterEvent(self, DialogueModuleEvent.DialogueEnded, self.OnDialogueEnded)
  self:RemoveButtonListener(self.CloseBtn.btnClose)
  self:RemoveButtonListener(self.Btn_PutIn.btnLevelUp)
end

function UMG_MagicCreationPanel_C:OnDialogueEnded()
  self:DoClose()
end

return UMG_MagicCreationPanel_C
