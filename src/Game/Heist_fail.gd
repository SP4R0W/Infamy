extends Panel

var titles: Dictionary = {
	"bank":"Downtown Hit",
}

var mourns = [
	"Oh no, how did that happen? Don't worry, I'll upload your mind to another robot and we'll start again.",
	"Crap! I'm very sorry, it wasn't your fault. I have another robot ready. We'll start again.",
	"How did this happen? Must have been my miscalculation. No worries, your new body is ready.",
	"No no no no! I'm very sorry, even I tend to make mistakes. Don't you worry, we can start again.",
	"Aw no! I'm sorry, I underestimated them. I'll upload your mind to a new robot soon. We'll start again."
]

func draw_fail():
	$Heist_title.text = titles[Game.level] + ": " + Game.difficulty_names[Game.difficulty] + " - FAIL"
	$Mourn.text = mourns[randi() % mourns.size()]
