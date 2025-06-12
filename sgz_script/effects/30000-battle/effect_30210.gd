extends "effect_30000.gd"

#拦截主动技
#【拦截】小战场，主动技。消耗一半战术值才能发动。在敌方后退方向的最后一列，创建一排拒马，持续(所消耗战术值/2)回合。

const EFFECT_ID = 30210
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const PASSIVE_EFFECT_ID = 30211

func on_view_model_2999()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_end", false)
	return

func effect_30210_start()->void:
	if me.battle_tactic_point <= 2:
		var msg = "战术点不足\n【{0}】需战术点 >= 2".format([
			ske.skill_name,
		])
		SceneManager.show_confirm_dialog(msg, me.actorId, 3)
		LoadControl.set_view_model(2999)
		return
	var bf = DataManager.get_current_battle_fight()
	var cost = int(me.battle_tactic_point / 2)
	ske.battle_cd(1)
	ske.battle_change_tactic_point(-cost, me)
	var xAxis = 0
	if me.actorId == bf.get_attacker_id():
		var sceneBattle = SceneManager.current_scene()
		xAxis = sceneBattle.cell_columns - 1
	bf.create_abatis_line(xAxis)
	ske.set_battle_skill_val(cost, cost, PASSIVE_EFFECT_ID)
	ske.battle_report()
	var msg = "{0}哪里走！\n今日不论胜负，只决生死！\n（已放置拒马，持续{1}回合".format([
		DataManager.get_actor_naughty_title(enemy.actorId, me.actorId), cost,
	])
	SceneManager.show_confirm_dialog(msg, me.actorId, 0)
	LoadControl.set_view_model(2999)
	return

func effect_30210_end():
	LoadControl.load_script("res://resource/sgz_script/battle/player_tactic.gd")
	FlowManager.add_flow("tactic_end")
	return
