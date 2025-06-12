extends "effect_20000.gd"

#铁索主动技 #消耗标记 #连续发动 #施加状态
#【铁索】大战场，主动技。选择场上2名武将为目标，消耗X点机动力发动：对这些目标分别附加/解除1回合{铁索}状态。(X=同一回合内，该技能的发动次数)。

const EFFECT_ID = 20402
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const EFFECT_CHOOSE_NAME = "战争."+str(EFFECT_ID)+".目标"
const EFFECT_CHOOSE_ACTOR = "战争."+str(EFFECT_ID)+".武将"
const EFFECT_DIALOG_FLAG = "战争."+str(EFFECT_ID)+".对话"

func get_cost_ap()->int:
	return ske.get_war_skill_val_int() + 1

# AI 判断，尝试将最笨的和最聪明的连起来
func check_AI_perform_20000()->bool:
	if me.action_point < get_cost_ap():
		return false
	var minWisdom = 99
	var maxWisdom = 1
	var targets = [-1, -1]
	for targetId in get_enemy_targets(me):
		var wa = DataManager.get_war_actor(targetId)
		if wa.get_buff_label_turn(["铁索"]) > 0:
			continue
		var wisdom = wa.actor().get_wisdom()
		if wisdom < minWisdom:
			minWisdom = wisdom
			targets[0] = wa.actorId
		if wisdom > maxWisdom:
			maxWisdom = wisdom
			targets[1] = wa.actorId
	if maxWisdom - minWisdom < 20:
		return false
	DataManager.set_env(EFFECT_CHOOSE_NAME, targets)
	return true

func effect_20402_AI_start()->void:
	goto_step("4")
	return

#初始化-一次连续操作只秀一次台词
func effect_20402_start():
	DataManager.unset_env(EFFECT_DIALOG_FLAG)
	# 先清空列表
	DataManager.set_env(EFFECT_CHOOSE_NAME, [])
	DataManager.set_env(EFFECT_CHOOSE_ACTOR, -1)
	_update_select_color()
	goto_step("go")
	return

#开始-选择6格内的任意任意
func effect_20402_go():
	if not assert_action_point(me.actorId, get_cost_ap()):
		return
	var targets = get_enemy_targets(me)
	targets.append_array(get_teammate_targets(me, -1, false))
	targets.append(me.actorId)
	if targets.size() < 2:
		var msg = "没有足够的目标\n无法发动【{0}】".format([ske.skill_name])
		play_dialog(me.actorId, msg, 3, 2999)
		return

	# 修改默认目标，尽量找敌军中没有被连的第一个
	var lastTargetId = get_env_int(EFFECT_CHOOSE_ACTOR)
	if lastTargetId >= 0 && lastTargetId in targets:
		targets.erase(lastTargetId)
		targets.insert(0, lastTargetId)

	var selected = get_env_int_array(EFFECT_CHOOSE_NAME)
	var status = "({0}/2)".format([selected.size()])
	var msg = "对何人发动【{0}】？".format([ske.skill_name]) + status
	if not wait_choose_actors(targets, msg):
		return
	if selected.size() < 2:
		# 修改默认目标，光标总指向最后选的那个
		for id in targets:
			if id in selected:
				continue
			var wa = DataManager.get_war_actor(id)
			if wa.get_buff_label_turn(["铁索"]) > 0:
				continue
			map.set_cursor_location(wa.position, true)
			set_env("武将", id)
			SceneManager.show_actor_info(id, true, msg)
			map.next_shrink_actors = [id]
			break
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	if Input.is_action_just_pressed("EMU_START"):
		goto_step("cancel")
		return
	wait_for_choose_actor(FLOW_BASE + "_2", true, true, FLOW_BASE + "_3")
	return

#确认连接/解除情况
func effect_20402_2():
	var targetId = DataManager.get_env_int("目标")
	var selected = get_env_int_array(EFFECT_CHOOSE_NAME)
	if targetId in selected:
		selected.erase(targetId)
	elif selected.size() < 2:
		selected.append(targetId)
	DataManager.set_env(EFFECT_CHOOSE_ACTOR, targetId)
	DataManager.set_env(EFFECT_CHOOSE_NAME, selected)
	_update_select_color()
	FlowManager.add_flow("draw_actors")
	goto_step("go")
	return

func effect_20402_cancel():
	DataManager.set_env(EFFECT_CHOOSE_NAME, [])
	_update_select_color()
	goto_step("go")
	return

func effect_20402_3():
	var selected = get_env_int_array(EFFECT_CHOOSE_NAME)
	if selected.empty():
		back_to_skill_menu()
		return
	if selected.size() < 2:
		goto_step("go")
		return
	var msgs = []
	for targetId in selected:
		var wa = DataManager.get_war_actor(targetId)
		var msg = "对{0}附加[铁索]"
		if wa.get_buff_label_turn(["铁索"]) > 0:
			msg = "解除{0}的[铁索]"
		msgs.append(msg.format([wa.get_name()]))
	msgs.append("消耗{0}机动力，可否？".format([get_cost_ap()]))
	play_dialog(me.actorId, "\n".join(msgs), 2, 2001, true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_4")
	return

#播放动画
func effect_20402_4():
	var selected = get_env_int_array(EFFECT_CHOOSE_NAME)
	if DataManager.get_env_int(EFFECT_DIALOG_FLAG) > 0:
		goto_step("5")
	else:
		DataManager.set_env(EFFECT_DIALOG_FLAG, 1)
		ske.play_war_animation("Strategy_ConnectBoat", 2002, selected[0], "铁锁横江，以待天时！", 0)
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation(FLOW_BASE + "_5")
	return

func effect_20402_5():
	var selected = get_env_int_array(EFFECT_CHOOSE_NAME)
	var msgs = []
	# 保留现场，因为 set_war_buff 可能触发技能破坏现场
	var currentSke = ske
	for targetId in selected:
		var wa = DataManager.get_war_actor(targetId)
		var linked = wa.get_buff_label_turn(["铁索"])
		var msg = ""
		if linked > 0:
			if ske.remove_war_buff(targetId, "铁索连环"):
				msg = "{0}已经解除[铁索]"
			else:
				msg = "未能接触{0}的[铁索]"
		else:
			if ske.set_war_buff(targetId, "铁索连环", 1) > 0:
				msg = "{0}已被[铁索]连起来"
			else:
				msg = "对{0}[铁索]失败"
		msgs.append(msg.format([wa.get_name()]))
	# 恢复现场
	ske = currentSke
	SkillHelper.save_skill_effectinfo(currentSke)
	init_vars()
	# 已经交代得很清楚了，仅记录日志
	var ap = get_cost_ap()
	ske.cost_ap(ap)
	ske.set_war_skill_val(ap, 1)
	ske.war_report()
	play_dialog(me.actorId, "\n".join(msgs), 2, 2003)
	return

func on_view_model_2003():
	wait_for_skill_result_confirmation(FLOW_BASE + "_6")
	return

func effect_20402_6():
	var moreTargets = false
	if me.get_controlNo() >= 0 and me.action_point >= get_cost_ap():
		for targetId in get_enemy_targets(me):
			var wa = DataManager.get_war_actor(targetId)
			if wa.get_buff_label_turn(["铁索"]) > 0:
				continue
			moreTargets = true
			break
	if not moreTargets:
		FlowManager.add_flow("player_skill_end_trigger")
		return
	ske.reset_for_redo()
	DataManager.set_env(EFFECT_CHOOSE_NAME, [])
	DataManager.set_env(EFFECT_CHOOSE_ACTOR, -1)
	goto_step("go")
	return

func _update_select_color():
	var positions = []
	for targetId in get_env_int_array(EFFECT_CHOOSE_NAME):
		var wa = DataManager.get_war_actor(targetId)
		positions.append(wa.position)
	map.show_color_block_by_position(positions)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return

