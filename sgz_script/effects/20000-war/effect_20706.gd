extends "effect_20000.gd"

# 儿趣锁定技
#【儿趣】大战场，锁定技。又想起儿时的那个暑假……（据说阿会喃会变身）

const EFFECT_ID = 20706
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const DIR_PATTERNS = [
	[Vector2.UP, "上"],
	[Vector2.UP, "上"],
	[Vector2.DOWN, "下"],
	[Vector2.DOWN, "下"],
	[Vector2.LEFT, "左"],
	[Vector2.RIGHT, "右"],
	[Vector2.LEFT, "左"],
	[Vector2.RIGHT, "右"],
]

func on_trigger_20003() -> bool:
	var moveType = DataManager.get_env_int("移动")
	var moveStopped = DataManager.get_env_int("结束移动")
	var msg = DataManager.get_env("对白")
	var history = DataManager.get_env_array("历史移动记录")
	if history.empty():
		return false
	var dirs = []
	var prev = Vector2(history[0]["x"], history[0]["y"])
	for i in range(1, history.size()):
		var pos = Vector2(history[i]["x"], history[i]["y"])
		dirs.append(pos - prev)
		prev = pos
	dirs.append(me.position - prev)
	var patterns = DIR_PATTERNS.duplicate(true)
	var info = ""
	for d in dirs:
		var p = patterns.pop_front()
		if p[0] != d:
			break
		info += p[1]
	if moveStopped > 0:
		if info.length() == DIR_PATTERNS.size():
			var ap = me.action_point
			if ap < 255:
				me.attach_free_dialog("！！！", 0)
				ske.change_actor_ap(actorId, 255 - ap)
				ske.cost_war_cd(99999)
				ske.war_report()
	else:
		if msg.split("\n").size() > 1 and info != "":
			msg += "\n" + info + " ……"
		DataManager.set_env("对白", msg)
	return false
