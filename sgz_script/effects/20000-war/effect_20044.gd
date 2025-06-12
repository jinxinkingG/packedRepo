extends "effect_20000.gd"

#引诱主动技
#【引诱】大战场，主动技。发动后的下个对方回合结束时，在你周围X格距离内的所有敌将（非城地形），尽可能地向你所在位置移动，至多移动3格。X=你的等级/2，每3个回合限一次

const MOVE_LIMIT = 3

func on_trigger_20016()->bool:
	if me.disabled or not me.has_position():
		return false
	if ske.get_war_skill_val_int() <= 0:
		return false
	var wa = DataManager.get_war_actor(ske.actorId)
	var x = int(actor.get_level() / 2)
	var disv = wa.position - me.position
	if max(abs(disv.x), abs(disv.y)) > x:
		return false
	var noticeKey = "战争.DAILY.{0}.{1}".format([
		ske.skill_name, actorId
	])
	var route = map.aStar.get_clear_path(wa.position, me.position)
	if route.empty():
		return false
	if false and DataManager.get_env_int(noticeKey) <= 0:
		DataManager.set_env(noticeKey, 1)
		var positions = []
		for i in range(-x, x + 1):
			for j in range(-x, x + 1):
				positions.append(Vector2(me.position.x + i, me.position.y + j))
		map.camer_to_actorId(actorId, "")
		map.show_color_block_by_position(positions)
		var msg = "来吧！"
		me.attach_free_dialog(msg, 0)
	ske.set_war_skill_val(MOVE_LIMIT, 1, -1, ske.actorId)
	return true

func effect_20044_start():
	var wa = DataManager.get_war_actor(ske.actorId)
	var msg = "{0}被迫向我靠拢".format([wa.get_name()])

	var steps = ske.get_war_skill_val_int(-1, ske.actorId)
	if steps <= 0:
		play_dialog(actorId, msg, 2, 2999)
		return

	var route = map.aStar.get_clear_path(wa.position, me.position)
	if route.size() <= 1:
		skill_end_clear()
		return

	ske.set_war_skill_val(steps - 1, 1, -1, ske.actorId)
	SceneManager.hide_all_tool()
	SceneManager.show_unconfirm_dialog(msg, actorId, 2)
	wa.move(route[1], true)
	goto_step("start")
	return

func on_view_model_2999()->void:
	wait_for_skill_result_confirmation("")
	return
