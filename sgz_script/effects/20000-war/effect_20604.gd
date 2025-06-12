extends "effect_20000.gd"

# 乘流效果
#【乘流】大战场，锁定技。你移动至少经过1格河流地形的场合，回合内后续移动消耗的机动力-1（不叠加，至少为1点）。

func on_trigger_20003() -> bool:
	var moveType = DataManager.get_env_int("移动")
	var moveStopped = DataManager.get_env_int("结束移动")
	var terrian = map.get_blockCN_by_position(me.position)
	var flag = ske.get_war_skill_val_int()
	if terrian == "河流" and moveType == 1 and flag < 2:
		# 移动至河流，且乘流状态未锁定，开启乘流状态（=1）
		ske.set_war_skill_val(1, 1)
		return false
	if moveType == 0 and moveStopped == 1 and flag > 0:
		# 已经结束移动，且乘流状态是开启的
		# 那么不存在回撤移动取消乘流状态的情况了
		# 锁定乘流状态（=2）
		ske.set_war_skill_val(2, 1)
		return false
	if moveType == -1 and flag == 1:
		# 回撤移动，乘流状态是开启的，且未锁定
		# 需要判断是否回撤了乘流
		var moveHistory = DataManager.get_env_array("历史移动记录")
		for h in moveHistory:
			if typeof(h) != TYPE_DICTIONARY:
				continue
			var x = Global.intval(Global.dic_val(h, "x", -1))
			var y = Global.intval(Global.dic_val(h, "y", -1))
			var pos = Vector2(x, y)
			var hTerrian = map.get_blockCN_by_position(pos)
			if hTerrian == "河流":
				# 历史移动记录中仍有河流
				# 保留乘流状态
				return false
		# 历史记录中已经没有河流了
		# 取消乘流状态
		ske.set_war_skill_val(0, 1)
	return false

func on_trigger_20007() -> bool:
	if ske.get_war_skill_val_int() > 0:
		reduce_move_ap_cost([], 1)
	return false
