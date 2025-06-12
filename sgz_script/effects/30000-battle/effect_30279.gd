extends "effect_30000.gd"

# 叛离效果
#【叛离】大战场，锁定技。若你转移过阵营，且当前所在阵营不是你的战争初始阵营，则你的白刃战士气+20，计策命中率 +15%。

func on_trigger_30005() -> bool:
	if me.vstateId == me.init_vstateId:
		return false
	ske.battle_change_morale(20)
	ske.battle_report()
	return false
