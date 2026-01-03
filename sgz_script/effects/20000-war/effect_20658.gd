extends "effect_20000.gd"

# 援遥主动技
#【援遥】大战场，主动技。你可以消耗5点机动力，指定一个6格以外的己方武将，并选择一个该武将冷却中的技能，你令该技能冷却回合数-1，若该武将本回合白刃战获胜过，你额外令其体力+5。每回合限1次。

const EFFECT_ID = 20658
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 5
const RECOVER_HP = 5

func check_AI_perform_20000()->bool:
	# AI 暂不发动
	return false

func effect_20658_start() -> void:
	if not assert_action_point(actorId, COST_AP):
		return
	var teammateIds = []
	for teammate in me.get_teammates(false, true):
		if Global.get_range_distance(teammate.position, me.position) <= 6:
			continue
		teammateIds.append(teammate.actorId)
	var targets = []
	for key in DataManager.skill_cd.keys():
		# 忽略限定技或永久禁用的技能
		if DataManager.skill_cd[key] >= 90000:
			continue
		var pieces = str(key).split("/")
		var sceneId = int(pieces[0])
		if sceneId != 20000:
			continue
		#var effectId = int(pieces[1])
		var targetId = int(pieces[2])
		if targetId in targets:
			continue
		if not targetId in teammateIds:
			continue
		targets.append(targetId)
	if targets.empty():
		var msg = "没有合适的【{0}】目标".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return

	var msg = "选择【{0}】目标".format([ske.skill_name])

	if not wait_choose_actors(targets, msg, true, false):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20658_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var skills = []
	var values = []
	for key in DataManager.skill_cd.keys():
		var cd = int(DataManager.skill_cd[key])
		# 忽略限定技或永久禁用的技能
		if cd >= 90000:
			continue
		var pieces = str(key).split("/")
		#var sceneId = int(pieces[0])
		var effectId = int(pieces[1])
		var cdActorId = int(pieces[2])
		if cdActorId != targetId:
			continue
		var skillName = pieces[3]
		skills.append("{0} [CD: {1}]".format([skillName, cd]))
		values.append([skillName, effectId])
	if skills.empty():
		var msg = "{0}没有合适的技能".format([
			ActorHelper.actor(targetId).get_name()
		])
		play_dialog(actorId, msg, 2, 2999)
		return

	var msg = "为{0}减技能冷却\n选择哪个技能？".format([
		ActorHelper.actor(targetId).get_name(),
	])
	SceneManager.show_unconfirm_dialog(msg, actorId)
	SceneManager.bind_top_menu(skills, values, 1)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001() -> void:
	wait_for_choose_item(FLOW_BASE + "_skill_selected")
	return

func effect_20658_skill_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var skillInfo = DataManager.get_env_array("目标项")
	var skillName = str(skillInfo[0])
	var effectId = int(skillInfo[1])
	var reduced = ske.reduce_actor_skill_cd(targetId, 1, [20000], [effectId])
	if reduced.empty():
		var msg = "无事发生".format([
			ActorHelper.actor(targetId).get_name()
		])
		play_dialog(actorId, msg, 3, 2999)
		return
	skillName = reduced.keys()[0]
	var cd = int(reduced[skillName])
	var msg = "{0}的【{1}】冷却现为 {2}".format([
		ActorHelper.actor(targetId).get_name(),
		skillName, cd
	])
	var wf = DataManager.get_current_war_fight()
	for r in wf.get_env_array("击败部队"):
		if r.size() != 3:
			continue
		var winnerId = int(r[0])
		var loserId = int(r[1])
		var dt = int(r[2])
		if winnerId != targetId or dt != wf.date:
			continue
		var recovered = ske.change_actor_hp(targetId, RECOVER_HP)
		if recovered > 0:
			msg += "\n因新胜{0}\n{1}体力回复 {2}".format([
				ActorHelper.actor(loserId).get_name(),
				ActorHelper.actor(targetId).get_name(),
				recovered,
			])
		break
	ske.cost_ap(COST_AP, true)
	ske.cost_war_cd(1)
	ske.war_report()
	play_dialog(actorId, msg, 1, 2999)
	return
