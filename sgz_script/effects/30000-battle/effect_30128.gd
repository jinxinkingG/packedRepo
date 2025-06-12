extends "effect_30000.gd"

#压制和压制*的小战场效果
#压制*的效果，区别是，每人每回合只生效一次，且压制仅限君主
#【压制】大战场,主将锁定技。你方总兵力＞对方，则对方武将白兵时，无法使用战术。

const EFFECT_ID = 30128
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const BUFF_NAME = "战术禁用"
const BUFF_LABEL_NAME = "战术禁用"

func on_trigger_30050()->bool:
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
	if teammate.get_main_actor_id() != actorId:
		return false
	if ske.skill_name == "压制" and actor.get_loyalty() != 100:
		return false
	# 兵力必须大于对方
	if teammate.war_vstate().get_all_soldiers() <= enemy.war_vstate().get_all_soldiers():
		return false
	# 如果已经战术禁用了，就不触发
	if enemy.get_buff_label_turn([BUFF_LABEL_NAME]) > 0:
		return false
	if ske.skill_name == "压制*":
		# 压制*的特殊处理
		var triggered = ske.get_war_skill_val_int_array()
		if teammate.actorId in triggered:
			return false
		triggered.append(teammate.actorId)
		ske.set_war_skill_val(triggered, 1)
	ske.set_battle_buff(enemy.actorId, BUFF_NAME, 99999)
	ske.battle_report()
	var msg = "大兵压境，谁敢阻我！\n（本场战斗\n（{0}的战术被禁用".format([
		enemy.get_name()
	])
	teammate.attach_free_dialog(msg, 0, 30000, actorId)
	return false

func on_trigger_30099()->bool:
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
	if teammate.get_main_actor_id() != actorId:
		return false
	var buff = enemy.get_buff(BUFF_NAME)
	if buff["回合数"] > 0 and buff["来源武将"] == actorId:
		ske.remove_war_buff(enemy.actorId, BUFF_NAME)
	return false
