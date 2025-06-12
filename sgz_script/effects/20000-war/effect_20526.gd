extends "effect_20000.gd"

#无咎效果实现
#【无咎】大战场，诱发技。战争初始，若你方为守方，若己方存在体力不满的武将，你可以消耗本城(50+10*X)金，令你方所有武将体力恢复至其上限。X＝你方体力未满人数，金不足无法发动。

const EFFECT_ID = 20526
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_GOLD_BASE = 50
const COST_GOLD_PER = 10

func get_gold_cost(x:int) -> int:
	return COST_GOLD_BASE + x * COST_GOLD_PER

func on_trigger_20019()->bool:
	# 仅第一天允许发动
	var wf = DataManager.get_current_war_fight()
	if wf.date != 1:
		return false

	if me.side() != "防守方":
		return false

	# 检查体力
	var wv = me.war_vstate()
	if wv == null:
		return false
	var x = 0
	for wa in wv.get_war_actors(false):
		if wa.actor().get_hp() < wa.actor().get_max_hp():
			x += 1
	if x == 0:
		return false
	return wv.money >= get_gold_cost(x)

func effect_20526_start() -> void:
	var msg = "大战又至，须赖众将之力\n当重金延医诊治，必求无咎"
	play_dialog(actorId, msg, 0, 2000)
	return

func on_view_model_2000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_20526_2() -> void:

	ske.cost_war_cd(99999)
	var wv = me.war_vstate()
	var x = 0
	for wa in wv.get_war_actors(false):
		var diff = wa.actor().get_max_hp() - wa.actor().get_hp()
		if diff > 0:
			ske.change_actor_hp(wa.actorId, diff)
			x += 1
	ske.cost_wv_gold(get_gold_cost(x))
	ske.war_report()
	goto_step("report")
	return

func effect_20526_report() -> void:
	report_skill_result_message(ske, 2001)
	return

func on_view_model_2001() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return
