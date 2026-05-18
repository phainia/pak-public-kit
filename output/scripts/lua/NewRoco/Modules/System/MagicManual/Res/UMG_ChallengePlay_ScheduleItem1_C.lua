local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ChallengePlay_ScheduleItem1_C = Base:Extend("UMG_ChallengePlay_ScheduleItem1_C")

function UMG_ChallengePlay_ScheduleItem1_C:OnConstruct()
end

function UMG_ChallengePlay_ScheduleItem1_C:OnDestruct()
end

function UMG_ChallengePlay_ScheduleItem1_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self:SetInfo()
end

function UMG_ChallengePlay_ScheduleItem1_C:SetInfo()
  self.Title:SetText(self.index)
  local PetBaseConf = _G.DataConfigManager:GetPetbaseConf(self.data.pet_base_id)
  if PetBaseConf then
    local modelConf = _G.DataConfigManager:GetModelConf(PetBaseConf.model_conf)
    if modelConf then
      self.PetIcon:SetPath(modelConf.icon)
      self.Text_Content:SetText(PetBaseConf.name)
    end
  end
  local num = math.floor(self.data.use_rate / 10)
  self.Text_AppearanceRate:SetText(string.format("%d%s", num, "%"))
end

function UMG_ChallengePlay_ScheduleItem1_C:OnItemSelected(_bSelected)
end

function UMG_ChallengePlay_ScheduleItem1_C:OnDeactive()
end

return UMG_ChallengePlay_ScheduleItem1_C
