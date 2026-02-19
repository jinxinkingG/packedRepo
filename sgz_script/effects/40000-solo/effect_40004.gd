extends "effect_40000.gd"

#神勇锁定技
#【神勇】小战场，锁定技。你触发 {横劈} 或者 {穿刺} 时，护甲+1；你的护甲值＞0时，护甲可承受超出该护甲值的伤害。

func on_trigger_40004()->bool:
	var damage = DataManager.get_env_int("单挑.伤害数值")
	var recover = int(damage/100.0 * actor.get_level() * 5)
	recover = ske.change_actor_hp(actorId, recover)
	if recover > 0:
		DataManager.set_env("单挑.补充信息", "{0}恢复{1}点体力".format([
			actor.get_name(), recover,
		]))
	return false

func on_trigger_40007()->bool:
	DataManager.set_env("单挑.暴击率", 0)
	return false
