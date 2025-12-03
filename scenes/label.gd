extends Label
var rng = RandomNumberGenerator.new()
var random_number = rng.randf_range(0, 23)
var timer = 0
var quips = ["This text is not a bandaid fix",
"Also check out Quaver", 
"Also check out Osu!", 
"Try to press L I M B O",
"Aleph-0 is lowkey fire",
"Hi :3", 
"Shoutout Epic games Fortnite Festival",
"example splash text",
"Hallo meneer de informatica-docent",
"Je vais te pirater!!!",
"'Matig naar mijn persoonlijke mening' -Dev",
"Thanks to TDMG The Master Gamer",
"'Github is not Google Drive!' -2nd Dev",
"Merry Christmas!",
"Shoutout school cafetaria, water costs 80p",
"Graphic design is mijn passie!",
"Nee ik ga NIET naar kiekieris",
"100% informatica",
"Hacked by Levi D",
"'No flaw no Skibidi Minecraft'",
"Mango Phonk is NOT tuff gng fr ong",
"Yoghurt",
"Ghurt: Yo"
]
func _ready():
	while true:
		await get_tree().create_timer(11).timeout
		random_number = rng.randf_range(0, 23)
		text = quips[random_number]
		
