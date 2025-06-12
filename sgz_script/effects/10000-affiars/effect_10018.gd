extends "effect_10000.gd"

#浅龙、帝统效果，命令书+1
#【浅龙】内政,锁定技。你无法执内政行动，你方势力命令书+1

func on_trigger_10001()->bool:
	DataManager.orderbook += 1
	return false

func on_trigger_10008()->bool:
	# 只有被选为指令执行人才会到这里
	# 如果是君主，不会有这一步，所以直接 return true 拒绝
	return true

func effect_10018_start():
	var msg = "朕……不欲干政\n公勿相疑，请另派他人"
	play_dialog(actorId, msg, 3, 2999)
	return
