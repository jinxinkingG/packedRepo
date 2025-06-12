extends "effect_30000.gd"

#咆哮主动技
#【咆哮】小战场，主动技。你可以选择<巨喝>和<长啸>其中之一，并立即发动之。白刃战限1次。☆制作组提示：在城地形无法选择<巨喝>，在<长啸>冷却时无法选择，二者都无法选择时，可以退出本技能发动界面。

const EFFECT_ID = 30001
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const SUB_SKILLS = ["长啸", "巨喝"]

const YANYU_EFFECT_ID = 30189

# AI 是否可发动
func check_AI_perform()->bool:
	actor = ActorHelper.actor(actorId)
	# 只要体力够就发动
	if actor.get_hp() < 50:
		return false
	if _get_available_sub_skills().empty():
		return false
	return true

# AI 发动
func effect_30001_AI_start():
	# AI 主动发动，只发动一次
	ske.battle_cd(99999)
	# 为防多次发动，再次检查
	if _get_available_sub_skills().empty():
		LoadControl.end_script()
		FlowManager.add_flow("unit_action")
		return
	if _chained_effect():
		var d = me.get_next_dialog(30000)
		if d != null:
			SceneManager.show_confirm_dialog(d.text, d.actorId, d.mood)
			LoadControl.set_view_model(3000)
			return
	goto_step("AI_2")
	return

func on_view_model_3000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_AI_2", false)
	return

func effect_30001_AI_2():
	var skills = _get_available_sub_skills()
	match skills.size():
		2:
			skills.shuffle()
			DataManager.set_env("战争.咆哮.AI.技能", skills[0])
			goto_step("AI_3")
		1:
			DataManager.set_env("战争.咆哮.AI.技能", skills[0])
			goto_step("AI_3")
		_:
			LoadControl.end_script()
			FlowManager.add_flow("unit_action")
	return

func effect_30001_AI_3():
	var skillName = DataManager.get_env_str("战争.咆哮.AI.技能")
	var skill = StaticManager.get_skill(skillName)
	for effect in SkillHelper.get_skill_effects(actorId, skill, ["主动"]):
		LoadControl.end_script()
		var subSke = effect.create_ske_for(actorId)
		SkillHelper.save_skill_effectinfo(subSke)
		LoadControl.load_script(effect.path)
		FlowManager.add_flow("effect_{0}_AI_start".format([effect.id]))
		return
	LoadControl.end_script()
	return

func effect_30001_start():
	_process_skill_cd()
	if _chained_effect():
		var d = me.get_next_dialog(30000)
		if d != null:
			SceneManager.show_confirm_dialog(d.text, d.actorId, d.mood)
			LoadControl.set_view_model(2000)
			return
	goto_step("2")
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_2", false)
	return

func effect_30001_2()->void:
	var skills = _get_available_sub_skills()
	match skills.size():
		2:
			var msg = "发动哪个？"
			SceneManager.show_yn_dialog(msg, actorId, 2, skills)
			LoadControl.set_view_model(2001)
		1:
			DataManager.set_env("战争.咆哮.技能", skills[0])
			goto_step("3")
		_:
			var msg = "无法发动【{0}】".format([ske.skill_name])
			SceneManager.show_confirm_dialog(msg, actorId, 3)
			LoadControl.set_view_model(2999)
	return

func on_view_model_2001():
	var skill = ""
	match wait_for_skill_option():
		0:
			skill = "长啸"
		1:
			skill = "巨喝"
	var lsc = SceneManager.actor_dialog.lsc
	var current = lsc.cursor_index
	if current >= 0 and current < lsc.items.size():
		var tacticName = "<" + lsc.items[current] + ">"
		SceneManager.current_scene().battle_tactic.show_description(tacticName)
	if skill == "":
		return
	DataManager.set_env("战争.咆哮.技能", skill)
	goto_step("4")
	return

func effect_30001_3():
	var skill = DataManager.get_env_str("战争.咆哮.技能")
	var msg = "发动【{0}】".format([skill])
	SceneManager.show_confirm_dialog(msg, actorId, 0)
	LoadControl.set_view_model(2002)
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation(FLOW_BASE + "_4", false)
	return

func effect_30001_4():
	var skill = DataManager.get_env_str("战争.咆哮.技能")
	if not SkillHelper.player_choose_skill(actorId, skill, true):
		var msg = "无法发动【{0}】".format([skill])
		SceneManager.show_confirm_dialog(msg, actorId, 3)
		LoadControl.set_view_model(2999)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation(FLOW_BASE + "_end", false)
	return

func effect_30001_end():
	ske.battle_set_skill_val({}, 99999, YANYU_EFFECT_ID, actorId)
	LoadControl.end_script()
	DataManager.set_env("当前武将", actorId)
	FlowManager.add_flow("load_script|battle/player_tactic.gd")
	FlowManager.add_flow("tactic_end")
	return

func _get_available_sub_skills()->PoolStringArray:
	var skills = []
	for skillName in SUB_SKILLS:
		var skill = StaticManager.get_skill(skillName)
		if skill == null or not skill.valid_for_actor(actorId):
			continue
		if not SkillHelper.get_skill_effects(actorId, skill, ["主动"]).empty():
			skills.append(skill.name)
	return skills

func _process_skill_cd()->void:
	var info = ske.battle_get_skill_val_dic(YANYU_EFFECT_ID, actorId)
	if info.empty():
		# 正常发动
		ske.battle_cd(99999)
	else:
		# 燕语发动
		# 只处理自己的 CD 重置
		if ske.skill_name in info["cd"]:
			for setting in info["cd"][ske.skill_name]:
				var sceneId = setting[0]
				var effectId = setting[1]
				var cd = setting[2]
				SkillHelper.set_skill_cd(sceneId, effectId, actorId, cd, ske.skill_name)
	return

func _chained_effect()->bool:
	if _get_available_sub_skills().empty():
		return false
	if SkillHelper.actor_has_skills(actorId, ["厉威"]):
		var recovered = ske.change_actor_hp(actorId, 12)
		if recovered > 0:
			var msg = "【厉威】回复体力{0}".format([recovered])
			me.attach_free_dialog(msg, 1, 30000)
			return true
	return false
