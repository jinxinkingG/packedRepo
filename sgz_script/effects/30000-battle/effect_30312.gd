extends "effect_30000.gd"

# 武烈小战场效果
#【武烈】大战场，锁定技。你方孙姓武将，进入小战场时，护甲+10点；进入单挑时，体力恢复10点，孙坚触发时，效果翻倍。你方君主为孙坚时，无视“孙姓”限制，但非孙姓触发，效果减半。每场战斗限1次。

const ARMOR_BONUS = 10

func on_trigger_30005() -> bool:
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null:
		return false
	var wv = wa.war_vstate()
	if wv == null:
		return false
	var bu = wa.battle_actor_unit()
	if bu == null:
		return false
	var lord = wv.get_lord()
	var armor = 0
	if wa.actor().get_first_name() == "孙":
		armor = ARMOR_BONUS
		if wa.actorId == StaticManager.ACTOR_ID_SUNJIAN:
			armor = ARMOR_BONUS * 2
	elif lord.actorId == StaticManager.ACTOR_ID_SUNJIAN:
		armor = ARMOR_BONUS / 2
	if armor <= 0 or bu.extra_armor >= armor:
		return false
	ske.battle_change_unit_armor(bu, armor)
	ske.battle_report()
	return false
