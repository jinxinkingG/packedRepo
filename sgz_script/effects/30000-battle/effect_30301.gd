extends "effect_30000.gd"

# 底力小战场效果
#【底力】大战场，君主锁定技。你方总兵力＜对方时，对方白刃战中，战术消耗变为2倍。若你方君主是袁术，则你无视君主身份也能触发。

const BUFF_NAME = "战术禁用"
const BUFF_LABEL_NAME = "战术禁用"

func on_trigger_30050() -> bool:
	var bf = DataManager.get_current_battle_fight()
	var attacker = bf.get_attacker()
	var defender = bf.get_defender()
	if attacker == null or defender == null:
		return false
	var teammate = attacker
	var enemy = defender
	if ske.actorId != teammate.actorId:
		teammate = defender
		enemy = attacker
	if ske.actorId != teammate.actorId:
		return false
	var lordId = teammate.war_vstate().get_lord_id()
	if not lordId in [actorId, StaticManager.ACTOR_ID_YUANSHU]:
		return false
	# 兵力必须小于对方
	if teammate.war_vstate().get_all_soldiers() > enemy.war_vstate().get_all_soldiers():
		return false
	# 如果已经战术禁用了，就不触发
	if enemy.get_buff_label_turn([BUFF_LABEL_NAME]) > 0:
		return false
	if not Global.get_rate_result(50):
		return false
	ske.set_battle_buff(enemy.actorId, BUFF_NAME, 99999)
	ske.battle_report()
	var msg = "代汉者，当途高也\n天命在吾，谁敢放肆！\n（本场战斗\n（{0}的战术被禁用".format([
		enemy.get_name()
	])
	ske.set_battle_skill_val(1)
	teammate.attach_free_dialog(msg, 0, 30000, actorId)
	return false

func on_trigger_30099()->bool:
	if ske.get_battle_skill_val_int() <= 0:
		return false
	var bf = DataManager.get_current_battle_fight()
	var attacker = bf.get_attacker()
	var defender = bf.get_defender()
	if attacker == null or defender == null:
		return false
	var teammate = attacker
	var enemy = defender
	if ske.actorId == defender.actorId:
		teammate = defender
		enemy = attacker
	var buff = enemy.get_buff(BUFF_NAME)
	if buff["回合数"] > 0 and buff["来源武将"] == actorId:
		ske.remove_war_buff(enemy.actorId, BUFF_NAME)
	return false
