local ProtoEnum = require("Data.PB.ProtoEnum")
local ViewNPCBase = require("NewRoco.Modules.Core.NPC.ViewDropNPCBase")
local Base = ViewNPCBase
local BP_MiniGame_Coin_Opaque_C = Base:Extend("BP_MiniGame_Coin_Opaque_C")

function BP_MiniGame_Coin_Opaque_C:OnVisible()
  Base.OnVisible(self)
end

function BP_MiniGame_Coin_Opaque_C:ReceiveHit(MyComp, Other, OtherComp, SelfMoved, HitLocation, HitNormal, NormalImpulse, Hit)
  Base.ReceiveHit(self, MyComp, Other, OtherComp, SelfMoved, HitLocation, HitNormal, NormalImpulse, Hit)
  self:SendPosToServer(ProtoEnum.SetNpcPosType.SNPT_ITEM_DROP)
end

return BP_MiniGame_Coin_Opaque_C
