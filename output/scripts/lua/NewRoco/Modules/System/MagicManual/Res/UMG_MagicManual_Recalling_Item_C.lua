local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local rapidjson = require("rapidjson")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_MagicManual_Recalling_Item_C = Base:Extend("UMG_MagicManual_Recalling_Item_C")

function UMG_MagicManual_Recalling_Item_C:OnConstruct()
  self.bInit = false
end

function UMG_MagicManual_Recalling_Item_C:OnDestruct()
end

function UMG_MagicManual_Recalling_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self.recallTermConf = _G.DataConfigManager:GetReacallTremsConf(self.data.id)
  if not self.recallTermConf then
    Log.Error("UMG_MagicManual_Recalling_Item_C:OnItemUpdate \229\143\179\228\190\167Tab\230\140\137\233\146\174\229\136\157\229\167\139\229\140\150\229\164\177\232\180\165\239\188\140\229\175\185\229\186\148\231\154\132RECALL_TERM_CONF id %s\230\178\161\230\156\137\229\156\168\232\161\168\228\184\173\230\137\190\229\136\176\239\188\140\230\163\128\230\159\165\233\133\141\231\189\174\232\161\168", self.data.id)
    return
  end
  self.demonstrationId = self.recallTermConf.reacall_terms_show
  self.teachId = self.recallTermConf.reacall_terms_teach
  self.jumpCmd = self.recallTermConf.reacall_terms_go
  if not string.IsNilOrEmpty(self.recallTermConf.args) then
    self.Args = rapidjson.decode(self.recallTermConf.args)
    if not self.Args then
      self.Args = self:SplitString(self.recallTermConf.args, ";")
      if 1 == #self.Args then
        self.Args = self.Args[1]
      end
    end
  end
  if not string.IsNilOrEmpty(self.recallTermConf.args2) then
    self.Args2 = rapidjson.decode(self.recallTermConf.args2)
    if not self.Args2 then
      self.Args2 = self:SplitString(self.recallTermConf.args2, ";")
      if 1 == #self.Args2 then
        self.Args2 = self.Args2[1]
      end
    end
  end
  self:OnAddButtonListener()
  self:_InitItem()
end

function UMG_MagicManual_Recalling_Item_C:OnAddButtonListener()
  if not self.bInit then
    self.bInit = true
    self:AddButtonListener(self.DemonstrationBtn, self.OnDemonstrationBtnClicked)
    self:AddButtonListener(self.TeachingBtn, self.OnTeachBtnClicked)
    self:AddButtonListener(self.JumpToBtn.btnLevelUp, self.OnJumpBtnClicked)
  end
end

function UMG_MagicManual_Recalling_Item_C:OnItemSelected(_bSelected)
end

function UMG_MagicManual_Recalling_Item_C:SplitString(Input, Delimiter)
  if not Input or not Delimiter then
    return {}
  end
  local Result = {}
  for str in string.gmatch(Input, "([^" .. Delimiter .. "]+)") do
    table.insert(Result, str)
  end
  return Result
end

function UMG_MagicManual_Recalling_Item_C:_InitItem()
  self.Selected:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Describe:SetText(self.recallTermConf.reacall_terms_text)
  self.Title:SetText(self.recallTermConf.reacall_terms_name)
  if self.NRCImage_38 then
    self.NRCImage_38:SetPath(self.recallTermConf.reacall_terms_picture)
  end
  self.DemonstrationBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.TeachingBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.JumpToBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.recallTermConf.reacall_terms_show and 0 ~= self.recallTermConf.reacall_terms_show then
    self.DemonstrationBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.recallTermConf.reacall_terms_teach and 0 ~= self.recallTermConf.reacall_terms_teach then
    self.TeachingBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.recallTermConf.reacall_terms_go and not string.IsNilOrEmpty(self.recallTermConf.reacall_terms_go) then
    self.JumpToBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_MagicManual_Recalling_Item_C:OnDemonstrationBtnClicked()
  self:PlayAnimation(self.Right_Press)
  local curId = _G.NRCModuleManager:DoCmd(_G.GuidanceModuleCmd.GetCurrentGuideGroupId)
  if curId and 0 ~= curId then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.reacall_guiding)
    return
  end
  local Ctx = DialogContext()
  Ctx:SetTitle(_G.LuaText.reacall_check_title)
  Ctx:SetContent(_G.LuaText.reacall_check_guidetext)
  Ctx:SetMode(DialogContext.Mode.OK_CANCEL)
  Ctx:SetCallbackOkOnly(self, self.OnDemonstrationBtnOk)
  Ctx:SetClickAnywhereClose(true)
  Ctx:SetButtonText(LuaText.YES, LuaText.NO)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function UMG_MagicManual_Recalling_Item_C:OnDemonstrationBtnOk()
  local bHasCompass = _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.HasCompass)
  if bHasCompass then
    _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.CloseCompass)
  end
  _G.NRCModuleManager:DoCmd(_G.MagicManualModuleCmd.CloseMagicManual)
  _G.NRCModuleManager:DoCmd(_G.GuidanceModuleCmd.StartLocalGuideGroup, self.demonstrationId)
end

function UMG_MagicManual_Recalling_Item_C:OnTeachBtnClicked()
  self:PlayAnimation(self.Left_Press)
  local Ctx = DialogContext()
  Ctx:SetTitle(_G.LuaText.reacall_check_title)
  Ctx:SetContent(_G.LuaText.reacall_check_teachtext)
  Ctx:SetMode(DialogContext.Mode.OK_CANCEL)
  Ctx:SetCallbackOkOnly(self, self.OnTeachBtnOk)
  Ctx:SetClickAnywhereClose(true)
  Ctx:SetButtonText(LuaText.YES, LuaText.NO)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function UMG_MagicManual_Recalling_Item_C:OnTeachBtnOk()
  _G.NRCModuleManager:DoCmd(_G.MagicManualModuleCmd.CloseMagicManual)
  _G.NRCModuleManager:DoCmd(_G.TeachingManualModuleCmd.OpenMainPanelByTeachId, self.teachId)
end

function UMG_MagicManual_Recalling_Item_C:OnJumpBtnClicked()
  local Ctx = DialogContext()
  Ctx:SetTitle(_G.LuaText.reacall_check_title)
  Ctx:SetContent(_G.LuaText.reacall_check_jumptext)
  Ctx:SetMode(DialogContext.Mode.OK_CANCEL)
  Ctx:SetCallbackOkOnly(self, self.OnJumpBtnOk)
  Ctx:SetClickAnywhereClose(true)
  Ctx:SetButtonText(LuaText.YES, LuaText.NO)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenDialog, Ctx)
end

function UMG_MagicManual_Recalling_Item_C:OnJumpBtnOk()
  _G.NRCModuleManager:DoCmd(_G.MagicManualModuleCmd.TutorJumpToPanel, self.jumpCmd, self.Args, self.Args2)
end

function UMG_MagicManual_Recalling_Item_C:OnDeactive()
end

function UMG_MagicManual_Recalling_Item_C:OnAnimationFinished(Anim)
  if Anim == self.Left_Press then
    self:PlayAnimation(self.Left_Up)
  elseif Anim == self.Right_Press then
    self:PlayAnimation(self.Right__Up)
  end
end

return UMG_MagicManual_Recalling_Item_C
