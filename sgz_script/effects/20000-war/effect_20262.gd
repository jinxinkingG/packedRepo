extends "effect_20000.gd"

#进策主动技
#【进策】大战场,主动技。你可以消耗10点机动力，指定一个你方武将，该武将立即进入移动状态，可以移动5步，无需消耗机动力。每2回合限1次

const EFFECT_ID = 20262
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const PASSIVE_EFFECT_ID = 20263
const COST_AP = 10
const FREE_STEPS = 5

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func on_view_model_3000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_AI_2")
	return

func check_AI_perform_20000()->bool:
	if me.action_point < COST_AP:
		return false
	# 选择兵力最多的非主将队友发动
	var maxSoldierActorId = -1
	var maxSoldier = 1000
	for targetId in get_teammate_targets(me):
		if targetId == me.get_main_actor_id():
			continue
		var soldiers = ActorHelper.actor(targetId).get_soldiers()
		if soldiers > maxSoldier:
			maxSoldier = soldiers
			maxSoldierActorId = targetId
	if maxSoldierActorId < 0:
		return false
	set_env("AI进策目标", maxSoldierActorId)
	return true

func effect_20262_AI_start():
	var targetId = get_env_int("AI进策目标")
	var msg = "机不可失，{0}可速进\n（{1}对{2}发动【{3}】".format([
		DataManager.get_actor_honored_title(targetId, me.actorId),
		me.get_name(), ActorHelper.actor(targetId).get_name(),
		ske.skill_name,
	])
	play_dialog(me.actorId, msg, 2, 3000)
	return

func effect_20262_AI_2():
	var targetId = get_env_int("AI进策目标")
	unset_env("AI进策目标")
	ske.cost_war_cd(2)
	ske.set_war_skill_val(FREE_STEPS, 1, PASSIVE_EFFECT_ID, targetId)
	DataManager.set_env("AI-当前武将", targetId)
	LoadControl.end_script()
	FlowManager.add_flow("AI_ready")
	return

func effect_20262_start():
	if not assert_action_point(me.actorId, COST_AP):
		return
	var targets = get_teammate_targets(me)
	if not wait_choose_actors(targets, "选择队友发动【{0}】"):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20262_2():
	var targetId = get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var msg = "消耗 {0}机动力\n对{1}发动【{2}】\n可否？".format([
		COST_AP, targetActor.get_name(), ske.skill_name,
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func effect_20262_3():
	var targetId = get_env_int("目标")
	ske.cost_war_cd(2)
	ske.set_war_skill_val(FREE_STEPS, 1, PASSIVE_EFFECT_ID, targetId)
	ske.cost_ap(COST_AP, true)
	map.show_color_block_by_position([])
	DataManager.player_choose_actor = targetId
	map.camer_to_actorId(targetId, "draw_actors")
	map.update_ap(targetId)
	LoadControl.end_script()
	FlowManager.add_flow("load_script|war/player_move.gd")
	FlowManager.add_flow("actor_move_start")
	return
