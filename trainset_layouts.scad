// OpenSCAD file to display all possible layouts of Ikea Lillabo 20-piece basic trainset

track_width = 10;
track_length = 100;

module straight() {
    cube([track_length, track_width, 2.5]);
}

module curve() {
}

module bridge() {
}

straight();
translate([track_length, 0, 0])
straight();