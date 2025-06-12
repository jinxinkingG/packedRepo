extends "effect_20000.gd"

#勉行主动技实现
#【勉行】大战场,主动技。你机动力＜3时才能使用：你可以无消耗移动一步。每回合限一次

const EFFECT_ID = 20248
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const AP_LIMIT = 3

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func on_view_model_2099():
	wait_for_skill_result_confirmation()
	return

func effect_20248_start():
	if me.action_point >= AP_LIMIT:
		var msg = "机动力需 < {0}".format([AP_LIMIT])
		play_dialog(me.actorId, msg, 3, 2099)
		return
	var msg = "还差一步\n都给我打起精神来！"
	play_dialog(me.actorId, msg, 0, 2000)
	return

func effect_20248_2():
	ske.set_war_skill_val(1)
	LoadControl.end_script()
	DataManager.player_choose_actor = me.actorId
	FlowManager.add_flow("load_script|war/player_move.gd")
	FlowManager.add_flow("actor_move_start")
	return

func on_trigger_20007()->bool:
	var freeSteps = ske.get_war_skill_val_int()
	if freeSteps <= 0:
		return false
	set_env(KEY_MOVE_AP_COST, 0)
	return false

func on_trigger_20003()->bool:
	if not DataManager.common_variable.has("移动"):
		return false

	var skv = SkillHelper.get_skill_variable(20000, EFFECT_ID, self.actorId)
	if skv["turn"] <= 0 or skv["value"] == null:
		return false
	var movement = get_env_int("移动")
	var freeSteps = ske.get_war_skill_val_int()
	match movement:
		1: # 尝试移动
			freeSteps -= 1
		-1: # 撤回移动
			freeSteps += 1
		0: # 开始或结束移动
			if get_env_int("结束移动") > 0:
				ske.cost_war_cd(1)
	freeSteps = min(1, freeSteps)
	ske.set_war_skill_val(freeSteps, 1)
	return false
