function update_debts(names::Matrix{String}, profits::Matrix{Float64})
    CSV.write("data/debts",names |> Tables.table, header = names)
end


function update_plot()
    names = CSV.File("data/current_debts").names .|> string
    profits = CSV.File("data/current_debts") |> Tables.matrix |> vec
    plot(names[profits .>= 0], profits[profits .>= 0]; seriestype=:bar, color = :green, label = false)
    plot!(names[profits .< 0], profits[profits .< 0]; seriestype=:bar, color = :red, label = false)
    plt = plot!(size = (1000,400))
    savefig(plt,"plots/current_debts.pdf")
    return plt
end




function add_latest_game()

    # Get data from google sheets
    url = "https://docs.google.com/spreadsheets/d/1EcKmJZ3xaPIjMmq-O8zaJPhoTqPUbAnKDMP13IecAY4/edit#gid=205549855"
    table = GoogleSheetsCSVExporter.fromURI(url) |> CSV.File |> Tables.matrix
    current_players = table[:,1] .!= "New Player"

    # Get profit
    profits = CSV.File("data/debts") |> Tables.matrix 
    names = table[current_players,1]
    new_profits = table[current_players,2:2]' |> Matrix{Float64}

    # Add previous profits
    updated_profits = zeros(size(profits)[1] + 1, length(names))
    updated_profits[1:size(profits)[1], 1:size(profits)[2]] .= profits

    # Add current profit
    updated_profits[end, :] = new_profits
    CSV.write("data/debts",updated_profits |> Tables.table, header = names)

    # Update current debt totals 
    current_debts = CSV.File("data/current_debts") |> Tables.matrix 
    updated_current_debts = zeros(1, length(names))
    updated_current_debts[:, 1:length(current_debts)] .= current_debts
    updated_current_debts += new_profits
    CSV.write("data/current_debts",updated_current_debts |> Tables.table, header = names)

    # History
    history = CSV.File("data/history") |> Tables.matrix 

    # Add previous profits
    updated_history = Matrix{Any}(undef, size(history)[1] + 1, length(names) + 1)
    updated_history[:,2:end] .= 0
    updated_history[1:size(history)[1],1:size(history)[2]] .= history
    updated_history[end,1:end] = hcat(today(), new_profits)
    CSV.write("data/history",updated_history |> Tables.table, header = vcat("Date", names))

end



function history_plot()
    scores = Tables.matrix(CSV.File("data/history"))[:,2:end]
    main_players = [1,2,3,5,6]
    main_scores = cumsum(scores[:,main_players], dims = 1) |> Matrix{Float64}
    plot(main_scores, labels = ["Antonio" "Michael" "Nathan" "George" "Lachlan"], legend = :topleft, linewidth = 3)
    plot!(size = (1000, 500))
    plt = plot!(legendfontsize=14, tickfontsize = 12, guidefont = 15)
    savefig(plt, "plots/history_plot.pdf")
    return plt
end


function settle_debts()
    # Read in data
    current_debts = CSV.File("data/current_debts") |> Tables.matrix
    names = CSV.File("data/current_debts").names .|> string
    range = collect(1:length(names))'[:,:]



    # Fix debts
    over_flow = -sum(current_debts)
    current_debts[sample(range)] += over_flow


    # Get winners and losers
    winners =range[current_debts .> 0]
    losers = range[current_debts .< 0]

    for w ∈ winners
        while current_debts[w] != 0
            payment =  min(current_debts[w],-current_debts[losers[1]])
            current_debts[w] -= payment
            current_debts[losers[1]] += payment
            println(
                string(names[losers[1]]) *
                " pays " *
                string(names[w]) *
                " \$" *
                string(round(payment, digits = 2))
            )
            losers = range[current_debts .< 0]
        end
    end
end




function clear_debts()
    # Read in data
    current_debts = CSV.File("data/current_debts") |> Tables.matrix
    names = CSV.File("data/current_debts").names .|> string
    current_debts = zeros(1, length(names))
    CSV.write("data/debts",current_debts |> Tables.table, header = names)
    CSV.write("data/current_debts",current_debts |> Tables.table, header = names)
end

