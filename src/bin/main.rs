mod conductor;

fn main() {
    println!("Hello, world!");

    let london = conductor::City { name: String::from("London") };
    let amsterdam = conductor::City { name: String::from("Amsterdam") };

    let route = conductor::Route { ends: [&london, &amsterdam] };
}
