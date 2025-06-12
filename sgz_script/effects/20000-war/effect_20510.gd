extends "effect_20000.gd"

#助望主动技
#【助望】大战场，主动技。本回合你方主将发动过主动技，你才能发动：令你方主将临时获得<德服>，持续2回合；若主将与你不同姓，你需要选择一个其他技能禁用。每3回合限1次。

const EFFECT_ID = 20510
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const TARGET_SKILL = "德服"

func on_trigger_20040() -> bool:
	# 我方武将发动主动技
	var prevSkeData = DataManager.get_env_dict("战争.完成技能")
	if prevSkeData.empty():
		return false
	var prevSke = SkillEffectInfo.new()
	prevSke.input_data(prevSkeData)
	if prevSke.effect_type != "主动":
		return false
	if prevSke.actorId != me.get_main_actor_id():
		return false
	ske.set_war_skill_val(1, 1)
	return false

func effect_20510_start()->void:
	var leader = me.get_leader()
	if ske.get_war_skill_val_int() <= 0:
		var msg = "{0}未发动主动技\n不可【{1}】".format([
			leader.get_name(), ske.skill_name,
		])
		play_dialog(actorId, msg, 2, 2999)
		return
	var skillNames = []
	if leader.actor().get_first_name() != me.actor().get_first_name():
		# 不同姓
		for skill in SkillHelper.get_actor_basic_skills(actorId):
			skillNames.append(skill.name)
		skillNames.erase(ske.skill_name)
		if skillNames.empty():
			var msg = "已无技能可以禁用\n不可【{0}】".format([
				ske.skill_name,
			])
			play_dialog(actorId, msg, 2, 2999)
			return

	if not skillNames.empty():
		var msg = "选择禁用技能以发动【{0}】".format([ske.skill_name])
		SceneManager.show_unconfirm_dialog(msg, actorId, 2)
		bind_menu_items(skillNames, skillNames, 2)
		LoadControl.set_view_model(2000)
		return

	DataManager.set_env("目标项", "")
	var msg = "发动【{0}】\n令{1}获得【{2}】\n可否？".format([
		ske.skill_name, me.get_leader().get_name(), TARGET_SKILL,
	])
		
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2000()->void:
	wait_for_choose_skill(FLOW_BASE + "_2")
	return

func effect_20510_2()->void:
	var discard = DataManager.get_env_str("目标项")
	var msg = "禁用【{0}】发动【{1}】\n令{2}获得【{3}】\n可否？".format([
		discard, ske.skill_name, me.get_leader().get_name(), TARGET_SKILL,
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001()->void:
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20510_3()->void:
	var discard = DataManager.get_env_str("目标项")
	ske.cost_war_cd(3)
	ske.add_war_skill(me.get_leader().actorId, TARGET_SKILL, 2)
	if discard != "":
		ske.ban_war_skill(actorId, discard, 99999)
	ske.war_report()

	var msg = "{0}既已定计\n吾自当呼应\n（{1}获得【{2}】".format([
		DataManager.get_actor_honored_title(me.get_leader().actorId, actorId),
		me.get_leader().get_name(), TARGET_SKILL
	])
	if discard != "":
		msg += "\n（{0}失去【{1}】".format([
			actor.get_name(), discard,
		])
	play_dialog(actorId, msg, 2, 2999)
	return
