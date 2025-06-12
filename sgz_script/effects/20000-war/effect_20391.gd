extends "effect_20000.gd"

#嘘枯和旅军效果实现
#【嘘枯】大战场，锁定技。你使用伤兵计时，机动力固定消耗2点，但伤害为原本的X%（X默认为20）。
#【旅军】大战场，锁定技。你的<嘘枯>效果中：X改为你的经验值/500，且X至多为120。

func on_trigger_20004()->bool:
	var schemes = get_env_array("战争.计策列表")
	var msg = get_env_str("战争.计策提示")
	for scheme in schemes:
		scheme[1] = 2
	change_stratagem_list(me.actorId, schemes, msg)
	return false

func on_trigger_20005()->bool:
	set_scheme_ap_cost("ALL", 2)
	return false

func on_trigger_20011()->bool:
	var x = 20
	if SkillHelper.actor_has_skills(actorId, ["旅军"], false):
		x = min(120, int(actor.get_exp() / 500))
		x = max(x, 20)
	change_scheme_damage_rate(x - 100, true)
	return false
