import Commander
import Foundation

let main = command(Argument<String>("map", description: "File to load the map from.")) { map in
    print("Reading map file \(map)...")

    guard let inputFile = InputStream(fileAtPath: map) else {
        throw ConductorError.fileInputError(path: map)
    }
    try LoadMapJSON(stream: inputFile)
}

main.run()
