extends "effect_20000.gd"

#退雄主动技
#【退雄】大战场，主动技。你可以在<冲魄>、<勇突>、<游龙>、<破围>、<奔袭>、<追袭>中，选择1个或2个，直至己方下回合开始前，附加给自己。选1个，冷却＝1回合；选2个，冷却＝2回合。选过的技能，不可再选，直到六个技能都被选过后，重置。

const EFFECT_ID = 20543
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const OPTIONAL_SKILLS = ["冲魄", "勇突", "游龙", "破围", "奔袭", "追袭"]

# 发动主动技
func effect_20543_start() -> void:
	_set_selected_skills([])
	var msg = "选择【{0}】技能（0/2）\n「B」键确认".format([
		ske.skill_name
	])
	var options = OPTIONAL_SKILLS.duplicate()
	for history in ske.get_war_skill_val_array():
		options.erase(history)
	if options.empty():
		ske.set_war_skill_val([])
		options = OPTIONAL_SKILLS.duplicate()
	SceneManager.show_unconfirm_dialog(msg)
	SceneManager.bind_top_menu(options, options, 2)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	var menu = SceneManager.lsc_menu_top
	var lsc = menu.lsc
	var selected = _get_selected_skills()

	var limit = 2
	if Global.is_action_pressed_BY() \
		and SceneManager.dialog_msg_complete():
			if lsc.get_selected_list().empty():
				var msg = "须选择1~2个技能（{0}/{1}）\n「A」键选择".format([
					lsc.get_selected_list().size(), limit
				])
				SceneManager.actor_dialog.rtlMessage.text = msg
			else:
				goto_step("2")
			return
	var idx = wait_for_choose_skill("", false, false, true, 2)
	if idx >= 0:
		var skill = lsc.items[idx]
		if skill in selected:
			selected.erase(skill)
		else:
			selected.append(skill)
		_set_selected_skills(selected)
		var msg = "选择【{0}】技能（{1}/{2}）\n「A」键选择".format([
			ske.skill_name, lsc.get_selected_list().size(), limit
		])
		if lsc.get_selected_list().size() > 0:
			msg = "选择【{0}】技能（{1}/{2}）\n「B」键确认".format([
				ske.skill_name, lsc.get_selected_list().size(), limit
			])
		SceneManager.actor_dialog.rtlMessage.text = msg
	return

func effect_20543_2() -> void:
	var lsc = SceneManager.lsc_menu_top.lsc
	var cd = 2
	var selected = []
	var history = ske.get_war_skill_val_array()
	for i in lsc.get_selected_list():
		var skill = lsc.items[i]
		ske.add_war_skill(actorId, skill, 1, true)
		selected.append("【" + skill + "】")
		history.append(skill)
	if selected.size() == 1:
		cd = 1
	ske.cost_war_cd(cd)
	ske.set_war_skill_val(history)
	ske.war_report()

	var msg = "看今朝英雄谁属！\n（解锁" + "、".join(selected)
	play_dialog(actorId, msg, 0, 2999)
	return

func _set_selected_skills(skills:Array)->void:
	var key = "战争.退雄.{0}".format([actorId])
	DataManager.set_env(key, skills)
	return

func _get_selected_skills()->Array:
	var key = "战争.退雄.{0}".format([actorId])
	return DataManager.get_env_array(key)
