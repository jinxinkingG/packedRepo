extends "effect_20000.gd"

#放权主动技
#【放权】大战场，主将主动技。回合内你未进行过移动、攻击、用计的场合，指定1名队友，消耗你的全部机动力才能发动。你的经验+300，你方结束阶段时，你指定的目标额外获得1个单独的行动回合。每回合限1次。

const EFFECT_ID = 20173
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const EXP_GAIN = 300

# 接收事件处理放权的可用状态
func on_trigger_20003()->bool:
	# 移动
	if get_env_int("结束移动") != 1:
		return false
	if get_env_array("历史移动记录").empty():
		return false
	ske.cost_war_cd(1)
	return false

func on_trigger_20009()->bool:
	# 用计，此处要考虑替代用计的情况，如孔明的锦囊
	var se = DataManager.get_current_stratagem_execution()
	if se.fromId != me.actorId:
		return false
	ske.cost_war_cd(1)
	return false

func on_trigger_20015()->bool:
	# 攻击
	var bf = DataManager.get_current_battle_fight()
	if bf.fromId == me.actorId or bf.get_attacker_id() == me.actorId:
		ske.cost_war_cd(1)
	return false

func effect_20173_start():
	if DataManager.is_extra_war_round():
		var msg = "当前已是额外回合\n【{0}】可另择良机".format([ske.skill_name])
		play_dialog(me.actorId, msg, 2, 2999)
		return

	var msg = "选择队友发动【{0}】".format([
		ske.skill_name
	])
	if not wait_choose_actors(get_teammate_targets(me), msg, true):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

# 已选定队友
func effect_20173_2():
	var targetId = get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var msg = "清空机动力发动【{0}】\n{1}将在回合结束后\n额外单独行动".format([
		ske.skill_name, targetActor.get_name(),
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

# 执行
func effect_20173_3():
	var targetId = get_env_int("目标")

	ske.cost_war_cd(1)
	ske.cost_ap(me.action_point, true)
	ske.change_actor_exp(me.actorId, EXP_GAIN)

	var title = "孤"
	if actor.get_loyalty() == 100:
		title = "朕"
	DataManager.add_actor_to_extra_round(targetId)
	var msg = "{1}先去遛鸟啊，战事如何…\n{0}自决吧\n（{2}经验增加{3}".format([
		DataManager.get_actor_honored_title(targetId, me.actorId), title,
		actor.get_name(), EXP_GAIN
	])
	play_dialog(me.actorId, msg, 1, 2999)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return
