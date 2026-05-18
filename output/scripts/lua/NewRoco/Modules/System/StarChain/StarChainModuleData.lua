local StarChainModuleData = _G.NRCData:Extend("StarChainModuleData")

function StarChainModuleData:Ctor()
  self.SourceReturnFlag = nil
  self.SourceReturnFunc = nil
  self.Call = nil
  self.IsOpenBuyDiamondGiftItem = false
  self.IsCall = false
  NRCData.Ctor(self)
end

function StarChainModuleData:GetShopSourceReturnFlag()
  return self.SourceReturnFlag
end

function StarChainModuleData:SetShopSourceReturnFlag(SourceReturnFlag)
  self.SourceReturnFlag = SourceReturnFlag
end

function StarChainModuleData:GetShopSourceReturnFunc()
  return self.SourceReturnFunc, self.Call
end

function StarChainModuleData:SetShopSourceReturnFunc(SourceReturnFunc, Call)
  self.SourceReturnFunc = SourceReturnFunc
  self.Call = Call
end

function StarChainModuleData:SetIsOpenBuyDiamondGiftItem(_IsOpenBuyDiamondGiftItem)
  self.IsOpenBuyDiamondGiftItem = _IsOpenBuyDiamondGiftItem
end

function StarChainModuleData:GetIsOpenBuyDiamondGiftItem()
  return self.IsOpenBuyDiamondGiftItem
end

function StarChainModuleData:SetIsCall(_IsCall)
  self.IsCall = _IsCall
end

function StarChainModuleData:GetIsCall()
  return self.IsCall
end

return StarChainModuleData
