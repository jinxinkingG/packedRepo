extends "effect_20000.gd"

#沉计主动技
#【沉计】大战场，主动技。无视计策获得条件，选择全计策列表中的1个计策，消耗其所需的机动力发动。使用该计策，那之后禁用之；以此法对智力比你低的敌将使用伤兵计时，无视命中率直接结算伤害。每回合限1次。

const EFFECT_ID = 20386
const FLOW_BASE = "effect_" + str(EFFECT_ID)

# 兼容并覆盖主流程场景：选择用计目标
func on_view_model_121():
	if not Global.is_action_pressed_BY():
		return
	if not SceneManager.dialog_msg_complete(false):
		return
	FlowManager.add_flow(FLOW_BASE + "_2")
	return

func effect_20386_start():
	play_dialog(actorId, "思而后行，举棋若定", 2, 2000)
	return

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_20386_2():
	var items = []
	var values = []
	for scheme in me.get_stratagems(99, 8):
		if not scheme.performable(me.actorId):
			continue
		var ap = scheme.get_cost_ap(me.actorId)
		items.append("{0}({1})".format([scheme.name, ap]))
		values.append(scheme.name)
	if items.empty():
		play_dialog(actorId, "没有任何可用计策", 3, 2999)
		return
	var msg = "【{0}】可使用全计策\n（当前机动力:{1}".format([
		ske.skill_name, me.action_point
	])
	DataManager.set_env("对话", msg)
	SceneManager.show_unconfirm_dialog(msg, me.actorId)
	bind_menu_items(items, values)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001():
	wait_for_choose_item(FLOW_BASE + "_3")
	return

func effect_20386_3():
	var schemeName = DataManager.get_env_str("目标项")
	var scheme = StaticManager.get_stratagem(schemeName)
	if scheme == null or not scheme.performable(me.actorId):
		goto_step("2")
		return
	start_scheme(schemeName)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return

func on_trigger_20009()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.skill != ske.skill_name:
		return false
	if se.get_action_id(me.actorId) != me.actorId:
		return false
	me.dic_skill_cd[se.name] = 99999
	ske.cost_war_cd(1)
	return false

func on_trigger_20010()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(me.actorId) != me.actorId:
		return false
	if se.skill != ske.skill_name:
		return false
	if se.targetId < 0:
		return false
	var targetActor = ActorHelper.actor(se.targetId)
	if se.damage_soldier() and actor.get_wisdom() > targetActor.get_wisdom():
		se.set_must_success(me.actorId, ske.skill_name)
	ske.war_report()
	return false
