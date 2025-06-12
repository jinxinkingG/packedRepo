extends "effect_20000.gd"

#耀武锁定技
#【耀武】大战场，锁定技。你移动结束时，若周围存在可攻击的敌将，则你必须与其中一名敌将进入白刃战。

const EFFECT_ID = 20202
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20003()->bool:
	var key = "技能.耀武.目标.{0}".format([me.actorId])
	unset_env(key)
	if get_env_int("移动") != 0:
		return false
	if get_env_int("结束移动") != 1:
		return false
	if me.get_controlNo() >= 0:
		# 玩家要求历史移动记录，不允许原地触发
		if get_env_array("历史移动记录").empty():
			return false

	var iwa = Global.load_script(DataManager.mod_path+"sgz_script/war/IWar_Attack.gd")
	var targets = iwa.get_can_attack_actors(me.actorId, true)[0]
	if targets.empty():
		return false
	set_env(key, targets)
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
	var key = "技能.耀武.目标.{0}".format([me.actorId])
	var targets = get_env_int_array(key)
	if not wait_choose_actors(targets):
		var msg = "没有可攻击的目标"
		play_dialog(me.actorId, msg, 3, 2009)
		return
	LoadControl.set_view_model(2000)
	return

func effect_20202_2():
	var targetId = get_env_int("目标")

	var msg = "谁在这里碍眼？\n{0}纳命来！".format([
		DataManager.get_actor_naughty_title(targetId, me.actorId)
	])
	play_dialog(me.actorId, msg, 0, 2001)
	map.next_shrink_actors = [me.actorId, targetId]
	return

func effect_20202_3():
	map.next_shrink_actors = []
	var targetId = get_env_int("目标")
	start_battle_and_finish(me.actorId, targetId)
	return

func effect_20202_AI_start():
	var key = "技能.耀武.目标.{0}".format([me.actorId])
	var targets = get_env_int_array(key)
	set_env("目标", targets[0])
	goto_step("2")
	return
