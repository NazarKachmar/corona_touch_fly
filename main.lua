local composer = require( "composer" )
display.setStatusBar(display.HiddenStatusBar)
math.randomseed(os.time())

highScore = 0

local options =
{
    effect = "fade",
    time = 1500
}

composer.gotoScene("scenes.menu",options)
