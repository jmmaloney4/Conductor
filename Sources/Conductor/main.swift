import Commander

let main = command(Argument<String>("map", description: "File to load the map from.")) { map in
    print("Reading map file \(map)...")
}

main.run()
