local UMG_LobbyMainInner_Icon_C = _G.NRCPanelBase:Extend("UMG_LobbyMainInner_Icon_C")

function UMG_LobbyMainInner_Icon_C:OnActive()
  Log.Debug("UMG_LobbyMainInner_Icon_C:OnActive")
  _G.NRCEventCenter:DispatchEvent(_G.MainUIModuleEvent.OnLobbyMainInnerIconLoaded, self)
end

function UMG_LobbyMainInner_Icon_C:OnDeactive()
end

function UMG_LobbyMainInner_Icon_C:OnAddEventListener()
end

function UMG_LobbyMainInner_Icon_C:Hide(immediate)
  self:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  if immediate then
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self:StopAllAnimations()
    self:PlayAnimation(self.Luopan_Close)
  end
end

function UMG_LobbyMainInner_Icon_C:Show(immediate, time, bNoRedPointAnim)
  if not UE4.UObject.IsValid(self) then
    return
  end
  if immediate then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self:StopAllAnimations()
    self:PlayAnimation(self.Loop)
    if not bNoRedPointAnim then
      self.NrcRedPoint:PlayRedPointAnimIn()
    end
  else
    self:DelaySeconds(time or 0, self.PlayShowAnimation, self)
  end
end

function UMG_LobbyMainInner_Icon_C:PlayShowAnimation()
  if not UE4.UObject.IsValid(self) then
    return
  end
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:StopAllAnimations()
  self:PlayAnimation(self.Luopan_Open)
  self.NrcRedPoint:PlayRedPointAnimIn()
end

function UMG_LobbyMainInner_Icon_C:FollowSocketPosition(Position, DeltaTime)
  self.Slot:SetPosition(Position)
end

function UMG_LobbyMainInner_Icon_C:GetPosition()
  return self.Slot:GetPosition()
end

function UMG_LobbyMainInner_Icon_C:SetSize(size)
  self:SetRenderScale(size)
end

function UMG_LobbyMainInner_Icon_C:PlayDisappearAnimation()
  self.Icon:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self:StopAllAnimations()
  self:PlayAnimation(self.Luopan_Close)
  self.NrcRedPoint:PlayRedPointAnimOut()
end

function UMG_LobbyMainInner_Icon_C:PlayAppearAnimation()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Icon:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self:PlayAnimation(self.Luopan_Open)
  self.NrcRedPoint:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.NrcRedPoint:PlayRedPointAnimIn()
end

function UMG_LobbyMainInner_Icon_C:InitIcon(parent, type, isEnable)
  self.parent = parent
  self.type = type
  self.isEnable = isEnable
  self.letters = {
    self.Letter1,
    self.Letter2,
    self.Letter3,
    self.Letter4,
    self.Letter5,
    self.Letter6,
    self.Letter7,
    self.Letter8,
    self.Letter9
  }
  self.texts = {
    self.Text1,
    self.Text2,
    self.Text3,
    self.Text4,
    self.Text5
  }
  self.ui_config = _G.DataConfigManager:GetUiLobbyMainCompass(self.type)
  if self.ui_config then
    self.name = self.ui_config.icon_name
    self.roco_name = self.ui_config.icon_name_roco
  else
    Log.Error("UMG_LobbyMainInner_Icon_C:InitIcon ui_config is nil")
  end
  self:UpdateText()
  self:UpdateBg()
  self:UpdateIconLock()
  local icon_paths = {}
  icon_paths[_G.MainUIModuleEnum.SubPanelOpenType.BattleUI] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Texture/img_duizhan.img_duizhan'"
  icon_paths[_G.MainUIModuleEnum.SubPanelOpenType.TaskUI] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Texture/img_renwu.img_renwu'"
  icon_paths[_G.MainUIModuleEnum.SubPanelOpenType.MapUI] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Texture/img_ditu.img_ditu'"
  icon_paths[_G.MainUIModuleEnum.SubPanelOpenType.HandbookUI] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Texture/img_tujian.img_tujian'"
  icon_paths[_G.MainUIModuleEnum.SubPanelOpenType.PetUI] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Texture/img_jingling.img_jingling'"
  icon_paths[_G.MainUIModuleEnum.SubPanelOpenType.BagUI] = "Texture2D'/Game/NewRoco/Modules/System/MainUI/Raw/Texture/img_beibao.img_beibao'"
  self.Icon_Lock:SetPath(icon_paths[self.type])
  self.Icon:SetPath(icon_paths[self.type])
end

function UMG_LobbyMainInner_Icon_C:UpdateText()
  for i, letter in ipairs(self.letters) do
    letter:GetParent():GetParent():SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  for i, text in ipairs(self.texts) do
    text:GetParent():GetParent():SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  for i, pinyin in ipairs(self.ui_config.chinese_pinyin) do
    if i > #self.texts then
      break
    end
    local text = self.texts[i]
    if text then
      text:GetParent():GetParent():SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      if self.isEnable then
        text:SetPath(string.format("PaperSprite'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUIStatic/Frames/img_%s_png.img_%s_png'", pinyin, pinyin))
      else
        text:SetPath(string.format("PaperSprite'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUIStatic/Frames/img_%s_Lock_png.img_%s_Lock_png'", pinyin, pinyin))
      end
    end
  end
  for i = 1, #self.roco_name do
    if i > #self.letters then
      break
    end
    local char = string.sub(self.roco_name, i, i)
    local letter = self.letters[i]
    if letter then
      letter:GetParent():GetParent():SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      if self.isEnable then
        letter:SetPath(string.format("PaperSprite'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUIStatic/Frames/img_%s_png.img_%s_png'", char, char))
      else
        letter:SetPath(string.format("PaperSprite'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUIStatic/Frames/img_%s_Lock_png.img_%s_Lock_png'", char, char))
      end
    end
  end
end

function UMG_LobbyMainInner_Icon_C:UpdateBg()
  if self.isEnable then
    self.BGCloud:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.BGCloudRed:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.BGCloudLock:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.BGCloud:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.BGCloudRed:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.BGCloudLock:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  end
end

function UMG_LobbyMainInner_Icon_C:UpdateIconLock()
  if self.isEnable then
    self.Icon_Lock:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Icon_Lock:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  end
end

function UMG_LobbyMainInner_Icon_C:ClearDelegate()
end

function UMG_LobbyMainInner_Icon_C:HideRedPoint(immediate)
  if immediate then
    self.NrcRedPoint:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.NrcRedPoint:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.NrcRedPoint:PlayRedPointAnimOut()
  end
end

function UMG_LobbyMainInner_Icon_C:ShowRedPoint()
  self.NrcRedPoint:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.NrcRedPoint:PlayRedPointAnimIn()
end

function UMG_LobbyMainInner_Icon_C:PlayClickLockAnimation()
  self:StopAnimation(self.Select_Lock)
  self:PlayAnimation(self.Select_Lock)
end

function UMG_LobbyMainInner_Icon_C:PlayClickAnimation(caller, callback)
  self:StopAnimation(self.Select)
  self:PlayAnimation(self.Select)
  self.caller = caller
  self.callback = callback
end

function UMG_LobbyMainInner_Icon_C:PlayUnSelectAnimation()
  self:StopAnimation(self.UnSelect)
  self:PlayAnimation(self.UnSelect)
end

function UMG_LobbyMainInner_Icon_C:OnAnimationFinished(Anim)
  if Anim == self.Select then
    local caller = self.caller
    local callback = self.callback
    self.caller = nil
    self.callback = nil
    if caller and callback then
      callback(caller)
    end
    caller = nil
    callback = nil
  elseif (Anim == self.Luopan_Open or Anim == self.Loop) and not self:IsAnimationPlaying(self.Loop) then
    self:PlayAnimation(self.Loop)
  end
end

function UMG_LobbyMainInner_Icon_C:SetEnable(isEnable)
  self.isEnable = isEnable
  self:UpdateIconLock()
  self:UpdateText()
  self:UpdateBg()
end

return UMG_LobbyMainInner_Icon_C
