local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_PetChangeTeam_C = _G.NRCViewBase:Extend("UMG_PetChangeTeam_C")

function UMG_PetChangeTeam_C:Initialize(Initializer)
end

function UMG_PetChangeTeam_C:OnConstruct()
  self:AddButtonListener(self.btnClose, self.OnBtnCloseClick)
  self:AddButtonListener(self.btnChangeTeam, self.OnBtnChangeTeamClick)
  self:RegisterEvent(self, PetUIModuleEvent.PET_UI_TEAMBTN_BTNCLICK, self.OnLeftPanelTeamButtonClick)
end

function UMG_PetChangeTeam_C:OnDestruct()
  self.petListScroll:ReleaseForce()
  self.petInfo = nil
end

function UMG_PetChangeTeam_C:OnEnable()
end

function UMG_PetChangeTeam_C:OnDisable()
end

function UMG_PetChangeTeam_C:OnBtnCloseClick()
  self:LoadAnimation(1)
end

function UMG_PetChangeTeam_C:OnAnimationFinished(Animation)
  if Animation == self:GetAnimByIndex(1) then
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_PetChangeTeam_C:OnBtnChangeTeamClick()
  local srcPetInfo = self.petInfo
  if self.curPetListSelectIndex and srcPetInfo and srcPetInfo.gid > 0 then
    local dstPetInfo = self.petList[self.curPetListSelectIndex]
    if not dstPetInfo then
      local showTip = _G.DataConfigManager:GetLocalizationConf("pet_choose_exchange_tip")
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, showTip.msg)
      return
    end
    self:DispatchEvent(PetUIModuleEvent.PET_UI_PET_CHANGE_TEAM, srcPetInfo.gid, dstPetInfo.gid)
    NRCModuleManager:DoCmd(PetUIModuleCmd.ChangePetPos2, srcPetInfo.gid, dstPetInfo.gid)
  end
  self:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_PetChangeTeam_C:OnLeftPanelTeamButtonClick(_btnId, _petInfo)
  if not _petInfo or 2 ~= _btnId then
    return
  end
  self.petInfo = _petInfo
  self:updatePetList()
  self:SetVisibility(UE4.ESlateVisibility.Visible)
  self:LoadAnimation(0)
end

function UMG_PetChangeTeam_C:OnScrollPetItemSelected(item, index)
  self.curPetListSelectIndex = index
end

function UMG_PetChangeTeam_C:updatePetList()
  local petFightPosList = {}
  local bagPosArray = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo().bag_pos_gid
  if bagPosArray then
    for i, fightPet_gid in ipairs(bagPosArray) do
      petFightPosList[fightPet_gid] = i
    end
  end
  local petInfos = {}
  local battlePetList = _G.DataModelMgr.PlayerDataModel:GetPlayerBattlePetInfo()
  if battlePetList then
    for i, petData in ipairs(battlePetList) do
      local fightPos = petFightPosList[petData.gid] or 9
      table.insert(petInfos, {
        gid = petData.gid,
        base_conf_id = petData.base_conf_id,
        isFight = true,
        isMainFight = 1 == fightPos,
        sort = fightPos,
        showPetHp = true
      })
    end
  end
  petCount = #petInfos
  if petCount < 6 then
    for i = petCount + 1, 6 do
      table.insert(petInfos, {
        gid = 0,
        base_conf_id = 0,
        isFight = true,
        sort = 10 + i
      })
    end
  end
  table.sort(petInfos, function(a, b)
    if a.sort ~= b.sort then
      return a.sort < b.sort
    else
      return a.gid < b.gid
    end
  end)
  self.curPetListSelectIndex = 0
  self.petList = petInfos
  self.petListScroll:SetDatas(petInfos)
  self.petListScroll:SetCaller(self)
  self.petListScroll.OnItemSelected = self.OnScrollPetItemSelected
end

return UMG_PetChangeTeam_C
