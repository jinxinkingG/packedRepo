extends "effect_20000.gd"

# 同阵效果
#【同阵】大战场，锁定技。<你>的体力上限增加「与你同姓的队友数」*5；回合结束时，<你>的体力恢复10点。☆制作组提示：若敌方赵云在场，此技能的效果会发生变化。

# 注意，此效果比较特殊，占用了 20584 用来指定目标
# 而使用 20585 来存储必要的体上限变量
const TARGET_EFFECT_ID = 20584

const ZY = StaticManager.ACTOR_ID_ZHAOYUN

func on_trigger_20013() -> bool:
	# 先判断赵云是否在场
	var wa = DataManager.get_war_actor(ZY)
	if not me.is_enemy(wa):
		wa = me
	# 设定目标
	ske.set_war_skill_val(wa.actorId, 1, TARGET_EFFECT_ID)
	# 判断数值
	var x = 0
	var fn = actor.get_first_name()
	for teammate in me.get_teammates(false):
		if teammate.actor().get_first_name() == fn:
			x += 1
	var current = ske.get_war_skill_val_int(-1, wa.actorId)
	ske.change_actor_max_hp(wa.actorId, x * 5 - current)
	ske.set_war_skill_val(x * 5, 99999, -1, wa.actorId)
	ske.war_report()
	return false

func on_trigger_20016() -> bool:
	var wa = DataManager.get_war_actor(ZY)
	if not me.is_enemy(wa):
		wa = me
	# 设定目标
	ske.set_war_skill_val(wa.actorId, 1, TARGET_EFFECT_ID)
	ske.change_actor_hp(wa.actorId, 10)
	ske.war_report()
	return false
