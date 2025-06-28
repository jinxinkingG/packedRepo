extends "effect_10000.gd"

#天子效果
#【天子】内政,锁定技。他势力的易招揽武将，若其“德”＞75，则视为你方势力的易招揽武将

const EFFECT_ID = 10020
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_10005()->bool:
	var cmd = DataManager.get_current_search_command()
	if cmd == null:
		return false
	if cmd.result != 10 or cmd.foundActorId < 0:
		return false
	if cmd.found_actor().get_moral() <= 75:
		return false
	# 尝试追加说服
	var rate:int = int(13.0 * 100 / 15.0)
	if not Global.get_rate_result(rate):
		return false

	# 追加说服成功，开始表演
	var msgs = [
		["汉室衰微如此\n先生岂可避世不出？", actorId, 3],
		["此臣之过…\n当随陛下驱驰", cmd.foundActorId, 2],
	]
	for setting in msgs:
		cmd.add_dialog(setting[0], setting[1], setting[2])

	# 修改结果，强制加入
	cmd.result = 5
	cmd.actorJoin = 1
	cmd.actorCost = 0
	cmd.accept_actor()
	# 移除最后一条对话
	cmd.dialogs.pop_back()

	return false
