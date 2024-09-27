-- main.lua
HC = require "HC"

-- Global variables
local player = {}
local enemies = {}
local bullets = {}
local items = {}
local skills = {}
local activeSkills = {}
local passiveSkills = {}
local boss = nil
local gameState = "play"  -- "play", "levelup", "gameover"
local selectedSkills = {}
local levelUpChoices = {}
local currentWave = 1
local enemiesInWave = 0
local maxEnemiesPerWave = 10
local timeBetweenWaves = 10
local waveTimer = 0
local survivalTime = 0
local difficultyMultiplier = 1

-- Load game assets and initialize
function love.load()
    love.window.setMode(1280, 720)
    love.keyboard.setKeyRepeat(true)
    math.randomseed(os.time())
    initializePlayer()
    initializeSkills()
end

function initializePlayer()
    player = {
        x = 640, y = 360,
        width = 20, height = 20,
        speed = 200,
        hp = 100, maxHp = 100,
        exp = 0, level = 1,
        nextLevelExp = 100,
        collider = HC.rectangle(640, 360, 20, 20),
        lastShot = 0,
        fireRate = 0.1,
        powerBoost = 1,
        powerBoostTimer = 0
    }
end

function initializeSkills()
    skills = {
        {name = "Rapid Fire", description = "Shoot faster for a duration", type = "active", cooldown = 5, duration = 3, key = "1"},
        {name = "Dash", description = "Quickly dash forward", type = "active", cooldown = 3, key = "2"},
        {name = "Explosive Round", description = "Bullets explode on impact", type = "passive"},
        {name = "Heal Burst", description = "Instantly heal 25% HP", type = "active", cooldown = 10, key = "3"},
        {name = "Shield", description = "Create a temporary damage shield", type = "active", cooldown = 15, duration = 5, key = "4"},
        {name = "Slow Time", description = "Slow down time briefly", type = "active", cooldown = 20, duration = 5, key = "5"},
        {name = "Bouncing Shot", description = "Bullets bounce to nearby enemies", type = "passive"},
        {name = "Piercing Bullet", description = "Bullets pierce through enemies", type = "passive"},
        {name = "Freeze Blast", description = "Freeze enemies temporarily", type = "active", cooldown = 8, duration = 2, key = "6"},
        {name = "Summon Ally", description = "Summon a temporary ally", type = "active", cooldown = 30, duration = 10, key = "7"},
        {name = "Sniper Shot", description = "Fire a high-damage, precise shot", type = "active", cooldown = 5, key = "8"},
        {name = "Grenade Launcher", description = "Launch a grenade that explodes on impact", type = "active", cooldown = 8, key = "9"},
        {name = "Overcharge", description = "Charge up a powerful energy beam", type = "active", cooldown = 15, key = "0", chargeTime = 2},
        {name = "Cluster Bomb", description = "Throw a bomb that splits into smaller explosives", type = "active", cooldown = 12},
        {name = "EMP Blast", description = "Release an electromagnetic pulse, stunning enemies", type = "active", cooldown = 20, chargeTime = 1.5},
        {name = "Critical Hit Chance", description = "Increase chance for critical hits", type = "passive", level = 0, maxLevel = 5},
        {name = "Armor Piercing", description = "Bullets penetrate enemy armor", type = "passive", level = 0, maxLevel = 5},
        {name = "Lifesteal Bullets", description = "Recover HP on hit", type = "passive", level = 0, maxLevel = 5},
        {name = "Explosive Rounds", description = "Bullets explode on impact", type = "passive", level = 0, maxLevel = 5}
    }
end

-- Main update function
function love.update(dt)
    if gameState == "play" then
        updatePlayer(dt)
        updateEnemies(dt)
        updateBullets(dt)
        updateSkills(dt)
        updateItems(dt)
        checkCollisions()
        updateWaveSystem(dt)
        checkLevelUp()
        updateDifficulty(dt)
        updateSurvivalTime(dt)
    elseif gameState == "levelup" then
        -- Level up logic is handled in love.keypressed
    end
end

function updatePlayer(dt)
    local dx, dy = 0, 0
    if love.keyboard.isDown("a") then dx = dx - 1 end
    if love.keyboard.isDown("d") then dx = dx + 1 end
    if love.keyboard.isDown("w") then dy = dy - 1 end
    if love.keyboard.isDown("s") then dy = dy + 1 end

    -- Normalize diagonal movement
    if dx ~= 0 and dy ~= 0 then
        dx = dx / math.sqrt(2)
        dy = dy / math.sqrt(2)
    end

    player.x = math.max(0, math.min(love.graphics.getWidth(), player.x + dx * player.speed * dt))
    player.y = math.max(0, math.min(love.graphics.getHeight(), player.y + dy * player.speed * dt))
    player.collider:moveTo(player.x, player.y)

    -- Auto-shooting
    player.lastShot = player.lastShot + dt
    if player.lastShot >= player.fireRate then
        shootBullet()
        player.lastShot = 0
    end

    -- Update power boost
    if player.powerBoostTimer > 0 then
        player.powerBoostTimer = player.powerBoostTimer - dt
        if player.powerBoostTimer <= 0 then
            player.powerBoost = 1
        end
    end
end

function updateEnemies(dt)
    for i, enemy in ipairs(enemies) do
        local dx = player.x - enemy.x
        local dy = player.y - enemy.y
        local dist = math.sqrt(dx*dx + dy*dy)
        
        if dist > 0 then
            enemy.x = enemy.x + (dx / dist) * enemy.speed * dt
            enemy.y = enemy.y + (dy / dist) * enemy.speed * dt
            enemy.collider:moveTo(enemy.x, enemy.y)
        end
    end

    if boss then
        local dx = player.x - boss.x
        local dy = player.y - boss.y
        local dist = math.sqrt(dx*dx + dy*dy)
        
        if dist > 0 then
            boss.x = boss.x + (dx / dist) * boss.speed * dt
            boss.y = boss.y + (dy / dist) * boss.speed * dt
            boss.collider:moveTo(boss.x, boss.y)
        end
    end
end

function updateBullets(dt)
    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        bullet.x = bullet.x + bullet.dx * dt
        bullet.y = bullet.y + bullet.dy * dt
        bullet.collider:moveTo(bullet.x, bullet.y)

        -- Remove bullets that are off-screen
        if bullet.x < 0 or bullet.x > love.graphics.getWidth() or
           bullet.y < 0 or bullet.y > love.graphics.getHeight() then
            HC.remove(bullet.collider)
            table.remove(bullets, i)
        end
    end
end

function updateSkills(dt)
    for _, skill in pairs(activeSkills) do
        if skill.cooldown > 0 then
            skill.cooldown = skill.cooldown - dt
        end
        if skill.duration then
            skill.duration = skill.duration - dt
            if skill.duration <= 0 then
                deactivateSkill(skill)
            end
        end
    end
end

function updateItems(dt)
    for i = #items, 1, -1 do
        local item = items[i]
        if player.collider:collidesWith(item.collider) then
            if item.type == "health" then
                player.hp = math.min(player.hp + 20, player.maxHp)
            elseif item.type == "power" then
                player.powerBoost = 1.5
                player.powerBoostTimer = 10
            end
            HC.remove(item.collider)
            table.remove(items, i)
        end
    end
end

function updateWaveSystem(dt)
    if #enemies == 0 and enemiesInWave == 0 then
        waveTimer = waveTimer + dt
        if waveTimer >= timeBetweenWaves then
            startNewWave()
        end
    end
end

function startNewWave()
    currentWave = currentWave + 1
    enemiesInWave = maxEnemiesPerWave + math.floor(currentWave / 2)
    waveTimer = 0
    local enemyHealth = 20 + currentWave * 5
    local enemySpeed = 50 + currentWave * 2
    
    for i = 1, enemiesInWave do
        spawnEnemy(enemyHealth, enemySpeed)
    end
end

function spawnEnemy(health, speed)
    local enemy = {
        x = math.random(0, love.graphics.getWidth()),
        y = math.random(0, love.graphics.getHeight()),
        width = 15, height = 15,
        speed = speed,
        hp = health,
        collider = HC.rectangle(0, 0, 15, 15)
    }
    enemy.collider:moveTo(enemy.x, enemy.y)
    table.insert(enemies, enemy)
end

function checkCollisions()
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        if player.collider:collidesWith(enemy.collider) then
            player.hp = player.hp - 10
            if player.hp <= 0 then
                gameState = "gameover"
            end
            HC.remove(enemy.collider)
            table.remove(enemies, i)
            enemiesInWave = enemiesInWave - 1
        end
    end

    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        for j = #enemies, 1, -1 do
            local enemy = enemies[j]
            if bullet.collider:collidesWith(enemy.collider) then
                enemy.hp = enemy.hp - (10 * player.powerBoost)
                if enemy.hp <= 0 then
                    HC.remove(enemy.collider)
                    table.remove(enemies, j)
                    enemiesInWave = enemiesInWave - 1
                    player.exp = player.exp + 10
                    if math.random() < 0.2 then
                        dropItem(enemy.x, enemy.y)
                    end
                end
                HC.remove(bullet.collider)
                table.remove(bullets, i)
                break
            end
        end
    end

    if boss then
        if player.collider:collidesWith(boss.collider) then
            player.hp = player.hp - 20
            if player.hp <= 0 then
                gameState = "gameover"
            end
        end
        for i = #bullets, 1, -1 do
            local bullet = bullets[i]
            if bullet.collider:collidesWith(boss.collider) then
                boss.hp = boss.hp - (10 * player.powerBoost)
                if boss.hp <= 0 then
                    HC.remove(boss.collider)
                    boss = nil
                    player.exp = player.exp + 100
                end
                HC.remove(bullet.collider)
                table.remove(bullets, i)
            end
        end
    end
end

function updateDifficulty(dt)
    difficultyMultiplier = 1 + (currentWave - 1) * 0.1
end

function updateSurvivalTime(dt)
    survivalTime = survivalTime + dt
end

function shootBullet()
    local bullet = {
        x = player.x,
        y = player.y,
        speed = 500,
        collider = HC.circle(player.x, player.y, 3)
    }
    local angle = math.atan2(love.mouse.getY() - player.y, love.mouse.getX() - player.x)
    bullet.dx = math.cos(angle) * bullet.speed
    bullet.dy = math.sin(angle) * bullet.speed
    table.insert(bullets, bullet)
end

function dropItem(x, y)
    local itemTypes = {"health", "power"}
    local itemType = itemTypes[math.random(#itemTypes)]
    local item = {
        x = x,
        y = y,
        type = itemType,
        collider = HC.circle(x, y, 10)
    }
    table.insert(items, item)
end

function checkLevelUp()
    if player.exp >= player.nextLevelExp then
        player.level = player.level + 1
        player.exp = player.exp - player.nextLevelExp
        player.nextLevelExp = math.floor(player.nextLevelExp * 1.2)
        player.maxHp = player.maxHp + 10
        player.hp = player.maxHp
        gameState = "levelup"
        generateLevelUpChoices()
    end
end

function generateLevelUpChoices()
    levelUpChoices = {}
    local availableSkills = {}
    for _, skill in ipairs(skills) do
        if not selectedSkills[skill.name] then
            table.insert(availableSkills, skill)
        end
    end
    for i = 1, 3 do
        if #availableSkills > 0 then
            local index = love.math.random(#availableSkills)
            table.insert(levelUpChoices, availableSkills[index])
            table.remove(availableSkills, index)
        end
    end
end

function activateSkill(skillName)
    local skill = selectedSkills[skillName]
    if skill and skill.type == "active" and (not activeSkills[skillName] or activeSkills[skillName].cooldown <= 0) then
        if skillName == "Rapid Fire" then
            player.fireRate = player.fireRate / 2
            activeSkills[skillName] = {cooldown = skill.cooldown, duration = skill.duration}
        elseif skillName == "Dash" then
            local angle = math.atan2(love.mouse.getY() - player.y, love.mouse.getX() - player.x)
            player.x = player.x + math.cos(angle) * 100
            player.y = player.y + math.sin(angle) * 100
            activeSkills[skillName] = {cooldown = skill.cooldown}
        elseif skillName == "Heal Burst" then
            player.hp = math.min(player.hp + player.maxHp * 0.25, player.maxHp)
            activeSkills[skillName] = {cooldown = skill.cooldown}
        elseif skillName == "Shield" then
            -- Implement shield logic
            activeSkills[skillName] = {cooldown = skill.cooldown, duration = skill.duration}
        elseif skillName == "Slow Time" then
            -- Implement slow time logic
            activeSkills[skillName] = {cooldown = skill.cooldown, duration = skill.duration}
        elseif skillName == "Freeze Blast" then
            -- Implement freeze blast logic
            activeSkills[skillName] = {cooldown = skill.cooldown, duration = skill.duration}
        elseif skillName == "Summon Ally" then
            -- Implement summon ally logic
            activeSkills[skillName] = {cooldown = skill.cooldown, duration = skill.duration}
        elseif skillName == "Sniper Shot" then
            -- Implement sniper shot logic
            activeSkills[skillName] = {cooldown = skill.cooldown}
        elseif skillName == "Grenade Launcher" then
            -- Implement grenade launcher logic
            activeSkills[skillName] = {cooldown = skill.cooldown}
        elseif skillName == "Overcharge" or skillName == "EMP Blast" then
            -- Start charging
            activeSkills[skillName] = {cooldown = skill.cooldown, charging = true, chargeTime = 0}
        end
    end
end

function deactivateSkill(skillName)
    local skill = selectedSkills[skillName]
    if skill.name == "Rapid Fire" then
        player.fireRate = player.fireRate * 2
    elseif skill.name == "Shield" then
        -- Remove shield
    elseif skill.name == "Slow Time" then
        -- Return time to normal
    end
    activeSkills[skillName] = nil
end

function updateCharging(dt)
    for name, skill in pairs(activeSkills) do
        if skill.charging then
            skill.chargeTime = skill.chargeTime + dt
            if skill.chargeTime >= selectedSkills[name].chargeTime then
                releaseChargedSkill(name)
            end
        end
    end
end

function releaseChargedSkill(skillName)
    local skill = selectedSkills[skillName]
    if skillName == "Overcharge" then
        -- Implement overcharge release logic
    elseif skillName == "EMP Blast" then
        -- Implement EMP blast release logic
    end
    activeSkills[skillName].charging = false
    activeSkills[skillName].chargeTime = 0
end

function selectSkill(skill)
    if #selectedSkills < 20 then
        selectedSkills[skill.name] = skill
        if skill.type == "passive" then
            passiveSkills[skill.name] = skill
        end
    else
        upgradeSkill(skill)
    end
end

function upgradeSkill(skill)
    if skill.level < skill.maxLevel then
        skill.level = skill.level + 1
        -- Implement upgrade effects for each skill
    end
end

-- Main draw function
function love.draw()
    if gameState == "play" then
        drawGame()
    elseif gameState == "levelup" then
        drawLevelUp()
    elseif gameState == "gameover" then
        drawGameOver()
    end
end

function drawGame()
    -- Draw player
    love.graphics.setColor(0, 0, 1)
    love.graphics.rectangle("fill", player.x - player.width/2, player.y - player.height/2, player.width, player.height)

    -- Draw enemies
    love.graphics.setColor(1, 0, 0)
    for _, enemy in ipairs(enemies) do
        love.graphics.rectangle("fill", enemy.x - enemy.width/2, enemy.y - enemy.height/2, enemy.width, enemy.height)
    end

    -- Draw boss
    if boss then
        love.graphics.setColor(1, 0, 1)
        love.graphics.rectangle("fill", boss.x - boss.width/2, boss.y - boss.height/2, boss.width, boss.height)
    end

    -- Draw bullets
    love.graphics.setColor(1, 1, 0)
    for _, bullet in ipairs(bullets) do
        love.graphics.circle("fill", bullet.x, bullet.y, 3)
    end

    -- Draw items
    for _, item in ipairs(items) do
        if item.type == "health" then
            love.graphics.setColor(0, 1, 0)
        else
            love.graphics.setColor(1, 1, 0)
        end
        love.graphics.circle("fill", item.x, item.y, 10)
    end

    -- Draw UI
    drawUI()
end

function drawUI()
    love.graphics.setNewFont(16)
    love.graphics.setColor(1, 1, 1)

    -- Draw HP bar
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", 10, 10, player.hp * 2, 20)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 10, 10, player.maxHp * 2, 20)
    love.graphics.print("HP: " .. player.hp .. "/" .. player.maxHp, 15, 15)

    -- Draw EXP bar
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", 10, 40, (player.exp / player.nextLevelExp) * 200, 20)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 10, 40, 200, 20)
    love.graphics.print("EXP: " .. player.exp .. "/" .. player.nextLevelExp, 15, 45)

    -- Draw level
    love.graphics.print("Level: " .. player.level, 220, 40)

    -- Draw wave
    love.graphics.print("Wave: " .. currentWave, love.graphics.getWidth() - 100, 10)

    -- Draw survival time
    love.graphics.print("Survival Time: " .. string.format("%.2f", survivalTime), 10, love.graphics.getHeight() - 30)

    -- Draw active skills
    local y = 70
    for name, skill in pairs(activeSkills) do
        love.graphics.print(name .. ": " .. math.ceil(skill.cooldown), 10, y)
        y = y + 20
    end

    -- Draw power boost if active
    if player.powerBoost > 1 then
        love.graphics.print("Power Boost: " .. string.format("%.1fx", player.powerBoost), 10, y)
    end
end

function drawLevelUp()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Level Up!", 0, 200, love.graphics.getWidth(), "center")
    
    for i, skill in ipairs(levelUpChoices) do
        love.graphics.printf(i .. ". " .. skill.name .. ": " .. skill.description, 0, 250 + i * 30, love.graphics.getWidth(), "center")
    end
    
    love.graphics.printf("Press 1, 2, or 3 to choose a skill", 0, love.graphics.getHeight() - 50, love.graphics.getWidth(), "center")
end

function drawGameOver()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    love.graphics.setColor(1, 0, 0)
    love.graphics.printf("Game Over!", 0, love.graphics.getHeight() / 2 - 40, love.graphics.getWidth(), "center")
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("You reached level " .. player.level, 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
    love.graphics.printf("Survival Time: " .. string.format("%.2f", survivalTime), 0, love.graphics.getHeight() / 2 + 30, love.graphics.getWidth(), "center")
    love.graphics.printf("Press R to restart", 0, love.graphics.getHeight() / 2 + 60, love.graphics.getWidth(), "center")
end

function love.keypressed(key)
    if gameState == "play" then
        if key == "space" then
            activateSkill("Dash")
        elseif tonumber(key) and tonumber(key) >= 1 and tonumber(key) <= 9 then
            local index = tonumber(key)
            for _, skill in ipairs(skills) do
                if skill.key == key then
                    activateSkill(skill.name)
                    break
                end
            end
        end
    elseif gameState == "levelup" then
        if key == "1" or key == "2" or key == "3" then
            local choice = tonumber(key)
            if levelUpChoices[choice] then
                selectSkill(levelUpChoices[choice])
                gameState = "play"
            end
        end
    elseif gameState == "gameover" then
        if key == "r" then
            restartGame()
        end
    end
end

function love.keyreleased(key)
    if gameState == "play" then
        for _, skill in ipairs(skills) do
            if skill.key == key and activeSkills[skill.name] and activeSkills[skill.name].charging then
                releaseChargedSkill(skill.name)
                break
            end
        end
    end
end

function restartGame()
    player = {}
    enemies = {}
    bullets = {}
    items = {}
    activeSkills = {}
    passiveSkills = {}
    selectedSkills = {}
    boss = nil
    gameState = "play"
    currentWave = 1
    enemiesInWave = 0
    waveTimer = 0
    survivalTime = 0
    difficultyMultiplier = 1
    initializePlayer()
    initializeSkills()
end

-- Run the game
function love.run()
    if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then love.timer.step() end

    local dt = 0

    -- Main loop time.
    return function()
        -- Process events.
        if love.event then
            love.event.pump()
            for name, a,b,c,d,e,f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a or 0
                    end
                end
                love.handlers[name](a,b,c,d,e,f)
            end
        end

        -- Update dt, as we'll be passing it to update
        if love.timer then dt = love.timer.step() end

        -- Call update and draw
        if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

        if love.graphics and love.graphics.isActive() then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())

            if love.draw then love.draw() end

            love.graphics.present()
        end

        if love.timer then love.timer.sleep(0.001) end
    end
end