extends "effect_10000.gd"

#颂词锁定技
#【颂词】内政，锁定技。你参与的战争胜利时，若当前为你方内政回合，且命令书为0的场合：使你方命令书+1，之后本月禁用「出征」指令。每月只触发1次。

const EFFECT_ID = 10101

func on_trigger_10013()->bool:
	var wf = DataManager.get_current_war_fight()
	# 目前触发到这里，一定是我是胜方了，直接触发就好
	# 稍微做个判断
	var city = wf.target_city()
	if not actorId in city.get_actor_ids():
		return false
	if DataManager.orderbook > 0:
		return false
	ske.affair_cd(1)
	var forbidden = DataManager.get_env_dict("内政.MONTHLY.禁出征")
	forbidden[str(city.get_vstate_id())] = [ske.skill_name, "true"]
	DataManager.set_env("内政.MONTHLY.禁出征", forbidden)
	DataManager.orderbook = 1
	var msg = "举炎火以炳飞蓬\n覆沧海以沃熛炭\n有何不灭者哉！"
	city.attach_free_dialog(msg, actorId, 0)
	msg = "{0}【{1}】发动\n命令书 +1".format([
		actor.get_name(), ske.skill_name,
	])
	city.attach_free_dialog(msg, -1, 2)
	# 强制设定当前控制城市
	# TODO 这个逻辑其实应该在战争结束后统一采用
	DataManager.player_choose_city = city.ID
	return false
