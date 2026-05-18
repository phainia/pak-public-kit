local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local DebugTabCollect = require("NewRoco.Modules.System.Debug.Tabs.DebugTabCollect")
local DebugTabHistory = require("NewRoco.Modules.System.Debug.Tabs.DebugTabHistory")
local JsonUtils = require("Common.JsonUtils")
local UMG_DebugButton1_2_C = Base:Extend("UMG_DebugButton1_2_C")

function UMG_DebugButton1_2_C:OnConstruct()
end

function UMG_DebugButton1_2_C:OnDestruct()
end

function UMG_DebugButton1_2_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.uiData = _data
  self:RefreshPanel()
  self:SetSelectable(false)
  self.Button.OnClicked:Add(self, self.Onclick)
  self.Caption:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("000000FF"))
end

function UMG_DebugButton1_2_C:Onclick()
  if not self.panel then
    self.panel = NRCModuleManager:DoCmd(DebugModuleCmd.GetGMPanel)
  end
  if self.Callback then
    if self.uiData[4] ~= nil and self.uiData[4][1] == "IsCollect" then
      local CollectInfos = JsonUtils.LoadSaved("DebugTabCollect", {})
      for i, v in ipairs(CollectInfos) do
        for j = 2, #v do
          if v[j] == self.ButtonName then
            self.Caption:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("960000FF"))
            break
          end
        end
      end
      for i = 1, #self.panel.Categories do
        if self.panel.Categories[i][1] == self.panel.CurrentTabName then
          local ButtonPath
          if nil ~= self.panel.Categories[i].SecondTabInfo then
            for j, k in ipairs(self.panel.Categories[i].SecondTabInfo) do
              if k[1] == self.panel.CurrentSecondTabName then
                ButtonPath = k[2]
              end
            end
          else
            ButtonPath = self.panel.Categories[i][2]
          end
          local Instruction = self.Instruction
          local UseType = self.UseType
          local Order = self.Order
          if "NewRoco.Modules.System.Debug.Tabs.DebugTabGlobalSearch" == ButtonPath and self.uiData.LuaFileName then
            ButtonPath = "NewRoco.Modules.System.Debug.Tabs." .. self.uiData.LuaFileName
          end
          if "NewRoco.Modules.System.Debug.Tabs.DebugTabHistory" == ButtonPath then
            if self.uiData.LuaFilePath then
              ButtonPath = self.uiData.LuaFilePath
            else
              ButtonPath = self.uiData[1]
            end
          end
          if "NewRoco.Modules.System.Debug.Tabs.DebugTabCollect" == ButtonPath and self.uiData.LuaFilePath then
            ButtonPath = self.uiData.LuaFilePath
          end
          if self.uiData.GMCommandGroupName then
            ButtonPath = self.uiData.GMCommandGroupName
          end
          DebugTabCollect:SaveBtnInfo(self.ButtonName, ButtonPath, Instruction, UseType, Order)
        end
      end
    elseif self.uiData[4] ~= nil and self.uiData[4][1] == "Collected" then
      if self.ButtonName == self.uiData[1] then
        DebugTabCollect:DeleteBtnInfo(self.ButtonName)
        self.Caption:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("960000FF"))
      end
    elseif self.uiData[4] ~= nil and self.uiData[4][2] == "IsHistory" then
      local CollectInfos = JsonUtils.LoadSaved("DebugTabHistory", {})
      for i, v in ipairs(CollectInfos) do
        for j = 2, #v do
          if v[j] == self.ButtonName then
            self.Caption:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("960000FF"))
            break
          end
        end
      end
    elseif self.uiData[4] ~= nil and self.uiData[4][2] == "Cleared" then
      if self.ButtonName == self.uiData[1] then
        DebugTabHistory:DeleteBtnInfo(self.ButtonName)
        self.Caption:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("960000FF"))
      end
    else
      for i = 1, #self.panel.Categories do
        if self.panel.Categories[i][1] == self.panel.CurrentTabName then
          local ButtonPath
          if nil ~= self.panel.Categories[i].SecondTabInfo then
            for j, k in ipairs(self.panel.Categories[i].SecondTabInfo) do
              if k[1] == self.panel.CurrentSecondTabName then
                ButtonPath = k[2]
              end
            end
          else
            ButtonPath = self.panel.Categories[i][2]
          end
          local Instruction = self.Instruction
          local UseType = self.UseType
          local Order = self.Order
          if self.uiData.LuaFileName then
            ButtonPath = "NewRoco.Modules.System.Debug.Tabs." .. self.uiData.LuaFileName
          end
          if self.uiData.LuaFilePath then
            ButtonPath = self.uiData.LuaFilePath
          end
          if self.uiData.GMCommandGroupName then
            ButtonPath = self.uiData.GMCommandGroupName
          end
          DebugTabHistory:SaveBtnInfo(self.ButtonName, ButtonPath, Instruction, UseType, Order)
        end
      end
      self.Callback(self.CallbackOwner, self.ButtonName, self.panel)
      local gmcommand = self:GetGMCommandByBtnName(self.ButtonName)
      NRCModuleManager:DoCmd(_G.DebugModuleCmd.SetHistory, self.ButtonName .. "\230\137\167\232\161\140\230\136\144\229\138\159\239\188\140gm\229\145\189\228\187\164\230\152\175:" .. gmcommand)
      if self.panel.CurrentTabName == "\229\142\134\229\143\178" then
        NRCModuleManager:DoCmd(_G.DebugModuleCmd.RefreshHistory)
      end
    end
  end
end

function UMG_DebugButton1_2_C:RefreshPanel()
  self.ButtonName = self.uiData[1]
  self.Caption:SetText(self.ButtonName or "None")
  self.Callback = self.uiData[2]
  if #self.uiData > 3 then
    if self.uiData[3] ~= nil and nil ~= self.uiData[3].Panel then
      self.panel = self.uiData[3].Panel
    else
      if self.uiData[3] then
        self.panel = self.uiData[3]
      else
      end
    end
  end
  if self.uiData[3] ~= nil and nil ~= self.uiData[3].Panel then
    self.CallbackOwner = self.uiData[3]
  else
    self.CallbackOwner = nil
  end
  self.Instruction = self.uiData[5]
  self.UseType = self.uiData[6]
  self.Order = self.uiData[7]
  self.Describe = self.uiData[8]
end

function UMG_DebugButton1_2_C:GetMaxTableIndex(table)
  local maxIndex = 1
  for i, val in pairs(table) do
    if type(i) == "number" and i > maxIndex then
      maxIndex = i
    end
  end
  return maxIndex
end

function UMG_DebugButton1_2_C:GetGMCommandByBtnName(btnName)
  local gmcommand = "\232\175\165\230\140\137\233\146\174\230\151\160\230\179\149\233\133\141\231\189\174\229\140\150\239\188\140\230\151\160\229\175\185\229\186\148\231\154\132gm\229\145\189\228\187\164"
  local GMGroupConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.GM_GROUP_CONF):GetAllDatas()
  local maxGroupIndex = self:GetMaxTableIndex(GMGroupConf)
  for i = 1, maxGroupIndex do
    if GMGroupConf[i] and btnName == GMGroupConf[i].button_name then
      gmcommand = GMGroupConf[i].gm_group
    end
  end
  return gmcommand
end

return UMG_DebugButton1_2_C
