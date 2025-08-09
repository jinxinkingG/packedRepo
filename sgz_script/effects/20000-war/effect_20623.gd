extends "effect_20000.gd"

# 恋土效果
#【恋土】大战场，锁定技。战争初始，你为守方，所在地域为荆州时，你的统数值若低于 X，临时提高到 X。X = 当前城池的统治度。

func on_trigger_20019() -> bool:
	ske.cost_war_cd(99999)
	var city = wf.target_city()
	if city.get_region() != "荆州":
		return false
	var x = city.get_loyalty()
	var leadership = actor.get_leadership()
	if leadership < x:
		x = ske.change_war_leadership(actorId, x - leadership)
		var msg = "吾父单骑定荆州，何等英雄\n{0}虽不才，亦当力保{1}！\n（「统」提升至{2}".format([
			actor.get_short_name(), city.get_full_name(),
			actor.get_leadership(),
		])
		me.attach_free_dialog(msg, 0)
	ske.war_report()
	return false
