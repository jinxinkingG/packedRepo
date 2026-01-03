extends "effect_20000.gd"

# 缓兵锁定效果
#【缓兵】大战场，主将限定技。你为守方时才能使用。从发动时开始计算，第2日结束前，敌军不能进行用计和攻击宣言，若己方执行用计/攻击，该效果提前解除。

func on_trigger_20012() -> bool:
	if not active_skill_performed():
		return false
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(actorId) != ske.actorId:
		return false
	se.skip_redo = 1
	var target = DataManager.get_war_actor(se.targetId)
	if target == null:
		target = me.get_war_enemy_leader()
	break_active_skill(target)
	return false

func on_trigger_20015() -> bool:
	if not active_skill_performed():
		return false
	var bf = DataManager.get_current_battle_fight()
	if bf.get_attacker_id() != ske.actorId:
		return false
	break_active_skill(bf.get_defender())
	return false

func active_skill_performed() -> bool:
	return ske.get_war_skill_val_int() > 0

func break_active_skill(target:War_Actor) -> void:
	if target == null:
		return
	var wf = DataManager.get_current_war_fight()
	var enemyLeader = me.get_war_enemy_leader()
	if enemyLeader == null:
		return
	var all = enemyLeader.get_teammates(false, true)
	all.insert(0, enemyLeader)
	for wa in all:
		var buff = wa.get_buff("罢兵")
		if buff["回合数"] <= 0:
			continue
		if buff["来源武将"] != actorId:
			continue
		ske.remove_war_buff(wa.actorId, "罢兵")
	ske.set_war_skill_val(0, 0)
	ske.war_report()

	if target.actorId != enemyLeader.actorId:
		target.attach_free_dialog("敌军偷袭！\n全军戒备！", 0)

	var msg = "{0}竟如此下作！\n全军速进！\n不破{1}，誓不回还！".format([
		DataManager.get_actor_naughty_title(actorId, enemyLeader.actorId),
		wf.target_city().get_full_name(),
	])
	target.attach_free_dialog(msg, 0, 20000, enemyLeader.actorId)
	return
