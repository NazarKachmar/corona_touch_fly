local composer = require("composer")
local scene = composer.newScene()
local json = require("json")

function scene:create(event)
  local sceneGroup = self.view

  saves = loadSaves("saves.json")
  if(saves) then
    highScore = saves.highScore
  end


  local background =  display.newImageRect( "Images/bgimage.jpg", 480, 640)
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    background.parent = sceneGroup
    background:toBack()
  local title = display.newText(sceneGroup,"Touch Fly",display.contentCenterX,130,"Obelix",50)
  local play = display.newCircle(sceneGroup,display.contentCenterX,display.contentCenterY+10,90)
  local dispScore = display.newText(sceneGroup,"high score:"..highScore,display.contentCenterX,550,"Obelix",16)
  dispScore:setFillColor(190/255,0,190/255)
  title:setFillColor(190/255,0,190/255)
  play:setFillColor(190/255,0,190/255)
  local image = display.newImageRect(sceneGroup, "Images/play.png", 130, 130 )
  image.x = display.contentCenterX+10
  image.y = display.contentCenterY+10
  -- display.newRoundedRect(sceneGroup, display.contentCenterX,display.contentCenterY+150,
  -- display.contentWidth-150,40, 50):setFillColor(198/255, 0, 168/255)
  -- local supportMe = display.newText(sceneGroup,"support me :3",display.contentCenterX,
  -- display.contentCenterY+150,"Obelix",20)
  -- supportMe:setFillColor(0)
    play:addEventListener("tap",gotoGame)

end

function scene:show(event)
  local sceneGroup = self.view
  local backgroundMusic = audio.loadStream( "menuaudio.wav" )
  local backgroundMusicChannel = audio.play( backgroundMusic, { channel=1, loops=-1,fadein = 1000 } )
end

function gotoGame ()
  audio.stop(1)
  local options =
  {
      effect = "fade",
      time = 500
  }
  composer.gotoScene("scenes.game",options)
end

function loadSaves(fileName)
  local path = system.pathForFile(fileName, system.ResourceDirectory)
  local contents = ""
  local myTable = {}
  local file = io.open(path, "r")
  if(file) then
    contents = file:read("*a")
    myTable = json.decode(contents)
    io.close(file)
    file = nil
    return myTable
  end
  return nil
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
return scene
