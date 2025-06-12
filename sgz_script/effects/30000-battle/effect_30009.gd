extends "effect_30000.gd"

#神武锁定技，及追义效果实现 
#【神武】小战场，锁定技。你为白刃战进攻方，己方单位攻击敌兵的行动结束前，若未击杀敌兵，追加1次50%伤害的攻击。
#【追义】大战场，锁定技。你方拥有<神武>技能的武将，其在白刃战防守方也可触发<神武>效果。

func on_trigger_30009()->bool:
	if me.actorId == bf.get_defender_id():
		# 小战场守方跳过
		# 守方判断【追义】
		if SkillRangeBuff.find_for_war_vstate("无条件神武", me.wvId).empty():
			ske.set_battle_skill_val([0, 0], 1)
			return false
	# 打开神武标记
	ske.set_battle_skill_val([1, 0], 1)
	return false

func on_trigger_30007()->bool:
	var flags = ske.get_battle_skill_val_int_array()
	if flags.empty() or flags[0] != 1:
		return false

	var unit = get_action_unit()
	if unit == null or unit.disabled:
		return false
	if unit.leaderId != me.actorId:
		# 非我方单位跳过
		return false
	if unit.wait_action_times != 0:
		# 非最后一击，跳过
		return false

	var last_action = unit.last_action_name
	if last_action != "攻击" and last_action != "射箭":
		return false

	if unit.last_attack_units.empty():
		# 最后一击目标丢失
		return false
	var target = get_battle_unit(unit.last_attack_units[0])
	if target == null or target.disabled:
		# 没找到或已经被击杀
		return false

	if flags[1] == unit.unitId + 1:
		return false
	# 设置追击标记，+1 以避免 0
	flags[1] = unit.unitId + 1
	ske.set_battle_skill_val(flags, 1)
	unit.remove_action_task()
	var action_dic = {
		"单位ID": unit.unitId,
		"行为方式": last_action,
		"目标坐标": "{0},{1}".format([
			target.unit_position.x,
			target.unit_position.y
		])
	}
	unit.other_wait_type = last_action
	unit.wait_action_times = 1
	unit.append_once_attack_tag(ske.skill_name, 9)
	unit.append_once_damage_rate(0.5)
	DataManager.battle_first_sort.append(action_dic)
	return false
