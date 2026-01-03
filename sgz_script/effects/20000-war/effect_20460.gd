extends "effect_20000.gd"

#斧手主动技部分
#【斧手】大战场，主动技。指定1名攻击范围内的敌将，消耗4点机动力发动。你对之发起攻击，以此法进入的白刃战，你固定为全步兵，但不计入实际兵力损失。每回合限一次。

const EFFECT_ID = 20460
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 4

func check_AI_perform_20000()->bool:
	if actor.get_hp() < 50:
		return false
	if me.action_point < COST_AP:
		return false
	var iwa = Global.load_script(DataManager.mod_path+"sgz_script/war/IWar_Attack.gd")
	var res = iwa.get_can_attack_actors(actorId)
	var candidates = check_combat_targets(res[0])
	if candidates.empty():
		return false
	var targets = Array(candidates)
	targets.shuffle()
	DataManager.set_env("目标", targets[0])
	# 避免重复判断
	ske.cost_war_cd(1)
	return true

func effect_20460_AI_start():
	goto_step("3")
	return

func effect_20460_start():
	if not assert_action_point(me.actorId, COST_AP):
		return
	var iwa = Global.load_script(DataManager.mod_path+"sgz_script/war/IWar_Attack.gd")
	var res = iwa.get_can_attack_actors(actorId)
	var targets = check_combat_targets(res[0])
	if not wait_choose_actors(targets, "选择攻击目标发动【{0}】"):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2", true)
	return

func effect_20460_2():
	var targetId = DataManager.get_env_int("目标")
	var msg = "消耗{0}点机动力\n可否？".format([COST_AP])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3", true)
	return

func effect_20460_3():
	var targetId = DataManager.get_env_int("目标")
	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)
	ske.set_war_skill_val(1, 1)
	ske.war_report()
	var msg = "{0}迫近，刀斧手齐上！".format([
		ActorHelper.actor(targetId).get_name(),
	])
	play_dialog(me.actorId, msg, 0, 2002)
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_20460_4():
	var targetId = DataManager.get_env_int("目标")
	start_battle_and_finish(actorId, targetId)
	return
