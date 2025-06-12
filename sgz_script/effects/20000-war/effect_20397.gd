extends "effect_20000.gd"

#双顾主动技
#【双顾】大战场，锁定技。你用计策选择1名目标后，若计策范围内有其他的合法目标：你可消耗2点机动力，额外指定1个计策目标（分别计算成功率）。

const EFFECT_ID = 20397
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 2

func on_trigger_20018()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if me.action_point < COST_AP + se.get_cost_ap(me.actorId):
		return false
	var wa = DataManager.get_war_actor(se.targetId)
	if wa == null:
		return false
	if se.get_affected_actors(wa.position).size() > 1:
		return false
	if se.stratagem._get_extended_targets(me, wa).size() > 1:
		return false
	var targets = se.get_available_targets()[0]
	targets.erase(se.targetId)
	if targets.empty():
		return false
	return true

func effect_20397_start():
	var se = DataManager.get_current_stratagem_execution()
	var targets = se.get_available_targets()[0]
	targets.erase(se.targetId)
	var msg = "【{0}】可消耗2机动力选择第二名计策对象".format([
		ske.skill_name,
	])
	if not wait_choose_actors(targets, msg, true):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2", false, true, FLOW_BASE + "_cancel")
	return

func effect_20397_cancel():
	var se = DataManager.get_current_stratagem_execution()
	var wa = DataManager.get_war_actor(se.targetId)
	map.set_cursor_location(wa.position, true)
	map.show_can_choose_actors([se.targetId])
	skill_end_clear()
	return

func effect_20397_2():
	var se = DataManager.get_current_stratagem_execution()
	var wa = DataManager.get_war_actor(se.targetId)
	var targetId = get_env_int("目标")
	set_env("战争.双顾.目标", targetId)
	se.perform_cost()
	ske.cost_ap(COST_AP)
	var msg = "消耗<y{0}>机动力，追加<y{1}>为计策对象".format([
		COST_AP, ActorHelper.actor(targetId).get_name(),
	])
	se.append_message(msg)
	msg = se.get_message() + "\n（【{0}】追加目标{1}".format([
		ske.skill_name, ActorHelper.actor(targetId).get_name(),
	])
	play_dialog(me.actorId, msg, 2, 2001)
	map.show_can_choose_actors([se.targetId, targetId])
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_20397_3():
	var se = DataManager.get_current_stratagem_execution()
	var targetId = get_env_int("战争.双顾.目标")
	var rawRate = se.get_raw_rate([se.targetId, targetId])
	var rate = se.get_rate([se.targetId, targetId])
	var signChar = "+"
	if rate < rawRate:
		signChar = "-"
	var msg = "对二人综合命中率：{0}({1}{2})%".format([
		rawRate, signChar, rate - rawRate,
	])
	SceneManager.play_war_animation(
		se.stratagem.get_animation(), -1, "",
		msg, me.actorId, 2
	)
	LoadControl.set_view_model(2002)
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_20397_4():
	var se = DataManager.get_current_stratagem_execution()
	var targetId = get_env_int("战争.双顾.目标")
	se.perform_to_targets([se.targetId, targetId])
	SkillHelper.auto_trigger_skill(se.get_action_id(se.hiddenActionId), 20009, "")
	FlowManager.add_flow("draw_actors")
	DataManager.set_env("对话PENDING", se.get_report_message())
	var st = SkillHelper.get_current_skill_trigger()
	st.next_flow = "stratagem_confirm_result"
	FlowManager.add_flow("draw_actors")
	LoadControl.end_script()
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return

# 暂不支持 AI
# 数据没问题，但视效和汇报有问题
# TODO
func DISABLED_effect_20397_AI_start():
	var se = DataManager.get_current_stratagem_execution()
	var targets = se.get_available_targets()[0]
	targets.erase(se.targetId)
	targets.shuffle()
	var targetId = targets[0]
	set_env("战争.双顾.目标", targetId)
	se.perform_cost()
	ske.cost_ap(COST_AP)
	var msg = "消耗<y{0}>机动力，追加<y{1}>为计策对象".format([
		COST_AP, ActorHelper.actor(targetId).get_name(),
	])
	se.append_message(msg)
	se.perform_to_targets([se.targetId, targetId])
	SkillHelper.auto_trigger_skill(se.get_action_id(se.hiddenActionId), 20009, "")
	var speakerWA = DataManager.get_war_actor(se.targetId)
	# 对队友用计、被笼络、被杀，均为敌方发言
	if speakerWA == null or speakerWA.disabled or not me.is_enemy(speakerWA):
		speakerWA = me.get_war_enemy_leader()
	DataManager.set_env("对话PENDING", se.get_report_message(speakerWA, me))
	var st = SkillHelper.get_current_skill_trigger()
	st.next_flow = "AI_strategem_1"
	FlowManager.add_flow("draw_actors")
	LoadControl.end_script()
	return
