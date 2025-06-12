extends "effect_10000.gd"

#陈势锁定效果部分
#【陈势】内政，主动技。指定1个相邻且只有1城的势力发动。向目标势力陈述厉害，提议投降给本势力。若目标君主同意：其势力灭亡，所有城归属给本势力，原君主变为忠90的将领；若其不同意，本月下一次对目标势力城发起攻击时，不消耗命令书。每3月限1次。[投降概率（玩家不可见）=双方城差数%，且至多为15%]

const ACTIVE_EFFECT_ID = 10080

func on_view_model_2999():
	wait_for_skill_result_confirmation("")
	return

func effect_10081_start():
	var targetCity = wf.target_city()
	var msg = "{0}志大而不见机\n今当为齑粉矣！\n（本次出征不消耗命令书".format([
		targetCity.get_leader_name()
	])
	SceneManager.show_confirm_dialog(msg, actorId, 0)
	LoadControl.set_view_model(2999)
	return

func on_trigger_10011()->bool:
	if wf == null:
		return false
	var prevTargetCityId = ske.affair_get_skill_val_int(ACTIVE_EFFECT_ID)
	if prevTargetCityId <= 0:
		return false
	# 陈势记录的是城市 id + 1
	if wf.target_city().ID != prevTargetCityId - 1:
		return false
	ske.affair_set_skill_val(0, 0, ACTIVE_EFFECT_ID)
	return true
