extends "effect_20000.gd"

#冠懿被动效果部分
#【冠懿】大战场，主动技。指定一名你方武将为目标才能发动。目标的主属性提升至在场所有武将中同属性的最大数值，直到回合结束。每回合限1次。这个效果发动的回合，目标之外的武将不能用计/攻击。

const ACTIVE_EFFECT_ID = 20498

func on_trigger_20016()->bool:
	cancel_buff()
	return false

func on_trigger_20027()->bool:
	cancel_buff()
	return false

func cancel_buff()->void:
	var buffed = ske.get_war_skill_val_array(ACTIVE_EFFECT_ID)
	if buffed.size() != 3:
		return
	ske.set_war_skill_val([], 0, ACTIVE_EFFECT_ID)
	var targetId = int(buffed[0])
	var attr = str(buffed[1])
	var val = int(buffed[2])
	ske.change_war_attr(targetId, attr, -val)
	ske.war_report()
	return
