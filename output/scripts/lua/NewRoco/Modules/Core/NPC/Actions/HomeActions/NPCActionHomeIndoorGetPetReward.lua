local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local PetUtils = require("NewRoco.Utils.PetUtils")
local NPCActionHomeIndoorGetPetReward = NPCActionBase:Extend("NPCActionHomeIndoorGetPetReward")

function NPCActionHomeIndoorGetPetReward:Ctor(owner, config, info)
  NPCActionBase.Ctor(self, owner, config, info)
end

function NPCActionHomeIndoorGetPetReward:Execute()
  NPCActionBase.Execute(self)
  local serverData = self.Owner.owner.serverData
  if not (serverData and serverData.base) or not serverData.home_pet then
    Log.Dump(serverData, 3, "invalid serverData")
    self:Finish(false)
    return
  end
  local req = ProtoMessage:newZoneHomePetFetchAwardReq()
  req.npc_obj_id = self.Owner.owner.serverData.base.actor_id
  req.pet_gid = self.Owner.owner.serverData.home_pet.home_pet_info.pet_gid
  Log.Dump(req, 3, "ZONE_HOME_PET_FETCH_AWARD_REQ")
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_HOME_PET_FETCH_AWARD_REQ, req, self, self.OnGetPetRewardRsp, false, true)
end

function NPCActionHomeIndoorGetPetReward:OnGetPetRewardRsp(rsp)
  Log.Dump(rsp, 3, "OnGetPetRewardRsp")
  if 0 == rsp.ret_info.ret_code then
    if rsp.fetch_goods then
      local fakeGoodsItems = {}
      for _, good in ipairs(rsp.fetch_goods) do
        local fakeItem = _G.ProtoMessage:newGoodsItem()
        fakeItem.num = good.goods_num
        fakeItem.id = good.goods_id
        fakeItem.type = good.goods_type
        if good.goods_award_type == _G.ProtoEnum.FlowReason.FLOW_REASON_HOME_PET_SURPRISE_REWARD then
          fakeItem.reward_reason = _G.ProtoEnum.FlowReason.FLOW_REASON_HOME_PET_SURPRISE_REWARD
          fakeItem.tag = _G.Enum.RewardTag.RTA_ADDITIONAL
        end
        table.insert(fakeGoodsItems, fakeItem)
      end
      _G.NRCModuleManager:DoCmd(_G.NPCShopUIModuleCmd.OpenNPCShopItemRewardsPanel, fakeGoodsItems, LuaText.battlepassmodule_4, nil, true)
    end
    self:Finish(true)
  elseif rsp.ret_info.ret_code == ProtoEnum.MOBA_RET.SceneErr.ERR_SCENE_HOME_PET_STATUS_ERROR and self.Owner.owner and self.Owner.owner:IsLogicStatus(_G.Enum.SpaceActorLogicStatus.SALS_HOME_PET_IN_PRODUCT) then
    local context = DialogContext()
    context:SetTitle(LuaText.TIPS):SetMode(DialogContext.Mode.OK):SetContent(LuaText.home_pet_steal_text_3):SetCallbackOkOnly(self, function()
      self:Finish(false)
    end)
    _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, context)
  else
    local tipsKey = string.format("Error_Code_%d", rsp.ret_info.ret_code)
    local tips = LuaText[tipsKey]
    if tips then
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, tips)
    end
    self:Finish(false)
  end
end

return NPCActionHomeIndoorGetPetReward
