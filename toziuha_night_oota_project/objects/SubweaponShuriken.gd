extends RigidBody2D

var id = "shuriken"

var velocity = Vector2.ZERO

export var direction = 1

func _ready():
	linear_velocity.x = 250 * direction
	set_anim()
	
func set_anim():
	if linear_velocity.x < 0 :
		$AnimationPlayer.play("show_reverse")
	else:
		$AnimationPlayer.play("show")


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_SubweaponShuriken_body_shape_entered(_body_id, _body, _body_shape, _local_shape):
	_on_impact()

func _on_impact():
	$TimerDelete.start()
	linear_velocity.x = 50 * (direction*-1)
	set_anim()
	$AnimationPlayer.playback_speed = 0.5
	gravity_scale = 1
	$CollisionShape2D.shape = null
#	if body.is_in_group("enemies"):
#		body.hurt(damage,position)


func play_sound():
	Audio.play_sfx("small_woosh")

func _on_TimerDelete_timeout():
	queue_free()


#func _on_Area2D_area_entered(area):
#	if area.is_in_group("torch"):
#		area.destroy()

#al entrar en contacto con hitbox enemigo shuriken desaparece
func _on_SubWeaponArea_area_entered(area):
	if area.is_in_group("hitbox_enemy") or area.is_in_group("subweapon"):
		_on_impact()
