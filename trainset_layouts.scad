// OpenSCAD file to display all possible layouts of Ikea Lillabo 20-piece basic trainset

track_width = 8;
track_length = 64;
track_height = 2;
curves_in_circle = 8;
half_w = track_width / 2;
p_w = track_length + half_w;

module straight(start_point=([0,0]), angle=0) {
    translate(start_point)
    rotate([0, 0, angle])
    translate([0, -half_w, 0])
    cube([track_length, track_width, track_height]);
}

module curve(start_point=([0,0]), angle=0) {
    translate(start_point)
    rotate([0, 0, angle])
    translate([0, track_length])
    linear_extrude(track_height) {
        difference() {
            circle(track_length + half_w);
            circle(track_length - half_w);
            polygon([[0, 0], [0, -p_w], [-p_w, -p_w], [-p_w, p_w], [p_w, p_w], [p_w, 0]]);
            polygon([[0, 0], [2*p_w, 0], [2*p_w, -2*p_w]]);
        }
    }
}

module bridge() {
}

straight();
curve([track_length, 0]);
//straight([20,20], 30);
//curve([-50, -50], -60);
