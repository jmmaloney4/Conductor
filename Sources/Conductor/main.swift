import Commander
import Foundation

let main = command(Argument<String>("mapfile", description: "File to load the map from.")) { mapfile in
    print("Reading map file \(mapfile)...")

    guard let inputFile = InputStream(fileAtPath: mapfile) else {
        throw ConductorError.fileInputError(path: mapfile)
    }
    let map = try Map(fromJSONStream: inputFile)
}

main.run()
