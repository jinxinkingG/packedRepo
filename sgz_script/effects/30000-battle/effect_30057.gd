extends "effect_30000.gd"

#截粮锁定技 #骑兵强化
#【截粮】小战场,锁定技。非城战，你的骑兵基础伤害倍率+0.12；你白刃战胜利时，你方米+X，对方米-X，X＝本次白刃战对方损失士兵数/20，若对方武将死亡，视为对方损失所有士兵。

const ENHANCEMENT = {
	"额外伤害": 0.12,
	"BUFF": 1,
}

func on_trigger_30004():
	var enemy = me.get_battle_enemy_war_actor()
	if enemy == null:
		return false
	if bf.loserId != enemy.actorId:
		return false
	var prev = bf.attackerSoldiers
	if enemy.actorId == bf.get_defender_id():
		prev = bf.defenderSoldiers
	var current = enemy.get_soldiers()
	match bf.lostType:
		BattleFight.ResultEnum.ActorDead:
			# 武将死亡，视为士兵全损
			current = 0
		BattleFight.ResultEnum.ActorSurrend:
			# 武将投降，视为士兵全损
			current = 0
	if current >= prev:
		return false
	var x = int((prev - current) / 20)
	if x <= 0:
		return false
	# 有可能投降，须以胜者为准
	x = ske.change_wv_rice(-x, me.war_vstate().get_enemy_vstate())
	x = ske.change_wv_rice(-x)
	# 虽然是小战场触发，但属于大战场效果，汇报大战场日志
	ske.war_report()
	var msg = "报主公\n此战杀敌{0}，截粮{1}".format([prev - current, x])
	me.attach_free_dialog(msg, 1)
	return false

func on_trigger_30024()->bool:
	ske.battle_enhance_current_unit(ENHANCEMENT, ["骑"])
	return false
