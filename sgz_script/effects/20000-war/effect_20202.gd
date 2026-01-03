extends "effect_20000.gd"

#耀武锁定技
#【耀武】大战场，锁定技。你移动结束时，若周围存在可攻击的敌将，则你必须与其中一名敌将进入白刃战。

const EFFECT_ID = 20202
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20003()->bool:
	if DataManager.get_env_int("移动") != 0:
		return false
	if DataManager.get_env_int("结束移动") != 1:
		return false
	if me.get_controlNo() >= 0:
		# 玩家要求历史移动记录，不允许原地触发
		if DataManager.get_env_array("历史移动记录").empty():
			return false

	var iwa = Global.load_script(DataManager.mod_path+"sgz_script/war/IWar_Attack.gd")
	var res = iwa.get_can_attack_actors(actorId, true)
	var targetIds = check_combat_targets(res[0])
	if targetIds.empty():
		return false
	ske.set_war_skill_val(targetIds, 1)
	return true

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2", true, false)
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func on_view_model_2009():
	wait_for_skill_result_confirmation()
	return

func effect_20202_start():
	var targetIds = ske.get_war_skill_val_int_array()
	if not wait_choose_actors(targetIds):
		var msg = "没有可攻击的目标"
		play_dialog(me.actorId, msg, 3, 2009)
		return
	LoadControl.set_view_model(2000)
	return

func effect_20202_2():
	var targetId = DataManager.get_env_int("目标")

	var msg = "谁在这里碍眼？\n{0}纳命来！".format([
		DataManager.get_actor_naughty_title(targetId, me.actorId)
	])
	play_dialog(me.actorId, msg, 0, 2001)
	map.next_shrink_actors = [me.actorId, targetId]
	return

func effect_20202_3():
	map.next_shrink_actors = []
	var targetId = DataManager.get_env_int("目标")
	start_battle_and_finish(actorId, targetId)
	return

func effect_20202_AI_start():
	var targetIds = ske.get_war_skill_val_int_array()
	DataManager.set_env("目标", targetIds[0])
	goto_step("2")
	return
