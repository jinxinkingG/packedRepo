extends "effect_20000.gd"

# 备筹主动技
#【备筹】大战场，主动技。你可以消耗100[备]，选择己方两个拥有[备]的武将，重新分配两人[备]的数量。每回合限1次。

const EFFECT_ID = 20648
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const FLAG_SCENE_ID = 10000
const FLAG_ID = 10025
const FLAG_NAME = "备"
const COST_FLAGS = 100

func effect_20648_start() -> void:
	if not assert_flag_count(actorId, FLAG_SCENE_ID, FLAG_ID, FLAG_NAME, COST_FLAGS):
		return
	var targets = []
	for targetId in get_teammate_targets(me):
		var flags = SkillHelper.get_skill_flags_number(FLAG_SCENE_ID, FLAG_ID, targetId, FLAG_NAME)
		if flags <= 0:
			continue
		targets.append(targetId)
	if targets.empty():
		var msg = "没有可以发动【{0}】的目标".format([ske.skill_name])
		play_dialog(actorId, msg, 2, 2999)
		return
	# 表示未选择
	ske.set_war_skill_val([-1, -1, targets], 1)
	if targets.size() == 1:
		# 表示选「我」和目标
		ske.set_war_skill_val([actorId, targets[0], targets], 1)
		goto_step("split")
		return
	var msg = "调整谁的[备]数量？"
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20648_selected() -> void:
	var settings = ske.get_war_skill_val_array()
	var targets = settings[2]
	var targetId = DataManager.get_env_int("目标")
	targets.erase(targetId)
	targets.append(actorId)
	# 选定了一个人
	ske.set_war_skill_val([targetId, -1, targets], 1)
	var msg = "调整谁与{0}的[备]数量？".format([
		ActorHelper.actor(targetId).get_name(),
	])
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001() -> void:
	wait_for_choose_actor(FLOW_BASE + "_second_selected")
	return

func effect_20648_second_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var settings = ske.get_war_skill_val_array()
	settings[1] = targetId
	ske.set_war_skill_val(settings, 1)
	goto_step("split")
	return

func effect_20648_split() -> void:
	var settings = ske.get_war_skill_val_array()
	var total = SkillHelper.get_skill_flags_number(FLAG_SCENE_ID, FLAG_ID, settings[0], FLAG_NAME)
	total += SkillHelper.get_skill_flags_number(FLAG_SCENE_ID, FLAG_ID, settings[1], FLAG_NAME)
	if settings[0] == actorId or settings[1] == actorId:
		total -= COST_FLAGS

	var msg = "将重新分配二人的 [备]\n{0}和{1}共有 {2}".format([
		ActorHelper.actor(settings[0]).get_name(),
		ActorHelper.actor(settings[1]).get_name(),
		total,
	])
	play_dialog(actorId, msg, 2, 2002)
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_numbers")
	return

func effect_20648_numbers() -> void:
	var settings = ske.get_war_skill_val_array()
	var total = SkillHelper.get_skill_flags_number(FLAG_SCENE_ID, FLAG_ID, settings[0], FLAG_NAME)
	total += SkillHelper.get_skill_flags_number(FLAG_SCENE_ID, FLAG_ID, settings[1], FLAG_NAME)
	if settings[0] == actorId or settings[1] == actorId:
		total -= COST_FLAGS

	var msg = "给{0}多少 [备]？".format([
		ActorHelper.actor(settings[0]).get_name(),
		ActorHelper.actor(settings[1]).get_name(),
		total,
	])
	SceneManager.show_input_numbers(msg, ["备"], [total])
	SceneManager.input_numbers.show_actor(actorId)
	LoadControl.set_view_model(2003)
	return

func on_view_model_2003():
	wait_for_number_input(FLOW_BASE + "_splited")
	return

func effect_20648_splited() -> void:
	var settings = ske.get_war_skill_val_array()
	var total = SkillHelper.get_skill_flags_number(FLAG_SCENE_ID, FLAG_ID, settings[0], FLAG_NAME)
	total += SkillHelper.get_skill_flags_number(FLAG_SCENE_ID, FLAG_ID, settings[1], FLAG_NAME)
	if settings[0] == actorId or settings[1] == actorId:
		total -= COST_FLAGS
	# 先扣减自身
	ske.cost_skill_flags(FLAG_SCENE_ID, FLAG_ID, FLAG_NAME, COST_FLAGS)
	var splited = DataManager.get_env_int("数值")
	splited = min(total, splited)
	SkillHelper.set_skill_flags(FLAG_SCENE_ID, FLAG_ID, settings[0], FLAG_NAME, splited)
	SkillHelper.set_skill_flags(FLAG_SCENE_ID, FLAG_ID, settings[1], FLAG_NAME, total - splited)
	var msg = "因时因需，有备无患\n（{0}的[{1}]现为 {2}\n（{3}的[{1}]现为 {4}".format([
		ActorHelper.actor(settings[0]).get_name(), FLAG_NAME,
		SkillHelper.get_skill_flags_number(FLAG_SCENE_ID, FLAG_ID, settings[0], FLAG_NAME),
		ActorHelper.actor(settings[1]).get_name(),
		SkillHelper.get_skill_flags_number(FLAG_SCENE_ID, FLAG_ID, settings[1], FLAG_NAME),
	])
	ske.cost_war_cd(1)
	ske.war_report()
	play_dialog(actorId, msg, 2, 2999)
	return
