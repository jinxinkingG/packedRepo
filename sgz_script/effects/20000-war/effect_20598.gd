extends "effect_20000.gd"

# 雄姿主动技
#【雄姿】大战场，主将主动技。你可以指定你方其他武将，将<截杀>、<潜行>、<接应>、<焚营>之一，附加给该武将。每个技能限附加1次，每个武将最多被附加1个技能。

const EFFECT_ID = 20598
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const SKILLS = [
	["潜行", "探敌，", "用兵之要，贵在出其不意"],
	["接应", "照应\n", "呼应得法，何惧非常之变"],
	["焚营", "杀伤，", "江东士卒，岂有不善射者"],
	["截杀", "掠阵\n", "伤敌十指，不若断其一指"],
]

func on_trigger_20017()->bool:
	var recorded = ske.get_war_skill_val_int_array()
	if recorded.empty() or recorded[0] <= 0:
		return false
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(actorId) != actorId:
		return false
	if not se.damage_soldier():
		return false
	change_scheme_chance(actorId, ske.skill_name, recorded[0] * 5)
	return false

func on_trigger_20026() -> bool:
	var recorded = ske.get_war_skill_val_int_array()
	if recorded.empty() or recorded[0] <= 0:
		return false
	DataManager.set_env("计策.ONCE.距离", {"ALL": {
		"范围修正": recorded[0],
		"距离修正": -recorded[0],
	}})
	return false

func check_AI_perform_20000() -> bool:
	return false

func effect_20598_start() -> void:
	var assigned = _get_assigned_actorIds()
	var targetIds = get_teammate_targets(me)
	var skills = []
	for i in SKILLS.size():
		if assigned[i] >= 0:
			targetIds.erase(assigned[i])
			continue
		skills.append(SKILLS[i][0])
	if skills.empty():
		var msg = ""
		for i in SKILLS.size():
			msg += "{0}{1}".format([
				DataManager.get_actor_honored_title(assigned[i], actorId),
				SKILLS[i][1]
			])
		msg += "分派已定，诸公依计行事"
		play_dialog(actorId, msg, 2, 2999)
		return
	if targetIds.empty():
		var msg = "未找到可分配技能的队友"
		play_dialog(actorId, msg, 2, 2999)
		return
	if skills.size() == 1:
		DataManager.set_env("目标项", skills[0])
		goto_step("skill_selected")
		return
	var msg = "将何技能交予队友？"
	SceneManager.show_unconfirm_dialog(msg, actorId)
	SceneManager.bind_top_menu(skills, skills, 1)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_skill(FLOW_BASE + "_skill_selected")
	return

func effect_20598_skill_selected() -> void:
	var assigned = _get_assigned_actorIds()
	var targetIds = get_teammate_targets(me)
	for assignedActorId in assigned:
		targetIds.erase(assignedActorId)
	var skill = DataManager.get_env_str("目标项")
	var msg = "将【{0}】分配给何人？".format([skill])
	if not wait_choose_actors(targetIds, msg):
		return
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001() -> void:
	wait_for_choose_actor(FLOW_BASE + "_actor_selected")
	return

func effect_20598_actor_selected() -> void:
	var skill = DataManager.get_env_str("目标项")
	var targetId = DataManager.get_env_int("目标")

	var idx = _assign_skill(skill, targetId)
	if idx < 0:
		var msg = "无法分配技能【{0}】".format([skill])
		play_dialog(actorId, msg, 3, 2999)
		return
	ske.add_war_skill(targetId, skill, 99999)
	ske.war_report()

	var msg = SKILLS[idx][2] + "\n{0}善用之，破敌无忧\n（{1}获得【{2}】".format([
		DataManager.get_actor_honored_title(targetId, actorId),
		ActorHelper.actor(targetId).get_name(), skill,
	])
	play_dialog(actorId, msg, 2, 2002)
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_start")
	return

func _get_assigned_actorIds() -> PoolIntArray:
	var recorded = Array(ske.get_war_skill_val_int_array())
	recorded.pop_front()
	var ret = []
	for i in SKILLS.size():
		if i < recorded.size():
			ret.append(recorded[i])
		else:
			ret.append(-1)
	return ret

# 赋予技能，返回技能 index
func _assign_skill(skill:String, targetId:int) -> int:
	var idx = -1
	var assigned = _get_assigned_actorIds()
	for i in SKILLS.size():
		if skill == SKILLS[i][0]:
			assigned[i] = targetId
			idx = i
			break
	var record = []
	record.append_array(assigned)
	var total = 0
	for assignedActorId in record:
		if assignedActorId >= 0:
			total += 1
	record.insert(0, total)
	ske.set_war_skill_val(record)
	return idx
