local Base = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local NPCActionHomeStopWait = Base:Extend("NPCActionHomeStopWait")

function NPCActionHomeStopWait:Ctor(owner, config, info)
  Base.Ctor(self, owner, config, info)
  local serverData = self.Owner.owner.serverData
  if not (serverData and serverData.base) or not serverData.home_pet then
    Log.Dump(serverData, 3, "invalid serverData")
    self:Finish(false)
    return
  end
  self.ownerPetGid = serverData.home_pet.home_pet_info.pet_gid
  self.ownerActorId = serverData.base.actor_id
end

function NPCActionHomeStopWait:Execute()
  Base.Execute(self)
  local petName = ""
  local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.ownerPetGid)
  if petData then
    petName = petData.name
  end
  local context = DialogContext()
  context:SetTitle(LuaText.TIPS):SetContent(LuaText.home_pet_feed_text_3):SetButtonText(LuaText.tips_dialog_butten_accept, LuaText.tips_dialog_butten_cancel):SetMode(DialogContext.Mode.OK_CANCEL):SetCloseOnCancel(true):SetCloseOnOK(true):SetCallback(self, self.ReqCancelFeed)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, context)
end

function NPCActionHomeStopWait:ReqCancelFeed(bConfirm)
  if bConfirm then
    local req = ProtoMessage:newZoneHomePetFeedCancelReq()
    req.npc_obj_id = self.ownerActorId
    req.pet_gid = self.ownerPetGid
    _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_HOME_PET_FEED_CANCEL_REQ, req, self, self.OnRspCancelFeed)
  else
    self:Finish(false)
  end
end

function NPCActionHomeStopWait:OnRspCancelFeed(rsp)
  Log.Dump(rsp, 3, "ZONE_HOME_PET_FEED_CANCEL_REQ")
  if 0 == rsp.ret_info.ret_code then
    self:Finish(true)
  else
    self:Finish(false)
  end
end

return NPCActionHomeStopWait
