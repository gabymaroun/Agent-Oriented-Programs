; exemple des robots fourrageurs
; auteur : Eric Gouardères, 2020

; This model was inspired from Ants Model of Uri Wilensky
; see the copyright notice below.

globals [

  couleur-vaisseau         ;; couleur des patchs vaisseau
  couleur-minerai          ;; couleur des patchs source de minerai
  couleur-label-minerai-1  ;; couleur label source minerai 1
  couleur-label-minerai-2  ;; couleur label source minerai 2
  couleur-label-minerai-3  ;; couleur label source minerai 3
  couleur-obstacle         ;; couleur des patchs obstacles
  couleur-marque           ;; base couleur des patchs avec marque
  couleur-robot-vide       ;; couleur robot qui ne porte pas de minerai
  couleur-robot-plein      ;; couleur robot portant du minerai
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Propriétés des agents                                           ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


patches-own [
  vaisseau?
  signal
  minerai
  obstacle?
  marque
]

turtles-own [
  Alerte_batterie
  Porte_echantillon?
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup procedures                                                ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  setup-colors
  setup-turtles
  setup-patches
  reset-ticks
end

to setup-colors
  set couleur-vaisseau violet
  set couleur-minerai yellow
  set couleur-label-minerai-1 red
  set couleur-label-minerai-2 lime
  set couleur-label-minerai-3 brown
  set couleur-obstacle grey
  set couleur-marque green
  set couleur-robot-vide red
  set couleur-robot-plein couleur-minerai
end

to setup-turtles
  crt population
  [ set shape "robot"
    set size 3                        ;; plus facile à voir
    set Alerte_batterie 100
    set color couleur-robot-vide  ]
end

to setup-patches
  ask patches
  [ setup-vaisseau
    setup-minerai
    setup-obstacles
    recolor-patch ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; initialisation des patchs - Patch procedures  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-vaisseau
  ;; initialisation de la variable vaisseau? pour les patchs vaisseau
  set vaisseau? (distancexy 0 0) < 5
  ;; diffusion du signal -- plus fort près du vaisseau
  set signal 200 - distancexy 0 0
end

to setup-minerai
  set minerai 0
  ;; initialisation de la source 1 de minerai sur la droite, valeur 1 ou 2 aléatoire
  if source-minerai-1
  [set minerai one-of [1 2] ]
  ;;initialisation de la source 2 de minerai en bas à gauche
  if source-minerai-2
  [ set minerai one-of [1 2] ]
  ;; initialisation de la source 3 de minerai en haut à gauche
  if source-minerai-3
  [ set minerai one-of [1 2] ]
end

to setup-obstacles
  ;; initialisation obstacle bas gauche
  set obstacle? false
  if ((distancexy (-0.3 * max-pxcor) (-0.3 * max-pycor)) < 3) or ((distancexy (-0.2 * max-pxcor) (-0.3 * max-pycor)) < 3) or ((distancexy (-0.4 * max-pxcor) (-0.3 * max-pycor)) < 3)
  [ set obstacle? true
    set signal signal * 0.8 ] ;; perte de 20 % du signal sur obstacle
  ;;initialisation obstacle haut droit
  if ((distancexy (-0.3 * max-pxcor) (0.5 * max-pycor)) < 3) or ((distancexy (-0.2 * max-pxcor) (0.6 * max-pycor)) < 3) or ((distancexy (-0.1 * max-pxcor) (0.7 * max-pycor)) < 3)
  [ set obstacle? true
    set signal signal * 0.8 ] ;; perte de 20 % du signal sur obstacle
end

to recolor-patch
  ;; colorer les patchs
  ifelse vaisseau?
  [ set pcolor couleur-vaisseau]
  [ifelse obstacle?
    [set pcolor couleur-obstacle ]
    [ifelse minerai > 0
      [ set pcolor couleur-minerai ]
      ;;dégradé de couleur de base pour représenter la concentration de marque
      [ set pcolor scale-color couleur-marque marque 0.1 5 ] ]]

end

to-report source-minerai-1
    if (pxcor = 0.6 * max-pxcor + 2) and (pycor = 0)
    [set plabel-color couleur-label-minerai-1
      set plabel "Source1"]
    report (distancexy (0.6 * max-pxcor) 0) < 5
end

to-report source-minerai-2
    if (pxcor = -0.6 * max-pxcor + 2) and (pycor = -0.6 * max-pycor)
    [set plabel-color couleur-label-minerai-2
      set plabel "Source2"]
    report (distancexy (-0.6 * max-pxcor) (-0.6 * max-pycor)) < 5
end

to-report source-minerai-3
    if (pxcor = -0.8 * max-pxcor + 2) and (pycor = 0.8 * max-pycor)
    [set plabel-color couleur-label-minerai-3
    set plabel "Source3"]
  report (distancexy (-0.8 * max-pxcor) (0.8 * max-pycor)) < 5
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Go procedures                                                                     ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to go
  ask turtles [
    Subsomption
  ]
  ifelse (coordination?)[
    diffuse marque (taux-diffusion / 100)
    ask patches [
      set marque marque * (100 - taux-evaporation) / 100
      recolor-patch
    ]
  ]
  [
    ask patches [
      set marque 0
      recolor-patch
    ]
  ]
  plot_minerai
  tick
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Subsomption - turtles procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to Subsomption
  ifelse Eviter
  [
    stop
  ]
  [
    ifelse Retourner
    [
      stop
    ]
    [ifelse Deposer
      [stop]
      [ifelse Rapporter
        [stop]
        [ifelse Ramasser
          [stop]
          [ifelse SuivreMarques
            [stop]
            [Explorer]
          ]
        ]
      ]
    ]
  ]
end
;***A COMPLETER

;;; Règles de comportement
;;; ----------------------

to Explorer
  if TRUE
  [Deplacement_aleatoire]
end

to-report SuivreMarques

  let condition? (coordination? and Percept_marque)
  if condition?
  [ Aller_vers_marque ]
  report condition?
end

to-report Rapporter
  let Rapporter? (not Vaisseau? and color = couleur-robot-plein)
  if Rapporter? [
    Aller_vers_signal
    if Coordination?
    [
      Deposer_marque
    ]
  ]
  report Rapporter?
end

to-report Ramasser
  let Ramasser? (not Vaisseau? and Percept_echantillon)
  if Ramasser? [
    Prendre_echantillon
    if Coordination?
    [
      Deposer_marque
    ]
  ]
  report Ramasser?
end

to-report Deposer
  let Deposer? ( Vaisseau? and color = couleur-robot-plein)
  if Deposer? [
    deposer_echantillon
    set Alerte_batterie 100
  ]
  report Deposer?
end
;mais si il passe sur le vaisseau sans rien il ne recharge pas, mais on a retourner pour les prblm

to-report Eviter
  if Percept_obstacle [
    Changer_direction
  ]
  report Percept_obstacle
end

to-report Retourner
  if (Alerte_batterie < 7) [
    Aller_vers_signal
  ]
  if (Vaisseau?) [
    set Alerte_batterie 100
  ]
  report (Alerte_batterie < 7)
end
;***A COMPLETER

;;; Percepts
;;; --------
to-report Percept_obstacle
  report (obstacle?)
end

to-report Percept_echantillon
  report (minerai > 0)
end

to-report Percept_dans_vaisseau
  report vaisseau?
end

to-report Percept_marque
  report (marque >= 0.05)
end
;***A COMPLETER

;;; Actions
;;; -------
to Aller_vers_marque
  uphill-marque
  avancer
end

to Aller_vers_signal
  uphill-signal
  avancer
end

to Prendre_echantillon
  set color couleur-robot-plein
  set minerai minerai - 1
  rt 180
end

to Deposer_echantillon
  set color couleur-robot-vide
  rt 180
end

to Deposer_marque
  set marque marque + 60
end

to Deplacement_aleatoire
  ifelse (not [obstacle?] of patch-ahead 4)
  [
    fd 1
    rt random 10
    lt random 10
    set Alerte_batterie Alerte_batterie - 0.1
  ]
  [changer_direction]
end

to Changer_direction

    rt 90
    fd 1
    set Alerte_batterie Alerte_batterie - 0.1

end

to avancer
  ifelse (not [obstacle?] of patch-ahead 4)
  [
    fd 1
    set Alerte_batterie Alerte_batterie - 0.1
  ]
  [changer_direction]
end

to uphill-marque
;; tester patchs devant et sur les côtés pour s'orienter vers la concentration de marque la plus forte
  let scent-ahead marque-at-angle   0                                                           ;; devant
  let scent-right marque-at-angle  45                                                           ;; à droite 45
  let scent-left marque-at-angle  -45                                                           ;; à gauche 45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead)
  [ ifelse scent-right > scent-left
    [ rt 45 ]
    [ lt 45 ] ]
   sens-suivi-marque
end

to uphill-signal
;; tester patchs devant et sur les côtés pour s'orienter vers le signal le plus fort
  let scent-ahead signal-at-angle   0                                                           ;; devant
  let scent-right max (list (signal-at-angle  45) (signal-at-angle 60) (signal-at-angle 90))    ;; à droite 45, 60 et 90 degrés
  let scent-left  max (list (signal-at-angle  -45) (signal-at-angle -60) (signal-at-angle -90)) ;; à gauche 45, 60 et 90 degrés
  if (scent-right > scent-ahead) or (scent-left > scent-ahead)
  [ ifelse scent-right > scent-left
    [ rt 45 ]
    [ lt 45 ] ]
end

to sens-suivi-marque
;; détermine la direction de suivi d'une marque (vers la source de minerai)
;; tester patchs devant et sur les côtés pour s'orienter vers le signal le moins fort
  let scent-ahead signal-at-angle   0
  if scent-ahead > signal
  [
  let scent-right signal-at-angle  45
  let scent-left signal-at-angle  -45
  ifelse scent-right > signal
  [lt 45]
  [rt 45]]
end

to-report signal-at-angle [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]
  report [signal] of p
end


to-report marque-at-angle [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]
  report [marque] of p
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Plotting procedures                                                               ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to plot_minerai
 set-current-plot-pen "minerai-1" plotxy ticks sum [minerai] of patches with [source-minerai-1]
 set-current-plot-pen "minerai-2" plotxy ticks sum [minerai] of patches with [source-minerai-2]
 set-current-plot-pen "minerai-3" plotxy ticks sum [minerai] of patches with [source-minerai-3]

 ifelse trace?
  [
    set-current-plot-pen "minerai-1" plot-pen-down
    set-current-plot-pen "minerai-2" plot-pen-down
    set-current-plot-pen "minerai-3" plot-pen-down
  ]
  [
    set-current-plot-pen "minerai-1" plot-pen-up
    set-current-plot-pen "minerai-2" plot-pen-up
    set-current-plot-pen "minerai-3" plot-pen-up
  ]

end

;***A COMPLETER

; *** NetLogo 4.0 Model Copyright Notice ***
;
; This model was created as part of the project: CONNECTED MATHEMATICS:
; MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL
; MODELS (OBPML).  The project gratefully acknowledges the support of the
; National Science Foundation (Applications of Advanced Technologies
; Program) -- grant numbers RED #9552950 and REC #9632612.
;
; Copyright 1998 by Uri Wilensky.  All rights reserved.
;
; Permission to use, modify or redistribute this model is hereby granted,
; provided that both of the following requirements are followed:
; a) this copyright notice is included.
; b) this model will not be redistributed for profit without permission
;    from Uri Wilensky.
; Contact Uri Wilensky for appropriate licenses for redistribution for
; profit.
;
; This model was converted to NetLogo as part of the projects:
; PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING
; IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT.
; The project gratefully acknowledges the support of the
; National Science Foundation (REPP & ROLE programs) --
; grant numbers REC #9814682 and REC-0126227.
; Converted from StarLogoT to NetLogo, 1998.
;
; To refer to this model in academic publications, please use:
; Wilensky, U. (1998).  NetLogo Ants model.
; http://ccl.northwestern.edu/netlogo/models/Ants.
; Center for Connected Learning and Computer-Based Modeling,
; Northwestern University, Evanston, IL.
;
; In other publications, please use:
; Copyright 1998 Uri Wilensky.  All rights reserved.
; See http://ccl.northwestern.edu/netlogo/models/Ants
; for terms of use.
;
; *** End of NetLogo 4.0 Model Copyright Notice ***
@#$#@#$#@
GRAPHICS-WINDOW
653
10
1158
516
-1
-1
7.0
1
10
1
1
1
0
1
1
1
-35
35
-35
35
0
0
1
ticks
30.0

BUTTON
75
81
148
114
NIL
setup
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
196
81
266
114
NIL
Go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
79
18
270
51
population
population
0
200
113.0
1
1
NIL
HORIZONTAL

SWITCH
77
142
270
175
coordination?
coordination?
0
1
-1000

SLIDER
76
186
271
219
taux-diffusion
taux-diffusion
0
100
50.0
1
1
%
HORIZONTAL

SLIDER
75
229
271
262
taux-evaporation
taux-evaporation
0
100
100.0
1
1
%
HORIZONTAL

PLOT
295
17
555
222
Quantité minerai par source
Time
minerai
0.0
10.0
0.0
2.2
true
true
"" ""
PENS
"minerai-1" 1.0 0 -5298144 true "" ""
"minerai-2" 1.0 0 -14439633 true "" ""
"minerai-3" 1.0 0 -8431303 true "" ""

SWITCH
295
231
556
264
trace?
trace?
0
1
-1000

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

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

robot
true
0
Rectangle -16777216 true false 180 150 195 180
Rectangle -16777216 true false 180 195 195 225
Rectangle -16777216 true false 105 150 120 180
Rectangle -16777216 true false 105 195 120 225
Rectangle -7500403 true true 120 90 180 210
Rectangle -7500403 true true 30 90 30 105
Rectangle -7500403 true true 45 105 45 135
Rectangle -16777216 true false 180 105 195 135
Rectangle -16777216 true false 105 105 120 135
Rectangle -7500403 false true 105 105 120 135
Rectangle -7500403 false true 180 105 195 135
Rectangle -7500403 false true 105 150 120 180
Rectangle -7500403 false true 180 150 195 180
Rectangle -7500403 false true 105 195 120 225
Rectangle -7500403 false true 180 195 195 225
Rectangle -16777216 true false 135 120 165 195
Circle -7500403 true true 129 69 42
Polygon -7500403 true true 135 60 120 90 165 60 180 90
Circle -7500403 true true 135 195 30

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
