extends "effect_40000.gd"

#神勇锁定技
#【神勇】单挑,锁定技。你免疫暴击，且造成伤害时，回复伤害量X%的血量（X＝你的等级*5）。：造成伤害后，回复伤害量X％的血量（X＝等级×5）

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
