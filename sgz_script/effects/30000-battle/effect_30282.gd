extends "effect_30000.gd"

# 盾勇效果
#【盾勇】小战场，锁定技。每轮初始，若你的总兵力小于对方，则本轮：你方士兵格挡率为40%。

const BUFF = {
	"格挡率": 40,
	"BUFF": 1,
}

func on_trigger_30009() -> bool:
	var buff = BUFF
	if me.get_soldiers() >= enemy.get_soldiers():
		buff = {}
	for bu in bf.battle_units(actorId):
		if not bu.is_soldier():
			continue
		ske.battle_buff_unit(bu, buff)
	return false
