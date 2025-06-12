extends "effect_30000.gd"

#烈弓效果实现
#【烈弓】小战场，锁定技。你对敌方目标造成射箭伤害后，若目标的血量低于X，将之直接秒杀。X=（你的胆/2）+你的等级*2。

func on_trigger_30023() -> bool:
	var bu = ske.battle_is_unit_hit_by(["将"], ["SOLDIERS"], ["射箭"])
	if bu == null:
		return false

	var targetUnitId = DataManager.get_env_int("白兵伤害.单位")
	var targetUnit = get_battle_unit(targetUnitId)
	if targetUnit == null or targetUnit.disabled:
		return false

	var x = int(me.battle_courage / 2 + actor.get_level() * 2)
	if targetUnit.get_hp() >= x:
		return false

	targetUnit.wait_action_name = "被斩杀"
	bu.add_status_effect("烈弓#FF0000")
	return false
