extends "effect_20000.gd"

#布恩效果
#【布恩】大战场，主将诱发技。在你的内政回合内发生战争，若你有剩余命令书，则在队友被敌军攻击的场合，你可消耗1枚命令书发动。取消那次攻击并令该对方武将机动力清零。每回合限1次。

const EFFECT_ID = 20466
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20015() -> bool:
	var bf = DataManager.get_current_battle_fight()
	if bf.targetId == actorId:
		return false
	if bf.targetId != ske.actorId:
		return false
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no]
	if vstateId != me.vstate().id:
		return false
	if DataManager.orderbook <= 0:
		return false
	return true

func effect_20466_start()->void:
	var bf = DataManager.get_current_battle_fight()
	var msg = "消耗一枚命令书（现有：{0}\n为{1}规避{2}的攻击\n并清空{2}的机动力，可否？".format([
		DataManager.orderbook, bf.get_defender().get_name(),
		bf.get_attacker().get_name(),
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000()->void:
	wait_for_yesno(FLOW_BASE + "_2", false)
	return

func effect_20466_2()->void:
	var bf = DataManager.get_current_battle_fight()
	var attacker = bf.get_attacker()
	ske.cost_war_cd(1)
	ske.change_actor_ap(attacker.actorId, -attacker.action_point)
	ske.war_report()
	DataManager.orderbook = max(0, DataManager.orderbook - 1)
	var msg = "此战凶险，{0}不必勉强\n（【{1}】令{2}攻击无效\n（花费1命令书，现为{3}".format([
		DataManager.get_actor_honored_title(ske.actorId, actorId),
		ske.skill_name, attacker.get_name(),
		DataManager.orderbook,
	])
	play_dialog(actorId, msg, 2, 2001)
	return

func on_view_model_2001()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_20466_3()->void:
	skill_end_clear(true)
	FlowManager.add_flow("AI_before_ready")
	return
