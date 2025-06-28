extends "effect_20000.gd"

#志继效果实现
#【志继】大战场,锁定技。你转为阳面时发动。你需从阴面技能中，选择1个可学习的技能，永久获得之。

const EFFECT_ID = 20213
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func appended_skill_list()->PoolStringArray:
	var ret = []
	var skill = SkillHelper.get_skill_variable_str(10000, EFFECT_ID, actorId)
	if skill != "":
		ret.append(skill)
	return ret

func effect_20213_AI_start():
	var skills = _get_skill_options()
	if skills.empty():
		LoadControl.end_script()
		return
	var chosen = skills[randi() % skills.size()]
	ske.affair_set_skill_val(chosen, 99999)
	SkillHelper.update_all_skill_buff("志继")
	var msg = "{0}【{1}】发动\n获得【{2}】".format([
		actor.get_name(), ske.skill_name, chosen
	])
	LoadControl._error(msg, -1)
	return
	
func effect_20213_start():
	var msg = "{0}转为 <阳>\n【{1}】发动".format([
		actor.get_name(), ske.skill_name
	])
	play_dialog(-1, msg, 2, 2000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_20213_2():
	var msg = "选择并获得一个阴面技能"
	SceneManager.show_unconfirm_dialog(msg, actorId)
	var skills = _get_skill_options()
	bind_menu_items(skills, skills, 2)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001()->void:
	wait_for_choose_skill(FLOW_BASE + "_3", false, false)
	return

func effect_20213_3():
	var chosen = DataManager.get_env_str("目标项")
	ske.affair_set_skill_val(chosen, 99999)
	SkillHelper.update_all_skill_buff("志继")
	var msg = "{0}获得【{1}】".format([
		actor.get_name(), chosen
	])
	LoadControl._error(msg, -1)
	return

func _get_skill_options()->PoolStringArray:
	var ret = SkillHelper.get_actor_unlocked_skill_names(actorId, "阴").values()
	ret.erase("逢亮")
	return ret
