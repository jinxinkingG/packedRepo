extends "effect_10000.gd"

#勤耕效果
#【勤耕】内政,锁定技。你执行开发土地时，体力-20%，获得2倍效果。你的体力＞40%才能发动

const TARGET_TYPE = "土地"

func on_trigger_10002()->bool:
	var cmd = DataManager.get_current_develop_command()
	if cmd.type != TARGET_TYPE:
		return false
	var hp = actor.get_hp()
	var maxHP = actor.get_max_hp()
	if hp * 5 <= maxHP * 2:
		return false

	cmd.source = ske.skill_name
	cmd.effectRate *= 2
	return false

func on_trigger_10019()->bool:
	var cmd = DataManager.get_current_develop_command()
	if cmd.source != ske.skill_name:
		return false
	if cmd.type != TARGET_TYPE:
		return false
	var hp = actor.get_hp()
	var maxHP = actor.get_max_hp()
	if hp * 5 > maxHP * 2:
		actor.set_hp(int(hp - maxHP * 0.2))
	var msg = "不辞劳苦，效果翻倍\n体力降低20%，现为{0}".format([
		actor.get_hp(),
	])
	cmd.append_extra_message(msg)
	return false
