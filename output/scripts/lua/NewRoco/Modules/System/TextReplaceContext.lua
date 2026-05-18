local Class = _G.MakeSimpleClass
local TextReplaceContext = Class("TextReplaceContext")

function TextReplaceContext:Ctor(Context)
  local Info = Context and Context.optionInfo
  local PetGID = Info and Info.enable_opt_gid or 0
  self.Params = Info and Info.cur_action_info and Info.cur_action_info.begin_act_params
  if PetGID and PetGID > 0 then
    self.PetData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(PetGID)
    self.PetBaseConf = _G.DataConfigManager:GetPetbaseConf(self.PetData.base_conf_id)
  end
  if Context and Context.owner and Context.owner.serverData then
    self.NpcServerData = Context.owner.serverData
  end
end

return TextReplaceContext
