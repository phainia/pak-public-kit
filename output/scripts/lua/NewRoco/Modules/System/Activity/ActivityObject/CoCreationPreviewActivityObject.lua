local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectBase")
local CoCreationPreviewActivityObject = Base:Extend("CoCreationPreviewActivityObject")

function CoCreationPreviewActivityObject:OnConstruct(_conf)
  self.CoCreationConf = _G.DataConfigManager:GetActivityPlayerCoCreation(_conf.base_id[1])
  self:AddActivityExpiredCallback("CoCreationPetExpired", self, self.CloseReviewPanel)
end

function CoCreationPreviewActivityObject:GetActivityNumTitle()
  local num = self.CoCreationConf.activity_number
  local numStr = ""
  for i = 1, 3 do
    local modNum = num % 10
    numStr = tostring(modNum) .. numStr
    num = num // 10
  end
  return numStr
end

function CoCreationPreviewActivityObject:GetPetImagePath()
  if self.bStart then
    return self.CoCreationConf.start_pet_img
  else
    return self.CoCreationConf.preview_pet_img
  end
end

function CoCreationPreviewActivityObject:GetPetBaseId()
  return self.CoCreationConf.show_petbase_id
end

function CoCreationPreviewActivityObject:GetTrackPetId()
  return self.CoCreationConf.track_petbase_id
end

function CoCreationPreviewActivityObject:OnSvrUpdateActivityData(cmdId, _updateData, _initUpdate)
  if _updateData then
    self.co_creation_data = _updateData
  end
end

function CoCreationPreviewActivityObject:GetFruitRewardId()
  return self.CoCreationConf.fruit_reward_id
end

function CoCreationPreviewActivityObject:CloseReviewPanel()
  local module = _G.NRCModuleManager:GetModule("ActivityModule")
  local panel = module:GetPanel("ActivityReview")
  if panel then
    panel:ClosePanel()
  end
end

return CoCreationPreviewActivityObject
