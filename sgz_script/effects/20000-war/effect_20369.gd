extends "effect_20000.gd"

#缥缈锁定技
#【缥缈】大战场，锁定技。若你不是主将：● 每次你方回合结束时，你从战场上消失。● 每次你方回合开始前，若你处于消失状态，回到消失之前的位置，若该位置被其他武将占据，回到附近的空位。

func on_trigger_20016()->bool:
	if me.get_main_actor_id() == me.actorId:
		return false
	var pos = "{0}|{1}".format([me.position.x, me.position.y])
	ske.set_war_skill_val(pos, 99999)
	if DataManager.get_env_int("战争.飘飖回雪") <= 0:
		return true
	fade_out()
	return false

func effect_20369_AI_start()->void:
	goto_step("start")
	return

func effect_20369_start()->void:
	play_dialog(actorId, "髣髴兮……\n若轻云之蔽月", 2, 2000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation("effect_20369_done")
	return

func effect_20369_done()->void:
	fade_out()
	skill_end_clear()
	return

func on_trigger_20001()->bool:
	if me.has_position():
		return false
	me.set_ext_variable("缥缈", 0)
	me.set_ext_variable("跳过布阵", 0)
	var posInfo = ske.get_war_skill_val_str()
	if posInfo.empty():
		return false
	var pos = Vector2(int(posInfo.split("|")[0]), int(posInfo.split("|")[1]))
	# 找没被人占据的位置
	while DataManager.get_war_actor_by_position(pos) != null:
		# 优先靠近战场中央
		var disx = map.cell_columns - pos.x * 2
		var disy = map.cell_rows - pos.y * 2
		if abs(disx) > abs(disy):
			if disx < 0:
				pos += Vector2.LEFT
			else:
				pos += Vector2.RIGHT
		else:
			if disy < 0:
				pos += Vector2.UP
			else:
				pos += Vector2.DOWN
	me.position = pos
	if DataManager.get_env_int("战争.飘飖回雪") <= 0:
		map.next_shrink_actors = [actorId]
		DataManager.set_env("战争.飘飖回雪", 1)
		var msg = "飘飖兮……\n若流风之回雪"
		me.attach_free_dialog(msg, 2)
	return false

func fade_out():
	var me = DataManager.get_war_actor(actorId)
	if me == null or me.disabled:
		return
	me.position = Vector2(-10, -10)
	me.set_ext_variable("缥缈", 1)
	me.set_ext_variable("跳过布阵", 1)
	return
