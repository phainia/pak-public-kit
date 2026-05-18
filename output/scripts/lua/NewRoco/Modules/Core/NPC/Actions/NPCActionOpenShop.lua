local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local Base = NPCActionBase
local NPCActionOpenShop = Base:Extend("NPCActionOpenShop")

function NPCActionOpenShop:Ctor(Owner, Config, Info, OwnerNpc)
  Base.Ctor(self, Owner, Config, Info, OwnerNpc)
  self.ShopID = tonumber(self.Config.action_param1) or 0
end

function NPCActionOpenShop:ExecuteWithModel()
  NRCModeManager:GetCurMode():DisablePanelByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  if 101 ~= self.ShopID and 102 ~= self.ShopID then
    local nameComponent = self:GetNameComponent()
    if nameComponent then
      nameComponent:SetComponentTickEnabled(false)
      nameComponent:SetRenderStatus(false, MainUIModuleEnum.DisableHudOpSource.EnterNpcShop)
    end
  else
    _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.RecycleAllThrowPets)
  end
  if 107 == self.ShopID or 108 == self.ShopID or 109 == self.ShopID then
    NRCProfilerLog:NRCClickBtn(true, "TailorShop")
  else
    NRCProfilerLog:NRCClickBtn(true, "NPCShop")
  end
  _G.NRCModuleManager:DoCmd(NPCShopUIModuleCmd.FinishNPCActionOpenShop, self)
end

function NPCActionOpenShop:Finish(success, data, param)
  if not self.SkipSubmit then
    NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
  end
  if 101 ~= self.ShopID and 102 ~= self.ShopID then
    local nameComponent = self:GetNameComponent()
    if nameComponent then
      nameComponent:SetComponentTickEnabled(true)
      nameComponent:SetRenderStatus(true, MainUIModuleEnum.DisableHudOpSource.EnterNpcShop)
    end
  end
  Base.Finish(self, success, data, param)
end

function NPCActionOpenShop:GetNameComponent()
  local OwnerView = self:GetOwnerNPCView()
  return OwnerView and OwnerView:GetComponentByClass(UE4.URocoWidgetComponent)
end

return NPCActionOpenShop
