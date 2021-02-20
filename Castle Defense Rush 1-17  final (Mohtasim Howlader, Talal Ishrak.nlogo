; Mohtasim Howlader and Talal Ishrak
; Castle Defense Final Project
; Castle Defense Rush



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;Castle Defense Rush;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;variables are explained in the function comments.
globals [gold level-active level? mouse-state? level timer1 time-a advance? advance-level defeat? block-defeat?]
;
turtles-own [health strength speed range enemy? turn-status corner-verify target original-shape next-shape shape2 fight-active? battle-ani? building? defense? gold-drop]
patches-own [ original-color next-color horzo-r? horzo-l? vertico? spec-pos]
breed [towers tower]
breed [castles castle]


;Invaders
breed [goblins goblin]
breed [giants giant]
breed [dragons dragon]
breed [witches witch]
witches-own [normal fire lightning]
breed [golems golem]

;Defense
breed [soldiers soldier]
breed [archers archer]
breed [horsemen horseman]
breed [sorcerers sorcerer]
breed [fireballs fireball]
fireballs-own [original-tower]


;residual function used when creating world, not used for game
;to paint
;  if mouse-down? and mouse-inside?
;  [
;    ask patch mouse-xcor mouse-ycor
;    [
;      set pcolor paint-color
;    ]
;  ]
;end


;Mohtasim Howlader
; 1.13.17 added resize-world, patch-size, original-color, patches with vertico?, patches with horzo-r?, patches with horzo-l? (which are crucial in movement)
; 1.14.17 added spec-pos (used for turning), defeat?, block-defeat?, castle sprouting, and castle stats. Corrected tower placement

;Talal Ishrak
; 1.13.17 added tower placement, tower-stats, and gold value during setup
to setup
  ca
  resize-world -70 70 -55 55
  set-patch-size 6
  import-pcolors "map-pre3.png"
  ask patches [
    set original-color pcolor]

  ;set-default-shape towers "tower"
  ;ask patches
  set gold 0
  set-default-shape castles "castle"
  ask patch 0 44
  [

    sprout-castles 1 [
      set building? true
      set defense? true
      set size 30
      set color red
      set health 20000
      set label health
      set label-color  black
       ]
  ]

  ask patches with [pcolor = 26.5 and ( (pxcor <= -38 and pycor <= -34) or ( (pxcor >= -62 and pxcor <= -15) and pycor >= 32) or ( (pxcor >= -12 and pxcor <= 17) and (pycor <= -22 and pycor >= -29)) or ( (pxcor >= 38 and pxcor <= 62) and (pycor >= -14 and pycor <= -7) ) )] [set horzo-r? true set horzo-l? false set vertico? false]
  ask patches with [pcolor = 26.5 and ( (pxcor >= 38 and pycor <= -33)  or ( (pxcor <= 62 and pxcor >= 15) and pycor >= 32) or ( (pxcor >= -4 and pxcor <= 17) and (pycor <= 7 and pycor >= 0) ) or ((pxcor <= -38 and pxcor >= -62) and (pycor >= -14 and pycor <= -7) ) )] [set horzo-l? true set vertico? false]
  ask patches with [pcolor = 26.5 and ( ((abs pxcor >= 38 and abs pxcor <= 48) and (pycor <= -6) ) or ( (abs pxcor >= 53 and abs pxcor <= 62) and (pycor >= -16 and pycor <= 41) ) or ( (pxcor >= -12 and pxcor <= -2) and (pycor <= -21) ) or ( (pxcor >= 8 and pxcor <= 17) and (pycor >= -30 and pycor <= 8) ) or ( (pxcor >= -4 and pxcor <= 5) and pycor >= -1) )] [set vertico? true ]

  ask patches with [(horzo-r? = true and vertico? = true) or (horzo-l? = true and vertico? = true)]
  [
    let x random 5
     if [pcolor] of patch-at 2 0 != white or [pcolor] of patch-at 0 2 != white
     [
       if x <= 2 [set spec-pos "a"]
       if x = 3 [set spec-pos "b"]
       if x = 4 [set spec-pos "c"]
     ]
     if [pcolor] of patch-at 2 0 = white or [pcolor] of patch-at -2 0 = white [set spec-pos "d"]
     if [pcolor] of patch-at 0 2 = white or [pcolor] of patch-at 0 -2 = white [set spec-pos "e"]
   ]



  set-default-shape towers "tower"
  ask patch -44 -20 [sprout-towers 1]
  ask patch -58 26  [sprout-towers 1]
  ask patch 12 -11  [sprout-towers 1]
  ask patch 57 26   [sprout-towers 1]
  ask patch 44 -21  [sprout-towers 1]

  ask towers [set-tower-stats]
  set gold 3000
  set defeat? false
  set block-defeat? false
  reset-ticks
end

;Mohtasim Howlader
; 1.12.17 added currency-start, reset-ticks (though game is not in ticks), level? true
; 1.13.17 set health label for characters and buildings, added enemy-move and defense-move (however they are not operational yet)
; 1.14.17 characters move now (though there are still some bugs), reworked tower-fight (still not operational), started stop-eachother (still not operational)

;Talal Ishrak
; 1.13.17  started tower-fight, added that enemies and defense will die if health goes below 0,
; 1.14.17 added gold-drop (amount of gold dropped by enemies when they die)
to go
  if defeat? = false [
  set level? true
  every 0.5 [set timer1 timer1 + 0.5]

  if level = 0 [set level 1]
  if level = 1 [level1]
  if level = 2
  [
    level2
    ask turtles with [enemy? = true] [set health health + 0.5]
  ]
  if level = 3
  [
    level3
    ask turtles with [enemy? = true] [set health health + 1]
  ]

  currency-start

  ask turtles [stop-eachother]
  every 1 / 4 [ask turtles [battle-eachother]]


  every 1 / 30 [



  ;ask turtles with [enemy? = true] [enemy-move]
  every 4 [
    reset-ticks
  ]
  ;proper-heading


  tower-fight
  ask turtles with [enemy? = true] [set label health set label-color red ]
  ask turtles with [enemy? = false] [set label health set label-color 102]
  ask turtles with [building? = true] [set label health set label-color black]


  ;ask turtles [battle-eachother]
  ask turtles with [enemy? = true and fight-active? = false] [enemy-move]
  ask turtles with [enemy? = false and fight-active? = false] [defense-move]
  ask turtles with [defense? = true] [if health <= 0 [die]]
  ask turtles with [enemy? = true]
  [
    if health <= 0
    [
      set gold gold + gold-drop
      die]
  ] ;added 1/13, Talal
  ]

  if block-defeat? = false [defeat-screen]
  ]
end

to reset
  ask patches [
    set pcolor original-color]
end

;ENEMY SPAWNING FUNCTIONS

;Mohtasim Howlader
; added before 1/11, also; many of the functions afterwards are just the same, but for different characters, so I won't comment for each one.
; For the enemies, just look at the comment for this one (goblins), and for defense, look at the comments for soldier.
; 1.11.17 SELECTING AND DROPPING FINALLY WORKS!!! (though this is an enemy, will not be selected in the real game, this is only for testing purposes)
; 1.14.17 removed mouse related functions
; 1.15.17 added time-a and timer1, this is to make sure this command is only run ONCE (as in when it is called based on the time of the game, which is timer1, only one set will be deployed, not hundreds)
; time-a is essentially a blocker for this function (and the subsequent enemy spawning function)
to goblin-spawn
  if time-a != timer1
  [

      sprout-goblins 1
      [
        set-goblin-stats
        ask patch-at 2 0
        [
          sprout-goblins 1
          [
            set-goblin-stats
            ask patch-at 2 0
            [
              sprout-goblins 1
              [
                set-goblin-stats
              ]
            ]

          ]
        ]
      ]
      set time-a timer1
  ]

end


; started before 1/11, this is the same for the subsequent enemy spawning related functions, therefore I will only have comments on this one
;Mohtasim Howlader
; 1.13.17 added enemy?, added health, range, color, size
; 1.14.17 added original-shape, shape2, set-default-shape
; 1.15.17 removed set-default shape, reworked health, speed, strength, added heading, added label for health
; 1.16.17 reworked health and strength, and speed

;Talal Ishrak
; 1.14.17 added speed, gold-drop,l
; 1.15.17 reworked speed, gold-drop, strength, health, speed, and range

to set-goblin-stats
  set original-shape "goblinz"
  set shape original-shape
  set shape2 "goblin 2"
  set heading 0
  set label health
  set size 4
  set color green
  set enemy? true
  set strength 2
  set health 200
  set range 5
  set speed 0.4
  set gold-drop 50

end

to giant-spawn
  if time-a != timer1
  [
;  set-default-shape giants "giant"
;  if mouse-down? and mouse-inside?
;  [set mouse-state? true]
;  if mouse-down? = false and mouse-inside? and mouse-state? = true
;  [ask patch mouse-xcor mouse-ycor
;    [
      sprout-giants 1 [set-giant-stats]
      set time-a timer1
;    ]
;   set mouse-state? false
  ]

end

to set-giant-stats
  set original-shape "giant"
  set shape2 "giant 2"
  set size 10
  set heading 0
  set enemy? true
  set strength 5
  set health 1000
  set speed 0.25
  set range 5
  set gold-drop 200
    ;set speed-attack

end

to dragon-spawn
  if time-a != timer1
  [
;  set-default-shape dragons "dragon"
;  if mouse-down? and mouse-inside?
;  [set mouse-state? true]
;  if mouse-down? = false and mouse-inside? and mouse-state? = true
;  [ask patch mouse-xcor mouse-ycor
;    [
      sprout-dragons 1 [set-dragon-stats]
      set time-a timer1
;    ]
;   set mouse-state? false
  ]
;
end

to set-dragon-stats
  set original-shape "dragon"
  set shape2 "dragon 2"
  set size 11
  set heading 0
  set enemy? true
  set strength 15
  set health 2000
  set speed 0.15
  set range 13
  set gold-drop 1000
  ;set speed-attack

end

to golem-spawn
  if time-a != timer1
  [
;  set-default-shape golems "golem"
;  if mouse-down? and mouse-inside?
;  [set mouse-state? true]
;  if mouse-down? = false and mouse-inside? and mouse-state? = true
;  [ask patch mouse-xcor mouse-ycor
;    [
      sprout-golems 1 [set-golem-stats]
      set time-a timer1
;    ]
;   set mouse-state? false
  ]

end

to set-golem-stats
  set original-shape "golem"
  set shape2 "golem 2"
  set size 10
  set heading 0
  set enemy? true
  set strength 10
  set health 1000
  set speed 0.25
  set range 5
  set gold-drop 300
  ;set speed-attack

end

to witch-spawn
  if time-a != timer1
  [
;  set-default-shape witches "witch"
;  if mouse-down? and mouse-inside?
;  [set mouse-state? true]
;  if mouse-down? = false and mouse-inside? and mouse-state? = true
;  [ask patch mouse-xcor mouse-ycor
;    [
      sprout-witches 1 [set-witch-stats]
      set time-a timer1
;    ]
;   set mouse-state? false
  ]

end

to set-witch-stats
  set original-shape "witch"
  set shape2 "witch 2"
  set size 5
  set heading 0
  set enemy? true
  set strength 2
  set health 450
  set speed 0.3
  set range 15
  set gold-drop 150
  ;set speed-attack

end


;DEFENSE UNITS
;this is the same for the subsequent defense spawning functions, therefore I will only have comments on this one.
;Mohtasim Howlader
; 1.11.17 SELECTING AND DROPING FINALLY WORKS. Used mouse-state? variable to make sure only ONE was placed with each click, not the hundreds as before!!
; 1.14.17 added everything pertaining to vertico? and horzo?, which means that the units cannot be placed inside the corners (places where vertico? and horzo? meet)
; 1.15.17 removed sprouting another soldier, because it messes with the placement and movement

;Talal Ishrak
; 1.14.17 added the amount of gold used when selecting a unit.
; 1.15.17, reworked amount of gold lose when selecting a unit

to soldier-spawn
  ;set-default-shape soldiers "soldier"
  if mouse-down? and mouse-inside?
  [set mouse-state? true]
  if mouse-down? = false and mouse-inside? and mouse-state? = true
  [
    ask patch mouse-xcor mouse-ycor
    [
      if (vertico? = true and horzo-r? = 0 and horzo-l? = 0) or (horzo-r? = true and horzo-l? = false and vertico? = false) or (horzo-l? = true and vertico? = false and horzo-r? = 0)
      [
        if gold >= 100
        [
          sprout-soldiers 1 [set-soldier-stats]
          set gold gold - 100
;          ask patch-at 2 0
;          [
;            sprout-soldiers 1
;          ]
        ]
      ]
    ]
    set mouse-state? false
  ]

end

; started before 1/11, this is the same for the subsequent defense spawning related functions, therefore I will only have comments on this one
;Mohtasim Howlader
; 1.13.17 added enemy?, added health, range, color, size
; 1.14.17 added original-shape, shape2, set-default-shape
; 1.15.17 removed set-default shape, reworked health, speed, strength, added heading, added label for health
; 1.16.17 reworked health and strength, and speed

;Talal Ishrak
; 1.14.17 added speed, reworked cost and range
; 1.15.17 reworked speed, gold-drop, strength, health, speed, and range
to set-soldier-stats
  set original-shape "soldier"
  set shape original-shape
  set shape2 "soldier 2"
  set label health
  set size 4
  set enemy? false
  set defense? true
  set strength 3
  set health 250
  set range 5
  set speed 0.35
  ;set range
  ;set speed
  ;set speed-atack

end

to horseman-spawn
 set-default-shape horsemen "horseman"
  if mouse-down? and mouse-inside?
  [set mouse-state? true]
  if mouse-down? = false and mouse-inside? and mouse-state? = true
  [
    ask patch mouse-xcor mouse-ycor
    [
      if (vertico? = true and horzo-r? = 0 and horzo-l? = 0) or (horzo-r? = true and horzo-l? = false and vertico? = false) or (horzo-l? = true and vertico? = false and horzo-r? = 0)
      [
        if gold >= 300
        [
          sprout-horsemen 1 [set-horseman-stats]
          set gold gold - 300

        ]
      ]
    ]
    set mouse-state? false
  ]

end

to set-horseman-stats
  set original-shape "horseman"
  set shape2 "horseman 2"
  set size 6
  set enemy? false
  set defense? true
  set strength 5
  set health 500
  set range 5
  set speed 1
  ;set speed-attack

end

to archer-spawn
  set-default-shape archers "archer"
  if mouse-down? and mouse-inside?
  [set mouse-state? true]
  if mouse-down? = false and mouse-inside? and mouse-state? = true
  [
    ask patch mouse-xcor mouse-ycor
    [
      if (vertico? = true and horzo-r? = 0 and horzo-l? = 0) or (horzo-r? = true and horzo-l? = false and vertico? = false) or (horzo-l? = true and vertico? = false and horzo-r? = 0)
      [
        if gold >= 200
          [
            sprout-archers 1 [set-archer-stats]
            set gold gold - 200
          ]
      ]
    ]
   set mouse-state? false
  ]

end

to set-archer-stats
  set original-shape "archer"
  set shape2 "archer 2"
  set size 4
  set enemy? false
  set defense? true
  set strength 1
  set health 150
  set speed 0.2
  ;set speed-attack
  set range 15

end

to sorcerer-spawn
  set-default-shape sorcerers "sorcerer"
  if mouse-down? and mouse-inside?
  [set mouse-state? true]
  if mouse-down? = false and mouse-inside? and mouse-state? = true
  [
    ask patch mouse-xcor mouse-ycor
    [
      if (vertico? = true and horzo-r? = 0 and horzo-l? = 0) or (horzo-r? = true and horzo-l? = false and vertico? = false) or (horzo-l? = true and vertico? = false and horzo-r? = 0)
      [
        if gold >= 300
        [
          sprout-sorcerers 1 [set-sorcerer-stats]
          set gold gold - 300
        ]
      ]
    ]
    set mouse-state? false
  ]

end

to set-sorcerer-stats
  set original-shape "sorcerer"
  set shape2 "sorcerer 2"
  set size 5
  set strength 2
  set enemy? false
  set defense? true
  set health 500
  set range 15
  set speed 0.2

end

;Mohtasim Howladr
; added 1/11/17, how currency increases by itself
; 1.15.7 reworked the rates, also set the limits so it doesn't go below or over
to currency-start
  if level? = true
;  [ if ticks mod 10000 = 1
;    [set gold gold + 1]
;  ]
  [ every 1 / 10
    [
       set gold gold + 1
    ]
  ]
  if gold < 0 [set gold 0]
  if gold > 3000 [set gold 3000]
end

;;;;BEGINNING OF MOVE FUNCTIONS;;;;


;Mohtasim Howlader
; All right, here comes the hard part. This is the part that I spent the most time doing, and reworking, and starting over, and reworking again. I just have to say I'm kind of proud of it.

;Also all the comments for the "move" functions will go here as I updated all of them together
; 1.13.17 considered labelling all the patches based on distance from the castle, but then scrapped the idea (sorry Mr. K). New idea is by labelling the path vertico?, horzo-r?, or horzo-l? to determine heading of turtles.
; 1.14.17 this is only for enemy-move, defense-move is a little different (kind of the opposite). Added only-up, only-right, only-left, right-up, up-right, left-up, up-left.
; 1.14.17 based on the state of the patches, the enemies will set their heading a specific direction. However, in turns, they will be slowly turning in one direction until they finally meet the next heading (for the next path)
; 1.14.17 spec-pos are the individual patches that signal the enemies to turn x amount of degrees.
; 1.14.17 added turn-status, which differentiates right-up and up-right, and up-left and left-up, and right-down
; 1.15.17 added corner-verify, because turn-status wasn't enough. Same purpose as turn-status, but works better.
; 1.15.17 FINALLY WORKS, they don't fly off anymore!
to enemy-move
  only-up
  only-right
  only-left
  right-up
  up-right
  up-left
  left-up
  fd speed

end

to only-right
  if horzo-r? = true and horzo-l? = false and vertico? = false
  [set heading 90 set corner-verify "r"]
end

to right-up
  if heading = 90 [set turn-status "90"]
  if turn-status = "90" and corner-verify = "r" and horzo-r? = true and vertico? = true and horzo-l? = false
  [
    if spec-pos = "a" or spec-pos = "e" [lt 4.2]
    if spec-pos = "b" [lt 2]
    if spec-pos = "c" [lt 1]
    if heading > 90 [set heading 0]
    if spec-pos = "d" [set heading 0]
  ]
  if heading = 0 [set turn-status "0"]
end

to only-up
  if vertico? = true and horzo-l? = 0 and horzo-r? = 0
  [set heading 0 set corner-verify "u"]
end


to up-right
  if heading = 0 [set turn-status "0"]
  if turn-status = "0" and corner-verify = "u" and horzo-r? = true and vertico? = true and horzo-l? = false
  [
    if spec-pos = "a" or spec-pos = "d" [rt 4.2]
    if spec-pos = "b" [rt 2]
    if spec-pos = "c" [rt 1]
    if heading > 90 [set heading 90]
    if spec-pos = "e" [set heading 90]
  ]
  if heading = 90 [set turn-status "90"]

end

to only-left
  if horzo-l? = true and vertico? = false
  [set heading 270 set corner-verify "l"]
end

to left-up
  if heading = 270 [set turn-status "270"]
  if turn-status = "270" and corner-verify = "l" and horzo-l? = true and vertico? = true
  [
    if spec-pos = "a" or spec-pos = "e" [rt 4.2]
    if spec-pos = "b" [rt 2]
    if spec-pos = "c" [rt 1]
    if heading < 270 and heading > 0 [set heading 0]
    if spec-pos = "d" [set heading 0]
  ]
  if heading = 0 [set turn-status "0"]

end

to up-left
  if heading = 0 [set turn-status "0"]
  if turn-status = "0" and corner-verify = "u" and horzo-l? = true and vertico? = true
  [
    if spec-pos = "a" or spec-pos = "d" [lt 3.5]
    if spec-pos = "b" [lt 2]
    if spec-pos = "c" [lt 1]
    if heading < 270 and heading > 0 [set heading 270]
    if spec-pos = "e" [set heading 270]
  ]
  if heading = 270 [set turn-status "270"]
end


; How defense troops move, comments are still above enemy-move since they are relatively the same. Only, defense has down, while enemy only had up.
to defense-move
  d-only-down
  d-only-right
  d-only-left
  right-down
  down-right
  left-down
  down-left

  fd speed
end

to d-only-down
  if vertico? = true and horzo-l? = 0 and horzo-r? = 0
  [set heading 180 set corner-verify "d"]
end

to d-only-right
  if horzo-l? = true and vertico? = false
  [set heading 90 set corner-verify "r"]
end

to d-only-left
  if horzo-r? = true and horzo-l? = false and vertico? = false
  [set heading 270 set corner-verify "l"]
end


to right-down
  if heading = 90 [set turn-status "90"]
  if turn-status = "90" and corner-verify = "r" and horzo-l? = true and vertico? = true
  [
    if spec-pos = "a" or spec-pos = "e" [rt 7]
    if spec-pos = "b" [rt 5]
    if spec-pos = "c" [rt 3]
    if heading > 180 [set heading 180]
    if spec-pos = "d" [set heading 180]
  ]
  if heading = 180 [set turn-status "180"]
end

to down-right
  if heading = 180 [set turn-status "180"]
  if turn-status = "180" and corner-verify = "d" and horzo-l? = true and vertico? = true
  [
    if spec-pos = "a" or spec-pos = "d" [lt 7]
    if spec-pos = "b" [lt 5]
    if spec-pos = "c" [lt 3]
    if heading < 90 [set heading 90]
    if spec-pos = "e" [set heading 90]
  ]
  if heading = 90 [set turn-status "90"]
end

to left-down
  if heading = 270 [set turn-status "270"]
  if turn-status = "270" and corner-verify = "l" and horzo-r? = true and vertico? = true and horzo-l? = false
  [
    if spec-pos = "a" or spec-pos = "e" [lt 7]
    if spec-pos = "b" [lt 5]
    if spec-pos = "c" [lt 3]
    if heading < 180 [set heading 180]
    if spec-pos = "d" [set heading 180]
  ]
  if heading = 180 [set turn-status "180"]
end




to down-left
  if heading = 180 [set turn-status "180"]
  if turn-status = "180" and corner-verify = "d" and horzo-r? = true and vertico? = true and horzo-l? = false
  [
    if spec-pos = "a" or spec-pos = "d" [rt 7]
    if spec-pos = "b" [rt 5]
    if spec-pos = "c" [rt 3]
    if heading > 270 [set heading 270]
    if spec-pos = "e" [set heading 270]
  ]
  if heading = 270 [set turn-status "270"]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; END OF MOVE FUNCTIONS;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;Talal Ishrak
; 1.14.17 created this, set health, label, size
; 1.15.17 reworked health
;Mohtasim Howlader
; 1.15.17 added turtle-variable building? and defense?
 to set-tower-stats
  set building? true
  set defense? true
  set color blue
  set size 15
  set health 8000
  set label health
  set label-color black
end


;Talal Ishrak
; 1.12.17 created this function, added fireballs hatching
; 1.13.17 added fireball stats
; strength is not a necesary stat, but will stay there
; 1.14.17 added feature that causes fireballs to damage enemies.
; 1.15.17 reworked damage
;Mohtasim Howlader
; 1.15.17 added local variables and turtle-varable original-tower so that it dies when it goes to far from original tower
; reworked damage
to tower-fight
  set-default-shape fireballs "circle"
  ask towers
  [
    let x who
    if any? turtles in-radius 16 with [enemy? = true]
    [
      hatch-fireballs 1
      [
        set original-tower x
        set building? 0
        set defense? 0
        set health 1
        set label ""
        set color red
        set size 1
        set speed .5
        set strength 25
        face min-one-of turtles with [enemy? = true] [distance myself]
      ]
    ]

    ask fireballs
    [
      let y original-tower
      if any? turtles in-radius 2 with [enemy? = true]
      [
        ask turtles in-radius 2 with [enemy? = true]
        [
          set health health - 4
        ]
        die
      ]
      fd speed

      if count towers in-radius 17 with [who = y] = 0 [die]
    ]
  ]

end

;;;;;START OF FIGHTING COMMANDS, WAS HARD TOO;;;;;;;


;Talal Ishrak
; 1.14.17 created stop-each other
;Mohtasim Howlader
; 1.15.17 reworked stop each other
to stop-eachother
  enemy-stop
  defense-stop
end

;Mohtasim Howlader
;1.15.17 created this, reworked this, made this universal to it applies to both enemies and defense
to battle-eachother
  enemy-fight
  defense-fight
end

;comments are same for defense-stop as well
;Talal Ishrak
; 1.14.17 created this function, added fight-active? (if true, stops wiggling/moving, if false: continues wiggling/moving)
; 1.15.17 added differentiation between enemies and defenses
;Mohtasim Howlader
; 1.15.17, added local variables and target variable so turtle keeps in mind who the target is, because this function sets up enemy-fight. Also added battle ani? for enemy-fight
; 1.15.17 added change shape back to original-shape so it doesn't keep the shape from the attack animation
; 1.16.17, changed in radius to in-cone because turtles started attacking castle from the beginning.

to enemy-stop
  ask turtles with [enemy? = true]
  [
    ifelse any? turtles with [enemy? = false] in-cone range 180 or any? towers in-cone (range + 3) 180 or any? castles in-cone (range + 14) 180
      [
        if any? turtles with [enemy? = false] in-cone range 180
        [
          set fight-active? true
          set target [who] of min-one-of turtles in-cone range 180 with [enemy? = false] [distance myself]
          let x target

          if any? turtles with [who = x]
          [
             face one-of turtles with [who = x]
             ;ask turtles with [who = x] [set health health - 0.1 ]  ;later replace with strength
             ;every 10
             ;[
             set battle-ani? true
          ]
        ]
        if any? turtles with [building? = true] in-cone (range + 3) 180
        [
          set target [who] of min-one-of towers in-cone (range + 3) 180  [distance myself]

          set fight-active? true
          set target [who] of min-one-of towers in-cone (range + 3) 180 [distance myself]
          let x target

          if any? turtles with [who = x]
          [
            face one-of turtles with [who = x]
            ;ask turtles with [who = x] [set health health - 0.1 ]  ;later replace with strength
            ;every 10
            ;[
            set battle-ani? true
          ]
        ]
        if any? castles in-cone (range + 14) 180
        [
          set target [who] of min-one-of castles in-cone (range + 14) 180 [distance myself]

          set fight-active? true
          set target [who] of min-one-of castles in-cone (range + 14) 180 [distance myself]
          let x target

          if any? turtles with [who = x]
          [
            face one-of turtles with [who = x]
            ;ask turtles with [who = x] [set health health - 0.1 ]  ;later replace with strength
            ;every 10
            ;[
            set battle-ani? true
          ]
        ]
      ]

      [
        ;set battle-ani? false
        set shape original-shape
        set fight-active? false
      ]

  ]
end

;same comments for defense-fight as well
;Mohtasim Howlader
; 1.15.17 created this, added local variables for changing animation. Does not always work for some reason, never caught the reason, but doesn't seem to affect attacking capabilities.

to enemy-fight
  if any? turtles with [enemy? = true and battle-ani? = true]
  [
    ask turtles with [enemy? = true and battle-ani? = true]
    [
      let x target
      let y strength
      if shape = original-shape [set next-shape shape2]
      if shape = shape2 [set next-shape original-shape]
      set shape next-shape
      ask turtles with [who = x] [set health health - y ]
    ]
  ]
end



to defense-stop
  ask turtles with [enemy? = false]
  [
    ifelse any? turtles with [enemy? = true] in-radius range
    [
      set fight-active? true
      set target [who] of min-one-of turtles in-radius range with [enemy? = true] [distance myself]
      let x target

      if any? turtles with [who = x]
      [
         face one-of turtles with [who = x]
         ;ask turtles with [who = x] [set health health - 0.1 ]  ;later replace with strength
         ;every 10
         ;[
         set battle-ani? true
      ]
    ]

    [
      ;set battle-ani? false
      set shape original-shape
      set fight-active? false
    ]
    if [pycor] of patch-at 0 -1 = -33
    [
      set fight-active? true
    ]


  ]
end

to defense-fight
  if any? turtles with [enemy? = false and battle-ani? = true]
  [
    ask turtles with [enemy? = false and battle-ani? = true]
    [
      let x target
      let y strength
      if shape = original-shape [set next-shape shape2]
      if shape = shape2 [set next-shape original-shape]
      set shape next-shape
      ask turtles with [who = x] [set health health - y ]
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;END OF FIGHTING FUNCTIONS;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;START OF LEVEL SPAWNING;;;;;;;;;
;The comments are the same for the other level functions, so look at the comments here.
;Talal Ishrak
; 1.15.17 created function, changed enemy-spawn functions so they would work in this function
;Mohtasim Howlader
; 1.16.17 reworked this function, added the game timer (timer1) that keeps track of in-game time when these will be spawned
; 1.16.17 adjusted spawn locations to they don't spawn off the path.
; 1.16.17 reworked times because game started becoming slow and laggy. Spread apart times
; 1.16.17 added how victory is determined, used victory-screen1, victory-screen2, and victory-screen3.
to level1
  if timer1 = 2 or timer1 = 10 or timer1 = 42
  [ask patch -70 -36 [goblin-spawn]];1
  if timer1 = 2.5 or timer1 = 10.5 or timer1 = 42.5
  [ask patch -8 -50 [goblin-spawn]] ;2
  if timer1 = 3 or timer1 = 11 or timer1 = 43
  [ask patch 66 -37 [goblin-spawn]] ;3


  if timer1 = 12 ;or timer1 = 64
  [ask patch -68 -36 [giant-spawn]] ;1
  if timer1 = 12.5 ;or timer1 = 64.5
  [ask patch -9 -50 [giant-spawn]] ;2
  if timer1 = 13 ;or timer1 = 65
  [ask patch 62 -37 [giant-spawn]] ;3

  if timer1 = 30 or timer1 = 95
  [ask patch -66 -36 [dragon-spawn]] ;1
  if timer1 = 30.5 or timer1 = 95.5
  [ask patch -7 -50 [dragon-spawn]];2
  if timer1 = 31 or timer1 = 96
  [ask patch 64 -37 [dragon-spawn]];3

  if timer1 = 15 or timer1 = 55
  [ask patch -65 -36 [witch-spawn]];1
  if timer1 = 15.5 or timer1 = 55.5
  [ask patch -6 -50 [witch-spawn]];2
  if timer1 = 16 or timer1 = 56
  [ask patch 65 -37 [witch-spawn]];3

  if timer1 = 70 ;or timer1 = 50
  [ask patch -62 -36 [golem-spawn]] ;1
  if timer1 = 70.5 ;or timer1 = 50.5
  [ask patch -7.5 -50 [golem-spawn]];2
  if timer1 = 71 ;or timer1 = 51
  [ask patch 61 -37 [golem-spawn]];3

  if timer1 > 96 and count (turtles with [enemy? = true]) = 0 [victory-screen1] ;after the last enemy has been spawned

end

;Talal Ishrak
; 1.14.17 created image files
;Mohtasim Howlader
; 1.16.17, created this function, added resize-world. Added new global variable defeat? so "go" is not continuously running.
to defeat-screen
  if count castles = 0
  [
    ca
    resize-world -450 450 -300 300
    set-patch-size 1
    import-pcolors "defeatscreen-1.png"
    set defeat? true
  ]
end

;Talal Ishrak
; 1.14.17 created image files
;Mohtasim Howlader
; 1.16.17, created this function, added resize-world. Added new global variable defeat? so "go" is not continuously running. Added advance? to advance-next-level can be used. Added block-defeat? so go does not ocntinuously run.
; 1.16.17 added advance-level so advance-next-level button can differentiate between levels.
to victory-screen1
  ca
  resize-world -450 450 -300 300
  set-patch-size 1
  import-pcolors "victoryscreen-1.png"
  set defeat? true
  set advance? true
  set block-defeat? true
  set advance-level 2

end

;Talal Ishrak
; 1.15.17 created this function
;Mohtasim Howlader
; 1.16.17 reworked this so it is operational. Added advance-level and advance?
to advance-next-level
  if advance? = true and advance-level = 2
  [
    setup
    set level 2
    set advance? false
  ]
  if advance? = true and advance-level = 3
  [
    setup
    set level 3
    set advance? false
  ]
end

to level2
  if timer1 = 2 or timer1 = 10 or timer1 = 22 or timer1 = 28 or timer1 = 37
  [ask patch -70 -36 [goblin-spawn]];1

  if timer1 = 2.5 or timer1 = 10.5 or timer1 = 22.5 or timer1 = 28.5 or timer1 = 37.5
  [ask patch -8 -50 [goblin-spawn]] ;2

  if timer1 = 3 or timer1 = 11 or timer1 = 23 or timer1 = 29 or timer1 = 38
  [ask patch 66 -37 [goblin-spawn]] ;3


  if timer1 = 12 or timer1 = 85
  [ask patch -68 -36 [giant-spawn]] ;1
  if timer1 = 12.5 or timer1 = 85.5
  [ask patch -9 -50 [giant-spawn]] ;2
  if timer1 = 13 or timer1 = 86
  [ask patch 62 -37 [giant-spawn]] ;3

  if timer1 = 60 or timer1 = 95
  [ask patch -66 -36 [dragon-spawn]] ;1
  if timer1 = 60.5 or timer1 = 95.5
  [ask patch -7 -50 [dragon-spawn]];2
  if timer1 = 61 or timer1 = 96
  [ask patch 64 -37 [dragon-spawn]];3

  if timer1 = 15 or timer1 = 46 or timer1 = 65
  [ask patch -65 -36 [witch-spawn]];1
  if timer1 = 15.5 or timer1 = 46.5 or timer1 = 65.5
  [ask patch -6 -50 [witch-spawn]];2
  if timer1 = 16 or timer1 = 47 or timer1 = 66
  [ask patch 65 -37 [witch-spawn]];3

  if timer1 = 52 or timer1 = 80
  [ask patch -62 -36 [golem-spawn]] ;1
  if timer1 = 52.5 or timer1 = 80.5
  [ask patch -7.5 -50 [golem-spawn]];2
  if timer1 = 53 or timer1 = 81
  [ask patch 61 -37 [golem-spawn]];3

  if timer1 > 96 and count (turtles with [enemy? = true]) = 0 [victory-screen2]
end

to victory-screen2
  ca
  resize-world -450 450 -300 300
  set-patch-size 1
  import-pcolors "victoryscreen-1.png"
  set defeat? true
  set block-defeat? true
  set advance? true
  set advance-level 3
end

to level3

  if timer1 = 2 or timer1 = 10 or timer1 = 22 or timer1 = 28 or timer1 = 37 or timer1 = 48
  [ask patch -70 -36 [goblin-spawn]];1

  if timer1 = 2.5 or timer1 = 10.5 or timer1 = 22.5 or timer1 = 28.5 or timer1 = 37.5 or timer1 = 48.5
  [ask patch -8 -50 [goblin-spawn]] ;2

  if timer1 = 3 or timer1 = 11 or timer1 = 23 or timer1 = 29 or timer1 = 38 or timer1 = 49
  [ask patch 66 -37 [goblin-spawn]] ;3


  if timer1 = 12 or timer1 = 62 or timer = 91
  [ask patch -68 -36 [giant-spawn]] ;1
  if timer1 = 12.5 or timer1 = 62.5 or timer = 91.5
  [ask patch -9 -50 [giant-spawn]] ;2
  if timer1 = 13 or timer1 = 63 or timer = 92
  [ask patch 62 -37 [giant-spawn]] ;3

  if timer1 = 60 or timer1 = 95 or timer = 130
  [ask patch -66 -36 [dragon-spawn]] ;1
  if timer1 = 60.5 or timer1 = 95.5 or timer = 130.5
  [ask patch -7 -50 [dragon-spawn]];2
  if timer1 = 61 or timer1 = 96 or timer = 131
  [ask patch 64 -37 [dragon-spawn]];3

  if timer1 = 15 or timer1 = 46 or timer1 = 65 or timer = 97
  [ask patch -65 -36 [witch-spawn]];1
  if timer1 = 15.5 or timer1 = 46.5 or timer1 = 65.5 or timer = 97.5
  [ask patch -6 -50 [witch-spawn]];2
  if timer1 = 16 or timer1 = 47 or timer1 = 66 or timer = 98
  [ask patch 65 -37 [witch-spawn]];3

  if timer1 = 20 or timer1 = 70 or timer = 110
  [ask patch -62 -36 [golem-spawn]] ;1
  if timer1 = 20.5 or timer1 = 70.5 or timer = 110.5
  [ask patch -7.5 -50 [golem-spawn]];2
  if timer1 = 21 or timer1 = 71 or timer = 111
  [ask patch 61 -37 [golem-spawn]];3

  if timer1 > 131 and count (turtles with [enemy? = true]) = 0 [victory-screen3]
end

to victory-screen3
  ca
  resize-world -450 450 -300 300
  set-patch-size 1
  import-pcolors "victoryscreen-3.png"
  set defeat? true
  set block-defeat? true
end

; Mohtasim Howlader
; 1.16.17 added this for displaying victory and defeat
to victory-test1
  set timer1 97
  ask turtles with [enemy? = true] [die]
end

to defeat-test1
  ask castles [die]
end

;;;;;END, FINALLLY;;;;


































@#$#@#$#@
GRAPHICS-WINDOW
233
10
1089
707
70
55
6.0
1
10
1
1
1
0
1
1
1
-70
70
-55
55
0
0
1
ticks
30.0

BUTTON
22
242
95
280
Sorcerer
sorcerer-spawn
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
6
11
79
44
NIL
setup\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
150
14
213
47
NIL
reset\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
131
180
212
213
Horseman
horseman-spawn\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
13
183
87
216
Soldier
soldier-spawn
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
11
57
74
90
NIL
go\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
133
114
214
159
NIL
gold
17
1
11

MONITOR
16
110
73
155
Timer
timer1
17
1
11

BUTTON
131
247
200
280
Archer
archer-spawn
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
31
317
173
350
Advance Next Level
advance-next-level
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
18
365
75
410
Level
level
17
1
11

BUTTON
9
433
112
466
NIL
victory-test1
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
127
436
229
469
NIL
defeat-test1
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

This tower defense game called Castle Defense Rush. The objective of the game is to use your own troops to fight off the enemies. If the enemies succeed in taking down the main castle, you lose. If you can kill all the enemies that come in through each level, you win. To completely beat the game, you must beat level 3.



## HOW IT WORKS

Once you press setup and go, the enemies come in from the bottom of each path with an objective to take down the main castle. However, there are turrets in between each path that tries to prevent them from coming in. Of course, the main point of the game is to deploy your own troops to defend your castle. However, it is limited. You can only put down the troops if you have enough gold. You also earn gold if enemies are killed. The enemies that come in get stronger by the time. First the weaker ones come in. As more enemies come in, the stronger types appear. All of these enemies get stronger by each level also.




## HOW TO USE IT

Buttons
* SETUP sets up the map with castle and towers.
* GO starts the game
* SOLDIER, HORSEMAN, SORCERER, ARCHER lets you deploy the respective troops. You must turn off one button to use another one.
* ADVANCE NEXT LEVEL allows you to advance to the next level one you beat each level.

Monitors
* TIMER1 shows how much time has passed.
* GOLD shows how much gold you currently have.
* LEVEL shows what level you are on.

Characters:

*DO NOT PUT DEFENSES BELOW PYCOR -32, THEY WILL GO ALL OVER THE PLACE*
Defending-
Tower-fireballs (ranged) really fast and decently strong
Soldiers(melee) pretty weak but good in numbers
Horsemen(melee) medium strength and medium health, very fast as well
Sorcerer(ranged) pretty weak but decent health and long range
Archer(ranged) weak but long range
(place them in the middle of the path to defend against enemies)

Invading-
Goblins (melee) they are pretty weak but come in bundles
Witches (ranged) they are weak but range is something to look out for
Golems (melee) strong and tanky
Dragons (ranged) strongest and highest health
Giants (melee) medium strength and decently tanky


## THINGS TO NOTICE

Determine the best way to use your troops and where to place them.

Determine how fast the enemies can take down your turrets.

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

ambulance
false
0
Rectangle -7500403 true true 30 90 210 195
Polygon -7500403 true true 296 190 296 150 259 134 244 104 210 105 210 190
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Circle -16777216 true false 69 174 42
Rectangle -1 true false 288 158 297 173
Rectangle -1184463 true false 289 180 298 172
Rectangle -2674135 true false 29 151 298 158
Line -16777216 false 210 90 210 195
Rectangle -16777216 true false 83 116 128 133
Rectangle -16777216 true false 153 111 176 134
Line -7500403 true 165 105 165 135
Rectangle -7500403 true true 14 186 33 195
Line -13345367 false 45 135 75 120
Line -13345367 false 75 135 45 120
Line -13345367 false 60 112 60 142

archer
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 75 135 105 165 225 120
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Polygon -6459832 false false 105 210 75 210 45 180 30 135 30 90 45 60 105 210
Polygon -6459832 false false 15 150 15 165 30 180 15 165
Line -6459832 false 135 135 15 165
Line -6459832 false 15 150 0 165
Line -6459832 false 30 180 0 165
Rectangle -1 true false 120 30 135 45
Rectangle -1 true false 165 30 180 45
Rectangle -1 true false 135 60 165 75

archer 2
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 75 135 150 150 240 90
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Polygon -6459832 false false 15 150 15 165 30 180 15 165
Line -6459832 false 135 135 15 165
Line -6459832 false 15 150 0 165
Line -6459832 false 30 180 0 165
Rectangle -1 true false 120 30 135 45
Rectangle -1 true false 165 30 180 45
Rectangle -1 true false 135 60 165 75
Polygon -6459832 false false 45 60 30 90 30 135 45 180 75 210 105 210 135 135 45 60

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

castle
false
0
Rectangle -7500403 true true 90 255 210 300
Line -16777216 false 75 255 225 255
Rectangle -16777216 false false 90 255 210 300
Polygon -7500403 true true 90 255 105 105 195 105 210 255
Polygon -7500403 false true 90 255 105 105 195 105 210 255
Rectangle -7500403 true true 75 90 120 60
Rectangle -7500403 true true 75 84 225 105
Rectangle -7500403 true true 135 90 165 60
Rectangle -7500403 true true 180 90 225 60
Polygon -7500403 false true 90 105 75 105 75 60 120 60 120 84 135 84 135 60 165 60 165 84 179 84 180 60 225 60 225 105
Rectangle -7500403 true true 75 60 120 90
Rectangle -7500403 true true 135 60 165 90
Rectangle -7500403 true true 180 60 225 90
Rectangle -7500403 true true 75 105 120 300
Rectangle -7500403 true true 195 105 225 300
Rectangle -6459832 true false 75 90 225 105
Rectangle -6459832 true false 75 135 225 150
Rectangle -6459832 true false 75 120 150 120
Rectangle -6459832 true false 75 180 225 195
Rectangle -6459832 true false 75 225 225 240
Rectangle -6459832 true false 75 270 135 270
Rectangle -7500403 true true 75 255 180 270
Rectangle -6459832 true false 75 270 225 285
Rectangle -7500403 true true 225 150 240 300
Rectangle -7500403 true true 285 150 300 300
Rectangle -7500403 true true 240 180 285 300
Rectangle -7500403 true true 60 150 75 300
Rectangle -7500403 true true 0 150 15 300
Rectangle -7500403 true true 15 180 60 300
Rectangle -6459832 true false 0 195 75 210
Rectangle -6459832 true false 225 195 300 210
Rectangle -6459832 true false 0 240 75 255
Rectangle -7500403 true true 225 240 300 255
Rectangle -6459832 true false 225 240 300 255

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

dragon
false
0
Circle -2674135 false false 56 56 67
Circle -2674135 true false 56 56 67
Polygon -2674135 true false 60 90 45 135 75 135 105 120 90 135 75 150 60 180 60 225 90 240 150 255 210 255 240 225 255 195 270 165 285 150 270 150 255 165 240 180 225 195 210 195 195 180 180 165 165 165 180 150 195 135 210 135 210 120 255 60 210 60 135 75 150 165 120 135 120 105
Polygon -2674135 true false 120 75 180 45 225 45 150 135 135 165
Polygon -1184463 true false 75 90 90 75 75 75 75 90
Polygon -2674135 true false 90 195 75 255 60 255 60 270 90 270 120 225 75 210 60 240 45 240 45 255 75 255
Polygon -2674135 true false 165 255 150 270 150 285 135 285 135 300 180 300 180 285 195 255
Polygon -2674135 true false 195 255 210 270 195 285 180 285
Polygon -16777216 true false 45 135 60 135 60 120 75 120 75 105 90 105
Polygon -2674135 true false 60 75 60 45 75 60 90 60 105 45

dragon 2
false
0
Circle -2674135 false false 56 56 67
Circle -2674135 true false 56 56 67
Polygon -2674135 true false 60 90 30 105 45 135 105 120 90 135 75 150 60 180 60 225 90 240 150 255 210 255 240 225 255 195 270 165 285 150 270 150 255 165 240 180 225 195 210 195 195 180 180 165 165 165 180 165 195 165 210 165 210 135 255 105 210 90 150 120 150 165 120 135 120 105
Polygon -2674135 true false 105 60 135 45 180 45 150 135 135 165
Polygon -1184463 true false 75 90 90 75 75 75 75 90
Polygon -2674135 true false 90 195 75 255 60 255 60 270 90 270 120 225 75 210 60 240 45 240 45 255 75 255
Polygon -2674135 true false 165 255 150 270 150 285 135 285 135 300 180 300 180 285 195 255
Polygon -2674135 true false 195 255 210 270 195 285 180 285
Polygon -16777216 true false 45 135 60 135 60 120 75 120 75 105 90 105
Polygon -2674135 true false 60 75 60 45 75 60 90 60 105 45

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

giant
false
0
Circle -6459832 true false 108 33 85
Polygon -6459832 true false 135 120 120 120 90 180 105 195 120 165 120 225 105 285 135 285 150 225 165 285 195 285 180 225 180 165 195 195 210 180 180 120 165 120 165 105 135 105
Rectangle -1 true false 120 60 135 75
Rectangle -1 true false 165 60 180 75
Rectangle -1 true false 135 90 165 105
Line -16777216 false 135 45 150 60
Line -16777216 false 150 60 165 45

giant 2
false
0
Circle -6459832 true false 108 33 85
Polygon -6459832 true false 135 120 120 120 60 135 75 165 120 165 120 225 105 285 135 285 150 225 165 285 195 285 180 225 180 165 225 165 240 135 180 120 165 120 165 105 135 105
Rectangle -1 true false 120 60 135 75
Rectangle -1 true false 165 60 180 75
Rectangle -1 true false 135 90 165 105
Line -16777216 false 135 45 150 60
Line -16777216 false 150 60 165 45

goblin
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Polygon -16777216 true false 223 147 236 130 248 140 233 157 223 148
Polygon -16777216 true false 237 132 219 114 225 118 228 112 268 148 264 156 244 140
Polygon -16777216 true false 241 123 274 87 293 86 291 102 256 138
Rectangle -2674135 true false 112 102 189 163
Polygon -2674135 true false 82 134 70 109 65 114 78 138 83 134
Polygon -2674135 true false 54 121 81 100 76 92 47 113 56 122
Polygon -2674135 true false 68 99 27 28 19 54 52 106
Polygon -2674135 true false 47 97 58 118
Polygon -2674135 true false 42 88 58 114 67 104 56 89 43 92

goblin 2
false
0
Circle -13840069 true false 108 33 85
Rectangle -13840069 true false 120 120 180 210
Polygon -13840069 true false 120 210 90 285 120 285 150 240 180 270 195 255 180 210
Polygon -13840069 true false 120 120 75 120 90 150 120 150 180 150 210 150 225 120 180 120
Rectangle -5825686 true false 120 60 135 75
Rectangle -5825686 true false 165 60 180 75
Rectangle -5825686 true false 135 90 165 105
Polygon -13840069 true false 120 60 105 45 105 75 120 90
Polygon -13840069 true false 180 60 195 45 195 75 180 90
Rectangle -2674135 true false 120 135 180 195

goblinz
false
6
Circle -13840069 true true 108 33 85
Rectangle -13840069 true true 120 120 180 210
Polygon -13840069 true true 120 210 105 285 135 285 150 240 165 285 195 285 180 210
Polygon -13840069 true true 120 120 45 90 45 120 120 150 180 150 255 120 255 90 180 120
Rectangle -5825686 true false 120 60 135 75
Rectangle -5825686 true false 165 60 180 75
Rectangle -5825686 true false 135 90 165 105
Polygon -13840069 true true 120 60 105 45 105 75 120 90
Polygon -13840069 true true 180 60 195 45 195 75 180 90
Rectangle -2674135 true false 120 135 180 195

golem
false
0
Rectangle -13791810 true false 90 0 210 75
Polygon -13791810 true false 120 75 120 90 60 105 30 165 60 195 90 150 90 225 210 225 210 150 240 195 270 165 240 105 180 90 180 75
Polygon -13791810 true false 90 225 75 225 75 300 135 300 135 255 165 255 165 300 225 300 225 225
Rectangle -14835848 true false 120 15 135 30
Rectangle -14835848 true false 165 15 180 30
Rectangle -14835848 true false 120 45 180 60

golem 2
false
0
Rectangle -13791810 true false 90 0 210 75
Polygon -13791810 true false 120 75 120 90 60 75 30 30 15 90 90 150 90 225 210 225 210 150 300 90 270 30 240 75 180 90 180 75
Polygon -13791810 true false 90 225 75 225 75 300 135 300 135 255 165 255 165 300 225 300 225 225
Rectangle -14835848 true false 120 15 135 30
Rectangle -14835848 true false 165 15 180 30
Rectangle -14835848 true false 120 45 180 60

golemsss
false
0
Rectangle -13791810 true false 90 15 210 60
Polygon -13791810 true false 120 75 120 90 60 105 30 165 60 195 90 150 90 225 210 225 210 150 240 195 270 165 240 105 180 90 180 75
Polygon -13791810 true false 90 225 75 225 75 300 135 300 135 255 165 255 165 300 225 300 225 225
Rectangle -14835848 true false 120 15 135 30
Rectangle -14835848 true false 165 15 180 30
Rectangle -14835848 true false 120 45 180 60
Rectangle -13791810 true false 90 59 210 68
Polygon -13791810 true false 154 78 116 80 97 79 86 64 85 54 86 34 86 11 105 10 217 10 219 25 218 46 220 58 220 65 211 77 183 79 171 77
Polygon -13791810 true false 144 59 153 60 152 91 161 91 182 66 151 69
Rectangle -13840069 true false 112 29 143 46
Rectangle -13840069 true false 172 29 200 46
Rectangle -13840069 true false 142 53 175 68

horseman
false
0
Polygon -6459832 true false 15 135 45 75 75 75 90 120 105 150 195 150 240 135 270 135 270 225 255 240 255 165 255 195 240 210 225 240 225 300 195 300 195 240 180 225 90 225 90 300 60 300 60 225 45 195 45 165 45 135 30 165 15 165 15 135
Polygon -1 true false 30 120 45 105 45 120
Circle -7500403 true true 116 11 67
Polygon -7500403 true true 135 75 75 90 90 105 135 90 120 150 180 150 165 90 180 90
Polygon -7500403 true true 165 75 180 90 105 135 105 120 150 90
Polygon -7500403 true true 120 150 135 165 165 165 180 150
Rectangle -7500403 true true 135 165 165 225
Polygon -7500403 true true 135 225 120 240 150 240 165 240 165 225 135 225
Rectangle -1 true false 135 30 150 45

horseman 2
false
0
Polygon -6459832 true false 15 135 45 75 75 75 90 120 105 150 195 150 240 135 270 135 270 225 255 240 255 165 255 195 240 210 225 240 240 255 225 285 195 240 180 225 90 225 30 270 15 240 45 225 45 195 45 165 45 135 30 165 15 165 15 135
Polygon -1 true false 30 120 45 105 45 120
Circle -7500403 true true 116 11 67
Polygon -7500403 true true 135 75 75 60 75 90 135 90 120 150 180 150 165 90 180 90
Polygon -7500403 true true 165 75 180 90 105 135 105 120 150 90
Polygon -7500403 true true 120 150 135 165 165 165 180 150
Rectangle -7500403 true true 135 165 165 225
Polygon -7500403 true true 135 225 120 240 150 240 165 240 165 225 135 225
Rectangle -1 true false 135 30 150 45

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

house ranch
false
0
Rectangle -7500403 true true 270 120 285 255
Rectangle -7500403 true true 15 180 270 255
Polygon -7500403 true true 0 180 300 180 240 135 60 135 0 180
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 45 195 105 240
Rectangle -16777216 true false 195 195 255 240
Line -7500403 true 75 195 75 240
Line -7500403 true 225 195 225 240
Line -16777216 false 270 180 270 255
Line -16777216 false 0 180 300 180

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

soldier
false
0
Circle -6459832 true false 108 3 85
Polygon -6459832 true false 135 75 135 90 120 90 60 150 75 165 120 135 105 210 195 210 180 135 225 165 240 150 180 90 165 90 165 75
Polygon -6459832 true false 120 210 105 300 135 300 150 255 195 300 180 210
Polygon -6459832 true false 135 225 165 300 195 300
Polygon -16777216 true false 210 150 255 45 270 75 225 150 210 165
Rectangle -1 true false 120 30 135 45
Rectangle -1 true false 165 30 180 45
Rectangle -1 true false 135 60 165 75
Polygon -7500403 true true 215 102 251 136 253 130 218 98 214 101
Polygon -16777216 true false 229 108 220 98 251 128 250 134 217 103 218 100 246 125
Polygon -16777216 true false 210 90 266 138 262 146 206 95 212 90
Polygon -16777216 true false 252 51 274 0 293 34 259 94

soldier 2
false
0
Circle -6459832 true false 108 3 85
Polygon -6459832 true false 135 75 135 90 120 90 60 150 75 165 120 135 105 210 195 210 180 135 195 165 210 135 180 90 165 90 165 75
Polygon -6459832 true false 120 210 105 300 135 300 150 255 195 300 180 210
Polygon -6459832 true false 135 225 165 300 195 300
Polygon -16777216 true false 195 150 240 255 255 225 210 150 195 135
Rectangle -1 true false 120 30 135 45
Rectangle -1 true false 165 30 180 45
Rectangle -1 true false 135 60 165 75
Polygon -16777216 true false 195 225 251 177 247 169 191 220 197 225
Polygon -16777216 true false 237 249 259 300 278 266 244 206

sorcerer
false
0
Circle -1 true false 116 56 67
Polygon -13791810 true false 105 90 120 75 180 75 195 90 150 15 105 90
Polygon -8630108 false false 135 120 135 135 90 165 90 180 135 165 105 210 90 285 210 285 195 210 165 165 210 180 210 165 165 135 165 120
Polygon -1184463 true false 165 135 135 135 90 165 90 180 135 165 105 210 90 285 210 285 195 210 165 165 195 180 210 165 165 135
Polygon -8630108 true false 165 135 165 120 165 135
Polygon -1184463 true false 135 120 135 135 165 150 165 105 135 105
Polygon -1184463 true false 135 135 60 180 60 210 135 165
Polygon -1184463 true false 165 135 240 180 240 210 195 180
Polygon -955883 true false 60 120 75 120 75 270 60 270 60 120
Polygon -14835848 true false 60 120 45 105 60 90 75 90 90 105 75 120 60 120

sorcerer 2
false
0
Circle -1 true false 116 56 67
Polygon -13791810 true false 105 90 120 75 180 75 195 90 150 15 105 90
Polygon -8630108 false false 135 120 135 135 90 120 90 135 135 165 105 210 90 285 210 285 195 210 165 165 195 150 165 135 165 120
Polygon -1184463 true false 165 135 135 135 90 135 135 165 105 210 90 285 210 285 195 210 165 165 180 165 210 150 165 135
Polygon -8630108 true false 165 135 165 120 165 135
Polygon -1184463 true false 135 120 135 135 165 150 165 105 135 105
Polygon -1184463 true false 135 135 60 105 60 135 135 165
Polygon -1184463 true false 165 135 255 90 255 135 210 150
Polygon -955883 true false 60 45 75 45 75 195 60 195 60 45
Polygon -14835848 true false 60 45 45 30 60 15 75 15 90 30 75 45 60 45

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tower
false
0
Rectangle -7500403 true true 90 255 210 300
Line -16777216 false 75 255 225 255
Rectangle -16777216 false false 90 255 210 300
Polygon -7500403 true true 90 255 105 105 195 105 210 255
Polygon -7500403 false true 90 255 105 105 195 105 210 255
Rectangle -7500403 true true 75 90 120 60
Rectangle -7500403 true true 75 84 225 105
Rectangle -7500403 true true 135 90 165 60
Rectangle -7500403 true true 180 90 225 60
Polygon -7500403 false true 90 105 75 105 75 60 120 60 120 84 135 84 135 60 165 60 165 84 179 84 180 60 225 60 225 105
Rectangle -7500403 true true 75 60 120 90
Rectangle -7500403 true true 135 60 165 90
Rectangle -7500403 true true 180 60 225 90

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

witch
false
0
Circle -8630108 true false 116 56 67
Polygon -5825686 true false 105 90 120 75 180 75 195 90 150 15 105 90
Polygon -8630108 false false 135 120 135 135 90 165 90 180 135 165 105 210 90 285 210 285 195 210 165 165 210 180 210 165 165 135 165 120
Polygon -8630108 true false 165 135 135 135 90 165 90 180 135 165 105 210 90 285 210 285 195 210 165 165 195 180 210 165 165 135
Polygon -8630108 true false 165 135 165 120 165 135
Polygon -8630108 true false 135 120 135 135 165 150 165 105 135 105
Polygon -8630108 true false 135 135 60 180 60 210 135 165
Polygon -8630108 true false 165 135 240 180 240 210 195 180
Polygon -7500403 true true 60 120 75 120 75 270 60 270 60 120
Polygon -6459832 true false 60 135 45 135 30 120 30 75 45 120 45 75 60 105 60 75 75 105 90 75 75 120 90 90 90 120

witch 2
false
0
Circle -8630108 true false 116 56 67
Polygon -5825686 true false 105 90 120 75 180 75 195 90 150 15 105 90
Polygon -8630108 false false 135 120 135 135 90 135 135 165 105 210 90 285 210 285 195 210 165 165 195 135 210 120 165 135 165 120
Polygon -8630108 true false 165 135 135 135 90 135 135 165 105 210 90 285 210 285 195 210 165 165 195 150 225 135 165 135
Polygon -8630108 true false 165 135 165 120 165 135
Polygon -8630108 true false 135 120 135 135 165 150 165 105 135 105
Polygon -8630108 true false 135 135 60 105 60 135 135 165
Polygon -8630108 true false 165 135 240 75 240 120 225 135
Polygon -7500403 true true 45 60 60 60 60 210 45 210 45 60
Polygon -6459832 true false 60 75 45 75 30 60 30 15 45 60 45 15 60 45 60 15 75 45 90 15 75 60 90 30 90 60

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
