;; Alien Trouble "Graduado Asesino"

extensions [sound]

;; The breeds used in the game
breed [ birds bird ]
breed [ clouds cloud ]
breed [ circles circle ]
breed [ people person ]
breed [ shells shell ]
breed [ tiles tile ]

globals [
  action            ;; Action depending on the key pressed
  quantity-ufo      ;; Quantity of UFOs in real time
  time-left         ;; Time remaining
  dead?             ;; True when no lives are left - used to stop the game
  lives             ;; Remaining lives
  x-vel
  y-vel
  velocity
  points            ;; Points accumulated in the game
]

turtles-own [
  speed            ;; The 'time' variable will be initialized to the value of 'speed' after the turtle moves
  time             ;; This keeps track of how many time loops have occurred since the turtle last moved.
]

;; ============================================= INITIAL SETUP =============================================

;; Procedure for the initial setup of game
to setup
  clear-all
  set action 0
  set points 0
  set dead? false
  set lives start-lives
  set time-left start-time
  set-default-shape shells "book"
  set-default-shape clouds "cloud"
  set-default-shape tiles "tile stones"

  draw-background

  set quantity-ufo random max-quantity-ufo + 1

  create-circles quantity-ufo
   [ randomize ]

  create-people 1 [
    set shape "person graduate"
    set color red
    set size 3
    setxy (max-pxcor / 2)
           (- max-pycor + 0.5 + size / 2 )
    set heading 0
  ]

  reset-ticks
end

;; ============================================= DRAW ELEMENTS =============================================

;; Procedure to draw the background of the game
to draw-background
  ask patches [
     set pcolor 97
  ]
  ask patches with [ pycor < 2 ]
    [ set pcolor black ]

  ;; Creation of clouds
  create-cloud max-pxcor - 5 max-pycor - 2
  create-cloud max-pxcor - 20 max-pycor - 3
  create-cloud max-pxcor - 15 max-pycor - 4
  create-cloud max-pxcor - 30 max-pycor - 3
  create-cloud 0 + 5  max-pycor - 4
  create-cloud 0 + 10  max-pycor - 2

  ;; Creation of birds
  create-bird 20 max-pycor - 6 270 .9
  create-bird 5 max-pycor - 7 270 .9
  create-bird max-pxcor - 15 max-pycor - 6 270 .8
  create-bird max-pxcor - 5 max-pycor - 8 270 .8

  setup-tiles

end

;; Procedure that creates clouds
to create-cloud [x y]
    create-clouds 1 [
    set shape "cloud"
    set color white
    set size 3 + random(5)
    setxy x y
    set heading 90
  ]
end

;; Procedure that creates birds
to create-bird [ x y direction quickness ]   ;; Creates and initializes a bird
  let bird-color yellow
  ask patches with [(pxcor = x or pxcor = (x + 1)) and pycor = y]
    [ sprout-birds 1
        [ set color bird-color
          set heading direction
          set speed quickness
          set time speed
          set size 2
          ;set shape "bird side"
          if ((pxcor = x) xor (direction = 90))
            [ set shape "bird side" ]
        ]
    ]
end

;; Procedure that draws the tiles
to setup-tiles
  set-default-shape tiles "tile stones"
  ask patches with [pycor < 2 ]
    [ sprout-tiles 1 ]
end

;; ============================================= GO =============================================
to go
  ;tick
  ask circles [
      bounce
      fd 0.0001
  ]
  move-person
  move-bird

  every 0.05
  [
    ask shells
    [
      setxy (xcor + x-vel) (ycor + y-vel)
      set velocity sqrt (( x-vel ^ 2 ) + (y-vel ^ 2))
      if (velocity > 1)
      [
        set x-vel x-vel / velocity
        set y-vel y-vel / velocity
        set velocity 1
      ]
      check-shell
    ]
  ]


  if dead?
    [ stop ]
end

;; ============================================= BIRDS =============================================
;; Procedure that moves the birds
to move-bird
  ask birds [
      ifelse shape = "bird side"
       [ set shape "bird side2" ]
       [ set shape "bird side" ]
      fd 0.0001
  ]
end
;; ============================================= SHELLS =============================================
;; Procedure that checks the shell which are the books
to check-shell
  if ( pycor = max-pycor and hidden? = false )
       [die]
     if (any? circles-here) [
        ask circles-here [
         if size != 1
           [
             hatch-circles 2 [
               set shape "ufo side"
               set size size - 1
               setxy size * 2 + random (max-pxcor * 3 / 4) size * 2 + 5 + random (max-pycor * 1 / 2)
               set quantity-ufo quantity-ufo + 1
             ]

            sound:play-note "Applause" 60 64 2
            ]
              die
         ]
         set points (points + 10)
         set quantity-ufo quantity-ufo - 1
         win
         die
       ]

      if (any? birds-here)
       [
         sound:play-note "Bird Tweet" 60 64 2
         set points (points - 5)
         die
      ]
    set pcolor 97
end


;; Procedure that lets the character shoot books
to shoot
  ask people
    [
      hatch-shells 1
      [
        set size 1
        set x-vel ( sin 0 * ( 80 / 100 ))
        set y-vel ( cos 0 * ( 80 / 100 ))
        set velocity 80 / 100
      ]
      sound:play-note "Gunshot" 60 64 1
    ]
end

;; ============================================= PERSON =============================================
;; Procedure that checks which keys are pressed
to move-person
  if (action != 0)
    [ if (action = 1)
        [ move-left ]
      if (action = 2)
        [ move-right ]
      set action 0
    ]

  every 0.1
  [ ask turtles
        [ decrement-time ]
      check-person
    ]
end

;; Procedure that lets the character move to the left
to move-left
  ask people with [xcor != min-pxcor]
    [ set heading 270
      if xcor > min-pxcor + size / 2[
         fd 1
      ]
    ]
  check-person
end

;; Procedure that lets the character move to the right
to move-right
  ask people with [xcor != max-pxcor]
    [ set heading 90
      if xcor < max-pxcor - size / 2[
        fd 1
      ]
    ]
  check-person
end

;; Procedure that checks the person
to check-person
  ask people
    [
      if (any? circles-here or (time-left < 0))
        [ kill-person ]
       ask circles-here [
        die
      ]
    ]
end

;; Procedure that kills the persona and shows the user messages
to kill-person        ;; This is called when the person dies, checks if the game is over
  set lives (lives - 1)
  ifelse (lives = 0)
    [ user-message "You lost a life!\nYou have no more lives!\nGAME OVER!"
      set dead? true
      die
    ][
    ifelse time-left <= 0
     [ user-message (word "Your time is up!\nYou have " lives " lives left.")
      reset-person
     ]
    [ user-message (word "A UFO took you!\nYou have " lives " lives left.")
      reset-person
    ]
  ]
end

;; Procedure that resets the person
to reset-person
  setxy (max-pxcor / 2)
        (- max-pycor + 0.5 + size / 2 )
  set heading 0
  set time-left start-time
end

;; ============================================= UFOs =============================================
;; Procedure that creates the UFOs in a randomized way
to randomize
  set shape "ufo side"
  setxy size * 2 + random (max-pxcor * 3 / 4) size * 2 + 5 + random (max-pycor * 2 / 3)
  set size random max-ufo-size + 1
  set color one-of base-colors
end

;; Procedure that imitates a bouncing effect for the UFOs
to bounce
  if [pxcor] of patch-ahead 0.1 >= max-pxcor - size / 2 or [pxcor] of patch-ahead 0.1 < 0 + size / 2
    [set heading (- heading)]
  if [pycor] of patch-ahead 0.1 >= max-pycor - size / 2 or [pycor] of patch-ahead 0.1 < 2 + size / 2
    [set heading (180 - heading)]

end

;; ============================================= GAME =============================================
to win
  if quantity-ufo = 0  [
     user-message (word "You won with " points " points! \n Press New Game to Play again!")
     reset-person
     set action 0
     set points 0
     set dead? false
     set lives start-lives
     set time-left start-time
  ]
end

;; Procedure that decrements time
to decrement-time
  ifelse (breed = circles)
    [ set time-left precision (time-left - 0.1) 1 ]
    [ set time precision (time - 0.1) 1 ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
23
870
454
-1
-1
12.8
1
10
1
1
1
0
1
1
1
0
50
0
32
0
0
1
ticks
30.0

BUTTON
19
26
98
59
New Game
setup
NIL
1
T
OBSERVER
NIL
N
NIL
NIL
1

BUTTON
112
26
187
60
Start
go
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
100
402
167
435
RIGHT
set action 2
NIL
1
T
OBSERVER
NIL
D
NIL
NIL
1

BUTTON
33
402
96
435
LEFT
set action 1
NIL
1
T
OBSERVER
NIL
A
NIL
NIL
1

BUTTON
64
364
136
397
SHOOT
shoot
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

SLIDER
19
75
191
108
max-ufo-size
max-ufo-size
1
10
7.0
1
1
NIL
HORIZONTAL

SLIDER
18
122
190
155
max-quantity-ufo
max-quantity-ufo
1
10
3.0
1
1
NIL
HORIZONTAL

SLIDER
17
205
189
238
start-lives
start-lives
1
10
5.0
1
1
NIL
HORIZONTAL

MONITOR
36
260
93
305
UFO
quantity-ufo
17
1
11

MONITOR
92
260
156
305
Time Left
time-left
17
1
11

SLIDER
17
164
189
197
start-time
start-time
1
240
120.0
1
1
NIL
HORIZONTAL

MONITOR
92
304
156
349
Lives Left
lives
17
1
11

MONITOR
35
304
92
349
Points
points
17
1
11

@#$#@#$#@
## WHAT IS IT?


The model is based on the game Bubble Trouble. The object of the game is to eliminate all the UFOs within the time frame given. 

## HOW IT WORKS

The game starts with a random number of UFOs in the sky, as well as birds. The graduated person is the main character which can be moved to the right or left. You may eliminate the UFOs by throwing books at them which will give you points, the UFOs will duplicate if their size is not the minimum size. On the other hand you must avoid hitting birds because points will be taken away if you hit them. 

The character will die by getting hit by UFOs or by having no time left. On the contrary you will win if you eliminate all the UFOs. 

## HOW TO USE IT

Buttons

- NEW-GAME resets the game
- START starts the game
- The direction buttons (LEFT, RIGHT) will move your person in that direction

Monitors

- UFO tells you how many remaining UFOs are left 
- TIME LEFT shows you how much time remains
- POINTS tells you how many points you have
- LIVES LEFT tells you how many remaining lives you have

Sliders 

- MAX-UFO-SIZE sets the maximum size that a UFO may have
- MAX-QUANTITY-UFO sets the maximum quantity of the UFO that may appear
- START-TIME sets how much time you start out with
- START-LIVES will determine how many lives you start with

Cast of characters 

- Graduated person: This is you 
- UFOs: Avoid at all costs. You would want to eliminate these
- Birds: You would want to avoid these
- Books: These are the things that will be thrown to the UFOs. 


## THINGS TO NOTICE

Determine how many hits can a UFO take before it disappears. 


## THINGS TO TRY

See if you can win with the maximum amount of UFOs

See if you can win with the maximum size of UFOs 

Try to make as few mistakes as possible by not shooting the birds. 

## EXTENDING THE MODEL

Add some bonuses or additional hazards. 


## NETLOGO FEATURES

This model uses breeds to implement the different moving game pieces.

The `user-message` command presents messages to the user.

## RELATED MODELS

- Projectile Attack
- Frogger 

## CREDITS AND REFERENCES

The models used as a reference in this models are: 

- Projectile Attack
- Lunar Lander 
- Frogger 
- Firework 

This game is made by Rachelle Nerie Reyes Udasco for Simulation subject
UABC 2019-2
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

balloon
false
0
Circle -7500403 true true 45 0 210
Polygon -7500403 true true 150 210 120 240 150 240 180 240 150 210
Line -16777216 false 150 240 150 300

bird side
false
0
Polygon -7500403 true true 0 120 45 90 75 90 105 120 150 120 240 135 285 120 285 135 300 150 240 150 195 165 255 195 210 195 150 210 90 195 60 180 45 135
Circle -16777216 true false 38 98 14

bird side2
false
0
Polygon -7500403 true true 0 120 45 90 75 90 105 120 150 120 240 135 240 105 270 120 300 135 240 150 195 165 255 165 210 195 150 210 90 195 60 180 45 135
Circle -16777216 true false 38 98 14

bird side3
false
0
Polygon -7500403 true true 0 120 45 90 75 90 105 120 150 120 240 135 285 120 285 135 300 150 240 150 195 165 255 195 210 195 150 210 90 195 60 180 45 135
Circle -16777216 true false 38 98 14

book
false
0
Polygon -7500403 true true 30 195 150 255 270 135 150 75
Polygon -7500403 true true 30 135 150 195 270 75 150 15
Polygon -7500403 true true 30 135 30 195 90 150
Polygon -1 true false 39 139 39 184 151 239 156 199
Polygon -1 true false 151 239 254 135 254 90 151 197
Line -7500403 true 150 196 150 247
Line -7500403 true 43 159 138 207
Line -7500403 true 43 174 138 222
Line -7500403 true 153 206 248 113
Line -7500403 true 153 221 248 128
Polygon -1 true false 159 52 144 67 204 97 219 82

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

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cloud
false
0
Circle -7500403 true true 13 118 94
Circle -7500403 true true 86 101 127
Circle -7500403 true true 51 51 108
Circle -7500403 true true 118 43 95
Circle -7500403 true true 158 68 134

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

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

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

person graduate
false
11
Circle -16777216 false false 39 183 20
Polygon -1 true false 50 203 85 213 118 227 119 207 89 204 52 185
Circle -7500403 true false 110 5 80
Rectangle -7500403 true false 127 79 172 94
Polygon -8630108 true true 90 19 150 37 210 19 195 4 105 4
Polygon -8630108 true true 120 90 105 90 60 195 90 210 120 165 90 285 105 300 195 300 210 285 180 165 210 210 240 195 195 90
Polygon -1184463 true false 135 90 120 90 150 135 180 90 165 90 150 105
Line -2674135 false 195 90 150 135
Line -2674135 false 105 90 150 135
Polygon -1 true false 135 90 150 105 165 90
Circle -1 true false 104 205 20
Circle -1 true false 41 184 20
Circle -16777216 false false 106 206 18
Line -2674135 false 208 22 208 57

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

tile brick
false
0
Rectangle -1 true false 0 0 300 300
Rectangle -7500403 true true 15 225 150 285
Rectangle -7500403 true true 165 225 300 285
Rectangle -7500403 true true 75 150 210 210
Rectangle -7500403 true true 0 150 60 210
Rectangle -7500403 true true 225 150 300 210
Rectangle -7500403 true true 165 75 300 135
Rectangle -7500403 true true 15 75 150 135
Rectangle -7500403 true true 0 0 60 60
Rectangle -7500403 true true 225 0 300 60
Rectangle -7500403 true true 75 0 210 60

tile stones
false
0
Polygon -6459832 true false 0 240 45 195 75 180 90 165 90 135 45 120 0 135
Polygon -6459832 true false 300 240 285 210 270 180 270 150 300 135 300 225
Polygon -6459832 true false 225 300 240 270 270 255 285 255 300 285 300 300
Polygon -6459832 true false 0 285 30 300 0 300
Polygon -6459832 true false 225 0 210 15 210 30 255 60 285 45 300 30 300 0
Polygon -6459832 true false 0 30 30 0 0 0
Polygon -6459832 true false 15 30 75 0 180 0 195 30 225 60 210 90 135 60 45 60
Polygon -6459832 true false 0 105 30 105 75 120 105 105 90 75 45 75 0 60
Polygon -6459832 true false 300 60 240 75 255 105 285 120 300 105
Polygon -6459832 true false 120 75 120 105 105 135 105 165 165 150 240 150 255 135 240 105 210 105 180 90 150 75
Polygon -6459832 true false 75 300 135 285 195 300
Polygon -6459832 true false 30 285 75 285 120 270 150 270 150 210 90 195 60 210 15 255
Polygon -6459832 true false 180 285 240 255 255 225 255 195 240 165 195 165 150 165 135 195 165 210 165 255

tree
false
7
Circle -10899396 true false 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -10899396 true false 65 21 108
Circle -10899396 true false 116 41 127
Circle -10899396 true false 45 90 120
Circle -10899396 true false 104 74 152

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

ufo side
false
0
Polygon -1 true false 0 150 15 180 60 210 120 225 180 225 240 210 285 180 300 150 300 135 285 120 240 105 195 105 150 105 105 105 60 105 15 120 0 135
Polygon -16777216 false false 105 105 60 105 15 120 0 135 0 150 15 180 60 210 120 225 180 225 240 210 285 180 300 150 300 135 285 120 240 105 210 105
Polygon -7500403 true true 60 131 90 161 135 176 165 176 210 161 240 131 225 101 195 71 150 60 105 71 75 101
Circle -16777216 false false 255 135 30
Circle -16777216 false false 180 180 30
Circle -16777216 false false 90 180 30
Circle -16777216 false false 15 135 30
Circle -7500403 true true 15 135 30
Circle -7500403 true true 90 180 30
Circle -7500403 true true 180 180 30
Circle -7500403 true true 255 135 30
Polygon -16777216 false false 150 59 105 70 75 100 60 130 90 160 135 175 165 175 210 160 240 130 225 100 195 70

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
NetLogo 6.1.1
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
