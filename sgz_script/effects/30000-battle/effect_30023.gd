extends "effect_30000.gd"

#奋威效果实现
#【奋威】小战场，锁定技。白刃战初始，若你士气＜对方，则你的士气+x，x＝你的等级×2。

func on_trigger_30005():
	if me.battle_morale >= enemy.battle_morale:
		return false
	ske.battle_change_morale(actor.get_level() * 2, me)
	ske.battle_report()
	return false
