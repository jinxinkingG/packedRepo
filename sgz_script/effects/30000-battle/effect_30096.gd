extends "effect_30000.gd"

#威名效果
#【威名】大战场,主将锁定技。己方“统”低于95的其他武将：其为白刃战攻方时，该武将“统”临时变为95。

const EFFECT_ID = 30096
const LEADERSHIP_FIX_VAL = 95

func on_trigger_30006():
	if me.actorId == ske.actorId:
		# 必须是「其他」
		return false
	# 战斗武将
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null or wa.disabled:
		return false

	if wa.actorId != bf.get_attacker_id():
		# 不是攻方
		return false

	if wa.actor().get_leadership() >= LEADERSHIP_FIX_VAL:
		return false
	var x = LEADERSHIP_FIX_VAL - wa.actor().get_leadership()
	var sbp = ske.get_battle_skill_property()
	sbp.leader += x
	ske.apply_battle_skill_property(sbp)
	ske.battle_report()
	
	var msg = "兵锋所至，何人可当！\n（因{0}【{1}】\n（{2}统增加{3}".format([
		me.get_name(), ske.skill_name, wa.get_name(), x,
	])
	wa.attach_free_dialog(msg, 0, 30000)

	return false
