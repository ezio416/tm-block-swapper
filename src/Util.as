// c 2024-03-19
// m 2024-03-19

const string IntToHex(const int i) {
    return "0x" + Text::Format("%X", i);
}

const int3 Nat3ToInt3(const nat3 coord) {
    return int3(coord.x, coord.y, coord.z);
}