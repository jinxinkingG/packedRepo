extends "effect_10000.gd"

# 母仪锁定效果
#【母仪】内政，主动技。选择城内一个包含阴、阳面的武将为目标，消耗1枚命令书发动。使目标直到本月结束前，无视条件转为另一面。每3月限1次。

const ACTIVE_EFFECT_ID = 10146

# 月末恢复：10099 触发
func on_trigger_10099() -> bool:
	var data = ske.affair_get_skill_val_array(ACTIVE_EFFECT_ID)
	ske.affair_set_skill_val(0, 0, ACTIVE_EFFECT_ID)
	if data.size() != 3:
		return false
	var targetId = int(data[0])
	var originalSide = str(data[1])
	var newSide = str(data[2])
	if targetId < 0 or originalSide == "" or newSide == "":
		return false
	var actor = ActorHelper.actor(targetId)
	if not actor.has_side():
		return false
	if actor.get_side(true) != newSide:
		return false
	actor.set_side(originalSide)
	return false
