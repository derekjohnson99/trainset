// OpenSCAD file to display all possible layouts of Ikea Lillabo 20-piece basic trainset

layout = ["A", "A", "A", "A", "A", "A", "S", "S", "C", "C", "C", "C", "C", "C", "B"];
track_width = 8;
track_length = 64;
track_height = 2;
curves_in_circle = 8;
half_w = track_width / 2;
p_w = track_length + half_w;
curve_angle = 360 / curves_in_circle;

module straight(start_point, angle) {
    translate(start_point)
    rotate([0, 0, angle])
    translate([0, -half_w, 0])
    cube([track_length, track_width, track_height]);
}

module a_curve(start_point, angle) {
    translate(start_point)
    rotate([0, 0, angle])
    translate([0, track_length])
    linear_extrude(track_height) {
        difference() {
            circle(track_length + half_w);
            circle(track_length - half_w);
            polygon([[0, 0], [0, -p_w], [-p_w, -p_w], [-p_w, p_w], [p_w, p_w], [p_w, 0]]);
            polygon([[0, 0], [p_w, 0], [p_w, -p_w]]);
        }
    }
}

module c_curve(start_point, angle) {
    translate(start_point)
    rotate([0, 0, angle])
    translate([0, -track_length])
    linear_extrude(track_height) {
        difference() {
            circle(track_length + half_w);
            circle(track_length - half_w);
            polygon([[0, 0], [0, p_w], [-p_w, p_w], [-p_w, -p_w], [p_w, -p_w], [p_w, 0]]);
            polygon([[0, 0], [p_w, 0], [p_w, p_w]]);
        }
    }
}

module bridge(start_point, angle) {
    translate(start_point)
    rotate([0, 0, angle])
    translate([0, -half_w, 0])
    cube([2*track_length, track_width, track_height]);
}

module joint(start_point, angle) {
    translate(start_point)
    rotate([0, 0, angle])
    translate([-0.2, -half_w, 0])
    cube([0.4, track_width, track_height + 1]);
}

$fa = 1;
$fs = 0.4;

function new_cursor(cursor, piece) = (
    let (
        p_len = piece[0],
        p_angle = piece[1] / 2,
        x = cursor[0] + p_len * cos(cursor[2] + p_angle),
        y = cursor[1] + p_len * sin(cursor[2] + p_angle),
        angle = cursor[2] + 2 * p_angle
    )
    [x, y, angle]
);

piece_details = [ for (i = [0 : len(layout)-1])
    let (
        piece = layout[i],
        length = (piece == "A") ?
            track_length * 2 * sin(curve_angle/2)
        : (piece == "C") ?
            track_length * 2 * sin(curve_angle/2)
        : (piece == "S") ?
            track_length * 1
        : (piece == "B") ?
            track_length * 2
        :
            undef,
        angle =  (piece == "A") ?
            curve_angle
        : (piece == "C") ?
            -curve_angle
        : (piece == "S") ?
            0
        : (piece == "B") ?
            0
        :
            undef
    )
    [length, angle]
];

function place_piece(i) = (
    i == 0 ?
        new_cursor([0, 0, 0], piece_details[i])
    :
        new_cursor(place_piece(i-1), piece_details[i])
);

positions = [
    [0, 0, 0],
    for (i = [0 : len(piece_details)-1])
        place_piece(i)
];

for (a = [0 : len(layout)-1])
{
    start_point = [positions[a][0], positions[a][1], 0];
    angle = positions[a][2];
    piece = layout[a];
    color("green")
    joint(start_point, angle);
    if (piece == "A")
    {
        color("cyan")
        a_curve((start_point), angle);
    }
    else if (piece == "C")
    {
        color("blue")
        c_curve(start_point, angle);
    }
    else if (piece == "S")
    {
        color("yellow")
        straight(start_point, angle);
    }
    else if (piece == "B")
    {
        color("red")
        bridge(start_point, angle);
    }
}
