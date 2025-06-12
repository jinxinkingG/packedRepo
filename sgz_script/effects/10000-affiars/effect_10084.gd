extends "effect_10000.gd"

#秉正锁定技
#【秉正】内政，锁定技。你与君主同城时，若君主德＜你的德，则你执行内政开发时，不提升自己的德属性，改为提升君主。

func on_trigger_10002() -> bool:
	var cmd = DataManager.get_current_develop_command()
	if cmd.actionId != actorId:
		return false
	if actor.get_loyalty() == 100:
		return false
	var leader = ActorHelper.actor(cmd.city().get_leader_id())
	if leader.actorId == actorId or leader.get_loyalty() < 100:
		return false
	if leader.get_moral() >= actor.get_moral():
		return false
	cmd.actorId = leader.actorId
	return false

