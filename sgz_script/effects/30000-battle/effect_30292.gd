extends "effect_30000.gd"

# 断后锁定效果
#【断后】小战场，锁定技。你以<血卫>效果进入白刃战的场合，敌方不能发动主动技能及战术。

const BUFF_NAME = "战术禁用"

func on_trigger_30050() -> bool:
	if bf.get_env_int("血卫") != actorId:
		return false
	ske.set_battle_buff(enemy.actorId, BUFF_NAME, 99999)
	ske.battle_report()
	var msg = "某家奕世忠义\n岂惧{0}伎俩！\n（{1}的战术被禁用".format([
		DataManager.get_actor_naughty_title(enemy.actorId, actorId),
		enemy.get_name(),
	])
	me.attach_free_dialog(msg, 0, 30000)
	return false

