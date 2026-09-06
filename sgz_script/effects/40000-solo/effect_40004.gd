extends "effect_40000.gd"

#无前锁定技 #武将强化
#【无前】单挑，锁定技。你免疫暴击，且造成伤害时，回复伤害量X%的血量（X＝你的等级*5）。

func on_trigger_40004()->bool:
	var extraMsgs = DataManager.get_env_array("单挑.补充信息")
	var damage = DataManager.get_env_int("单挑.伤害数值")
	var recover = int(damage/100.0 * actor.get_level() * 5)
	recover = ske.change_actor_hp(actorId, recover)
	if recover > 0:
		var msg = "{0}恢复{1}点体力".format([
			actor.get_name(), recover,
		])
		extraMsgs.append(msg)
		DataManager.set_env("单挑.补充信息", extraMsgs)
	return false

func on_trigger_40007()->bool:
	DataManager.set_env("单挑.暴击率", 0)
	return false
