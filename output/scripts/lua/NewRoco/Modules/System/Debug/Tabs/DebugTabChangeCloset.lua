local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabChangeCloset = Base:Extend("DebugTabChangeCloset")

function DebugTabChangeCloset:Ctor()
  Base.Ctor(self)
end

function DebugTabChangeCloset:SetupTabs()
end

function DebugTabChangeCloset:ChangeFashionSuits(name, panel, id)
  local fashionSuitsId
  if panel then
    fashionSuitsId = panel:GetInputNumber()
  else
    fashionSuitsId = id
  end
  if 0 == fashionSuitsId then
    fashionSuitsId = tonumber(id)
  end
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local salonIds = player:GetSalonIds()
  local fashionSuitConf = _G.DataConfigManager:GetFashionSuitsConf(fashionSuitsId)
  local fashionIds = fashionSuitConf.item_id
  _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetDefaultSuit, fashionIds, salonIds, nil, false)
  _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.OnCmdSetFashionDataReq, 1, fashionIds)
end

function DebugTabChangeCloset:ChangeFashionItem(name, panel, id)
  local fashionId
  if panel then
    fashionId = panel:GetInputNumber()
  else
    fashionId = id
  end
  if 0 == fashionId then
    fashionId = tonumber(id)
  end
  local newFashionItemConf = _G.DataConfigManager:GetFashionItemConf(fashionId)
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local fashionItems = player:GetFashionItems()
  local salonIds = player:GetSalonIds()
  local newFashionIds = {fashionId}
  if fashionItems and #fashionItems > 0 then
    for k, v in pairs(fashionItems) do
      if v and 0 ~= v.wearing_item_id then
        local fashionItemConf = _G.DataConfigManager:GetFashionItemConf(v.wearing_item_id)
        if fashionItemConf and fashionItemConf.type ~= newFashionItemConf.type then
          table.insert(newFashionIds, v.item_id)
        end
      end
    end
  end
  _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetDefaultSuit, newFashionIds, salonIds, nil, false)
  _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.OnCmdSetFashionDataReq, 1, newFashionIds)
end

function DebugTabChangeCloset:ChangeSalonItem(name, panel, id)
  local salonConfId
  if panel then
    salonConfId = panel:GetInputNumber()
  else
    salonConfId = id
  end
  if 0 == salonConfId then
    salonConfId = tonumber(id)
  end
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local fashionItems = player:GetFashionItems()
  _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetDefaultSuit, fashionItems, {
    {item_wear_id = salonConfId, color_wear_id = 1}
  }, nil, false)
  _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.SetBeauty, salonConfId, false, 1)
  _G.NRCModuleManager:DoCmd(_G.AppearanceModuleCmd.OnCmdSetSalonDataReq)
end

return DebugTabChangeCloset
