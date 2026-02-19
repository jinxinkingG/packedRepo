extends "effect_20000.gd"

# 乱诛效果
#【乱诛】大战场，诱发技。你以白刃战，战胜了「战争初始阵营和当前阵营不同的」敌将，且对方未死亡时才能发动。你以那名敌将为目标，无视条件发动1次<揽权>。

const EFFECT_ID = 20714
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const EXTENDED_SKILL = "揽权"

func on_trigger_20020() -> bool:
	var loser = bf.get_loser()
	if loser == null or loser.actorId == actorId:
		return false
	if loser.wvId == me.wvId or loser.wvId == loser.initWvId:
		# 与我同阵营，或未更换阵营
		return false
	if loser.disabled:
		# 已战败
		return false
	return true

func effect_20714_AI_start() -> void:
	goto_step("start")
	return

func effect_20714_start() -> void:
	var flags = {}
	flags["预设目标"] = [bf.loserId]
	SkillHelper.player_choose_skill(actorId, EXTENDED_SKILL, true, flags)
	return
