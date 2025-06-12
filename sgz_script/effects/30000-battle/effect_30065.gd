extends "effect_30000.gd"

#水盾效果实现 #战术值
#【水盾】小战场,锁定技。若你在水地形，则对方弓兵伤害-12%，且其战术值减半。

const DEBUFF = {
	"额外伤害": -0.12,
	"BUFF": -1,
}

# 锁定技判断
func on_trigger_30005()->bool:
	var x = int((enemy.battle_tactic_point + 1) / 2)
	ske.battle_change_tactic_point(-x, enemy)
	ske.battle_report()
	return false

func on_trigger_30024()->bool:
	# 注意这里是敌方触发
	if enemy == null or ske.actorId != enemy.actorId:
		return false
	ske.battle_enhance_current_unit(DEBUFF, ["弓"], "", true)
	return false
