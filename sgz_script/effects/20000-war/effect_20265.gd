extends "effect_20000.gd"

#缓进被动效果部分 #胜利触发 #失败触发 #机动力上限 #回复兵力
#【缓进】大战场,限定技。你可以减5点机动力上限，指定一个你方武将，其获得一个[助]标记。拥有[助]的武将，若其白刃战胜利，兵力恢复本次白刃战损失兵力的50%；若其白刃战失败，该武将移动到与你最近的那格，且失去[助]标记，你机动力上限+5。

const HUANJIN_EFFECT_ID = 20264

# 被动效果部分
func on_trigger_20020()->bool:
	if ske.get_war_skill_val_int(HUANJIN_EFFECT_ID, ske.actorId) != me.actorId:
		# 友军没有 [助] 标记，或者不是「我」
		return false
	var loser = bf.get_loser()
	if loser == null:
		return false
	var winner = loser.get_battle_enemy_war_actor()
	if winner == null:
		return false

	if loser.actorId == ske.actorId:
		# 友军失败
		if loser.disabled:
			# 彻底战败
			return false
		var newPos = null
		var maxDistance = -1
		for dir in StaticManager.NEARBY_DIRECTIONS:
			var pos = me.position + dir
			if not loser.can_move_to_position(pos):
				continue
			var disv = pos - loser.position
			var distance = abs(disv.x) + abs(disv.y)
			if distance > maxDistance:
				newPos = pos
				maxDistance = distance
		if newPos == null:
			return false
		# 有位置，拉回来
		ske.change_war_actor_position(loser.actorId, newPos)
		# 恢复机动力上限
		ske.set_actor_extra_ap_limit(actorId, 0)
		# 清除标记
		ske.set_war_skill_val(0, 0, HUANJIN_EFFECT_ID, ske.actorId)
		ske.set_war_skill_val(-1, 0, HUANJIN_EFFECT_ID, actorId)
		ske.war_report()
		var map = SceneManager.current_scene().war_map
		map.camer_to_actorId(me.actorId, "draw_actors")
		map.next_shrink_actors = [me.actorId, ske.actorId]
		var msg = "小挫而已，{0}且回\n可徐徐图之\n（{1}失去 [助] 标记".format([
			DataManager.get_actor_honored_title(ske.actorId, me.actorId),
			loser.get_name()
		])
		me.attach_free_dialog(msg)

	if winner.actorId == ske.actorId:
		# 友军胜利
		var prev = bf.attackerSoldiers
		var current = bf.attackerRemaining
		if winner.actorId == bf.get_defender_id():
			prev = bf.defenderSoldiers
			current = bf.defenderRemaining
		var recover = int((prev - current) / 2)
		if recover <= 0:
			return false
		ske.change_actor_soldiers(ske.actorId, recover)
		var map = SceneManager.current_scene().war_map
		map.camer_to_actorId(ske.actorId, "draw_actors")
		map.next_shrink_actors = [me.actorId, ske.actorId]
		var msg = "得{0}之助\n兵力恢复 {1}".format([
			DataManager.get_actor_honored_title(me.actorId, ske.actorId),
			recover
		])
		me.attach_free_dialog(msg)

	ske.war_report()
	return false
