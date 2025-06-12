extends "effect_30000.gd"

#连弩主动技部分
#【连弩】小战场,主动技。使用后：你的全体士兵立即装备连弩，每日限1次。注：连弩：远近伤害倍率均为0.6，默认1~3格射程，火矢不生效，一回合射击3次，持续3回合。

const EFFECT_ID = 30109
const BUFF_TURNS = 3

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation("tactic_end", false)
	return

# 小战场主动技部分
func effect_30109_start():
	var states = bf.get_units_states(me.actorId)
	for k in states:
		if k == "将":
			continue
		states[k] = "待机"
	bf.set_unit_state(me.actorId, states)
	me.set_buff("连弩", BUFF_TURNS, me.actorId)
	ske.set_battle_skill_val(1, 99999)
	ske.cost_war_cd(1)
	ske.battle_cd(99999)
	for bu in DataManager.battle_units:
		if bu == null or bu.disabled or bu.leaderId != me.actorId:
			continue
		if bu.get_unit_type() == "将":
			continue
		bu.dic_combat["近身伤害"] = 0.7
		bu.dic_combat["射击距离"] = 3
		bu.dic_combat["射击伤害"] = 0.7
		var originalActionTimes = bu.get_action_times()
		bu.set_action_times(3)
		if originalActionTimes < 3:
			bu.wait_action_times += 3 - originalActionTimes
		bu.dic_combat["移动所需行动次数"] = 3
		bu.dic_combat["禁用火矢"] = 1

	SceneManager.show_confirm_dialog("连弩速射，片甲不留！", me.actorId, 0)
	LoadControl.set_view_model(2000)
	return false
