# #!/usr/bin/env ruby
# 
# colors = {
#   Red: "#f00-#c00",
#   Green: "#0a0-#080",
#   Yellow: "#ff0-#dd0",
# }
# 
# basename = "TableViewCell"
# height = 45
# 
# colors.each_pair do |name, color|
#   `convert -size 1x#{height} gradient:#{color} #{basename}-#{name}Gradient.png`
#   `convert -size 1x#{height*2} gradient:#{color} #{basename}-#{name}Gradient@2x.png`
# end

colors = %w(red green yellow)

task :make_markers do
  `cp ~/desktop/marker.001.png artefacts/images/pin-red.v4.png`
  `cp ~/desktop/marker.002.png artefacts/images/pin-yellow.v4.png`
  `cp ~/desktop/marker.003.png artefacts/images/pin-green.v4.png`
  
  colors.each do |color|
    source = "artefacts/images/pin-#{color}.v4.png"
    `convert #{source} -fuzz 15% -transparent "rgb(213, 250, 128)" #{source}`
    `convert #{source} -background transparent -gravity north -extent 200x400 #{source}`
    `convert #{source} -resize 40x80 data/images/pin.v4-#{color}.png`
    `convert #{source} -resize 80x160 data/images/pin.v4-#{color}@2x.png`
  end 
end
