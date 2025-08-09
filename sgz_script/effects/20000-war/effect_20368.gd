extends "effect_20000.gd"

#弓阵锁定技
#【弓阵】大战场，主将锁定技。若你为战争守方，对方回合结束时，你发动弓阵，对对方全体武将造成40兵力伤害。

const EFFECT_ID = 20368
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const DAMAGE = 40

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func on_view_model_2001()->void:
	wait_for_skill_result_confirmation("")
	return

func effect_20368_AI_start():
	goto_step("start")
	return

func effect_20368_start():
	var wv = me.war_vstate()
	var enemyLeaderId = wv.get_enemy_vstate().main_actorId
	ske.cost_war_cd(1)
	var msg = "万——箭——齐发！\n（{0}发动【{1}】".format([
		me.get_name(), ske.skill_name,
	])
	play_dialog(me.actorId, msg, 0, 2000)
	SceneManager.play_war_animation("Strategy_CityArrows", enemyLeaderId, "")
	return

func effect_20368_2():
	var total = 0.0
	for targetId in get_enemy_targets(me, true, 999):
		total += DataManager.damage_sodiers(me.actorId, targetId, DAMAGE)
	var msg = "敌军兵力下降{0}".format([int(total)])
	play_dialog(me.actorId, msg, 1, 2001)
	return

func on_trigger_20016()->bool:
	return get_enemy_targets(me, true, 999).size() > 0
