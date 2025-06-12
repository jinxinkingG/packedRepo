extends "effect_30000.gd"

#秘丸效果实现，大小战场锁定技部分
#【秘丸】小战场，主动技。每日限一次。你吃下黄巾军秘药大力丸：若体力>50，你在小战场的武力立即+x。大战场次回合，效果消失，体力-x，最低为1。其中x＝武/5。

const MIWAN_EFF_ID = 30087

func on_trigger_30006():
	var x = ske.get_war_skill_val_int(MIWAN_EFF_ID)
	if x <= 0:
		return false

	var sbp = ske.get_battle_skill_property()
	sbp.power += x
	ske.apply_battle_skill_property(sbp)
	ske.battle_report()

	var msg = "药力…… 尚在！\n（【{0}】持续期间\n（武力增加{1}".format([
		ske.skill_name, x,
	])
	me.attach_free_dialog(msg, 0, 30000)

	return false

