extends "effect_20000.gd"

# 敢决主动技
#【敢决】大战场，主动技。你可禁用自身1个装备区，选择1名敌将为目标发动。你与目标进入白刃战，其中点数较大者视为攻方(点数相同则你视为攻方)。

const EFFECT_ID = 20686
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20686_start() -> void:
	var options = []
	var items = []
	var disabled = actor.get_disabled_equip_types()
	for et in StaticManager.EQUIPMENT_TYPES.duplicate():
		if et in disabled:
			continue
		options.append(et)
		items.append("{0}（{1}）".format([
			et, actor.get_equip(et).name(),
		]))
	if options.empty():
		var msg = "已无装备栏可禁用"
		play_dialog(actorId, msg, 3, 2999)
		return
	if get_combat_targets(me).empty():
		var msg = "没有目标可以发动【{0}】".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return
	SceneManager.show_unconfirm_dialog("禁用何种装备？", actorId)
	SceneManager.bind_top_menu(items, options, 1)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_item(FLOW_BASE + "_decided")
	return

func effect_20686_decided() -> void:
	var dt = DataManager.get_env_str("目标项")
	var msg = "对何人发动【{0}】".format([ske.skill_name])
	if not wait_choose_actors(get_combat_targets(me), msg):
		return
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20686_selected() -> void:
	var dt = DataManager.get_env_str("目标项")
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)

	DataManager.disable_actor_equip_type(20000, actorId, dt)
	var msg = "{0}！\n让尔三招，可敢一战！\n（禁用{1}，"
	if me.get_poker_point_diff(targetWA) >= 0:
		start_battle_and_finish(actorId, targetId)
		msg += "向{2}发起攻击"
	else:
		start_battle_and_finish(targetId, actorId)
		msg += "{2}发起攻击"
	msg = msg.format([
		DataManager.get_actor_naughty_title(targetId, actorId),
		dt, targetWA.get_name(),
	])
	me.attach_free_dialog(msg, 0)
	return
