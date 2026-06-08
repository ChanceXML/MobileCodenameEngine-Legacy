package funkin.options.categories;

class MobileOptions extends OptionsScreen
{
	public function new()
	{
		super("Mobile Options", 'Change Mobile Specific Stuff.');

		add(new MobileControlsOption(
	        "Mobile Controls",
			"Changes the controls for mobile"
        ));

		add(new Checkbox(
			"Pause Button",
			"Displays a pause button in the screen. when clicked it pauses the game, Uncheck this if u want the button to be invisible.",
			"pauseButton"));
		
		add(new NumOption(
            "VirtualPad Opacity",
			"Changes the opacity of the virtualpad.",
			0,
            1,
            0.05,
			'virtualPadOpacity'
		));

        add(new ArrayOption(
            "Hint Style",
			"Changes the style of the hint",
            ['Simple', 'Gradient'],
            ['Simple', 'Gradient'],
            'hintStyle'
        ));

        add(new ArrayOption(
            "Hitbox Style",
			"Changes the style of the hitbox",
            ['Simple', 'Gradient'],
            ['Simple', 'Gradient'],
            'hitboxStyle'
        ));

        add(new NumOption(
            "Hint Opacity",
			"Changes the opacity of the hints",
			0,
            1,
            0.05,
			'hintOpacity'
		));

        add(new NumOption(
            "Hitbox Opacity",
			"Changes the opacity of the hitbox",
			0,
            1,
            0.05,
			'hitboxOpacity'
		));
	}
}
