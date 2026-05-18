local FsmSerializeUtils = {}

function FsmSerializeUtils:ToFlowchart(fsm, dir)
  local strings = {
    "```mermaid",
    string.format("graph %s", dir or "TD")
  }
  table.insert(strings, string.format("* --> %s", fsm.initialStateName))
  for _, state in ipairs(fsm.states) do
    for _, transition in ipairs(state.transitions) do
      if transition.event == "FINISHED" then
        table.insert(strings, string.format("%s --> %s", state:GetName(), transition.next))
      else
        table.insert(strings, string.format("%s --%s--> %s", state:GetName(), transition.event, transition.next))
      end
    end
  end
  table.insert(strings, "```\n")
  for _, state in ipairs(fsm.states) do
    self:InternalStateToFlowchart(state, strings)
  end
  return table.concat(strings, "\n")
end

function FsmSerializeUtils:InternalStateToFlowchart(state, strings)
  table.insert(strings, "```mermaid")
  table.insert(strings, "graph TB")
  table.insert(strings, string.format("subgraph %s", state:GetName()))
  for i = 1, #state.actions do
    local this = state.actions[i]
    local follow = state.actions[i + 1]
    if follow then
      table.insert(strings, string.format("%s --> %s", this.class.name, follow.class.name))
    else
      table.insert(strings, this.class.name)
    end
  end
  table.insert(strings, "end")
  table.insert(strings, "```\n")
end

return FsmSerializeUtils
