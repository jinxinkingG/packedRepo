extends "effect_20000.gd"

#狭威主动技
#【狭威】大战场，主动技。你可消耗任意点数的机动力发动。将消耗的机动力转为等量的“威”标记；你每有一个“威”标记，白刃战时你的士气 +1，最大升至70；你方回合开始时，清空你的“威”标记。每回合限1次。

const EFFECT_ID = 20495
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const FLAG_NAME = "威"

func effect_20495_start()->void:
	if me.action_point <= 0:
		var msg = "机动力不足\n无法发动【{0}】".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return
	SceneManager.hide_all_tool()
	var msg = "将多少机动力转化为「威」？"
	SceneManager.show_input_numbers(msg, ["机动力"], [me.action_point], [0], [2])
	SceneManager.input_numbers.show_actor(actorId)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_number_input(FLOW_BASE + "_go")
	return

func effect_20495_go()->void:
	var ap = DataManager.get_env_int("数值")
	ske.change_actor_ap(actorId, -ap)
	ske.add_skill_flags(20000, ske.effect_Id, FLAG_NAME, ap, 99)
	ske.cost_war_cd(1)
	ske.war_report()
	var msg = "不动如山，其威自见\n（机动力 -{0}\n（「威」标记 +{0}".format([ap])
	play_dialog(actorId, msg, 2, 2999)
	return

func on_view_model_2999()->void:
	wait_for_skill_result_confirmation()
	return
