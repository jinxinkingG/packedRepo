extends "effect_20000.gd"

#力挽被动触发判断
#【力挽】大战场，锁定技。你不为主将时，若主将阵亡，被俘，大战场撤退，不判定战争失败，你自动成为新的主将。你失去<力挽>，并获得原主将的一个技能，持续到战争结束前。

const EFFECT_ID = 20412
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20027()->bool:
	if me.actorId == ske.actorId:
		# 自己不发动
		return false
	if ske.actorId != me.get_main_actor_id():
		# 不是主将不发动
		return false
	# 主将即将完蛋，在此之前，让自己成为主将
	me.war_vstate().main_actorId = me.actorId
	me.set_tmp_variable("替代主将", ske.actorId)
	me.set_tmp_variable("替代技能", ske.skill_name)
	var msg = "{0}之败，何其勇烈！\n我等岂能束手？听我号令！\n（{1}【{2}】成为主将".format([
		DataManager.get_actor_honored_title(ske.actorId, me.actorId),
		me.get_name(), ske.skill_name,
	])
	ske.ban_war_skill(actorId, ske.skill_name, 99999)
	var d = me.attach_free_dialog(msg, 0)
	d.callback_script = "effects/20000-war/effect_20412.gd"
	d.callback_method = "inheritage"
	return false

func inheritage()->bool:
	actor = ActorHelper.actor(actorId)
	me = DataManager.get_war_actor(actorId)
	var prevLeaderId = me.get_tmp_variable("替代主将", -1)
	var skillName = me.get_tmp_variable("替代技能", "")
	if prevLeaderId < 0 or skillName == "":
		return false
	var skills = SkillHelper.get_actor_skill_names(prevLeaderId, 10000)
	if skills.empty():
		return false
	if me.get_controlNo() < 0:
		skills.shuffle()
		SkillHelper.add_actor_scene_skill(20000, actorId, skills[0], 99999, actorId, skillName)
		SkillHelper.update_all_skill_buff("ADD_WAR_SKILL")
		var msg = "失去【{1}】\n获得【{2}】".format([
			actor.get_name(), skillName, skills[0]
		])
		me.attach_free_dialog(msg, 2, 20000, -1)
		return false
	var vmAI = DataManager.get_env_int("战争-AI-步骤")
	var vmPlayer = DataManager.get_env_int("战争-玩家-步骤")
	DataManager.set_env("战争-AI-步骤", -1)
	DataManager.set_env("战争-AI-步骤.{0}".format([EFFECT_ID]), vmAI)
	DataManager.set_env("战争-玩家-步骤", -1)
	DataManager.set_env("战争-玩家-步骤.{0}".format([EFFECT_ID]), vmPlayer)
	var triggerKey = "{0}/{1}/{2}/{3}/{4}".format([
		skillName, -1, "特殊", EFFECT_ID, actorId,
	])
	var skill = StaticManager.get_skill(skillName)
	var effect = skill.get_effect(EFFECT_ID)
	var ske = effect.create_ske_for(actorId)
	SkillHelper.save_skill_effectinfo(ske)
	var path = "effects/20000-war/effect_{0}.gd".format([EFFECT_ID])
	LoadControl.load_script(path)
	var msg = "{0}之败，何其勇烈！\n我等岂能束手？听我号令！\n（{1}【{2}】成为主将".format([
		DataManager.get_actor_honored_title(prevLeaderId, me.actorId),
		me.get_name(), skillName,
	])
	play_dialog(actorId, msg, 2, 2000)
	return true

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_choice")
	return

func effect_20412_choice()->void:
	var prevLeaderId = me.get_tmp_variable("替代主将", -1)
	var skillName = me.get_tmp_variable("替代技能", "")
	var skills = SkillHelper.get_actor_skill_names(prevLeaderId, 10000)
	var msg = "选择{0}的一个技能".format([
		ActorHelper.actor(prevLeaderId).get_name()
	])
	SceneManager.show_unconfirm_dialog(msg, actorId)
	bind_menu_items(skills, skills, 2)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001()->void:
	wait_for_choose_skill(FLOW_BASE + "_chosen", false, false)
	return

func effect_20412_chosen()->void:
	var skillName = me.get_tmp_variable("替代技能", "")
	var skill = DataManager.get_env_str("目标项")
	SceneManager.hide_all_tool()
	var vmAI = DataManager.get_env_int("战争-AI-步骤.{0}".format([EFFECT_ID]))
	var vmPlayer = DataManager.get_env_int("战争-玩家-步骤.{0}".format([EFFECT_ID]))
	DataManager.set_env("战争-AI-步骤", vmAI)
	DataManager.set_env("战争-玩家-步骤", vmPlayer)
	SkillHelper.add_actor_scene_skill(20000, actorId, skill, 99999, actorId, skillName)
	SkillHelper.update_all_skill_buff("ADD_WAR_SKILL")
	var msg = "失去【{1}】\n获得【{2}】".format([
		actor.get_name(), skillName, skill,
	])
	me.attach_free_dialog(msg, 2, 20000, -1)
	LoadControl.end_script()
	FlowManager.add_flow("player_skill_end_trigger")
	return
