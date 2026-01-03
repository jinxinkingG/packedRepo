extends "effect_20000.gd"

# 避嫌主动技 #禁用计策
#【避嫌】大战场，主动技。至少存在1个可用的计策时才能发动：向敌方展示你的计策列表，令对方选择你的1个计策，直到战争结束前禁用；那之后，你获得该禁用计策的机动力。每回合限1次。

const EFFECT_ID = 20669
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func check_AI_perform_20000() -> bool:
	var stratagems = me.get_stratagems()
	# 排除基本计策
	stratagems.erase("火计")
	stratagems.erase("虚兵")
	stratagems.erase("要击")
	stratagems.erase("乱水")
	return stratagems.size() > 0

func effect_20669_AI_start() -> void:
	var stratagems = me.get_stratagems()
	var msg = "诡谋非我所好\n{0}意下如何？\n（{1}发动【{2}】".format([
		DataManager.get_actor_honored_title(me.get_war_enemy_leader().actorId, actorId),
		actor.get_name(), ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2000)
	return

func on_view_model_3000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_confirmed")
	return

func effect_20669_start() -> void:
	var stratagems = me.get_stratagems()
	if stratagems.empty():
		var msg = "已无计策可用，不可【{0}】".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return

	var msg = "发动【{0}】，展示可用计策\n令{1}任选一个禁用\n获得对应机动力，可否？".format([
		ske.skill_name, me.get_war_enemy_leader().get_name(),
	])
	play_dialog(actorId, msg, 2, 2000)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20669_confirmed() -> void:
	var stratagems = me.get_stratagems()
	var enemyLeader = me.get_war_enemy_leader()

	# 判断对方是否 AI 来决定接下来的交互
	if enemyLeader.get_controlNo() < 0:
		# AI 随便选一个
		stratagems.shuffle()
		DataManager.set_env("目标项", stratagems[0].name)
		goto_step("selected")
		return

	# 让玩家选择
	var items = []
	var values = []
	for stratagem in stratagems:
		var info = "{0} ({1})".format([
			stratagem.name, stratagem.get_cost_ap(actorId),
		])
		items.append(info)
		values.append(stratagem.name)

	var msg = "可禁用{0}一个计策\n令其获得对应机动力\n选哪个？".format([
		actor.get_name(),
	])
	SceneManager.show_unconfirm_dialog(msg, enemyLeader.actorId)
	SceneManager.bind_top_menu(items, values, 2)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001() -> void:
	wait_for_choose_item(FLOW_BASE + "_selected", true, false)
	return

func effect_20669_selected() -> void:
	var schemeName = DataManager.get_env_str("目标项")
	var scheme = StaticManager.get_stratagem(schemeName)
	var enemyLeader = me.get_war_enemy_leader()

	me.dic_skill_cd[scheme.name] = 99999
	var info = "选择禁用<y{0}>的<y{1}>".format([actor.get_name(), scheme.name])
	ske.append_message(info, enemyLeader.actorId)
	ske.cost_war_cd(1)
	var ap = ske.change_actor_ap(actorId, scheme.get_cost_ap(actorId))
	ske.war_report()

	var msg = "便如尔所言，又待如何？\n（禁用{1}的{2}".format([
		enemyLeader.get_name(), actor.get_name(),
		scheme.name
	])
	report_skill_result_message(ske, 2002, msg, 2, enemyLeader.actorId, false)
	return

func on_view_model_2002() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20669_report() -> void:
	report_skill_result_message(ske, 2002)
	return
