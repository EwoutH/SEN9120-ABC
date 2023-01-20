__includes ["init.nls" "tick.nls"]
extensions [gis rnd table]
globals [parking-dataset residential-dataset grass-dataset houses-dataset station-dataset projection day month year days-in-year]

breed [spots spot]
breed [households household]
breed [residents resident]
breed [cars car]

patches-own [station?]
spots-own [capacity private? household-nr occupancy]
households-own [driveway distance-spot distance-station child-wish]
residents-own [
  household-nr age parent? owns-car? car-nr neighbours-contacts parent-contacts work-destinations other-destinations
  adoption-speed modality-preference initial-modality-preference
]
cars-own [owner shared? age yearly-costs km-costs mileage lease? in-use?]

;; ##### HIGH-LEVEL FUNCTIONS ####

to setup
  clear-all
  load
  draw
  setup-spots
  setup-station
  setup-households
  setup-contacts
  setup-destinations
  ask spots [set label (capacity - occupancy)]
  set days-in-year days-in-month * months-in-year
  reset-ticks
end

to go ;; one year
  repeat months-in-year [
    repeat days-in-month [go-daily]
    go-monthly
  ]
  go-yearly
end

to go-daily
  ;; - Make one or multiple trips
  ;; - Spread info to household
  ;; - Chance of spreading info to connections
  set day day + 1
end

to go-monthly
  ;; - Update destinations (add some and remove some)
  ;; - Pay train or car-sharing fees
  ;; - Consider new subscriptions or canceling ones
  ;; - Consider buying or selling a car
  ;; - Add and remove connections (meet new people and lose contact with)
  set month month + 1
end

to go-yearly
  ask residents [age-resident]
  move-households
  move-out-child
  set year year + 1
  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
288
11
1571
667
-1
-1
19.62
1
12
1
1
1
0
0
0
1
-32
32
-16
16
0
0
1
ticks
60.0

BUTTON
24
103
87
136
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
25
243
99
276
NIL
clear-all
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
111
100
193
145
households
count households
17
1
11

MONITOR
114
153
195
198
public parking
sum [capacity] of spots with [is-number? capacity]
17
1
11

MONITOR
114
204
198
249
private parking
sum [driveway] of households
17
1
11

MONITOR
114
295
171
340
parents
count residents with [parent?]
17
1
11

MONITOR
113
347
174
392
childeren
count residents with [not parent?]
17
1
11

MONITOR
115
431
200
476
total child wish
sum [child-wish] of households
17
1
11

SLIDER
21
709
221
742
initial-car-chance-parent
initial-car-chance-parent
0
100
60.0
1
1
%
HORIZONTAL

MONITOR
37
296
108
341
cars
count cars
17
1
11

SLIDER
22
673
211
706
initial-car-chance-child
initial-car-chance-child
0
100
20.0
1
1
%
HORIZONTAL

MONITOR
200
155
282
200
available spots
sum [capacity] of spots - sum [occupancy] of spots
17
1
11

PLOT
1611
154
1863
304
car age
age
cars
0.0
10.0
0.0
150.0
true
true
"set-plot-pen-interval 1" ""
PENS
"lease" 1.0 1 -5825686 true "" "histogram [age] of cars with [lease?]"
"private" 1.0 1 -13791810 true "" "histogram [age] of cars with [not lease?]"
"total" 1.0 1 -13840069 true "" "histogram [age] of cars"

BUTTON
66
173
121
206
NIL
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
6
170
61
203
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
1604
10
1862
143
resident age distribution
age
residents
0.0
65.0
0.0
300.0
true
false
"" ""
PENS
"total" 5.0 1 -13840069 true "" "histogram [age] of residents"

SLIDER
24
852
196
885
days-in-month
days-in-month
2
31
5.0
1
1
NIL
HORIZONTAL

SLIDER
24
888
196
921
months-in-year
months-in-year
2
12
3.0
1
1
NIL
HORIZONTAL

MONITOR
206
853
286
898
days in year
days-in-year
17
1
11

MONITOR
9
10
66
55
NIL
day
17
1
11

MONITOR
70
10
127
55
NIL
month
17
1
11

MONITOR
132
10
189
55
NIL
year
17
1
11

SLIDER
21
760
250
793
chance-of-household-moving
chance-of-household-moving
0
25
10.0
1
1
%
HORIZONTAL

SLIDER
391
717
559
750
mean-distance-work
mean-distance-work
0
100
22.0
1
1
km
HORIZONTAL

SLIDER
394
759
560
792
mean-distance-other
mean-distance-other
0
100
11.0
1
1
km
HORIZONTAL

SLIDER
565
717
758
750
variance-distance-work
variance-distance-work
0
400
220.0
1
1
NIL
HORIZONTAL

SLIDER
831
716
1009
749
mean-weekly-work-trips
mean-weekly-work-trips
2
6
4.0
0.1
1
NIL
HORIZONTAL

TEXTBOX
395
695
622
723
Distances: Gamma distribution parameters
11
0.0
1

TEXTBOX
832
696
1085
724
Frequencies: Poisson distribution parameters
11
0.0
1

SLIDER
830
754
1018
787
mean-weekly-other-trips
mean-weekly-other-trips
0
10
6.0
0.1
1
NIL
HORIZONTAL

SLIDER
17
566
214
599
average-neighbour-contacts
average-neighbour-contacts
0
25
5.0
1
1
NIL
HORIZONTAL

SLIDER
18
607
247
640
average-parent-contacts-per-child
average-parent-contacts-per-child
0
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
22
795
203
828
chance-of-moving-out
chance-of-moving-out
5
25
15.0
1
1
%
HORIZONTAL

SLIDER
570
758
754
791
variance-distance-other
variance-distance-other
0
200
110.0
1
1
NIL
HORIZONTAL

SLIDER
390
842
582
875
shared-car-costs-per-km
shared-car-costs-per-km
0.05
0.8
0.3
0.01
1
€
HORIZONTAL

SLIDER
586
843
806
876
shared-car-costs-per-hour
shared-car-costs-per-hour
1
10
3.25
0.25
1
€
HORIZONTAL

SLIDER
833
837
1005
870
work-trip-length
work-trip-length
1
12
8.0
1
1
hour
HORIZONTAL

SLIDER
834
874
1007
907
other-trip-length
other-trip-length
0.5
6
2.5
0.25
1
hour
HORIZONTAL

SLIDER
388
881
581
914
car-costs-per-km
car-costs-per-km
0
0.3
0.23
0.01
1
€
HORIZONTAL

SLIDER
586
882
772
915
car-monthly-costs
car-monthly-costs
0
500
257.0
1
1
€
HORIZONTAL

SLIDER
389
944
583
977
public-transport-fixed-costs
public-transport-fixed-costs
0
3
0.89
0.01
1
€
HORIZONTAL

SLIDER
590
944
792
977
public-transport-costs-per-km
public-transport-costs-per-km
0
0.50
0.17
0.01
1
€
HORIZONTAL

TEXTBOX
397
820
547
838
Costs
11
0.0
1

TEXTBOX
837
819
987
837
Trip duration
11
0.0
1

TEXTBOX
396
1018
546
1036
Travel speed
11
0.0
1

SLIDER
396
1039
568
1072
mean-car-speed
mean-car-speed
0
100
46.3
1
1
km/h
HORIZONTAL

SLIDER
805
1037
986
1070
mean-bike-speed
mean-bike-speed
0
45
11.8
0.1
1
km/h
HORIZONTAL

SLIDER
577
1038
797
1071
mean-public-transport-speed
mean-public-transport-speed
0
100
34.8
0.1
1
km/h
HORIZONTAL

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
NetLogo 6.3.0
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
