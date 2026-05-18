local PetUIModuleEnum = require("NewRoco.Modules.System.PetUI.PetUIModuleEnum")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_DetailsDifferences_C = _G.NRCPanelBase:Extend("UMG_DetailsDifferences_C")

function UMG_DetailsDifferences_C:OnConstruct()
  self:SetChildViews(self.PopUp2)
end

function UMG_DetailsDifferences_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.ClosePanel
  CommonPopUpData.Btn_RightHandler = self.OnOK
  CommonPopUpData.ClosePanelHandler = self.ClosePanel
  if 2 == self.openType then
    CommonPopUpData.TitleText = LuaText.lineup_code_fix_lack
  end
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp2:SetPanelInfo(CommonPopUpData)
end

function UMG_DetailsDifferences_C:OnActive(openType, SolveAllDiffList)
  self.openType = openType
  self:SetCommonPopUpInfo()
  if 1 == openType then
    local List = {}
    for i, v in pairs(SolveAllDiffList) do
      local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(i)
      local data = v
      if data then
        if data[PetUIModuleEnum.PetTeamShareReviseType.Talent] and #data[PetUIModuleEnum.PetTeamShareReviseType.Talent] then
          for _, item in ipairs(data[PetUIModuleEnum.PetTeamShareReviseType.Talent]) do
            local ItemData = {
              petData = petData,
              type = PetUIModuleEnum.PetTeamShareReviseType.Talent,
              UiData = item
            }
            table.insert(List, ItemData)
          end
        end
        if data[PetUIModuleEnum.PetTeamShareReviseType.Nature] and #data[PetUIModuleEnum.PetTeamShareReviseType.Nature] then
          for _, item in ipairs(data[PetUIModuleEnum.PetTeamShareReviseType.Nature]) do
            local ItemData = {
              petData = petData,
              type = PetUIModuleEnum.PetTeamShareReviseType.Nature,
              UiData = item
            }
            table.insert(List, ItemData)
          end
        end
        if data[PetUIModuleEnum.PetTeamShareReviseType.Blood] and #data[PetUIModuleEnum.PetTeamShareReviseType.Blood] then
          for _, item in ipairs(data[PetUIModuleEnum.PetTeamShareReviseType.Blood]) do
            local ItemData = {
              petData = petData,
              type = PetUIModuleEnum.PetTeamShareReviseType.Blood,
              UiData = item
            }
            table.insert(List, ItemData)
          end
        end
      end
    end
    self.Scrollview:InitList(List)
    self.NRCText:SetText(LuaText.lineup_code_diff_modify)
  elseif 2 == openType then
    local SolveAllLostList = SolveAllDiffList
    local List = {}
    for i, v in pairs(SolveAllLostList) do
      local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(i)
      local data = v
      if data and data[PetUIModuleEnum.PetTeamShareReviseType.Skill] and #data[PetUIModuleEnum.PetTeamShareReviseType.Skill] then
        for i, item in pairs(data[PetUIModuleEnum.PetTeamShareReviseType.Skill]) do
          local ItemData = {
            petData = petData,
            type = PetUIModuleEnum.PetTeamShareReviseType.Skill,
            UiData = item
          }
          table.insert(List, ItemData)
        end
      end
    end
    self.Scrollview:InitList(List)
    self.NRCText:SetText(LuaText.lineup_code_lack_modify)
  end
  self:LoadAnimation(0)
end

function UMG_DetailsDifferences_C:ClosePanel()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_DetailsDifferences_C:ClosePanel")
  self:LoadAnimation(2)
end

function UMG_DetailsDifferences_C:OnOK()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_DetailsDifferences_C:OnOK")
  self:LoadAnimation(2)
end

function UMG_DetailsDifferences_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_DetailsDifferences_C:OnDeactive()
end

function UMG_DetailsDifferences_C:OnAddEventListener()
end

return UMG_DetailsDifferences_C
