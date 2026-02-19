extends "effect_20000.gd"

# 立晋主动技
#【立晋】大战场，君主主动技。敌我场上没有姓司马的武将时，你可以从司马懿、司马昭、司马师3人的技能列表选择其中1个技能附加给自己；该效果附加的技能至多存在1个，且无视专属条件生效。每3回合限1次。

const EFFECT_ID = 20716
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const TARGET_ACTORS = [318, 455, 461]

func effect_20716_start()->void:
	for wa in me.get_teammates(false, true):
		if wa.actor().get_first_name() == actor.get_first_name():
			var msg = "{0}尚在，未可擅专\n（同姓武将在场\n（不可发动【{1}】".format([
				DataManager.get_actor_honored_title(wa.actorId, actorId),
				ske.skill_name,
			])
			play_dialog(actorId, msg, 2, 2999)
			return
	var attached = ske.get_war_skill_val_str()
	var items = []
	var values = []
	for targetId in TARGET_ACTORS:
		for skill in SkillHelper.get_actor_skills(targetId, 10000, true):
			if skill.name == attached:
				continue
			items.append("{0} 【{1}】".format([
				ActorHelper.actor(targetId).get_name(), skill.name
			]))
			values.append(skill.name)
	SceneManager.show_unconfirm_dialog("选择一个技能\n附加给自己", actorId)
	SceneManager.bind_top_menu(items, values, 2)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_item(FLOW_BASE + "_selected")
	return

func effect_20716_selected():
	var attached = ske.get_war_skill_val_str()
	var skillName = DataManager.get_env_str("目标项")
	if attached != "":
		ske.remove_war_skill(actorId, attached)
	ske.add_war_skill(actorId, skillName, 99999)
	ske.set_war_skill_val(skillName)
	ske.cost_war_cd(3)
	ske.war_report()

	var msg = "父兄功业，惟吾继之！\n（获得【{0}】".format([skillName])
	if attached != "":
		msg += "\n（替换【{0}】".format([attached])
	play_dialog(actorId, msg, 1, 2999)
	return
