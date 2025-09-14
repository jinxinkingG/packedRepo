extends "effect_20000.gd"

# 智囊效果
#【智囊】大战场，锁定技。你用伤兵计时，获得X%的暴击率和Y%的暴击伤害加成。你可通过主动发动该技能，手动调整X和Y的值，默认均为0，但(2X+Y)之和不能大于(等级*20)。

const EFFECT_ID = 20635
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20011()->bool:
	var flags = recalc_flags()
	if Global.get_rate_result(flags[0]):
		change_scheme_damage_rate(flags[1], false)
	return false

func on_trigger_20013() -> bool:
	recalc_flags()
	return false

func recalc_flags() -> Array:
	var flags = ske.get_war_skill_val_int_array()
	if flags.size() != 2:
		flags = [0, 0]
	var level = actor.get_level()
	var limit = level * 20
	if flags[0] * 2 + flags[1] != limit:
		flags[1] = limit - flags[0] * 2
	if flags[0] <= 0 or flags[1] <= 0:
		flags[0] = level * 5
		flags[1] = level * 10
	ske.set_war_skill_val(flags)
	return flags

func effect_20635_start() -> void:
	var msg = "调整【{0}】概率：".format([ske.skill_name])
	SceneManager.show_input_numbers(msg, ["概率"], [actor.get_level() * 10 - 1], [0])
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_multiple_number_input(FLOW_BASE + "_decided")
	return

func effect_20635_decided() -> void:
	var x = DataManager.get_env_int_array("多项数值")[0]
	var y = actor.get_level() * 20 - x * 2
	ske.set_war_skill_val([x, y])
	var msg = "圆转如意，方堪为智囊\n（调整为 {0}% 概率\n（增伤 {1}%".format([
		x, y,
	])
	play_dialog(actorId, msg, 2, 2999)
	return
