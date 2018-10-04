extern crate colored;
#[macro_use] extern crate serde_derive;
extern crate serde_json;
extern crate serde;

use colored::*;
use serde_json::Error;

#[derive(Serialize, Deserialize, Debug)]
pub struct City {
    pub name: String,
}

// #[derive(Serialize, Deserialize, Debug)]
pub struct Route<'a> {
    pub ends: [&'a City; 2],
    pub ferries: i32,
    pub tunnel: bool,
}

fn do_json() -> Result<(), Error> {
    let input: &str = r#"
                        {
                            "name": "Frankfurt"
                        }
                    "#;
    
    let city: City = serde_json::from_str(input)?;
    println!("{}", city.name);
    
    Ok(())
}

fn main() {
    println!("Hello, world!");

    let london = City { name: String::from("London") };
    let amsterdam = City { name: String::from("Amsterdam") };

    let route = Route { ends: [&london, &amsterdam], ferries: 1, tunnel: true };

    println!("{} -> {}", route.ends[0].name.blue(), route.ends[1].name);

    do_json();
}
