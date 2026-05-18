require("UnLuaEx")
local Timer = require("Utils.Timer")
local UMG_BattleSettlementPetEntry_C = NRCUmgClass:Extend("")

function UMG_BattleSettlementPetEntry_C:Construct()
  self.timer = Timer()
end

function UMG_BattleSettlementPetEntry_C:Tick(MyGeometry, InDeltaTime)
  self.timer:Update(InDeltaTime)
end

function UMG_BattleSettlementPetEntry_C:SetData(oldPetData, newPetData)
  local petBaseCfg = _G.DataConfigManager:GetPetbaseConf(newPetData.base_conf_id)
  if not petBaseCfg then
    Log.ErrorFormat("pet base cfg is nil %d", newPetData.base_conf_id)
    return
  end
  local modelConf = _G.DataConfigManager:GetModelConf(petBaseCfg.model_conf)
  if not modelConf then
    Log.ErrorFormat("pet model cfg is nil %d", petBaseCfg.model_conf)
    return
  end
  self.Icon:SetPath(modelConf.icon)
  self.NameTxt:SetText(petBaseCfg.name)
  self.LevelTxt:SetText(newPetData.level)
  local lastLevelUpExp = 1 == oldPetData.level and 0 or _G.DataConfigManager:GetPetLevelConf(oldPetData.level - 1).pet_exp
  local oldPetLevelCfg = _G.DataConfigManager:GetPetLevelConf(oldPetData.level)
  local newLastLevelUpExp = oldPetData.level == newPetData.level and lastLevelUpExp or _G.DataConfigManager:GetPetLevelConf(newPetData.level - 1).pet_exp
  local petLevelCfg = oldPetData.level == newPetData.level and oldPetLevelCfg or _G.DataConfigManager:GetPetLevelConf(newPetData.level)
  if not petLevelCfg then
    Log.ErrorFormat("pet level cfg is nil, level %d", newPetData.level)
  end
  local curPercent = (oldPetData.exp - lastLevelUpExp) / (oldPetLevelCfg.pet_exp - lastLevelUpExp)
  local targetPercent = (newPetData.exp - newLastLevelUpExp) / (petLevelCfg.pet_exp - newLastLevelUpExp)
  self.LevelHintTxt:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.ExpChangeTxt:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.ExpProgressBar:SetPercent(curPercent)
  if curPercent ~= targetPercent or oldPetData.level ~= newPetData.level then
    self.timer:After(1.5, function()
      self:PlayAnimation(self.AddExp)
      local tweenData = {percent = curPercent}
      if newPetData.level > oldPetData.level then
        self.LevelHintTxt:SetVisibility(UE4.ESlateVisibility.Visible)
        self.ExpChangeTxt:SetVisibility(UE4.ESlateVisibility.Hidden)
        self.timer:Tween(1.25, tweenData, {percent = 1}, "out-quart")
        self.timer:During(1.25, function()
          self.ExpProgressBar:SetPercent(tweenData.percent)
        end, function()
          self:BindToAnimationFinished(self.LevelUP, {
            self,
            function(self)
              self:PlayAnimation(self.AddExp)
              tweenData.percent = 0
              self.timer:Tween(1.25, tweenData, {percent = targetPercent}, "out-quart")
              self.timer:During(1.25, function()
                self.ExpProgressBar:SetPercent(tweenData.percent)
              end)
            end
          })
          self:PlayAnimation(self.LevelUP)
        end)
      else
        self.LevelHintTxt:SetVisibility(UE4.ESlateVisibility.Hidden)
        self.ExpChangeTxt:SetVisibility(UE4.ESlateVisibility.Visible)
        self.ExpChangeTxt:SetText(string.format("+%d", newPetData.exp - oldPetData.exp))
        self.timer:Tween(1.25, tweenData, {percent = targetPercent}, "out-quart")
        self.timer:During(1.25, function()
          self.ExpProgressBar:SetPercent(tweenData.percent)
        end)
      end
    end)
  end
end

return UMG_BattleSettlementPetEntry_C
