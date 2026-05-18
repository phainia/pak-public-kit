local FakePerformConf = _G.Class("FakePerformConf")

function FakePerformConf:Ctor(skill_path)
  self.id = 0
  self.skill_path = skill_path
  self.performer = {}
  self.skill_blackboard_value = {}
  self.out_value = {}
  self.commands = {}
end

function FakePerformConf:AddPerformer(key, npc_id, delete_model, character_index, blackboard_key)
  table.insert(self.performer, {
    key = key,
    npc_id = npc_id,
    delete_model = delete_model,
    character_index = character_index,
    blackboard_key = blackboard_key
  })
end

function FakePerformConf:AddSkillBlackboardValue(key, delete_model)
  table.insert(self.skill_blackboard_value, {key = key, delete_model = delete_model})
end

return FakePerformConf
