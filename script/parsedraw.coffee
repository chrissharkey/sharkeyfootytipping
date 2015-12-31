fs = require 'fs'
mysql = require '../lib/mysql'
teams = ['Knights', 'Eels', 'Bulldogs', 'Tigers', 'Panthers', 'Broncos', 'Storm', 'Raiders', 'Roosters', 'Rabbitohs', 'Dragons', 'Warriors', 'Sharks', 'Titans', 'SeaEagles', 'Cowboys']
daysOfWeek = ['Monday,', 'Tuesday,', 'Wednesday,', 'Thursday,', 'Friday,', 'Saturday,', 'Sunday,']
currentRound = null
currentDate = null
currentStadium = null
currentChannel = null
currentTime = null
currentHashtag = null
stadiums = {}
rounds = {}
roundMap: 
  One: 1, Two: 2, Three: 3, Four: 4, Five: 5, Six: 6, Seven: 7, Eight: 8, Nine: 9, Ten: 10, Eleven: 11, Twelve: 12, Thirteen: 13, Fourteen: 14, Fifteen: 15, Sixteen: 16, Seventeen: 17, Eighteen: 18, Nineteen: 19, Twenty: 20
roundLimitReached = false
rawDraw = fs.readFileSync('./script/draw.txt').toString().replace(/Sea Eagles/g, 'SeaEagles').split "\n"
rawDraw.forEach (line) ->
  return if roundLimitReached
  parts = line.split " "
  if parts[0] is 'Round'
    currentRound = line.match(/^Round (.*)/)[1]
  if parts[0] in daysOfWeek
    currentDate = "#{parts[0]} #{parts[1]} #{parts[2]}"
  if parts[0] in teams
  	team1 = parts[0]
  if parts[2] in teams
    team2 = parts[2]
    rest = parts[3..parts.length-1].join ' '
    currentStadium = rest.match(/(.*) \(/)?[1]
    currentChannel = rest.match(/\((.*)\)/)?[1]
    currentTime = rest.match(/\) (.*) /)?[1].split(' ')[0]
    currentHashtag = parts[parts.length-1]
  if currentRound
    roundLimitReached = true if currentRound is 'Twenty'
  team1 = team1?.replace 'SeaEagles', 'Sea Eagles'
  team2 = team2?.replace 'SeaEagles', 'Sea Eagles'
  if team1 and team2
    console.log "#{currentRound} :: #{currentDate} :: #{currentTime} :: #{currentStadium} :: #{currentChannel} :: #{team1} vs #{team2} :: #{currentHashtag}"
