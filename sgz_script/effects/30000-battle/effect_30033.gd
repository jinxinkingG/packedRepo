extends "effect_30000.gd"

#后发效果实现
#【后发】小战场,锁定技。对方先于你发动战术，次回合你的战术值+10。

func on_trigger_30009()->bool:
	if ske.battle_get_skill_val_int() <= 0:
		return false
	ske.battle_cd(99999)
	ske.battle_change_tactic_point(10)
	ske.battle_report()
	return false

func on_trigger_30008()->bool:
	if ske.battle_get_skill_val_int() > 0:
		# 标记已设置，说明是对方先发动，什么都不做
		return false
	# 我方先发动战术，且标记未设置，说明是我方先发动
	# 设置技能 CD，「后发」本场战斗无效
	ske.battle_cd(99999)
	return false

func on_trigger_30018()->bool:
	# 对方发动战术，设置标记，表示「后发」可以发动
	ske.battle_set_skill_val(1, 99999)
	return false
