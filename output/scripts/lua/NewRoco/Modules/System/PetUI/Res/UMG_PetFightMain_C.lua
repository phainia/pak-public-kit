local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_PetFightMain_C = _G.NRCViewBase:Extend("UMG_PetFightMain_C")

function UMG_PetFightMain_C:Initialize(Initializer)
end

function UMG_PetFightMain_C:OnConstruct()
  self:SetChildViews(self.petFightInfoPanel, self.petTalentInfoPanel, self.petRaceInfoPanel, self.btnMenu1, self.btnMenu2, self.btnMenu3)
  self.subPanels = {
    self.petFightInfoPanel,
    self.petTalentInfoPanel,
    self.petRaceInfoPanel
  }
  self.menuButtons = {
    self.btnMenu1,
    self.btnMenu2,
    self.btnMenu3
  }
  local icon1 = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/GameBtnIcon/Frames/ui_petinfo_btn_zhanli_normal_png.ui_petinfo_btn_zhanli_normal_png'"
  local icon2 = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/GameBtnIcon/Frames/ui_petinfo_btn_zhanli_selected_png.ui_petinfo_btn_zhanli_selected_png'"
  local icon3 = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/GameBtnIcon/Frames/ui_petinfo_btn_getiqianli_normal_png.ui_petinfo_btn_getiqianli_normal_png'"
  local icon4 = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/GameBtnIcon/Frames/ui_petinfo_btn_getiqianli_selected_png.ui_petinfo_btn_getiqianli_selected_png'"
  local icon5 = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/GameBtnIcon/Frames/ui_petinfo_btn_race_normal_png.ui_petinfo_btn_race_normal_png'"
  local icon6 = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Atlas/GameBtnIcon/Frames/ui_petinfo_btn_race_selected_png.ui_petinfo_btn_race_selected_png'"
  self.btnMenu1:SetData({
    index = 1,
    soundId = 40002004,
    title = LuaText.umg_petfightmain_1,
    icon1 = icon1,
    icon2 = icon2,
    callbackCaller = self,
    callbackFunc = self.OnMenuButtonClick
  })
  self.btnMenu2:SetData({
    index = 2,
    soundId = 40002004,
    title = LuaText.umg_petfightmain_2,
    icon1 = icon3,
    icon2 = icon4,
    callbackCaller = self,
    callbackFunc = self.OnMenuButtonClick
  })
  self.btnMenu3:SetData({
    index = 3,
    soundId = 40002020,
    title = LuaText.umg_petfightmain_3,
    icon1 = icon5,
    icon2 = icon6,
    callbackCaller = self,
    callbackFunc = self.OnMenuButtonClick
  })
  self.curIndex = 0
  self:ShowSubPanel(1)
end

function UMG_PetFightMain_C:OnDestruct()
  self.subPanels = nil
  self.menuButtons = nil
  self.btnMenu1:Destruct()
  self.btnMenu2:Destruct()
  self.btnMenu3:Destruct()
  self.petFightInfoPanel:Destruct()
  self.petTalentInfoPanel:Destruct()
  self.petRaceInfoPanel:Destruct()
end

function UMG_PetFightMain_C:OnEnable()
end

function UMG_PetFightMain_C:OnDisable()
end

function UMG_PetFightMain_C:OnMenuButtonClick(_index, _playAni)
  if nil == _index or _index > 0 and _index == self.curIndex then
    return
  end
  if _playAni then
    self:ChangeCurButtonState(false)
    self.curIndex = _index
    self:ChangeCurButtonState(true)
    if self:IsAnimationPlaying(self.ChangeInfo_In) then
      self:StopAnimation(self.ChangeInfo_In)
    end
    if not self:IsAnimationPlaying(self.ChangeInfo_Out) then
      self:PlayAnimation(self.ChangeInfo_Out)
    end
  else
    self:ChangeCurButtonState(false)
    self.curIndex = _index
    self:SetSubPanelVisible(_index)
    self:ChangeCurButtonState(true)
  end
end

function UMG_PetFightMain_C:ShowSubPanel(_index)
  if self.curIndex ~= _index then
    self:OnMenuButtonClick(_index)
  end
end

function UMG_PetFightMain_C:SetSubPanelVisible(_index)
  for panelIndex, subPanel in pairs(self.subPanels) do
    if subPanel then
      if _index == panelIndex then
        subPanel:SetVisibility(UE4.ESlateVisibility.Visible)
      else
        subPanel:SetVisibility(UE4.ESlateVisibility.Hidden)
      end
    end
  end
end

function UMG_PetFightMain_C:ChangeCurButtonState(_select)
  if self.curIndex ~= nil then
    local curMenuBtton = self.menuButtons[self.curIndex]
    if curMenuBtton then
      curMenuBtton:SetSelectState(_select)
    end
  end
end

function UMG_PetFightMain_C:OnAnimationFinished(Animation)
  if Animation == self.Out then
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
  elseif Animation == self.ChangeInfo_Out then
    self:SetSubPanelVisible(self.curIndex)
    self:PlayAnimation(self.ChangeInfo_In)
  end
end

function UMG_PetFightMain_C:OnPanelStateChange(_isShow)
  self:StopAllAnimations()
  if _isShow then
    self:PlayAnimation(self.In, 0, 1, 0, 1.5)
  else
    self:PlayAnimation(self.Out)
  end
end

function UMG_PetFightMain_C:updatePetInfo(_petData, _petBaseConf)
  self.petRaceInfoPanel:updatePetInfo(_petData, _petBaseConf)
  self.petFightInfoPanel:updatePetInfo(_petData, _petBaseConf)
  self.petTalentInfoPanel:updatePetInfo(_petData, _petBaseConf)
end

return UMG_PetFightMain_C
