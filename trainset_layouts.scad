// OpenSCAD file to display all possible layouts of Ikea Lillabo 20-piece basic trainset

layouts = [
    "BAASSAAAACCAAAA",
    "BAAAAAASSCCCCCC",
    "BAAAASSACAAAAAC",
    "BAAAASACSAAAAAC",
    "BAAAAACSSAAAAAC",
    "BAASSAAACAACAAA",
    "BAAAASSCAAAAACA",
    "BAAAASCASAAAACA",
    "BAAAACASSAAAACA",
    "BAAACAASSAAACAA"
];

track_width = 7;
track_length = 56;
track_height = 2;
curves_in_circle = 8;
half_w = track_width / 2;
p_w = track_length + half_w;
curve_angle = 360 / curves_in_circle;
origin = [0, 0, 0];

layout_start = [
    for (i = [0 : 9])
        let (
            angle = i == 1 ? 45 : 36 * i,
            radius = 6 * track_length
        )
        [radius * cos(angle), radius * sin(angle), angle]
];

module straight() {
    translate([0, -half_w, 0])
    cube([track_length, track_width, track_height]);
}

module a_curve() {
    translate([0, track_length])
    linear_extrude(track_height) {
        intersection() {
            polygon([[0, 0], [p_w, -p_w], [0, -p_w]]);
            difference() {
                circle(track_length + half_w);
                circle(track_length - half_w);
            }
        }
    }
}

module c_curve() {
    translate([0, -track_length])
    linear_extrude(track_height) {
        intersection() {
            polygon([[0, 0], [p_w, p_w], [0, p_w]]);
            difference() {
                circle(track_length + half_w);
                circle(track_length - half_w);
            }
        }
    }
}

module bridge() {
    let (
        inner_radius = 12,
        bridge_shape = [
            [0, 0],
            for (i = [0 : 2 * track_length])
            let (
                height_range = 8,
                t_ratio = 360 / (track_length * 2)
            )
            [i, height_range + track_height - cos(i * t_ratio) * height_range],
            [track_length * 2, 0]
        ],
        side_arch_distance = track_length / 2 + 4
    )
    translate([0, half_w, 0])
    rotate([90, 0, 0])
    linear_extrude(track_width) {
        difference() {
            polygon(bridge_shape);
            // Inner arch
            translate([track_length, track_height, 0])
            circle(inner_radius);
            translate([track_length - inner_radius, 0, 0])
            square([inner_radius * 2, track_height]);
            // Side arches
            translate([side_arch_distance, 0, 0])
            circle(8);
            translate([2 * track_length - side_arch_distance, 0, 0])
            circle(8);
        }
    }
}

module joint() {
    translate([-0.2, -half_w - 0.2, 0])
    cube([0.4, track_width + 0.4, track_height]);
}

$fa = 1;
$fs = 0.4;

// Function to return the length and angle of each type of track piece
function piece_details(piece) = (
    let (
        length = piece == "A" ?
            track_length * 2 * sin(curve_angle/2)
        : piece == "C" ?
            track_length * 2 * sin(curve_angle/2)
        : piece == "S" ?
            track_length * 1
        : piece == "B" ?
            track_length * 2
        :
            undef,
        angle = piece == "A" ?
            curve_angle / 2
        : piece == "C" ?
            -curve_angle / 2
        : piece == "S" ?
            0
        : piece == "B" ?
            0
        :
            undef
    )
    [length, angle]
);

// Function to find the new cursor position (x, y and angle) given the
// original cursor postion, and the details of the track piece
function new_cursor(cursor, piece) = (
    let (
        piece_detail = piece_details(piece),
        p_len = piece_detail[0],
        p_angle = piece_detail[1],
        x = cursor[0] + p_len * cos(cursor[2] + p_angle),
        y = cursor[1] + p_len * sin(cursor[2] + p_angle),
        angle = cursor[2] + 2 * p_angle
    )
    [x, y, angle]
);

// Function to give the final cursor position (x, y and angle) of the
// given piece number in the layout
function place_piece(i, start_point, layout) = (
    i == 0 ?
        new_cursor(start_point, layout[i])
    :
        new_cursor(place_piece(i-1, start_point, layout), layout[i])
);

for (l = [0 : len(layouts)-1])
{
    layout = layouts[l];
    for (i = [0 : len(layout)-1])
    {
        positions = [
            layout_start[l],
            for (i = [0 : len(layout)-1])
                place_piece(i, layout_start[l], layout)
        ];
        pos = positions[i];
        start_point = [pos[0], pos[1], 0];
        angle = pos[2];
        col = i % 2 == 0 ? "navy" : "yellow";
        translate(start_point)
        rotate([0, 0, angle])
        {
            color("black")
            joint();

            piece = layout[i];
            if (piece == "A")
            {
                color(col)
                a_curve();
            }
            else if (piece == "C")
            {
                color(col)
                c_curve();
            }
            else if (piece == "S")
            {
                color(col)
                straight();
            }
            else if (piece == "B")
            {
                color("red")
                bridge();
            }
        }
    }
}
