// OpenSCAD file to display all possible layouts of Ikea Lillabo 20-piece basic trainset

track_width = 10;
track_length = 100;
track_height = 2.5;
curves_in_circle = 8;
half_w = track_width / 2;
p_w = track_length + half_w;

module straight(start_point=([0,0]), angle=0) {
    translate(start_point)
    translate([0, -half_w, 0])
    cube([track_length, track_width, track_height]);
}

module curve() {
    linear_extrude(track_height) {
        difference() {
            circle(track_length + half_w);
            circle(track_length - half_w);
            polygon([[0,0], [p_w, p_w], [-p_w, p_w], [-p_w, -p_w], [p_w, -p_w], [p_w, 0]]);
        }
    }
}

module bridge() {
}

curve();
straight();
straight([20,20]);