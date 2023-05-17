// OpenSCAD file to display all possible layouts of Ikea Lillabo 20-piece basic trainset

track_width = 10;
track_length = 100;
track_height = 2.5;
curves_in_circle = 8;
half_w = track_width / 2;


module straight() {
    cube([track_length, track_width, track_height]);
}

module curve() {
    linear_extrude(track_height) {
        difference() {
            circle(track_length + half_w);
            circle(track_length - half_w);
        }
    }
}

module bridge() {
}

curve();
straight();
//translate([track_length, 0, 0])
//straight();