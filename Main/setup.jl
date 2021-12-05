using Test,HTTP, GoogleSheetsCSVExporter, CSV, Tables, Plots, Dates




url = "https://docs.google.com/spreadsheets/d/1EcKmJZ3xaPIjMmq-O8zaJPhoTqPUbAnKDMP13IecAY4/edit#gid=205549855"
table = GoogleSheetsCSVExporter.fromURI(url) |> CSV.File |> Tables.matrix
current_players = table[:,1] .!= "New Player"

names = table[current_players,1]
profits = table[current_players,2:2]' |> Matrix{Float64}
debts = zeros()
CSV.write("data/debts",profits |> Tables.table, header = names)
CSV.write("data/current_debts",profits |> Tables.table, header = names)

bar(names, profits', labels = false)
plot!(size = (1000,400))



history = Matrix{Any}(undef, 1, size(profits)[2] + 1)
history[1] = today()
history[:,2:end] .= profits
CSV.write("data/history",history |> Tables.table, header = vcat("Date", names))



url = "https://docs.google.com/spreadsheets/d/1EcKmJZ3xaPIjMmq-O8zaJPhoTqPUbAnKDMP13IecAY4/edit#gid=2017283520"
table = GoogleSheetsCSVExporter.fromURI(url) |> CSV.File |> Tables.matrix

table[ismissing.(table)] .= 0

names = ["Date Logged","Antonio","Michael ","Nathan","Oliver","George ","Lachlan","Div ","Braden","Connor","Jack","Amy"]


history = Matrix{Any}(undef, size(table)[1], size(table)[2] + 1)

history[:, 2:end] = table
history[:,1] .= today()


CSV.write("data/history",history |> Tables.table, header = names)



-23.00, 80.00, -18.00, 11.00, -79.00, 11.00, 36.00, 11.00, -7.00, -17.00, -6.00

