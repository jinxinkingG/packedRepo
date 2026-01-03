extends "effect_20000.gd"

# 斩道触发效果和亢英效果
#【斩道】大战场，主动技。指定1个6格内的非城地形，消耗5点机动力发动，标记目标位置。若敌将移至被你标记过位置时，令其选择一项：1.你与其进入白刃战；2.结算一次火计伤害。战争中至多存在5个标记位置，每回合限1次。
#【亢英】大战场，锁定技。你的<斩道>效果中的“令之选择一项”改为“由你选择一项”。

const EFFECT_ID = 20703
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const ACTIVE_EFFECT_ID = 20702

func on_trigger_20042() -> bool:
	# 确认一下位置，位置有效就触发
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null or wa.disabled or not wa.has_position():
		return false
	if not wa.position in get_marked_positions():
		return false
	# 去除此位置标记
	demark_position(wa.position)
	return true

func effect_20703_start() -> void:
	if SkillHelper.actor_has_skills(actorId, ["亢英"], true):
		# 我来选
		goto_step("decide")
		return
	# 令其选择一项
	goto_step("choice")
	return

func effect_20703_choice() -> void:
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa.get_controlNo() < 0:
		# AI 随机选
		if randi() % 2 == 0:
			goto_step("fight")
		else:
			goto_step("fire")
		return

	# 提示选择
	var options = ["进入战斗", "承受火伤"]
	var msg = "{0}【{1}】效果触发\n请选择一项：".format([
		actor.get_name(), ske.skill_name
	])
	SceneManager.show_yn_dialog(msg, actorId, 2, options)
	LoadControl.set_view_model(2000)
	return

func effect_20703_decide() -> void:
	var wa = DataManager.get_war_actor(ske.actorId)
	if me.get_controlNo() < 0:
		# AI 随机选
		if randi() % 2 == 0:
			goto_step("fight")
		else:
			goto_step("fire")
		return

	var options = ["进入战斗", "承受火伤"]
	var msg = "{0}触发【{1}】效果\n为其选择一项：".format([
		wa.get_name(), ske.skill_name
	])
	SceneManager.show_yn_dialog(msg, actorId, 2, options)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	match wait_for_skill_option():
		0:
			goto_step("fight")
		1:
			goto_step("fire")
	return

func effect_20703_fight() -> void:
	var msg = "{0}既蹈死地，何惧一战！".format([
		DataManager.get_actor_naughty_title(ske.actorId, actorId)
	])
	me.attach_free_dialog(msg, 0)
	start_battle_and_finish(actorId, ske.actorId)
	return

func effect_20703_fire() -> void:
	var msg = "{0}死地可免，活罪难逃！".format([
		DataManager.get_actor_naughty_title(ske.actorId, actorId)
	])
	play_dialog(actorId, msg, 0, 2001)
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_firing")
	return

func effect_20703_firing() -> void:
	var se = DataManager.new_stratagem_execution(actorId, "火计", ske.skill_name)
	se.set_target(ske.actorId)
	se.set_must_success(actorId, ske.skill_name)
	se.perform_to_targets([ske.actorId])
	ske.play_se_animation(se, 2002)
	return

func on_view_model_2002() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20703_report() -> void:
	var se = DataManager.get_current_stratagem_execution()
	report_stratagem_result_message(se, 2002)
	return

func get_marked_positions() -> PoolVector2Array:
	var marked = ske.get_war_skill_val_int_array(ACTIVE_EFFECT_ID)
	var markedPositions = []
	for i in range(0, marked.size(), 2):
		var x = marked[i]
		var y = marked[i + 1]
		markedPositions.append(Vector2(x, y))
	return markedPositions

func demark_position(pos: Vector2) -> void:
	var marked = get_marked_positions()
	marked.erase(pos)
	var vals = []
	for p in marked:
		vals.append(p.x)
		vals.append(p.y)
	ske.set_war_skill_val(vals, 99999, ACTIVE_EFFECT_ID)
	return
