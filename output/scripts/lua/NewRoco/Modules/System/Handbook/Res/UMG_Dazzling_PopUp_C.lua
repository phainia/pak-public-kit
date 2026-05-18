local HandbookModuleEvent = reload("NewRoco.Modules.System.Handbook.HandbookModuleEvent")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_Dazzling_PopUp_C = _G.NRCPanelBase:Extend("UMG_Dazzling_PopUp_C")

function UMG_Dazzling_PopUp_C:OnActive(Record, SelectMutations)
  self:EnablePanel(Record, SelectMutations)
end

function UMG_Dazzling_PopUp_C:ItemCompletes(infos, selectMutations)
  for i = 1, #selectMutations do
    if PetUtils.CheckIsShiningChaos(selectMutations[i]) then
      local color = _G.DataConfigManager:GetPetGlobalConfig("hb_record_nightmare_color").str
      local colors = self:SplitString(color, ";")
      local iconPath = _G.DataConfigManager:GetPetGlobalConfig("hb_record_nightmare_icon").str
      local info = {
        mutationInfo = selectMutations[i],
        isChaos = true,
        colorA = colors[1],
        colorB = colors[2],
        particle = iconPath
      }
      table.insert(infos, info)
    elseif PetUtils.CheckIsCHAOS(selectMutations[i]) then
      local color = _G.DataConfigManager:GetPetGlobalConfig("hb_record_nightmare_color").str
      local colors = self:SplitString(color, ";")
      local iconPath = _G.DataConfigManager:GetPetGlobalConfig("hb_record_nightmare_icon").str
      local info = {
        mutationInfo = selectMutations[i],
        isChaos = true,
        colorA = colors[1],
        colorB = colors[2],
        particle = iconPath
      }
      table.insert(infos, info)
    end
  end
  local count = #infos
  local row = math.ceil(count / 3)
  for i = 1, row * 3 - count do
    table.insert(infos, {IsNull = true})
  end
  return infos
end

function UMG_Dazzling_PopUp_C:SplitString(inputString, delimiter)
  local result = {}
  for match in (inputString .. delimiter):gmatch("(.-)" .. delimiter) do
    table.insert(result, match)
  end
  return result
end

function UMG_Dazzling_PopUp_C:OnDeactive()
end

function UMG_Dazzling_PopUp_C:OnAddEventListener()
  self:AddButtonListener(self.NRCButton_42, self.OnClickNRCButton_42)
end

function UMG_Dazzling_PopUp_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_Dazzling_PopUp_C:OnDestruct()
end

function UMG_Dazzling_PopUp_C:OnPcClose()
  self:DispatchEvent(HandbookModuleEvent.OnCloseDazzlingPopUp, self.IsShiningGlass)
  self:DisablePanel()
end

function UMG_Dazzling_PopUp_C:CreateShineColorInfo(glass_info)
  local shineColorInfo = PetMutationUtils.DecodeShineColorId(glass_info)
  return shineColorInfo
end

function UMG_Dazzling_PopUp_C:OnAnimationFinished(anim)
  if anim == self.Pop_out then
    self:Disable()
  end
end

function UMG_Dazzling_PopUp_C:EnablePanel(Record, SelectMutations)
  self:Enable()
  self:PlayAnimation(self.Pop_in)
  self.Record = Record
  local infos = {}
  self.IsShiningGlass = false
  self.CheckIsShiningChaos = false
  for i = 1, #SelectMutations do
    if PetUtils.CheckIsShiningGlass(SelectMutations[i]) then
      self.IsShiningGlass = true
    end
    if PetUtils.CheckIsShiningChaos(SelectMutations[i]) then
      self.CheckIsShiningChaos = true
    end
  end
  self.Switcher:SetActiveWidgetIndex(self.IsShiningGlass and 1 or 0)
  if self.IsShiningGlass == false and false == self.CheckIsShiningChaos and Record.glass_infos and #Record.glass_infos > 0 then
    for i = 1, #Record.glass_infos do
      local glass_info = Record.glass_infos[i]
      if glass_info then
        local info = {
          info = self:CreateShineColorInfo(glass_info),
          mutationInfo = _G.Enum.MutationDiffType.MDT_GLASS
        }
        table.insert(infos, info)
      end
    end
  end
  if self.IsShiningGlass and Record.shine_glass_infos and #Record.shine_glass_infos > 0 then
    for i = 1, #Record.shine_glass_infos do
      local glass_info = Record.shine_glass_infos[i]
      if glass_info and (glass_info.glass_type == ProtoEnum.GlassType.GT_COMMON or glass_info.glass_type == ProtoEnum.GlassType.GT_HIDDEN) then
        for j = 1, #SelectMutations do
          local mutation = SelectMutations[j]
          if PetUtils.CheckIsShiningGlass(mutation) then
            local info = {
              info = self:CreateShineColorInfo(glass_info),
              mutationInfo = mutation
            }
            table.insert(infos, info)
            break
          end
        end
      end
    end
  end
  infos = self:ItemCompletes(infos, SelectMutations)
  if #infos > 6 then
    self.ScrollBox_0:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.ScrollBox_0:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self.MutationOption:InitGridView({})
  self.MutationOption:InitGridView(infos)
  if #infos > 0 then
    self.MutationOption:SelectItemByIndex(0)
  end
end

function UMG_Dazzling_PopUp_C:DisablePanel()
  if self.enableView then
    self:PlayAnimation(self.Pop_out)
  end
end

function UMG_Dazzling_PopUp_C:OnClickNRCButton_42()
  self:DispatchEvent(HandbookModuleEvent.OnCloseDazzlingPopUp, self.IsShiningGlass)
  self:DisablePanel()
end

return UMG_Dazzling_PopUp_C
