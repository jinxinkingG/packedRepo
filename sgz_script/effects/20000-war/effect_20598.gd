extends "effect_20000.gd"

# 雄姿主动技
#【雄姿】大战场，主将主动技。你可以指定你方其他武将，将<截杀>、<潜行>、<接应>、<焚营>之一，附加给该武将。每个技能限附加1次，每个武将最多被附加1个技能。

const EFFECT_ID = 20598
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const SKILLS = {
	"截杀": "伤敌十指，不若断其一指",
	"潜行": "用兵只要，贵在出其不意",
	"接应": "呼应得法，何惧非常之变",
	"焚营": "江东士卒，岂有不善射者",
}

func check_AI_perform_20000() -> bool:
	return false

func effect_20598_start() -> void:
	var assigned = ske.get_war_skill_val_dic()
	var skills = SKILLS.keys()
	var targetIds = get_teammate_targets(me)
	for key in assigned:
		skills.erase(key)
		var assignedActorId = Global.intval(assigned[key])
		targetIds.erase(assignedActorId)
	if skills.empty():
		var names = []
		for skill in ["潜行", "接应", "焚营", "截杀"]:
			names.append(DataManager.get_actor_honored_title(assigned[skill], actorId))
		var msg = "{0}探敌，{1}照应\n{2}杀伤，{3}掠阵\n分派已定，诸公依计行事".format(names)
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
	var assigned = ske.get_war_skill_val_dic()
	var skills = SKILLS.keys()
	var targetIds = get_teammate_targets(me)
	for key in assigned:
		skills.erase(key)
		var assignedActorId = Global.intval(assigned[key])
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
	var assigned = ske.get_war_skill_val_dic()
	var skill = DataManager.get_env_str("目标项")
	var targetId = DataManager.get_env_int("目标")

	assigned[skill] = targetId
	ske.set_war_skill_val(assigned)
	ske.add_war_skill(targetId, skill, 99999)
	ske.war_report()

	var msg = SKILLS[skill] + "\n{0}善用之，破敌无忧\n（{1}获得【{2}】".format([
		DataManager.get_actor_honored_title(targetId, actorId),
		ActorHelper.actor(targetId).get_name(), skill,
	])
	play_dialog(actorId, msg, 2, 2999)
	return
