extends "effect_30000.gd"

#止啼效果实现
#【止啼】小战场,锁定技。你的战术持续回合内，敌将「技能」和「战术」全部失效，你临时获得<骑神>效果。

const TARGET_SKILL = ""

func on_trigger_30009()->bool:
	var maxTurn = 0
	for buff in StaticManager.CONTINUOUS_TACTICS:
		maxTurn = max(maxTurn, me.get_buff(buff)["回合数"])
	if maxTurn <= 0:
		_disable_effect(me, enemy)
	return false

func on_trigger_30010()->bool:
	# 避免同一回合触发两次
	ske.battle_cd(1)
	var maxTurn = 0
	for buff in StaticManager.CONTINUOUS_TACTICS:
		maxTurn = max(maxTurn, me.get_buff(buff)["回合数"])
	if maxTurn <= 0:
		_disable_effect(me, enemy)
		return false
	# 取消对方持续中的战术
	for buff in StaticManager.CONTINUOUS_TACTICS:
		if enemy.get_buff(buff)["回合数"] > 0:
			ske.remove_war_buff(enemy.actorId, buff)
	# 禁用对方战术和技能
	ske.set_war_buff(enemy.actorId, "沉默", 1)
	ske.set_war_buff(enemy.actorId, "战术禁用", maxTurn)
	# 临时获得附加技能
	if TARGET_SKILL != "":
		ske.battle_add_skill(me.actorId, TARGET_SKILL, maxTurn)
	ske.battle_report()
	var wf = DataManager.get_current_war_fight()
	var region = wf.target_city().get_region()
	var msg = "{0}小儿\n也知{1}威名！\n（{2}获得【{4}】".format([
		region, DataManager.get_actor_self_title(me.actorId),
		me.get_name(), ske.skill_name, TARGET_SKILL,
	])
	if TARGET_SKILL == "":
		msg = "{0}小儿\n也知{1}威名！\n（{2}触发【骑神】".format([
			region, DataManager.get_actor_self_title(me.actorId),
			me.get_name(),
		])
		if bf.is_terrian_city():
			msg = "{0}小儿\n也知{1}威名！".format([
				region, DataManager.get_actor_self_title(me.actorId),
				me.get_name(),
			])
	me.attach_free_dialog(msg, 0, 30000)
	return false

func on_trigger_30099()->bool:
	var enemy = me.get_battle_enemy_war_actor()
	if enemy == null: # disabled 也触发
		return false
	_disable_effect(me, enemy)
	return false

func _disable_effect(me:War_Actor, enemy:War_Actor):
	# 取消敌方的沉默和战术禁用
	for buff in ["沉默", "战术禁用"]:
		var buffStatus = enemy.get_buff(buff)
		if buffStatus["回合数"] > 0 and buffStatus["来源武将"] == me.actorId:
			ske.remove_war_buff(enemy.actorId, buff)
	# 失去附加技能
	if TARGET_SKILL != "":
		ske.battle_remove_skill(me.actorId, TARGET_SKILL)
	ske.battle_report()
	return
