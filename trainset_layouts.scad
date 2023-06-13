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

echo("new_cursor test: ", new_cursor([0,0,0], [0.77, 22.5]));

track_r_thetas = [ for (i = [0 : len(layout)-1])
    let (
        item = layout[i],
        length = (item == "A") ?
            track_length * 2 * sin(curve_angle/2)
        : (item == "C") ?
            track_length * 2 * sin(curve_angle/2)
        : (item == "S") ?
            track_length * 1
        : (item == "B") ?
            track_length * 2
        :
            undef,
        angle =  (item == "A") ?
            curve_angle
        : (item == "C") ?
            -curve_angle
        : (item == "S") ?
            0
        : (item == "B") ?
            0
        :
            undef
    )
    [length, angle]
];
echo("track_r_thetas: ", track_r_thetas);

function place_piece(i) = (
    i == 0 ?
        new_cursor([0, 0, 0], track_r_thetas[i])
    :
        new_cursor(place_piece(i-1), track_r_thetas[i])
);

positions = [
    [0, 0, 0], 
    for (i = [0 : len(track_r_thetas)-1])
        place_piece(i)
];
echo("positions: ", positions);

for (a = [0 : len(layout)-1])
{
    start_point = [positions[a][0], positions[a][1], 0];
    angle = positions[a][2];
    item = layout[a];
    color("green")
    joint(start_point, angle);
    if (item == "A")
    {
        color("cyan")
        a_curve((start_point), angle);
    }
    else if (item == "C")
    {
        color("blue")
        c_curve(start_point, angle);
    }
    else if (item == "S")
    {
        color("yellow")
        straight(start_point, angle);
    }
    else if (item == "B")
    {
        color("red")
        bridge(start_point, angle);
    }
}
