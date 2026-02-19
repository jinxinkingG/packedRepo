extends "effect_20000.gd"

# 揽权限定技
#【揽权】大战场，限定技。你可无视距离指定主将以外的至多2名队友，强制其回到营帐且封禁其所有技能，并将之兵力最大限度转移给你，以此法你至多可增至3000兵。

const EFFECT_ID = 20315
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const TEAM_COUNT = 2
const EFFECT_CHOOSE_NAME = "战争."+str(EFFECT_ID)+"目标";
const EFFECT_CHOOSE_ACTOR = "战争."+str(EFFECT_ID)+"武将";
const DIALOGS = [
	["权柄岂可轻予？", "{0}也敢乱权！"],
]

#开始-选择不限距离任意队友
func effect_20315_start() -> void:
	# 允许传入预设目标
	if "预设目标" in ske.ext_flags:
		var presetTargetIds = Global.intarrval(ske.ext_flags["预设目标"])
		if not presetTargetIds.empty():
			DataManager.set_env(EFFECT_CHOOSE_NAME, presetTargetIds)
			goto_step("decided")
			return
	#先清空选择列表
	DataManager.set_env(EFFECT_CHOOSE_NAME, [])
	DataManager.set_env(EFFECT_CHOOSE_ACTOR, -1)
	_update_select_color([])
	goto_step("go")
	return
	
func effect_20315_go() -> void:
	var selected = DataManager.get_env_int_array(EFFECT_CHOOSE_NAME)
	
	var targets = get_teammate_targets(me, 999)
	targets.erase(me.get_leader().actorId)
	if targets.empty():
		play_dialog(actorId, "没有可以发动【揽权】的目标", 3, 2999)
		return

	# 修改默认目标，光标总指向最后选的那个
	var lastTargetId = DataManager.get_env_int(EFFECT_CHOOSE_ACTOR)
	if lastTargetId >= 0 && lastTargetId in targets:
		targets.erase(lastTargetId)
		targets.insert(0, lastTargetId)

	var status = "({0}/{1})".format([selected.size(), TEAM_COUNT])
	var msg = "对何人发动{0}?" + status
	if selected.size() > TEAM_COUNT:
		selected = selected.slice(0, TEAM_COUNT - 1)
		DataManager.set_env(EFFECT_CHOOSE_NAME, selected)
		status = "({0}/{1})".format([selected.size(), TEAM_COUNT])
		msg = "最多选择{0}人".format([TEAM_COUNT]) + status
	if not wait_choose_actors(targets, msg):
		return
	_update_select_color(targets)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected", true, true, FLOW_BASE + "_decided")
	return

#确认添加减少情况
func effect_20315_selected() -> void:
	SceneManager.hide_all_tool()
	map.clear_can_choose_actors()
	var targetId = DataManager.get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)
	var selected = Array(get_env_int_array(EFFECT_CHOOSE_NAME))
	
	var msg = "(当前人数:{0}/{1})".format([selected.size(), TEAM_COUNT])

	if targetId in selected:
		selected.erase(targetId)
	else:
		selected.append(targetId)
	DataManager.set_env(EFFECT_CHOOSE_ACTOR, targetId)
	DataManager.set_env(EFFECT_CHOOSE_NAME, selected)
	goto_step("go")
	return

func effect_20315_decided() -> void:
	var selected = DataManager.get_env_int_array(EFFECT_CHOOSE_NAME)
	if selected.empty():
		back_to_skill_menu()
		return

	var names = []
	for targetId in selected:
		names.append(ActorHelper.actor(targetId).get_name())
	var msg = "发动【{0}】，令{1}回营并夺其兵力\n可否？".format([ske.skill_name, "、".join(names)])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_perform")
	return

func effect_20315_perform() -> void:
	var selected = DataManager.get_env_int_array(EFFECT_CHOOSE_NAME)

	ske.cost_war_cd(99999)
	var soldiers = 0
	for targetId in selected:
		ske.war_camp_in(targetId)
		ske.set_war_buff(targetId, "沉默", 99999)
		var targetActor = ActorHelper.actor(targetId)
		soldiers += targetActor.get_soldiers()
	var dialogs = DIALOGS.duplicate()
	dialogs.shuffle()
	var msg = dialogs[0][0]
	if selected.size() == 1:
		msg = dialogs[0][1].format([
			DataManager.get_actor_naughty_title(selected[0], actorId)
		])
	soldiers = ske.add_actor_soldiers(actorId, soldiers, 3000)
	if soldiers > 0:
		var targets = []
		targets.append_array(selected)
		while not targets.empty():
			var reduced = int(soldiers / targets.size())
			var targetId = targets.pop_front()
			reduced = ske.sub_actor_soldiers(targetId, reduced)
			soldiers -= reduced
	DataManager.unset_env(EFFECT_CHOOSE_NAME)
	DataManager.unset_env(EFFECT_CHOOSE_ACTOR)
	report_skill_result_message(ske, 2002, msg, 0)
	return

func on_view_model_2002() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20315_report() -> void:
	report_skill_result_message(ske, 2002)
	return

func _update_select_color(targetIds:PoolIntArray) -> void:
	var selected = DataManager.get_env_int_array(EFFECT_CHOOSE_NAME)
	map.show_can_choose_actors(targetIds, -1, selected)
	return
