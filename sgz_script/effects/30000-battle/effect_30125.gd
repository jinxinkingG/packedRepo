extends "effect_30000.gd"

#骁勇小战场效果
#【骁勇】大战场,主动技。1回合1次，消耗1机动力发动：你可选择回到前3~10步之内的任意位置。以此效果进行位移后，若你相邻存在可攻击的敌将，你必须与其中一名敌将进入白兵，并在本次白兵结束之前，禁用对手所有技能。

const XIAOYONG_EFFECT_ID = 20013
const EFFECT_ID = 30125
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_30050() -> bool:
	if ske.get_war_skill_val_int(XIAOYONG_EFFECT_ID) <= 0:
		return false
	var enemy = me.get_battle_enemy_war_actor()
	if enemy == null or enemy.disabled:
		return false
	# 如果已经被沉默了，就不触发
	if enemy.get_buff_label_turn(["战斗沉默"]) > 0:
		return false
	ske.set_battle_buff(enemy.actorId, "战斗沉默", 99999)
	var msg = "敌势可破，全军突击！！！\n（本场战斗\n（{0}的技能被禁用".format([
		enemy.get_name()
	])
	me.attach_free_dialog(msg, 0, 30000)
	ske.battle_report()
	return false
