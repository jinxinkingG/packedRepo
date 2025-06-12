extends "effect_20000.gd"

#催进主动技，及监使附加效果
#【催进】大战场,主动技。你可以指定一个与你相邻的己方武将：若其体力＞50，则使其体力-3，并移动一格。每回合限1次。
#【监使】大战场，锁定技。你的<催进>调整为每回合限3次；同时，你每执行一次<催进>你的机动力+3

const EFFECT_ID = 20212
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20212_start():
	var targets = get_teammate_targets(me, 1)
	if not wait_choose_actors(targets, "选择队友发动【{0}】"):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20212_2():
	var targetId = get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var targetActor = ActorHelper.actor(targetId)
	if targetActor.get_hp() <= 50:
		LoadControl._error("{0}体力不足，需 > 50".format([targetActor.get_name()]))
		return

	var array = [];#移动目标列表
	map.show_color_block_by_position([]);
	for dir in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		var pos = targetWA.position + dir
		if not targetWA.can_move_to_position(pos):
			continue
		var blockCN = map.get_blockCN_by_position(pos)
		if blockCN in StaticManager.CITY_BLOCKS_CN:
			# 不能选城地形
			continue
		array.append(pos)
	if array.empty():
		var msg = "无可用位置"
		LoadControl._error(msg, me.actorId)
		return false

	map.set_cursor_location(array[0], true)
	map.show_color_block_by_position(array)
	var msg = "请指定【{0}】位移地点".format([ske.skill_name])
	SceneManager.show_unconfirm_dialog(msg)
	set_env("可选目标", array)
	DataManager.set_target_position(array[0])
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001():
	wait_for_choose_position(FLOW_BASE + "_3")
	return

func effect_20212_3():
	var targetId = get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var msg = "对{0}发动【{1}】\n{0}体力将会 -3，可否？".format([
		targetActor.get_name(), ske.skill_name
	])
	play_dialog(me.actorId, msg, 2, 2002, true)
	return

func on_view_model_2002():
	wait_for_yesno(FLOW_BASE + "_4")
	return

func effect_20212_4():
	var targetId = get_env_int("目标")
	var targetPosition = DataManager.get_target_position()

	var special = false
	if SkillHelper.actor_has_skills(actorId, ["监使"], false):
		special = true

	if special:
		ske.cost_war_limited_times(3)
		ske.change_actor_ap(actorId, 3)
	else:
		ske.cost_war_cd(1)
	ske.change_actor_hp(targetId, -3)
	ske.change_war_actor_position(targetId, targetPosition)
	ske.war_report()

	var msg = "军情紧急，{0}速进".format([
		DataManager.get_actor_honored_title(targetId, me.actorId),
	])
	append_free_dialog(me, msg, 1)

	map.show_color_block_by_position([])
	FlowManager.add_flow("draw_actors")
	FlowManager.add_flow("player_skill_end_trigger")
	return
