extends "effect_30000.gd"

#攻城锁定技 #士兵强化
#【攻城】小战场,锁定技。你在城地形为攻方时，你的士兵额外获得0.1倍基础减伤和0.1倍基础增伤

const ENHANCEMENT = {
	"额外伤害": 0.1,
	"额外免伤": 0.1,
	"BUFF": 1,
}

func on_trigger_30005()->bool:
	var msg = "{0}攻无不克\n何人螳臂当车！\n（【{1}】发动".format([
		DataManager.get_actor_self_title(me.actorId),
		ske.skill_name
	])
	me.attach_free_dialog(msg, 0, 30000)
	return false

func on_trigger_30024()->bool:
	ske.battle_enhance_current_unit(ENHANCEMENT, ["SOLDIERS"])
	return false
