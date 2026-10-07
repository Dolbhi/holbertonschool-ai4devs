struct World {
    places: Vec<(f32, f32)>,
    people: Vec<f32>,
    trees: Vec<i32>,
}

impl World {
    fn give_home(&mut self) {
        for i in 0..self.people.len() {
            if self.people[i] > 0. {
                self.add_home((1., 0.));
            } else {
                self.add_home((0., 1.));
            }
        }
    }

    fn add_home(&mut self, home: (f32, f32)) {
        self.places.push(home);
    }
}