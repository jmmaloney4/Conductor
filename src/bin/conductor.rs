    
    pub struct City {
        pub name: String,
    }

    pub struct Route<'a> {
        pub ends: [&'a City; 2]
    }

fn main() {
    println!("Hello, world!");

    let london = City { name: String::from("London") };
    let amsterdam = City { name: String::from("Amsterdam") };

    let route = Route { ends: [&london, &amsterdam] };

    println!("{} -> {}", route.ends[0].name, route.ends[1].name)
}
