extends Node2D
class_name Weapon

var bullet_scene = preload("res://src/Weapons/Player_bullet.tscn")

export (float, 1,1000,1) var base_firerate = 1
export (float, 0.1,10,0.1) var base_reload_time = 1
export (float, 0.1,10.0,0.1) var base_empty_reload_time = 1
export (float, 0.1,1000.0,0.1) var base_damage = 0.1
export (float, 0.1,1,0.05) var cam_shake_intensity = 0.1

export (int, 1,1000,1) var base_mag_size = 1
export (int, 1,1000,1) var base_ammo_count = 1
export (int, 0,100,1) var base_accuracy = 0
export (int, 0,10,1) var base_concealment = 0

export var weapon_position = Vector2(0,0)

export (String, "light", "heavy") var animation = "light"

onready var sprite: Sprite = $Sprite
onready var melee_shape: CollisionShape2D = $MeleeShape
onready var anim_player: AnimationPlayer = $AnimationPlayer

onready var firerate_timer: Timer = $Firerate
onready var reload_timer: Timer = $Reload_timer

onready var fire_sound: AudioStreamPlayer = $Fire
onready var fire_dry_sound: AudioStreamPlayer  = $Fire_dry
onready var reload_sound: AudioStreamPlayer  = $Reload_sound
onready var reload_empty_sound: AudioStreamPlayer  = $Reload_empty

var shake_camera: bool = false

var firerate: float
var reload_time: float
var empty_reload_time: float
var damage: float

var mag_size: int
var ammo_count: int
var accuracy: int
var concealment: int

var is_weapon_visible: bool = true
var current_mag_size: int
var current_ammo_count: int

func shoot():
	pass
	
func reload():
	pass
	
func reload_finish():
	pass
	
func melee():
	pass
