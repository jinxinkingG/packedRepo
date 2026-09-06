extends "effect_20000.gd"

#仿笔主动技
#【仿笔】大战场，限定技。你可指定一个敌方知系武将（非主将），并选择该武将的一个锁定技或主动技，直到本次战争之前，你临时习得该技能。可对城地形发动。

const EFFECT_ID = 20730
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20730_start() -> void:
	var targets = []
	var enemyLeader = me.get_war_enemy_leader()
	for targetId in get_enemy_targets(me, true):
		if targetId == enemyLeader.actorId:
			continue
		var ta = ActorHelper.actor(targetId)
		var maxAttr = max(ta.get_wisdom(), ta.get_politics())
		maxAttr = max(maxAttr, ta.get_power())
		maxAttr = max(maxAttr, ta.get_leadership())
		if maxAttr > ta.get_wisdom():
			continue
		if SkillHelper.actor_has_skills(targetId, ["贞烈"]):
			continue
		if get_valid_skills(targetId).empty():
			continue
		targets.append(targetId)
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

# 已选定对手
func effect_20730_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var msg = "仿笔哪个技能？"
	SceneManager.show_unconfirm_dialog(msg, actorId)
	var items = get_valid_skills(targetId)
	SceneManager.bind_top_menu(items, items, 2)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001() -> void:
	wait_for_choose_skill(FLOW_BASE + "_confirmed")
	return

# 已选定技能，执行
func effect_20730_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	var skill = DataManager.get_env_str("目标项")

	ske.cost_war_cd(99999)
	var learned = ske.get_war_skill_val_str()
	if learned != "":
		ske.remove_war_skill(actorId, learned)
	ske.add_war_skill(actorId, skill, 99999)
	ske.set_war_skill_val(skill)

	var msg = "落笔之处，皆有形迹"
	report_skill_result_message(ske, 2002, msg, 0)
	return

func on_view_model_2002() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")

func effect_20730_report() -> void:
	report_skill_result_message(ske, 2002)
	return

func get_valid_skills(targetId:int) -> PoolStringArray:
	var ret = []
	for skillName in get_valuable_skill_list(targetId):
		var skill = StaticManager.get_skill(skillName)
		if skill == null:
			continue
		if skill.has_feature("限定"):
			continue
		ret.append(skillName)
		for eff in skill.effects:
			if not eff.type in ["锁定", "主动", "光环"]:
				ret.erase(skillName)
				break
	return ret
