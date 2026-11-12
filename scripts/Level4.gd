extends LevelBase

## Nivel 4. Toda la lógica común (incluidos los checkpoints) está en
## LevelBase.gd: al morir con un checkpoint tomado se recarga el nivel
## completo y el jugador aparece en el checkpoint.

func _init() -> void:
	level_id = 4
	supports_two_players = false
