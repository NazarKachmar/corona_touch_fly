local composer = require("composer")
local physics = require("physics")
local json = require("json")
local scene = composer.newScene()
physics.start()
physics.setGravity(0,0)

local score = 0
local speedGame = 1
local death = false
local asteroidTable = {}
local gameLoopTimer
local speedtimer
local scoreText
local canMove = true
local backGroup = display.newGroup()
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()

function scene:create(event)
  local sceneGroup = self.view
  physics.pause()

  bg1 =  display.newImageRect(backGroup, "Images/bgimage.jpg", 480, 640)
    bg1.x = display.contentCenterX
    bg1.y = display.contentCenterY
    bg1.parent = backGroup
  bg2 =  display.newImageRect(backGroup, "Images/bgimage.jpg", 480, 640)
    bg2.x = display.contentCenterX
    bg2.y = bg1.y+640
    bg2.parent = backGroup
  bg3 =  display.newImageRect(backGroup, "Images/bgimage.jpg", 480, 640)
    bg3.x = display.contentCenterX
    bg3.y = bg2.y+640
    bg3.parent = backGroup

  display.newRoundedRect(backGroup, display.contentCenterX,20,
  680,40, 0):setFillColor(198/255, 0, 168/255)
  display.newRoundedRect(uiGroup, display.contentCenterX,20,
  680,40, 0):setFillColor(198/255, 0, 168/255)
  pause = display.newImage(uiGroup,"Images/pause.png", display.contentWidth - 20, 20)
  target = display.newImage(mainGroup,"Images/target_img.png",105,330)
  target.isVisible = false
  rocket = display.newImage(mainGroup,"Images/rocket_img.png",
  display.contentCenterX,470)
  local shapeRocket = {0,-28, -24,24, 24,24}
  physics.addBody(rocket,"static",{shape = shapeRocket, inSensor = true})
  rocket.myName = "rocket"
  scoreText = display.newText(uiGroup,"Score: " .. math.floor(score),display.contentCenterX,20,"Obelix",20)
  scoreText:setFillColor(0)

  local backgroundMusic = audio.loadStream( "gameaudio.wav" )
  local backgroundMusicChannel = audio.play( backgroundMusic, { channel=1, loops=-1, fadein=2000 } )




  sceneGroup:insert(backGroup)
  sceneGroup:insert(mainGroup)
  sceneGroup:insert(uiGroup)
end

function moveBG()
  bg1.y = bg1.y + speedGame
  bg2.y = bg2.y + speedGame
  bg3.y = bg3.y + speedGame
  if(bg1.y+bg1.contentWidth)>1440 then
    bg1:translate(0,-1900)
  end
  if(bg2.y+bg2.contentWidth)>1440 then
    bg2:translate(0,-1900)
  end
  if(bg3.y+bg3.contentWidth)>1440 then
    bg3:translate(0,-1900)
  end
end

 function createAsteroid(event)
         score = score + speedGame
         scoreText.text = "Score: " .. math.floor(score)
    local newAsteroid = display.newImage(mainGroup,"Images/asteroid_img.png")
    table.insert(asteroidTable,newAsteroid)
    physics.addBody(newAsteroid,"dynamic",{radius = 24,bounse = 0.8})
    newAsteroid.myName = "asteroid"
    local whereFrom = math.random(3)
      if (whereFrom == 1) then
        newAsteroid.x = -30
        newAsteroid.y = math.random(60)
        newAsteroid:setLinearVelocity(math.random(40, 120),speedGame*(math.random(20, 60)))

      elseif (whereFrom == 2) then
        newAsteroid.x = math.random(display.contentWidth)
        newAsteroid.y = -30
        newAsteroid:setLinearVelocity(math.random(-40, 40),speedGame*(math.random(40, 120)))

      elseif (whereFrom == 3) then
        newAsteroid.x = display.contentWidth + 30
        newAsteroid.y = math.random(60)
        newAsteroid:setLinearVelocity(math.random(-120, -40),speedGame*(math.random(20, 60)))

      end
end

function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase
  if(phase == "will") then

  end
  if(phase == "did") then
  physics.start()
  Runtime:addEventListener("collision", onCollision)
  Runtime:addEventListener("enterFrame", moveBG)
  gameLoopTimer = timer.performWithDelay(1000/speedGame, gameLoop, 0)
  speedtimer = timer.performWithDelay(2000*speedGame, speedFunct, 0)
  bg1:addEventListener("tap", movingRocket)
  bg2:addEventListener("tap", movingRocket)
  bg3:addEventListener("tap", movingRocket)
  pause:addEventListener("tap", pauseFunct)
  end
end
function speedFunct()
  speedGame = speedGame+0.1
end
function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase
  if(phase == "will") then
  timer.cancel(gameLoopTimer)
  timer.cancel(speedtimer)
  end
  if(phase == "did") then
    Runtime:removeEventListener("collision",onCollision)
    physics.pause()
    audio.stop(1)
    composer.removeScene("scenes.game")
  end
end


function movingRocket(event)
 if (canMove == true and event.y>40) then
 canMove = false
 target.isVisible = true
 target.x = event.x
 target.y = event.y
 local res = 2*((math.sqrt((rocket.x - event.x)^2 + (rocket.y - event.y)^2)))
 transition.to( rocket, { time = (res/(speedGame/2)), alpha=1, x=event.x, y=event.y,
 tag="transRocket",onComplete = function() target.isVisible = false canMove = true end } )
 end
end

function gameLoop()
  createAsteroid()
  for i = #asteroidTable,1,-1 do
    local thisAsteroid = asteroidTable[i]
    if(thisAsteroid.x < -60 or
       thisAsteroid.x > display.contentWidth+60 or
       thisAsteroid.y < -60 or
       thisAsteroid.y > display.contentHeight+60)
    then
      display.remove(thisAsteroid)
      table.remove(asteroidTable,i)
    end
  end

end

function endGame()
  physics.pause()
  transition.pause("transRocket")
  display.newText(uiGroup,"GAME OVER",display.contentCenterX,
  110,"Obelix",50):setFillColor(0.9,0,0.1)
  display.newText(uiGroup,"score: "..math.floor(score),display.contentCenterX,
  200,"Obelix",30):setFillColor(0.9,0,0.1)
  if(score > highScore) then
  sc = {}
  sc.highScore = math.floor(score)
  saveScore(sc, "saves.json")
  end
  composer.gotoScene("scenes.menu",{time = 3000,effect = "crossFade"})
  Runtime:removeEventListener("enterFrame", moveBG)
end

function pauseFunct()
  audio.pause(1)
  canMove = false
  physics.pause()
  transition.pause("transRocket")
  timer.pause(gameLoopTimer)
  timer.pause(speedtimer)
  bg1:removeEventListener("tap", movingRocket)
  bg2:removeEventListener("tap", movingRocket)
  bg3:removeEventListener("tap", movingRocket)
  Runtime:removeEventListener("enterFrame", moveBG)
  local pauseVindow = display.newRoundedRect(uiGroup, display.contentCenterX,display.contentCenterY,
  330,200, 30)
  pauseVindow:setFillColor(198/255, 0, 168/255)
  local pauseText = display.newText(uiGroup,"pause",display.contentCenterX,
  250,"Obelix",30)
  pauseText:setFillColor(0)
  local pauseScore = display.newText(uiGroup,"score: "..math.floor(score),display.contentCenterX,
  display.contentCenterY-20,"Obelix",20)
  pauseScore:setFillColor(0)
  local buttonsVindow = display.newRoundedRect(uiGroup, display.contentCenterX,360,
  300,50, 30)
  local resumebtn = display.newText(uiGroup,"resume",display.contentCenterX-60,
  360,"Obelix",30)
  local backbtn = display.newText(uiGroup,"back",display.contentCenterX+80,
  360,"Obelix",30)
  buttonsVindow:setFillColor(0)
  backbtn:setFillColor(0.9,0.1,0.1)
  resumebtn:setFillColor(0.1,0.9,0.3)
  backbtn:addEventListener("tap",function()
    composer.gotoScene("scenes.menu",{time = 1000,effect = "crossFade"})
  end)
  resumebtn:addEventListener("tap",function()
    display.remove(buttonsVindow)
    display.remove(pauseScore)
    display.remove(pauseVindow)
    display.remove(backbtn)
    display.remove(pauseText)
    display.remove(resumebtn)
    canMove = true
    physics.start()
    audio.resume(1)
    transition.resume("transRocket")
    Runtime:addEventListener("enterFrame", moveBG)
    timer.resume(gameLoopTimer)
    timer.resume(speedtimer)
    timer.performWithDelay(100, function()
      bg1:addEventListener("tap", movingRocket)
      bg2:addEventListener("tap", movingRocket)
      bg3:addEventListener("tap", movingRocket)
    end, 1)

  end)
end

function onCollision(event)
  if (event.phase == "began")then
    local obj1 = event.object1
    local obj2 = event.object2
    if((obj1.myName == "rocket" and obj2.myName == "asteroid")or
       (obj2.myName == "rocket" and obj1.myName == "asteroid")) then
         endGame()
    end
  end
end

function saveScore(s, fileName)
  local path = system.pathForFile(fileName, system.ResourceDirectory)
  local file = io.open(path, "w")
  if(file) then
    local contents = json.encode(s)
    file:write(contents)
    io.close(file)
    return true
  else
    return false
  end
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
return scene
