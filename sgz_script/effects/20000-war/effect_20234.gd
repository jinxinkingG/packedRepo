extends "effect_20000.gd"

#国色主动技 #施加状态
#【国色】大战场,主动技。若你的五行为火，你可以指定1名敌将，并消耗4机动力发动。有3/4的概率成功：为目标添加1回合“疲兵”状态。（疲兵：负面状态。小战场士气减半，战术值减半。）

const EFFECT_ID = 20234
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 4
const BUFF_NAME = "疲兵"
const BUFF_LABEL_NAME = "疲兵"
const FIVE_PHASES_ALLOWED = [War_Character.FivePhases_Enum.Fire]

func check_AI_perform_20000()->bool:
	# AI 发动条件：机动力充足、范围内有合理目标、花色满足条件
	if me.action_point < COST_AP:
		return false
	if not me.five_phases in FIVE_PHASES_ALLOWED:
		return false
	var targets = _get_available_targets(me)
	return not targets.empty()

func effect_20234_AI_start() -> void:
	var targets = _get_available_targets(me)
	targets.shuffle()
	var targetId = targets[0]
	set_env("目标", targetId)
	var targetWA = DataManager.get_war_actor(targetId)
	map.set_cursor_location(targetWA.position, true)
	map.next_shrink_actors = [ske.skill_actorId, targetId]

	var msg = "{0}对我军发动{1}".format([
		me.get_name(), ske.skill_name
	])
	play_dialog(targetId, msg, 0, 3000)
	return

func on_view_model_3000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_AI_2")
	return

func effect_20234_AI_2():
	var targetId = DataManager.get_env_int("目标")
	if not _perform_skill(targetId):
		ske.war_report()
		play_dialog(targetId, "但未造成影响", 1, 3001)
		return
	report_skill_result_message(ske, 3001)
	return

func on_view_model_3001():
	wait_for_pending_message(FLOW_BASE + "_AI_3", "AI_before_ready")
	return

func effect_20234_AI_3() -> void:
	report_skill_result_message(ske, 3001)
	return

func effect_20234_start() -> void:
	if not assert_action_point(me.actorId, COST_AP):
		return
	if not me.five_phases in FIVE_PHASES_ALLOWED:
		var msg = "花色为{0}\n不可发动{1}".format([
			me.get_five_phases_str(), ske.skill_name
		])
		play_dialog(actorId, msg, 3, 2999)
		return
	var targets = _get_available_targets(me)
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20234_2() -> void:
	var targetId = get_env_int("目标")
	var msg = "消耗{2}机动力\n对{0}发动{1}\n可否？".format([
		ActorHelper.actor(targetId).get_name(), ske.skill_name, COST_AP
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20234_3() -> void:
	var targetId = DataManager.get_env_int("目标")
	if not _perform_skill(targetId):
		ske.war_report()
		play_dialog(ske.skill_actorId, "很遗憾\n未能奏效", 3, 2002)
		return
	map.next_shrink_actors = []
	report_skill_result_message(ske, 2002)
	return

func on_view_model_2002() -> void:
	wait_for_pending_message(FLOW_BASE + "_4")
	return

func effect_20234_4() -> void:
	report_skill_result_message(ske, 2002)
	return

func _get_available_targets(me:War_Actor)->Array:
	var ret = []
	for targetId in get_enemy_targets(me):
		var wa = DataManager.get_war_actor(targetId)
		if wa.get_buff_label_turn([BUFF_LABEL_NAME]) > 0:
			continue
		ret.append(targetId)
	return ret

func _perform_skill(targetId:int)->bool:
	ske.cost_ap(COST_AP, true)
	if not Global.get_rate_result(75):
		return false
	return ske.set_war_buff(targetId, BUFF_NAME, 1) > 0
