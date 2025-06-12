extends "effect_20000.gd"

# 决阵诱发技
#【决阵】大战场，诱发技。你进行攻击宣言时才能发动。你可消耗任意点数的机动力，令被敌将在那次白刃战中减少同样点数的战术值。

const EFFECT_ID = 20594
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20015() -> bool:
	ske.set_war_skill_val(0)
	if bf.get_attacker_id() != actorId:
		return false
	if me.action_point <= 0:
		return false
	return true

func effect_20594_AI_start() -> void:
	var ap = min(me.action_point, 6)
	DataManager.set_env("数值", ap)
	goto_step("confirmed")
	return

func effect_20594_start() -> void:
	var msg = "消耗多少机动力？".format([
		bf.get_target().get_name()
	])
	SceneManager.show_input_numbers(msg, ["机动力"], [me.action_point], [0], [2])
	SceneManager.input_numbers.show_actor(actorId)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_number_input(FLOW_BASE + "_confirmed")
	return

#播放动画
func effect_20594_confirmed() -> void:
	var ap = DataManager.get_env_int("数值")
	ap = ske.cost_ap(ap, true)
	ske.set_war_skill_val(ap, 1)

	var msg = "倾力一击，{0}受死！\n（{1}机动力 -{2}".format([
		DataManager.get_actor_naughty_title(bf.get_target().actorId, actorId),
		actor.get_name(), ap,
	])
	play_dialog(actorId, msg, 0, 2990)
	return
