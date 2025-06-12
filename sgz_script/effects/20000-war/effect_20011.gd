extends "effect_20000.gd"

#秘丸效果实现，大战场次日效果部分
#【秘丸】小战场，主动技。每日限一次。你吃下黄巾军秘药大力丸：若体力>50，你在小战场的武力立即+x。大战场次回合，效果消失，体力-x，最低为1。其中x＝武/5。

const MIWAN_EFF_ID = 30087

func on_trigger_20013()->bool:
	var x = ske.get_war_skill_val_int(MIWAN_EFF_ID)
	if x <= 0:
		return false
	# 去除变量
	ske.set_war_skill_val(0, 0, MIWAN_EFF_ID)
	# 体力扣减
	ske.change_actor_hp(actorId, -x)
	return false
