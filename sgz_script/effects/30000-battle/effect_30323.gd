extends "effect_30000.gd"

#虎翼主动技部分
#【虎翼】大战场&小战场，主动技。①你方存在<龙骧>队友时，你的体力上限+10。②白刃战中，你可以消耗5点机动力发动：你的体力恢复30点，每个大战场回合限1次。

const EFFECT_ID = 30323
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 5
const RECOVER_HP = 30

# AI 是否可发动
func check_AI_perform() -> bool:
	return false

func effect_30323_start() -> void:
	if me.action_point < COST_AP:
		var msg = "机动力不足，需 >= {0}".format([COST_AP])
		SceneManager.show_confirm_dialog(msg, actorId, 3)
		LoadControl.set_view_model(2009)
		return
	var bu = me.battle_actor_unit()
	if bu == null or not actor.is_injured():
		var msg = "未受伤害，无须【{0}】".format([ske.skill_name])
		SceneManager.show_confirm_dialog(msg, actorId, 1)
		LoadControl.set_view_model(2009)
		return
	var msg = "消耗{0}机动力发动【{1}】\n可否？".format([
		COST_AP, ske.skill_name
	])
	SceneManager.show_yn_dialog(msg, actorId, 2)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_yesno(FLOW_BASE + "_confirmed", "tactic_end")
	return

func effect_30323_confirmed()->void:
	ske.battle_cd(99999)
	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP)

	var bu = me.battle_actor_unit()
	var hp = ske.battle_change_unit_hp(bu, RECOVER_HP)

	var msg = "虎出苍莽，回气再战！\n（体力回复{0}".format([hp])
	SceneManager.show_confirm_dialog(msg, actorId, 0)
	LoadControl.set_view_model(2009)
	return

func on_view_model_2009() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_end")
	return

func effect_30323_end() -> void:
	tactic_end()
	return
