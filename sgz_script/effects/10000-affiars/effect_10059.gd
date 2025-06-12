extends "effect_10000.gd"

#先机主动技
#【先机】内政，君主主动技。立即结束内政，剩余的命令书累积到下个月，且下个月你的势力最先行动，每4个月一次。

const EFFECT_ID = 10059
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_10059_start():
	var msg = "洞烛机先，在于筹谋\n立刻结束本月行动，下月优先行动，且命令书+{0}，可否？".format([DataManager.orderbook])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000()->void:
	wait_for_yesno(FLOW_BASE + "_2")
	return

func effect_10059_2():
	var cityId = DataManager.player_choose_city
	var vstateId = clCity.city(cityId).get_vstate_id()
	ske.affair_cd(3)
	DataManager.set_env("优先行动势力", [vstateId, DataManager.orderbook])
	DataManager.orderbook = 0
	FlowManager.add_flow("player_ready")
	return
