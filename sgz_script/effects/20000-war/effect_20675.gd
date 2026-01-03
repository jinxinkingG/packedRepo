extends "effect_20000.gd"

# 虚实效果
#【虚实】大战场，主将锁定技。你方武将受到计策伤害时，概率产生以下效果之一：①避实就虚，本次计策伤害无效；②将虚就实，累计记录本回合你方武将受到的伤兵数值X，你下次主动施放伤兵计策时，对主要计策目标增伤X。③判虚错实，令该计策使用者机动力+3。

const AP_BONUS = 3
const RESULT_A_CHANCE = 40
const RESULT_AB_CHANCE = 80

func on_trigger_20002() -> bool:
	var se = DataManager.get_current_stratagem_execution()
	var rnd = get_random_result(se)
	if rnd < RESULT_A_CHANCE:
		change_scheme_damage_rate(-100)
		se.skip_redo = 1
	return false

func on_trigger_20009() -> bool:
	var se = DataManager.get_current_stratagem_execution()
	var rnd = get_random_result(se)

	var fromId = se.get_action_id(actorId)
	if fromId != ske.actorId:
		return false
	var damage = se.get_total_damage()
	if damage <= 0:
		return false
	if rnd < RESULT_A_CHANCE:
		return false
	if rnd < RESULT_AB_CHANCE:
		var total = ske.get_war_skill_val_int()
		total += damage
		ske.set_war_skill_val(total)
		se.skip_redo = 1
		var msg = "用兵之道，能虚实彼己也\n{0}好计，必有报之".format([
			ActorHelper.actor(fromId).get_name(),
		])
		me.attach_free_dialog(msg, 2)
	else:
		se.skip_redo = 1
		var ap = ske.change_actor_ap(fromId, AP_BONUS)
		var msg = "虚实之道，难知如阴 ……\n（错判敌策\n（{1}获得 {2}机动力".format([
			ske.skill_name, ActorHelper.actor(fromId).get_name(), ap,
		])
		me.attach_free_dialog(msg, 3)
	return false

func on_trigger_20011() -> bool:
	var se = DataManager.get_current_stratagem_execution()
	var total = ske.get_war_skill_val_int()
	if total <= 0:
		return false
	var targetId = DataManager.get_env_int("计策.ONCE.伤害武将")
	if targetId != se.targetId:
		return false
	var targetWA = DataManager.get_war_actor(targetId)
	if targetWA == null:
		return false
	var damage = DataManager.get_env_int("计策.ONCE.伤害")
	var buff = min(total, targetWA.get_soldiers() - damage)
	if buff <= 0:
		return false
	total -= buff
	change_scheme_damage_value(actorId, ske.skill_name, buff)
	ske.set_war_skill_val(total)
	return false

func get_random_result(se:StratagemExecution) -> int:
	var key = "{0}.{1}".format([ske.skill_name, actorId])
	var rnd = se.get_env_int(key)
	if rnd <= 0:
		# 第一次触发时，记录随机结果到计策环境
		rnd = randi() % 100 + 1
		se.set_env(key, rnd)
	return rnd
