require("UnLua")
local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local Base = NPCActionBase
local NPCActionPetGift = Base:Extend("NPCActionPetGift")

function NPCActionPetGift:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionPetGift:Execute()
  Log.Debug("NPCActionPetGift:Execute")
  Base.Execute(self)
  local Params = self.Info.begin_act_params
  if Params and #Params > 0 then
    self.GiftId = Params[1]
    self.Need = Params[2]
    self.Have = Params[3]
  end
  _G.NRCModuleManager:DoCmd(DialogueModuleCmd.OpenPetGiftPanel, self)
end

function NPCActionPetGift:Finish(success, data, param)
  Log.Debug("NPCActionPetGift:Finish")
  Base.Finish(self, success, data, param)
end

return NPCActionPetGift
