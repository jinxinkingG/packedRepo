extends "res://script/controls.gd"

# 君主为武将加忠，包含了统一计算逻辑
# @return 实际加的数值
func add_actor_loyalty(lord:ActorHelper.ActorInfo, actor:ActorHelper.ActorInfo, gold:int, treasure:int=0)->int:
	var moral = lord.get_moral()
	# 考虑相性
	var distance = lord.personality_distance(actor)
	if distance == 0:
		# 完全匹配，视为德 90
		moral = max(90, moral)
	elif distance <= 10:
		# 比较亲近，视为德提升
		moral = int((200 + moral) / 3)
	var val = 0
	var extra = 0
	# 赏赐宝，忠诚上升 = 赏 100 金幅度 + 1~5
	if treasure > 0:
		gold = 100
		extra = randi() % 5 + 1
	if gold > 0:
		# 赏赐金，忠诚上升=君主德/10+消耗金额/20
		val += int(moral/10) + int(gold/20) + extra
	return actor.add_loyalty(val)

