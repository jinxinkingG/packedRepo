extends "effect_30000.gd"

#疾驰效果实现
#【疾驰】小战场，锁定技。每回合你第一次行动，若不是攻击，则你可以额外行动一次。（武将有两动，第一动，如果打到对手，则不发动疾驰效果；第一动如果是移动，即没有攻击对手，则还可以两动。）

func on_trigger_30007()->bool:
	var unit = get_action_unit()
	if unit == null or unit.disabled:
		return false
	if unit.leaderId != me.actorId:
		return false
	if unit.get_unit_type() != "将":
		return false
	# 非第一动，跳过
	if unit.wait_action_times != unit.get_action_times() - 1:
		return false
	ske.battle_cd(1)
	if unit.last_action_name != "移动":
		return false
	unit.wait_action_times += 1
	return false
