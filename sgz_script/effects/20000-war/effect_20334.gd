extends "effect_20000.gd"

#离间主动技 #计伤
#【离间】大战场，主动技。你可以指定2名敌方不在太守府的男性武将，消耗6点机动力发动，视为你对两者分别发动计策“要击”，若计策成功，伤害计算和结算则视为两者相互发动。

const EFFECT_ID = 20334
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 6
const STRATAGEM = "要击"

func effect_20334_start() -> void:
	if not assert_action_point(actorId, COST_AP):
		return
	_clear_selected_targets()
	DataManager.unset_env("目标")
	goto_step("go")
	return

func effect_20334_go() -> void:
	_mark_selected_target()
	var selected = _get_selected_targets()
	if selected.size() >= 2:
		LoadControl.set_view_model(-1)
		goto_step("selected")
		return
	var targets = []
	var positions = []
	for selectedId in selected:
		var wa = DataManager.get_war_actor(selectedId)
		if wa != null and wa.has_position():
			positions.append(wa.position)
	map.show_color_block_by_position(positions)
	for targetId in get_enemy_targets(me, true):
		if targetId in selected:
			continue
		var wa = DataManager.get_war_actor(targetId)
		if wa.actor().get_gender() != "男":
			#仅限男性
			continue
		var blockCN = map.get_blockCN_by_position(wa.position)
		if blockCN == "太守府":
			#不允许勾引太守府敌军
			continue
		targets.append(wa.actorId)
	if targets.size() + selected.size() < 2:
		var msg = "没有可以发动【{0}】的目标".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return
	var msg = "选择敌军发动【{0}】（{1}/2）".format([
		ske.skill_name, selected.size()
	])
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_go")
	return

func effect_20334_selected() -> void:
	var selected = _get_selected_targets()
	var war_map = SceneManager.current_scene().war_map
	var positions = []
	for selectedId in selected:
		var wa = DataManager.get_war_actor(selectedId)
		if wa != null and wa.has_position():
			positions.append(wa.position)
	war_map.cursor.hide()
	war_map.show_color_block_by_position(positions)
	var msg = "花费{2}机动力发动【离间】\n令{0}和{1}相争，可否？".format([
		ActorHelper.actor(selected[0]).get_name(),
		ActorHelper.actor(selected[1]).get_name(),
		COST_AP,
	])
	play_dialog(self.actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20334_confirmed() -> void:
	var selected = _get_selected_targets()
	var msg = "二位将军...\n谁能为小女子做主呢？"
	ske.play_war_animation("Strategy_Talking", 2002, selected[0], msg, 3)
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_first_talk")
	return

func effect_20334_first_talk() -> void:
	var selected = _get_selected_targets()
	var first = ActorHelper.actor(selected[0])
	var second = ActorHelper.actor(selected[1])
	if first.get_moral() < second.get_moral():
		var tmp = first
		first = second
		second = tmp
	var msg = "{0}！\n尔惑于女色，欲图不轨耶？".format([
		DataManager.get_actor_naughty_title(second.actorId, first.actorId),
	])
	play_dialog(first.actorId, msg, 0, 2003)
	return

func on_view_model_2003() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_second_talk")
	return

func effect_20334_second_talk() -> void:
	var selected = _get_selected_targets()
	var first = ActorHelper.actor(selected[0])
	var second = ActorHelper.actor(selected[1])
	if first.get_moral() < second.get_moral():
		var tmp = first
		first = second
		second = tmp
	var msg = "{0}欺吾太甚！\n心存不轨者\n未知究竟何人！".format([
		DataManager.get_actor_naughty_title(first.actorId, second.actorId),
	])
	play_dialog(second.actorId, msg, 0, 2004)
	return

func on_view_model_2004() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_perform")
	return

func effect_20334_perform() -> void:
	var selected = _get_selected_targets()
	var targets = [[selected[0], selected[1]], [selected[1], selected[0]]]
	ske.cost_ap(COST_AP, true)
	var msgs = []
	var mood = 3
	var totalDamage = 0
	for target in targets:
		var msg = ""
		# 以发动者计算命中率
		var targetId = target[0]
		var anotherId = target[1]
		# 计策视为由 target 对 another 发起
		var se = DataManager.new_stratagem_execution(targetId, STRATAGEM, ske.skill_name)
		se.set_target(anotherId)
		# 但概率由「我」对 target 计算
		var rate = se.stratagem.get_rate(self.actorId, targetId)
		var targetActor = ActorHelper.actor(targetId)
		var anotherActor = ActorHelper.actor(anotherId)
		if Global.get_rate_result(rate):
			# 以对方实施和计算伤害，并无条件命中
			var soldiers = anotherActor.get_soldiers()
			se.perform_to_targets([anotherId], true)
			var damage = se.get_soldier_damage_for(anotherId)
			if damage > 0:
				totalDamage += damage
				mood = 1
				msg = "{0}攻击令{1}损兵{2}".format([
					targetActor.get_name(), anotherActor.get_name(), damage
				])
			se.report()
		if msg == "":
			msg = "{0}不为所动".format([
				targetActor.get_name()
			])
		msgs.append(msg)
	if totalDamage == 0:
		msgs = ["敌军未起争端"]
	DataManager.actor_add_Exp(actorId, totalDamage)
	play_dialog(actorId, "\n".join(msgs), mood, 2005)
	return

func on_view_model_2005() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_redo")
	return

func effect_20334_redo() -> void:
	if me.action_point < COST_AP:
		goto_step("end")
		return
	var msg = "是否继续发动【{0}】？".format([ske.skill_name])
	play_dialog(actorId, msg, 2, 2006, true)
	return

func on_view_model_2006() -> void:
	wait_for_yesno(FLOW_BASE + "_perform", true, FLOW_BASE + "_end")
	return

func effect_20334_end() -> void:
	_clear_selected_targets()
	map.show_color_block_by_position([])
	FlowManager.add_flow("player_skill_end_trigger")
	return

func _mark_selected_target():
	var targetId = DataManager.get_env_int("目标")
	if targetId < 0:
		return
	var selected = _get_selected_targets()
	selected.append(targetId)
	DataManager.unset_env("目标")
	DataManager.set_env("离间.目标", selected)
	return

func _get_selected_targets()->Array:
	return DataManager.get_env_int_array("离间.目标")

func _clear_selected_targets():
	DataManager.unset_env("离间.目标")
	return
