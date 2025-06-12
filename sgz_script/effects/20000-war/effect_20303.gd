extends "effect_20000.gd"

#急退效果
#【急退】小战场，锁定技。你小战场撤退时，若无阻挡，可以退2格。

const EFFECT_ID = 20303

func check_trigger_correct():
	var me = DataManager.get_war_actor(self.actorId)
	match self.triggerId:
		20015: # 战前记录位置
			var pos = "{0}|{1}".format([me.position.x, me.position.y])
			SkillHelper.set_skill_variable(20000, EFFECT_ID, self.actorId, pos, 1)
		20020: # 战后检查位置
			var skv = SkillHelper.get_skill_variable(20000, EFFECT_ID, self.actorId)
			if skv["turn"] <= 0 or typeof(skv["value"]) != TYPE_STRING:
				SkillHelper.set_skill_variable(20000, EFFECT_ID, self.actorId, null, 0)
				return false
			var flag = str(skv["value"]).split("|")
			if flag.size() != 2:
				return false
			var pos = Vector2(int(flag[0]), int(flag[1]))
			var disv = pos - me.position
			if abs(disv.x) + abs(disv.y) != 1:
				return false
			var targetPos = me.position * 2 - pos
			if not me.can_move_to_position(targetPos):
				return false
			me.move(targetPos)
	return false
