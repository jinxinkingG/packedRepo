extends "effect_20000.gd"

#秘计效果实现
#【秘计】大战场，锁定技。你是战争守方的场合：对方回合结束阶段，若敌方武将数＞你方武将数，对方需选择超出数量的武将回营。

const EFFECT_ID = 20252
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20016()->bool:
	# 必须先设 CD，避免 turn_control_end 重入
	ske.cost_war_cd(1)
	if me == null or me.disabled:
		return false
	var wv = me.war_vstate()
	if wv == null:
		return false
	var enemyWV = wv.get_enemy_vstate()
	if enemyWV == null:
		return false
	return wv.get_war_actors(false, true).size() < enemyWV.get_war_actors(false, true).size()

func effect_20252_AI_start():
	goto_step("start")
	return

func effect_20252_start():
	var msg = "敌势虽众，其心必异\n妾设秘计，可分而治之"
	play_dialog(actorId, msg, 2, 2000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_20252_2():
	var wv = me.war_vstate()
	var limit = wv.get_actors_count()
	var enemyWV = wv.get_enemy_vstate()
	var camped = []
	for wa in enemyWV.get_war_actors(false, true):
		limit -= 1
		if wa.actorId == wa.get_main_actor_id():
			continue
		if limit < 0:
			wa.camp_in()
			camped.append(wa)
	var names = []
	for wa in camped:
		names.append(wa.get_name())
		if names.size() >= 3:
			break
	var msg = "、".join(names)
	if camped.size() > 3:
		msg += "等{0}人".format([camped.size()])
	msg += "已被迫回营"
	FlowManager.add_flow("draw_actors")
	var reporter = me.get_main_actor_id()
	var mood = 1
	if me.get_controlNo() < 0:
		msg = "！！此何人也？\n" + msg
		reporter = enemyWV.get_leader().actorId
		mood = 3
	elif reporter != actorId:
		msg = "真巧思也！\n" + msg
	play_dialog(reporter, msg, 2, 2001)
	return

func on_view_model_2001()->void:
	wait_for_skill_result_confirmation("")
	return
