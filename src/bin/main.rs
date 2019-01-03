extern crate colored;
#[macro_use]
extern crate serde_derive;
extern crate serde;
extern crate serde_json;

use colored::*;
use serde_json::Error;

use std::fs::File;
use std::io::prelude::*;
use std::path::{Path, PathBuf};
use std::marker::PhantomData;

#[derive(Debug)]
pub struct City<'a> {
    pub name: String,
    pub route_count: u32,
    lifetime: PhantomData<&'a ()>,
}

impl<'a> City<'a> {
    fn new(name: &str) -> City {
        City {
            name: name.to_owned(),
            route_count: 0,
            lifetime: PhantomData::new<'a: T>();
        }
    }
}

#[derive(Debug)]
pub struct Route<'a> {
    pub ends: Vec<&'a City<'a>>,
    pub ferries: u32,
    pub tunnel: bool,
}

#[derive(Debug)]
pub struct Map<'a> {
    pub routes: Vec<Route<'a>>,
    pub cities: Vec<City<'a>>,
}

#[derive(Serialize, Deserialize, Debug)]
struct MapDefJson {
    endpoints: [String; 2],
    color: String,
    length: u32,
    tunnel: bool,
    ferries: u32,
}

impl<'a> Map<'a> {
    fn load<P: AsRef<Path>>(file: P) -> Map<'a>
    {
        let mut buffer = String::new();
        let mut f = File::open(file.as_ref()).expect("file not found");
        f.read_to_string(&mut buffer)
            .expect("something went wrong reading the file");

        let json: Vec<MapDefJson> =
            serde_json::from_str(buffer.as_ref()).expect("Error loading JSON");

        println!("{:?}", json);

        let mut map = Map {
            routes: vec![],
            cities: vec![],
        };
        for entry in json {
            // Check that cities exist
            let mut cities = Vec::new();
            for n in 0..1 {
                match map.cities.iter().find(|x| x.name == entry.endpoints[n]) {
                    Some(city) => cities.push(city),
                    None => {
                        map.cities.push(City::new(entry.endpoints[n].as_ref()));
                        cities.push(&map.cities[map.cities.len()]);
                    }
                }
            }

            map.routes.push(Route {
                ends: [cities[0], cities[1]],
                ferries: entry.ferries,
                tunnel: entry.tunnel,
            });
        }

        return map
    }
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
    /*
    let london = City { name: String::from("London") };
    let amsterdam = City { name: String::from("Amsterdam") };

    let route = Route { ends: [&london, &amsterdam], ferries: 1, tunnel: true };

    println!("{} -> {}", route.ends[0].name.blue(), route.ends[1].name);

    do_json().unwrap();
    */

    let map = Map::load("./europe.json");
}
