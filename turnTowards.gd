extends Node


func turn_towards(rot, pos1, pos2, smooth):
	var targetDir = pos1 - pos2	
	var facing = atan2(targetDir.x, -targetDir.y)
	return lerp_angle(rot, facing, smooth)

func rot_towards(rot1, rot2, smooth):
	return lerp_angle(rot1, rot2, smooth)

func lerp_angle(from, to, weight):
	return from + short_angle_dist(from, to) * weight

func short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference
