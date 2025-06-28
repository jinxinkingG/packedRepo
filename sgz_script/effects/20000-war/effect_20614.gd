extends "effect_20000.gd"

# 知机限定技
#【知机】大战场，限定技。找出战场破局点，制定针对性的策略。你指定一个“知不高于你的敌方武将”发动，本场战争中对此目标武将：我方发动计策的成功率 +10%，主动攻击时白兵战士气 +8。被你指定的武将死亡或者脱离战场，重置本技能冷却。

const EFFECT_ID = 20614
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20614_start() -> void:
	var targetIds = []
	for targetId in get_enemy_targets(me):
		var enemy = DataManager.get_war_actor(targetId)
		if enemy.actor().get_wisdom() > actor.get_wisdom():
			continue
		targetIds.append(targetId)
	if targetIds.empty():
		var msg = "未能找到敌方弱点"
		play_dialog(actorId, msg, 3, 2999)
		return
	if not wait_choose_actors(targetIds):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20614_selected()->void:
	var targetId = DataManager.get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)

	var msg = "将{0}设定为【{1}】目标\n可否？".format([
		wa.get_name(), ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2001, true)
	map.next_shrink_actors = [targetId, actorId]
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20614_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)
	ske.set_war_skill_val(targetId)
	ske.cost_war_cd(99999)
	ske.war_report()
	
	var msg = "{0}不知兵机而居冲要\n合力破之，敌势必挫！".format([
		DataManager.get_actor_naughty_title(targetId, actorId)
	])
	play_dialog(actorId, msg, 0, 2999)
	return
