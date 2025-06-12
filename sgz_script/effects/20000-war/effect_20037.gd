extends "effect_20000.gd"

#摧克
#【摧克】大战场,锁定技。你用火计/乱水/要击计指定目标时，目标周围X格距离的敌将也成为计策目标（分别计算成功率），每对1个额外目标用计成功时，额外扣除2点机动力（X = 等级/4 + 1）。

const STRATAGEMS_ALLOWED = ["火计","要击","乱水"]

func on_trigger_20009()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if not se.name in STRATAGEMS_ALLOWED:
		return false
	if se.succeeded <= 0:
		return false
	var targets = se.get_all_damaged_targets()
	targets.erase(se.targetId)
	if targets.empty():
		return false
	var extraCostAP = targets.size() * 2
	var name = ActorHelper.actor(targets[0]).get_name()
	if targets.size() > 1:
		name += "等人"
	extraCostAP = ske.cost_ap(extraCostAP, false)
	se.cost += extraCostAP
	var msg = "因【{0}】命中{1}\n机动力额外-{2}".format([
		ske.skill_name, name, extraCostAP
	])
	se.append_result(ske.skill_name, msg, extraCostAP, actorId)
	return false

func on_trigger_20021()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if not se.name in STRATAGEMS_ALLOWED:
		return false
	se.rangeRadius = int(actor.get_level() / 4) + 1
	return false
