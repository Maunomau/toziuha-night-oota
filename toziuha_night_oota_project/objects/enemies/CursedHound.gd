extends KinematicBody2D

var cE = load("res://scripts/enemy.gd").new()

#velocidad de movimiento
var velocity = Vector2()
#direcion en x o y
var direction = Vector2()

#var facing = -1
#var state = "idle"
var gravity = 600
var speed = 150

#export var id = "cursed_hound"
#var hp_max = Vars.enemy[id]["hp_max"]
#var hp_now = hp_max
#var atk = Vars.enemy[id]["atk"]
#var def = Vars.enemy[id]["def"]
#var default_def = Vars.enemy[id]["def"]

var anim_state_machine
var anim_current

var player_near_on_floor = false

#debug
#func _process(_delta):
#	ScreenDebugger.dict["State"] = state
#	ScreenDebugger.dict["raycast_front"] = str( $Sprite/RayCastDetectFrontWall.is_colliding() )
#	ScreenDebugger.dict["is_on_wall"] = str( is_on_wall() )

func _ready():
	cE.set_vars("cursed_hound")
	#Enemy.connect("collision_with_player",self,"_on_collision_with_player")
	anim_state_machine = $AnimationTree.get("parameters/playback")
	anim_current = anim_state_machine.get_current_node()
	change_state("idle",true)
	
func _physics_process(delta):
	
	if cE.state in ["run","jump"]:
		velocity.x = speed * cE.facing

	if is_on_floor() and cE.state in ["idle","dead"]:
		velocity.x = 0

	velocity.y += gravity*delta
	
	velocity = move_and_slide(velocity, Vector2.UP,true)
	
	#Enemy.check_body_collisions(self)

	fix_state()

	
func change_state(new_state, forced=false):
	if (new_state != cE.state or forced) and cE.state != "dead":
		
		#al caer actualizar el facing solo cuando el jugador no esté debajo del enemigo (comparando posicion en .y)
		if new_state == "run" and cE.state == "fall":
			if (Functions.get_main_level_scene().get_player().position.y-30) > position.y:
				new_state = "idle"
			else:
				cE.update_facing(self,$Sprite)
		
		cE.state = new_state
		anim_state_machine.travel(cE.state)

func fix_state():
	
	if cE.state == "dead":
		return
		
	elif player_near_on_floor and cE.state == "idle":
		cE.update_facing(self,$Sprite)		
		change_state("run")

	elif cE.state == "run" and velocity.x == 0:
		change_state("idle")
		
	elif is_on_floor() and ( $Sprite/RayCastDetectFrontWall.is_colliding() or !$Sprite/RayCastDetectNoFloor.is_colliding() ) and cE.state == "run":
		jump()
		
	elif cE.state == "jump" and $Sprite/RayCastDetectFrontWall.is_colliding():
		change_state("idle")
	
	elif velocity.y > 0 and cE.state != "fall":
		change_state("fall")
		
	elif velocity.x != 0 and cE.state != "run" and is_on_floor():
		change_state("run")
	
	elif velocity.y < 0 and cE.state != "jump":
		change_state("jump") 
	
	elif cE.state == "fall" and is_on_floor():
		change_state("run")

func hurt(damage,weapon_position):
	
	if cE.state != "dead" and cE.hp_now > 0:
		
		change_state("idle")
		
		$Sprite.modulate = Color(1,0,0,1)
		$TimerHurt.start()
		Audio.play_sfx("hit4")
		
		cE.apply_damage(self,damage,weapon_position)

		if cE.hp_now <= 0:
			$Sprite.modulate = Color(1,1,1,1)
			$HitboxEnemy.set_disabled_collision(true)
			cE.drop_item_and_show_name(self)
			Audio.play_sfx("roar")
			change_state("dead")
			$Sprite.modulate = Color(1,1,1,1)
			return

	yield($TimerHurt,"timeout")
	change_state("run")
	cE.update_facing(self,$Sprite)
	$Sprite.modulate = Color(1,1,1,1)

func jump():
	if is_on_floor():
		Audio.play_sfx("roar2")
		velocity.y = -200
		change_state("jump")

#----------------- señales -----------------


func _on_AreaDetectPlayer_body_entered(body):
	if body.is_in_group("player"):
		if is_on_floor():
			Audio.play_sfx("roar2")
			cE.update_facing(self,$Sprite)
		change_state("run")

func _on_AreaDetectPlayer_body_exited(body):
	if body.is_in_group("player") and is_on_floor():
		$TimerChangeFacing.start()
		change_state("run")

func _on_VisibilityEnabler2D_screen_entered():
	cE.update_facing(self,$Sprite)

func _on_collision_with_player():
	Audio.play_sfx("roar2")


func _on_AreaDetectPlayerNearOnFloor_body_entered(body):
	if body.is_in_group("player"):
		player_near_on_floor = true


func _on_AreaDetectPlayerNearOnFloor_body_exited(body):
	if body.is_in_group("player"):
		player_near_on_floor = false


func _on_TimerChangeFacing_timeout():
	cE.update_facing(self,$Sprite)
