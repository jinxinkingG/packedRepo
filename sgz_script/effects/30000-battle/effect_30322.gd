extends "effect_30000.gd"

#龙骧主动技部分
#【龙骧】大战场&小战场，主动技。①你方存在<虎翼>队友时，你的机动力上限+10。②白刃战中，若你有士兵单位，你可以消耗50金发动：你的战术值+3，兵力恢复200，该增援兵力均摊到你方存活的士兵单位中，每个大战场回合限1次。

const EFFECT_ID = 30322
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_GOLD = 50
const RECOVER_SOLDIERS = 200

# AI 是否可发动
func check_AI_perform() -> bool:
	return false

func effect_30322_start() -> void:
	if me.war_vstate().money < COST_GOLD:
		var msg = "金不足，需 >= {0}".format([COST_GOLD])
		SceneManager.show_confirm_dialog(msg, actorId, 3)
		LoadControl.set_view_model(2009)
		return
	var units = []
	for bu in bf.battle_units(actorId):
		if not bu.is_soldier():
			continue
		units.append(bu)
	if units.empty():
		var msg = "无士兵单位，不可发动【{0}】".format([ske.skill_name])
		SceneManager.show_confirm_dialog(msg, actorId, 3)
		LoadControl.set_view_model(2009)
		return
	var msg = "消耗{0}金发动【{1}】\n可否？".format([
		COST_GOLD, ske.skill_name
	])
	SceneManager.show_yn_dialog(msg, actorId, 2)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_yesno(FLOW_BASE + "_confirmed", "tactic_end")
	return

func effect_30322_confirmed()->void:
	ske.battle_cd(99999)
	ske.cost_war_cd(1)
	ske.cost_wv_gold(COST_GOLD)

	var units = []
	for bu in bf.battle_units(actorId):
		if not bu.is_soldier():
			continue
		units.append(bu)
	var left = RECOVER_SOLDIERS
	while left > 0  and not units.empty():
		var recover = int(left / units.size())
		var bu = units.pop_front()
		ske.battle_change_unit_hp(bu, recover)
		left -= recover
	ske.battle_change_tactic_point(3)
	ske.battle_report()

	var msg = "龙起潜渊，鼓勇而前！\n（战术值、士兵回复"
	SceneManager.show_confirm_dialog(msg, actorId, 0)
	LoadControl.set_view_model(2009)
	return

func on_view_model_2009() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_end")
	return

func effect_30322_end() -> void:
	tactic_end()
	return
