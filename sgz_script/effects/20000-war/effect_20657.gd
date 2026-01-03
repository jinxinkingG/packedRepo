extends "effect_20000.gd"

# 存嗣限定技
#【存嗣】大战场，限定技。己方总兵力比对方少3000以上时，你可选择1名队友为目标，你禁用所有技能并减少一半体力上限才能发动。目标队友获得技能<决死>，你与其分别附加{围困}10回合。

const EFFECT_ID = 20657
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func check_AI_perform_2000() -> bool:
	# AI 不发动
	return false

func effect_20657_start() -> void:
	var targets = get_teammate_targets(me)
	if targets.empty():
		var msg = "没有可以发动【{0}】的目标".format([
			ske.skill_name
		])
		play_dialog(actorId, msg, 3, 2999)
		return

	# 兵力 < 对方 - 3000
	var wv = me.war_vstate()
	if wv.get_all_soldiers() > me.get_enemy_war_vstate().get_all_soldiers() - 3000:
		var msg = "兵力虽稍有不足，仍可奋战\n（不满足【{0}】发动条件".format([
			ske.skill_name
		])
		play_dialog(actorId, msg, 2, 2999)
		return

	if targets.size() == 1:
		DataManager.set_env("目标", targets[0])
		goto_step("selected")
		return

	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20657_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var msg = "对{0}发动限定技【{1}】\n可否？".format([
		ActorHelper.actor(targetId).get_name(), ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2001, true)
	map.next_shrink_actors = [actorId, targetId]
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20657_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	ske.add_war_skill(targetId, "决死", 99999)
	var maxHP = actor.get_max_hp()
	ske.change_actor_max_hp(actorId, -int(maxHP / 2))
	ske.set_war_buff(actorId, "围困", 10)
	ske.set_war_buff(targetId, "围困", 10)
	for skillName in SkillHelper.get_actor_skill_names(actorId):
		ske.ban_war_skill(actorId, skillName, 99999)
	ske.cost_war_cd(99999)
	ske.war_report()

	var msg = "主公大业，尚赖{0}\n今陷重围，但决死杀敌\n勿以{1}为念，休得两误！"
	if actor.get_loyalty() == 100:
		msg = "大业未成，惟托于{0}\n今陷重围，但决死杀敌\n勿以{1}为念，休得两误！"
	msg = msg.format([
		DataManager.get_actor_honored_title(targetId, actorId),
		DataManager.get_actor_self_title(actorId),
	])
	report_skill_result_message(ske, 2002, msg, 0)
	return

func on_view_model_2002() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20657_report() -> void:
	report_skill_result_message(ske, 2002)
	return
