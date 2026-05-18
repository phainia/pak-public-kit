local UMG_Activity_PlayeSWork_C = _G.NRCPanelBase:Extend("UMG_Activity_PlayeSWork_C")

function UMG_Activity_PlayeSWork_C:OnActive(base_id, activity_id, emoj_rsp)
  self:LoadAnimation(0)
  for i = 0, self.ExpressionList:GetItemCount() - 1 do
    self.ExpressionList:GetItemByIndex(i):PlayItemAnim(true)
  end
  self.activity_id = activity_id
  local coCreationConf = _G.DataConfigManager:GetActivityPlayerCoCreation(base_id)
  self.Text_TitleName:SetText(coCreationConf.player_img_text)
  self.CreativityIcon:SetPath(coCreationConf.player_img)
  local emoj_list = emoj_rsp.emoj_info.emoj_list
  local emojConf = _G.DataConfigManager:GetActivityPlayerCoCreation(base_id).emoji_group
  local emojData = {}
  for i = 1, #emojConf do
    table.insert(emojData, {})
  end
  local selectEmoj = emoj_rsp.emoj_list
  for _, v in ipairs(emoj_list) do
    emojData[v.emoj_type].type = v.emoj_type
    emojData[v.emoj_type].num = v.emoj_cnt
    local bSelected = false
    if selectEmoj then
      for _, val in ipairs(selectEmoj) do
        if val == v.emoj_type then
          bSelected = true
          break
        end
      end
    end
    emojData[v.emoj_type].bSelected = bSelected
    emojData[v.emoj_type].caller = self
    emojData[v.emoj_type].callback = self.OnClickEmoj
    for _, emoj in ipairs(emojConf) do
      if emoj.emoji_enum == v.emoj_type then
        emojData[v.emoj_type].icon = emoj.emoji_img
        emojData[v.emoj_type].selectIcon = emoj.emoji_img_select
        break
      end
    end
  end
  self.emojData = emojData
  self.ExpressionList:InitGridView(emojData)
  self:AddButtonListener(self.FullScreen_Close, self.ClosePanel)
end

function UMG_Activity_PlayeSWork_C:ClosePanel()
  if self.bWaitEmojChange then
    return
  end
  for i = 0, self.ExpressionList:GetItemCount() - 1 do
    self.ExpressionList:GetItemByIndex(i):PlayItemAnim(false)
  end
  self:LoadAnimation(2)
end

function UMG_Activity_PlayeSWork_C:OnAnimationFinished(Anim)
  if Anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_Activity_PlayeSWork_C:OnClickEmoj(emoj_type, bSelected)
  if self.bWaitEmojChange then
    return
  end
  local req = _G.ProtoMessage:newZoneActivitySetCoCreationEmojReq()
  req.activity_id = self.activity_id
  req.emoj_id = emoj_type
  req.is_cancel = bSelected
  self.change_emoj = emoj_type
  self.bWaitEmojChange = true
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_ACTIVITY_SET_CO_CREATION_EMOJ_REQ, req, self, self.ChangeEmojPanel, false, true)
end

function UMG_Activity_PlayeSWork_C:ChangeEmojPanel(rsp)
  self.bWaitEmojChange = false
  if rsp.ret_info and 0 == rsp.ret_info.ret_code then
    self.emojData[self.change_emoj].bSelected = not self.emojData[self.change_emoj].bSelected
    local emoj_list = rsp.emoj_info.emoj_list
    for _, v in ipairs(emoj_list) do
      self.emojData[v.emoj_type].num = v.emoj_cnt
    end
    self.ExpressionList:InitGridView(self.emojData)
  end
end

function UMG_Activity_PlayeSWork_C:OnPcClose()
  self:ClosePanel()
end

function UMG_Activity_PlayeSWork_C:OnDeactive()
  self:RemoveButtonListener(self.FullScreen_Close)
end

return UMG_Activity_PlayeSWork_C
