extends "effect_20000.gd"

#酩酊锁定技 #技能附加
#【酩酊】大战场，锁定技。每回合初始，你随机获得如下技能之一：<魂智>、<增援>、<进策>、<智局>。

const SKILLS = {
	"魂智": "吾之策道，鬼神辟易",
	"增援": "大势无虞，吾尚有后手",
	"进策": "言听计从，士之幸也",
	"智局": "战事洞明如棋局",
}

func on_trigger_20013()->bool:
	var skills = SKILLS.keys()
	skills.shuffle()
	var skill = skills[0]
	ske.add_war_skill(me.actorId, skill, 1)
	ske.war_report()
	var msg = "{0}\n（因【{1}】解锁【{2}】".format([
		SKILLS[skill], ske.skill_name, skill
	])
	me.attach_free_dialog(msg, 1)
	return false
